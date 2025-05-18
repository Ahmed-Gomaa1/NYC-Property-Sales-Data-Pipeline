# NYC Property Sales Data Processing Project

## Project Overview
This project processes and analyzes New York City property sales data from 2010 to 2023 across four boroughs: Manhattan, Brooklyn, Queens, and the Bronx. The project pipeline downloads raw property sales data from NYC Department of Finance, performs data cleaning and standardization, and loads it into a SQL Server database for analysis.

## Data Source
- **Source:** NYC Department of Finance
- **URL Format:** `https://www.nyc.gov/assets/finance/downloads/pdf/rolling_sales/annualized-sales/{year}/{year}_{borough}.xls`
- **Time Period:** 2010-2023
- **Boroughs:** Manhattan, Brooklyn, Queens, Bronx
- **File Format:** Excel (.xls/.xlsx)

## Project Structure
```
project/
├── Download_Data.py            # Script to download raw sales data files
├── Ingest_Files_inStaging_DataBase.py  # Script to process files and load to database
├── create_staging.sql          # SQL script to create database schema and tables
├── SQL Quaries.sql             # SQL queries for data validation and exploration
├── Logs/
│   └── processing_log.txt      # Processing log with detailed execution information
└── Data/                       # Directory containing downloaded data files
    └── {year}_{borough}.xls    # Raw data files
```

## Database Schema
The project uses a SQL Server database with a staging schema that contains the property_sales_raw table.

### Table: staging.property_sales_raw

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| borough | NVARCHAR(100) | Borough name (Manhattan, Brooklyn, Queens, Bronx) |
| neighborhood | NVARCHAR(255) | Neighborhood within the borough |
| building_class_category | NVARCHAR(255) | Building classification category |
| tax_class_at_present | NVARCHAR(50) | Current tax class |
| block | INT | Tax block number |
| lot | INT | Tax lot number |
| ease_ment | NVARCHAR(100) | Easement information (noted as inconsistent column) |
| building_class_at_present | NVARCHAR(50) | Current building class code |
| address | NVARCHAR(255) | Property street address |
| apartment_number | NVARCHAR(50) | Apartment number if applicable |
| zip_code | INT | Property ZIP code |
| residential_units | INT | Number of residential units |
| commercial_units | INT | Number of commercial units |
| total_units | INT | Total number of units |
| land_square_feet | FLOAT | Land area in square feet |
| gross_square_feet | FLOAT | Gross building area in square feet |
| year_built | INT | Year the structure was built |
| tax_class_at_time_of_sale | NVARCHAR(50) | Tax class at time of sale |
| building_class_at_time_of_sale | NVARCHAR(50) | Building class code at time of sale |
| sale_price | BIGINT | Sale price in USD |
| sale_date | DATE | Date of sale |
| file_source | NVARCHAR(100) | Source file information |

## Pipeline Workflow

### 1. Data Download (Download_Data.py)
- Iterates through years (2010-2023) and boroughs (Manhattan, Brooklyn, Queens, Bronx)
- Downloads Excel files from NYC Department of Finance website
- Handles redirects from Office Online viewer URLs
- Saves files to local directory

### 2. Database Setup (create_staging.sql)
- Creates staging schema
- Creates property_sales_raw table with appropriate column definitions

### 3. Data Processing & Loading (Ingest_Files_inStaging_DataBase.py)
- **Configuration**
  - Defines target database connection details
  - Sets up logging
  - Configures SQL data types for each column

- **Processing Steps**
  - Reads Excel files with appropriate engine based on file format (.xls vs .xlsx)
  - Handles varying header row positions across different years (using skiprows parameter)
  - Cleans and standardizes column names
  - Converts data types appropriately
  - Handles null values and data format issues
  - Adds borough information if missing
  - Ensures consistency with expected schema
  - Loads data to SQL Server database

- **Data Cleaning Operations**
  - Standardizes column names (lowercase, spaces to underscores)
  - Removes duplicate columns
  - Replaces empty strings with NULL
  - Cleans and converts numeric values
  - Properly formats dates
  - Handles missing columns
  - Standardizes borough names

### 4. Data Validation (SQL Quaries.sql)
- Counts total rows
- Checks for null values across all columns
- Identifies completely empty rows
- Provides basic data exploration capabilities

## Processing Results
Based on the processing_log.txt:
- **Files Processed:** 52
- **Files with Errors:** 0
- **Total Records Loaded:** 996,853
- **Missing Years:** 2018 (for all boroughs)
- **Common Issue:** "ease-ment" column inconsistently present across files

## Data Distribution by Borough
- **Bronx:** 84,504 records (8.5%)
- **Brooklyn:** 310,373 records (31.1%)
- **Manhattan:** 255,180 records (25.6%)
- **Queens:** 346,796 records (34.8%)

## Data Distribution by Year
The data shows yearly property sales records ranging from approximately 62,000 to 99,000 records per year, with notable dip in transactions during 2020 (likely due to COVID-19 pandemic) and missing data for 2018.

## Known Issues and Limitations
1. 2018 data is missing for all boroughs
2. Inconsistent column naming across years (particularly 'ease-ment')
3. File formats vary (.xls for older years, .xlsx for newer years)
4. Header row positions vary by year requiring different skiprows values
5. Some sales records may have zero or null prices which require further cleaning for analysis

## Next Steps
1. Create a data warehouse schema with dimension and fact tables
2. Implement data quality checks and constraints
3. Create analysis views for common queries
4. Develop analytics dashboards
5. Implement regular data refresh processes

## Dependencies
- Python 3.x
- pandas
- sqlalchemy
- pyodbc
- requests
- numpy
- Microsoft SQL Server
- ODBC Driver 17 for SQL Server

## Execution Instructions
1. Run `create_staging.sql` to set up the database schema
2. Run `Download_Data.py` to download all raw data files
3. Run `Ingest_Files_inStaging_DataBase.py` to process and load data
4. Use queries in `SQL Quaries.sql` to validate and explore the data