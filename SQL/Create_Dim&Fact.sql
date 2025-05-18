-- =============================
-- CREATE DIMENSION TABLES
-- =============================
CREATE TABLE Dm.dim_date (
    date_key INT PRIMARY KEY, -- format YYYYMMDD
    full_date DATE,
    year INT,
    month INT,
    day INT,
    quarter INT
);

CREATE TABLE Dm.dim_location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    borough NVARCHAR(255),
    zip_code INT
);

CREATE TABLE Dm.dim_property (
    property_id INT IDENTITY(1,1) PRIMARY KEY,
    address NVARCHAR(255),
    building_class_category NVARCHAR(255),
    building_class_at_time_of_sale NVARCHAR(50),
    tax_class_at_time_of_sale NVARCHAR(50),
    block INT,
    lot INT,
    year_built INT,
    residential_units INT,
    commercial_units INT,
    total_units INT,
    land_square_feet FLOAT,
    gross_square_feet FLOAT
);

-- =============================
-- CREATE FACT TABLE
-- =============================

CREATE TABLE Dm.fact_property_sales (
    sale_id INT IDENTITY(1,1) PRIMARY KEY,
    sale_price BIGINT,
    sale_date_key INT FOREIGN KEY REFERENCES DM.dim_date(date_key),
    property_id INT FOREIGN KEY REFERENCES DM.dim_property(property_id),
    location_id INT FOREIGN KEY REFERENCES DM.dim_location(location_id)
);
