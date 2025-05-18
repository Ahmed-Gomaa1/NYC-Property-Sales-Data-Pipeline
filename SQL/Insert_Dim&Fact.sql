WITH DateSeries AS (
    SELECT CAST('2010-01-01' AS DATE) AS full_date
    UNION ALL
    SELECT DATEADD(DAY, 1, full_date)
    FROM DateSeries
    WHERE full_date < '2023-12-31'
)
INSERT INTO dm.dim_date (date_key, full_date, year, month, day, quarter)
SELECT 
    CONVERT(INT, FORMAT(full_date, 'yyyyMMdd')),
    full_date,
    YEAR(full_date),
    MONTH(full_date),
    DAY(full_date),
    DATEPART(QUARTER, full_date)
FROM DateSeries
OPTION (MAXRECURSION 32767);
-------------------------------------------------------------------------
INSERT INTO dm.dim_location (borough, zip_code)
SELECT DISTINCT borough, zip_code
FROM cleansed.property_sales_clean
WHERE
    borough IS NOT NULL AND
    zip_code IS NOT NULL;
------------------------------------------------------------------------
WITH RankedProperties AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY address, block, lot
            ORDER BY sale_date DESC  -- Keep the latest sold version of the property
        ) AS rn
    FROM cleansed.property_sales_clean
    WHERE
        address IS NOT NULL AND
        building_class_category IS NOT NULL AND
        building_class_at_time_of_sale IS NOT NULL AND
        tax_class_at_time_of_sale IS NOT NULL AND
        block IS NOT NULL AND
        lot IS NOT NULL AND
        year_built IS NOT NULL AND
        residential_units IS NOT NULL AND
        commercial_units IS NOT NULL AND
        total_units IS NOT NULL AND
        land_square_feet IS NOT NULL AND
        gross_square_feet IS NOT NULL
)
INSERT INTO dm.dim_property (
    address, building_class_category, building_class_at_time_of_sale, tax_class_at_time_of_sale,
    block, lot, year_built, residential_units, commercial_units,
    total_units, land_square_feet, gross_square_feet
)
SELECT
    address, building_class_category, building_class_at_time_of_sale, tax_class_at_time_of_sale,
    block, lot, year_built, residential_units, commercial_units,
    total_units, land_square_feet, gross_square_feet
FROM RankedProperties
WHERE rn = 1;

CREATE UNIQUE INDEX UX_dim_property_address_block_lot
ON dm.dim_property (address, block, lot);;


------------------------------------------------------------------------------
INSERT INTO dm.fact_property_sales (sale_price, sale_date_key, property_id, location_id)
SELECT
    c.sale_price,
    d.date_key,
    p.property_id,
    l.location_id
FROM cleansed.property_sales_clean c
JOIN dm.dim_date d ON d.full_date = c.sale_date
JOIN dm.dim_property p ON 
    p.address = c.address AND
    p.block = c.block AND
    p.lot = c.lot
JOIN dm.dim_location l ON 
    l.borough = c.borough AND
    l.zip_code = c.zip_code

-- Check duplicates in dim_property (on join keys)
SELECT address, block, lot, COUNT(*)
FROM dm.dim_property
GROUP BY address, block, lot
HAVING COUNT(*) > 1;

-- Check duplicates in dim_location (on join keys)
SELECT borough, zip_code, COUNT(*)
FROM dm.dim_location
GROUP BY borough, zip_code
HAVING COUNT(*) > 1;

-- Check duplicates in dim_date (on join key)
SELECT date_key, full_date, COUNT(*)
FROM dm.dim_date
GROUP BY date_key, full_date
HAVING COUNT(*) > 1;


