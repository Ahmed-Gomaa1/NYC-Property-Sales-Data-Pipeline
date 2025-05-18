select count(*)
from staging.property_sales_raw

delete from staging.property_sales_raw

select * from staging.property_sales_raw

SELECT 
  COUNT(*) AS total_rows,
  COUNT(CASE WHEN borough IS NULL THEN 1 END) AS borough_nulls,
  COUNT(CASE WHEN neighborhood IS NULL THEN 1 END) AS neighborhood_nulls,
  COUNT(CASE WHEN building_class_category IS NULL THEN 1 END) AS building_class_category_nulls,
  COUNT(CASE WHEN tax_class_at_present IS NULL THEN 1 END) AS tax_class_at_present_nulls,
  COUNT(CASE WHEN block IS NULL THEN 1 END) AS block_nulls,
  COUNT(CASE WHEN lot IS NULL THEN 1 END) AS lot_nulls,
  COUNT(CASE WHEN building_class_at_present IS NULL THEN 1 END) AS building_class_at_present_nulls,
  COUNT(CASE WHEN address IS NULL THEN 1 END) AS address_nulls,
  COUNT(CASE WHEN apartment_number IS NULL THEN 1 END) AS apartment_number_nulls,
  COUNT(CASE WHEN zip_code IS NULL THEN 1 END) AS zip_code_nulls,
  COUNT(CASE WHEN residential_units IS NULL THEN 1 END) AS residential_units_nulls,
  COUNT(CASE WHEN commercial_units IS NULL THEN 1 END) AS commercial_units_nulls,
  COUNT(CASE WHEN total_units IS NULL THEN 1 END) AS total_units_nulls,
  COUNT(CASE WHEN land_square_feet IS NULL THEN 1 END) AS land_square_feet_nulls,
  COUNT(CASE WHEN gross_square_feet IS NULL THEN 1 END) AS gross_square_feet_nulls,
  COUNT(CASE WHEN year_built IS NULL THEN 1 END) AS year_built_nulls,
  COUNT(CASE WHEN tax_class_at_time_of_sale IS NULL THEN 1 END) AS tax_class_at_time_of_sale_nulls,
  COUNT(CASE WHEN building_class_at_time_of_sale IS NULL THEN 1 END) AS building_class_at_time_of_sale_nulls,
  COUNT(CASE WHEN sale_price IS NULL THEN 1 END) AS sale_price_nulls,
  COUNT(CASE WHEN sale_date IS NULL THEN 1 END) AS sale_date_nulls
FROM cleansed.property_sales_clean;


SELECT COUNT(*) AS null_rows
FROM staging.property_sales_raw
WHERE borough IS NULL
  AND neighborhood IS NULL
  AND building_class_category IS NULL
  AND tax_class_at_present IS NULL
  AND block IS NULL
  AND lot IS NULL
  AND building_class_at_present IS NULL
  AND address IS NULL
  AND apartment_number IS NULL
  AND zip_code IS NULL
  AND residential_units IS NULL
  AND commercial_units IS NULL
  AND total_units IS NULL
  AND land_square_feet IS NULL
  AND gross_square_feet IS NULL
  AND year_built IS NULL
  AND tax_class_at_time_of_sale IS NULL
  AND building_class_at_time_of_sale IS NULL
  AND sale_price IS NULL
  AND sale_date IS NULL;

select count(*) from cleansed.property_sales_clean 
select count(*) from staging.property_sales_raw


SELECT count(*)
    FROM staging.property_sales_raw
    WHERE sale_price IS NOT NULL AND sale_price > 0

SELECT COUNT(*)
FROM staging.property_sales_raw
WHERE sale_date BETWEEN '1900-01-01' AND '2023-12-31';

delete from cleansed.property_sales_clean

SELECT count(*)
    FROM staging.property_sales_raw
    WHERE
        sale_price IS NOT NULL AND sale_price > 0
        AND sale_date BETWEEN '2010-01-01' AND '2023-12-31'

SELECT count(*)
FROM cleansed.property_sales_clean
WHERE 
    borough IS NOT NULL
    AND neighborhood IS NOT NULL
    AND building_class_category IS NOT NULL
    -- tax_class_at_present IS NULL → allowed
    AND block IS NOT NULL
    AND lot IS NOT NULL
    AND building_class_at_present IS NOT NULL
    AND address IS NOT NULL
    -- apartment_number IS NULL → allowed
    AND zip_code IS NOT NULL
    AND residential_units IS NOT NULL
    AND commercial_units IS NOT NULL
    AND total_units IS NOT NULL
    AND land_square_feet IS NOT NULL
    AND gross_square_feet IS NOT NULL
    AND year_built IS NOT NULL
    AND tax_class_at_time_of_sale IS NOT NULL
    AND building_class_at_time_of_sale IS NOT NULL
    AND sale_price IS NOT NULL
    AND sale_date IS NOT NULL;
SELECT address, block, lot, COUNT(*) 
FROM dm.dim_property
GROUP BY address, block, lot
HAVING COUNT(*) > 1;

SELECT address, block, lot, COUNT(*) as cnt
FROM dm.dim_property
WHERE address IN ('365 BRIDGE STREET', '2800 COYLE STREET, 510', '88-40 87TH STREET', '89-42 202ND STREET', '3646 BRONXWOOD AVENUE', '37-59 61ST STREET')
GROUP BY address, block, lot
HAVING COUNT(*) > 1;

SELECT address, block, lot, COUNT(*) as cnt
FROM cleansed.property_sales_clean
WHERE address IN ('365 BRIDGE STREET', '2800 COYLE STREET, 510', '88-40 87TH STREET', '89-42 202ND STREET', '3646 BRONXWOOD AVENUE', '37-59 61ST STREET')
GROUP BY address, block, lot
ORDER BY cnt DESC;

SELECT COUNT(*) AS total_duplicates
FROM (
    SELECT 
        address,borough, zip_code, block, lot, sale_date, sale_price,
        COUNT(*) AS cnt
    FROM cleansed.property_sales_clean
    GROUP BY address,borough, zip_code, block, lot, sale_date, sale_price
    HAVING COUNT(*) > 1
) dup;

WITH Duplicates_CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY address, borough, zip_code,block, lot, sale_date, sale_price
               ORDER BY (SELECT NULL) -- arbitrary order
           ) AS rn
    FROM cleansed.property_sales_clean
)
DELETE FROM Duplicates_CTE
WHERE rn > 1;
