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
FROM staging.property_sales_raw;


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
