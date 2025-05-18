WITH filtered_sales AS (
    SELECT *
    FROM staging.property_sales_raw
    WHERE sale_price IS NOT NULL AND sale_price > 0
),
cleaned_address AS (
    SELECT *,
        UPPER(LTRIM(RTRIM(address))) AS clean_address,
        UPPER(LTRIM(RTRIM(apartment_number))) AS clean_apartment_number
    FROM filtered_sales
),
cleaned_building_class AS (
    SELECT *,
        UPPER(building_class_at_present) AS clean_building_class_at_present,
        UPPER(building_class_at_time_of_sale) AS clean_building_class_at_time_of_sale
    FROM cleaned_address
),
valid_dates AS (
    SELECT *
    FROM cleaned_building_class
    WHERE sale_date BETWEEN '2010-01-01' AND '2023-12-31'
)

INSERT INTO cleansed.property_sales_clean (
    borough, neighborhood, building_class_category,
    tax_class_at_present, block, lot,
    building_class_at_present, address, apartment_number,
    zip_code, residential_units, commercial_units,
    total_units, land_square_feet, gross_square_feet,
    year_built, tax_class_at_time_of_sale,
    building_class_at_time_of_sale, sale_price, sale_date
)
SELECT
    borough, neighborhood, building_class_category,
    tax_class_at_present, block, lot,
    clean_building_class_at_present, clean_address, clean_apartment_number,
    zip_code, residential_units, commercial_units,
    total_units, land_square_feet, gross_square_feet,
    year_built, tax_class_at_time_of_sale,
    clean_building_class_at_time_of_sale, sale_price, sale_date
FROM valid_dates;
