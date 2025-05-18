-- 1. Table Schema Overview
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'property_sales_raw';

-- 2. Row Count
SELECT COUNT(*) AS total_rows
FROM staging.property_sales_raw;


-- 3. Distinct Value Count
SELECT 
    COUNT(DISTINCT borough) AS unique_boroughs,
    COUNT(DISTINCT neighborhood) AS unique_neighborhoods,
    COUNT(DISTINCT building_class_category) AS unique_categories,
    COUNT(DISTINCT sale_price) AS unique_sale_prices,
    COUNT(DISTINCT sale_date) AS unique_sale_dates
FROM staging.property_sales_raw;

-- 4. Top 10 Frequent Sale Prices
SELECT TOP 10 
    sale_price, COUNT(*) AS frequency
FROM staging.property_sales_raw
GROUP BY sale_price
ORDER BY frequency DESC;

-- 5. Invalid Sale Price Values (<= 0)
SELECT *
FROM staging.property_sales_raw
WHERE sale_price <= 0;

-- 6. Invalid Sale Dates
SELECT count(*)
FROM staging.property_sales_raw
WHERE TRY_CAST(sale_date AS DATE) IS NULL;

-- 7. Year Built in the Future (outlier check)
SELECT count (*)
FROM staging.property_sales_raw
WHERE year_built > YEAR(GETDATE());

