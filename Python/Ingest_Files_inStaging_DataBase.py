import pandas as pd
import os
from sqlalchemy import create_engine, types
import sys
import numpy as np
import warnings
from datetime import datetime
import traceback

sys.stdout.reconfigure(encoding='utf-8')
warnings.filterwarnings("ignore", category=UserWarning, module='openpyxl')

# 📁 Step 1: Config
folder_path = r'C:\Users\3hmed\OneDrive\Desktop\Data Projects\real_estate_transactions_cleansing_modeling\Data'
dry_run = False  # ✅ Set to False to enable DB loading

server = 'localhost'
database = 'RealEstateDB'
table_name = 'property_sales_raw'
schema_name = 'staging'

log_file = "Logs\processing_log.txt"
with open(log_file, 'w', encoding='utf-8') as log:
    log.write(f"📘 Log started at {datetime.now()}\n")

# 🛠️ Step 2: Create SQLAlchemy engine
connection_string = (
    f"mssql+pyodbc://{server}/{database}"
    "?driver=ODBC+Driver+17+for+SQL+Server"
    "&Trusted_Connection=yes"
)
engine = create_engine(connection_string)

# SQL column types
sql_data_types = {
    'borough': types.NVARCHAR(length=100),
    'neighborhood': types.NVARCHAR(length=255),
    'building_class_category': types.NVARCHAR(length=255),
    'tax_class_at_present': types.NVARCHAR(length=50),
    'block': types.INTEGER(),
    'lot': types.INTEGER(),
    'building_class_at_present': types.NVARCHAR(length=50),
    'address': types.NVARCHAR(length=255),
    'apartment_number': types.NVARCHAR(length=50),
    'zip_code': types.INTEGER(),
    'residential_units': types.INTEGER(),
    'commercial_units': types.INTEGER(),
    'total_units': types.INTEGER(),
    'land_square_feet': types.FLOAT(),
    'gross_square_feet': types.FLOAT(),
    'year_built': types.INTEGER(),
    'tax_class_at_time_of_sale': types.NVARCHAR(length=50),
    'building_class_at_time_of_sale': types.NVARCHAR(length=50),
    'sale_price': types.BIGINT(),
    'sale_date': types.DATE()
}

boroughs = ['bronx', 'brooklyn', 'manhattan', 'queens']
years = range(2010, 2024)

def log_msg(message):
    print(message)
    with open(log_file, 'a', encoding='utf-8') as log:
        log.write(f"{message}\n")

def clean_and_standardize_dataframe(df, borough):
    df.columns = [col.strip().lower().replace(' ', '_') for col in df.columns]
    df.columns = [col.replace('__', '_') for col in df.columns]

    if any(df.columns.duplicated()):
        log_msg(f"⚠️ Found duplicate columns: {df.columns[df.columns.duplicated()]}")
        df = df.loc[:, ~df.columns.duplicated()]

    df.replace(r'^\s*$', np.nan, regex=True, inplace=True)
    df.dropna(how='all', inplace=True)

    if 'borough' not in df.columns:
        df['borough'] = borough.title()

    numeric_cols = ['block', 'lot', 'zip_code', 'residential_units', 'commercial_units', 'total_units', 'year_built', 'sale_price']
    for col in numeric_cols:
        if col in df.columns and df[col].dtype == object:
            if col == 'sale_price':
                df[col] = df[col].astype(str).str.replace(r'[$,]', '', regex=True)
            df[col] = pd.to_numeric(df[col], errors='coerce')

    if 'sale_date' in df.columns:
        df['sale_date'] = pd.to_datetime(df['sale_date'], errors='coerce')

    for col in df.select_dtypes(include='object').columns:
        df[col] = df[col].str.strip()

    df.replace(r'^\s*$', np.nan, regex=True, inplace=True)

    for col in df.columns:
        col_type = str(df[col].dtype)
        if 'int' in col_type:
            if col in numeric_cols:
                df[col] = df[col].fillna(0).astype('Int64')
        elif col == 'sale_price':
            df[col] = df[col].fillna(0).astype('Int64')

    expected_columns = list(sql_data_types.keys())

    # Handle missing columns
    missing_cols = [col for col in expected_columns if col not in df.columns]
    for col in missing_cols:
        df[col] = np.nan
        log_msg(f"⚠️ Added missing column: {col}")

    # Drop unexpected columns
    unexpected_cols = [col for col in df.columns if col not in expected_columns]
    if unexpected_cols:
        log_msg(f"⚠️ Dropping unexpected columns: {unexpected_cols}")
    df = df[[col for col in df.columns if col in expected_columns]]

    df = df[expected_columns]
    return df

# Processing
files_processed = 0
files_with_errors = 0
total_records_loaded = 0

for borough in boroughs:
    for year in years:
        filename_xlsx = f"{year}_{borough}.xlsx"
        filename_xls = f"{year}_{borough}.xls"

        file_path_xlsx = os.path.join(folder_path, filename_xlsx)
        file_path_xls = os.path.join(folder_path, filename_xls)

        if os.path.exists(file_path_xlsx):
            file_path = file_path_xlsx
            engine_arg = 'openpyxl'
        elif os.path.exists(file_path_xls):
            file_path = file_path_xls
            engine_arg = 'xlrd'
        else:
            log_msg(f"⚠️ File not found for {year} {borough}: Skipping")
            continue

        try:
            log_msg(f"\n{'='*50}")
            log_msg(f"📂 Processing {file_path}...")

            # Determine skiprows based on year
            if year < 2011:
                skip_rows = 3
            elif year < 2020:
                skip_rows = 4
            else:
                skip_rows = 6

            try:
                df = pd.read_excel(file_path, skiprows=skip_rows, engine=engine_arg)

                if df.iloc[0].apply(lambda x: isinstance(x, str)).sum() > len(df.columns) / 2:
                    df = pd.read_excel(file_path, skiprows=skip_rows + 1, engine=engine_arg)

            except Exception as read_err:
                log_msg(f"⚠️ Primary read failed with skiprows={skip_rows}: {read_err}")
                df = pd.read_excel(file_path, skiprows=skip_rows + 2, engine=engine_arg)
                log_msg(f"✅ Retried with skiprows={skip_rows + 2}")

            df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
            df = clean_and_standardize_dataframe(df, borough)

            if df.empty:
                log_msg(f"❌ No data in {file_path} after cleaning and validation.")
                files_with_errors += 1
                continue

            if not dry_run:
                try:
                    df.to_sql(
                        name=table_name,
                        con=engine,
                        schema=schema_name,
                        if_exists='append',
                        index=False,
                        dtype=sql_data_types
                    )
                except Exception as db_error:
                    log_msg(f"❌ Error loading to SQL: {db_error}")
                    log_msg(traceback.format_exc())
                    files_with_errors += 1
                    continue

                total_records_loaded += len(df)

            files_processed += 1
            log_msg(f"✅ {len(df)} rows {'prepared' if dry_run else 'loaded'} from {year}_{borough}")

        except Exception as e:
            log_msg(f"❌ Error processing {file_path}: {e}")
            log_msg(traceback.format_exc())
            files_with_errors += 1

# Summary
log_msg(f"\n{'='*50}")
log_msg("🏁 Import Complete!" if not dry_run else "🧪 Dry Run Complete!")
log_msg("📊 Summary:")
log_msg(f"   - Files processed: {files_processed}")
log_msg(f"   - Files with errors: {files_with_errors}")
log_msg(f"   - Total records {'loaded' if not dry_run else 'cleaned'}: {total_records_loaded}")
log_msg(f"{'='*50}")
log_msg(f"📘 Log file: {log_file}")