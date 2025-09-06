SET SCHEMA 'fmcg';

SELECT *
FROM fmcg_data;

-- STANDARDIZING DATA

-- Sku
-- Found minimal typo's on sku column
SELECT sku
FROM fmcg_data
GROUP BY sku;

BEGIN TRANSACTION; -- For safe updating values

-- trimming SKU to 6 characters, anything beyond is a typo
UPDATE fmcg_data
SET sku = LEFT(sku, 6);

-- Brand
SELECT brand
FROM fmcg_data
GROUP BY brand;

-- Using proper case for brand
UPDATE fmcg_data
SET brand = INITCAP(brand);

-- trimming brand to 8 characters, anything beyond is a typo
UPDATE fmcg_data
SET brand = LEFT(brand, 8);

COMMIT;

-- Segment

-- fixing typo's on segment
SELECT segment
FROM fmcg_data
GROUP BY segment;

BEGIN TRANSACTION; -- For safe updating values 

-- -- Fix trailing typos: ^ = start of text, .+$ = one or more extra chars at the end, replace with correct segment
UPDATE fmcg_data
SET segment = 'Juice-Seg3'
WHERE segment ~ '^Juice-Seg3.+$';

UPDATE fmcg_data
SET segment = 'Milk-Seg1'
WHERE segment ~ '^Milk-Seg1.+$';

UPDATE fmcg_data
SET segment = 'Milk-Seg2'
WHERE segment ~ '^Milk-Seg2.+$';

UPDATE fmcg_data
SET segment = 'Milk-Seg3'
WHERE segment ~ '^Milk-Seg3.+$';

UPDATE fmcg_data
SET segment = 'ReadyMeal-Seg1'
WHERE segment ~ '^ReadyMeal-Seg1.+$';

UPDATE fmcg_data
SET segment = 'ReadyMeal-Seg2'
WHERE segment ~ '^ReadyMeal-Seg2.+$';

UPDATE fmcg_data
SET segment = 'ReadyMeal-Seg3'
WHERE segment ~ '^ReadyMeal-Seg3.+$';

UPDATE fmcg_data
SET segment = 'SnackBar-Seg1'
WHERE segment ~ '^SnackBar-Seg1.+$';

UPDATE fmcg_data
SET segment = 'SnackBar-Seg2'
WHERE segment ~ '^SnackBar-Seg2.+$';

UPDATE fmcg_data
SET segment = 'SnackBar-Seg3'
WHERE segment ~ '^SnackBar-Seg3.+$';

UPDATE fmcg_data
SET segment = 'Yogurt-Seg1'
WHERE segment ~ '^Yogurt-Seg1.+$';

UPDATE fmcg_data
SET segment = 'Yogurt-Seg2'
WHERE segment ~ '^Yogurt-Seg2.+$';

UPDATE fmcg_data
SET segment = 'Yogurt-Seg3'
WHERE segment ~ '^Yogurt-Seg3.+$';

COMMIT;

-- Category
SELECT category
FROM fmcg_data
GROUP BY category;

BEGIN TRANSACTION; -- For safe updating values

UPDATE fmcg_data
SET category = 'Milk'
WHERE category LIKE '%Milk%';

UPDATE fmcg_data
SET category = 'Juice'
WHERE category LIKE '%Juice%';

UPDATE fmcg_data
SET category = 'ReadyMeal'
WHERE category LIKE '%ReadyMeal%';

UPDATE fmcg_data
SET category = 'Yogurt'
WHERE category LIKE '%Yogurt%';

UPDATE fmcg_data
SET category = 'SnackBar'
WHERE category LIKE '%SnackBar%';

COMMIT;

-- Channel
SELECT channel
FROM fmcg_data
GROUP BY channel;

BEGIN TRANSACTION; -- For safe updating values

UPDATE fmcg_data
SET channel = INITCAP(channel);

UPDATE fmcg_data
SET channel = 'Retail'
WHERE channel LIKE '%Retail%';

UPDATE fmcg_data
SET channel = 'Discount'
WHERE channel LIKE '%Discount%';

UPDATE fmcg_data
SET channel = 'E-commerce'
WHERE channel LIKE '%E-commerce%';

COMMIT;

-- Region
SELECT region
FROM fmcg_data
GROUP BY region;

BEGIN TRANSACTION; -- For safe updating values

UPDATE fmcg_data
SET region = UPPER(LEFT(region, 2)) || SUBSTRING(region, 3);

UPDATE fmcg_data
SET region = 'PL-Central'
WHERE region LIKE '%PL-Central%';

UPDATE fmcg_data
SET region = 'PL-North'
WHERE region LIKE '%PL-North%';

UPDATE fmcg_data
SET region = 'PL-South'
WHERE region LIKE '%PL-South%';

COMMIT;

-- Pack type
SELECT pack_type
FROM fmcg_data
GROUP BY pack_type;

BEGIN TRANSACTION; -- For safe updating values

UPDATE fmcg_data
SET pack_type = 'Carton'
WHERE pack_type LIKE '%Carton%';

UPDATE fmcg_data
SET pack_type = 'Multipack'
WHERE pack_type LIKE '%Multipack%';

UPDATE fmcg_data
SET pack_type = 'Single'
WHERE pack_type LIKE '%Single%';

COMMIT;

-- Detecting duplicates using ROW_NUMBER()
WITH fmcg_duplicate AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY date, sku, brand, segment, category,
                            channel, region, pack_type, price_unit,
                            promotion_flag, delivery_days, stock_available,
                            delivered_qty, units_sold
          ) AS row_num
   FROM fmcg_data
)
SELECT *
FROM fmcg_duplicate
WHERE row_num > 1;

BEGIN TRANSACTION;

-- Creating a staging table to hold clean data and insert row_num values since you cannot delete within the CTE
-- Deleting duplicates are in 
DROP TABLE IF EXISTS fmcg_data_staging;
CREATE TABLE IF NOT EXISTS fmcg_data_staging (
	date DATE,
	sku VARCHAR(20),
	brand VARCHAR(20),
	segment VARCHAR(20),
	category VARCHAR(20),
	channel VARCHAR(20),
	region VARCHAR(20),
	pack_type VARCHAR(20),
	price_unit NUMERIC,
	promotion_flag BOOLEAN,
	delivery_days INTEGER,
	stock_available INTEGER,
	delivered_qty INTEGER,
	units_sold INTEGER,
	row_num INTEGER
);

-- Inserting values from the original table
INSERT INTO fmcg_data_staging
SELECT *, 
ROW_NUMBER() OVER (
	PARTITION BY date, sku, brand, segment, category,
      channel, region, pack_type, price_unit,
      promotion_flag, delivery_days, stock_available,
      delivered_qty, units_sold
    ) AS row_num
FROM fmcg_data;


-- Deleting duplicates
DELETE FROM
fmcg_data_staging
WHERE row_num > 1;

-- Dropping unwanted columns
ALTER TABLE fmcg_data_staging
DROP COLUMN row_num;

-- Saving changes
COMMIT;

COPY fmcg_data_staging 
TO 'C:/Data Projects/FMCG/dirty_FMCG.csv'
CSV HEADER 
DELIMITER ',';




