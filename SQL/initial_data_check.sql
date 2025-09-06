SET SCHEMA 'fmcg';

-- Data Quality Check: FMCG Sales Table

-- Check for duplicate transactions (based on date + SKU + channel + region)
SELECT 
    date,
    sku,
    channel,
    region,
    COUNT(*) AS duplicate_count
FROM fmcg_data
GROUP BY date, sku, channel, region
HAVING COUNT(*) > 1;


-- Check for missing/null values in key columns
SELECT
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN sku IS NULL THEN 1 ELSE 0 END) AS missing_sku,
    SUM(CASE WHEN brand IS NULL THEN 1 ELSE 0 END) AS missing_brand,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS missing_segment,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END) AS missing_channel,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN pack_type IS NULL THEN 1 ELSE 0 END) AS missing_pack_type,
    SUM(CASE WHEN price_unit IS NULL THEN 1 ELSE 0 END) AS missing_price_unit,
    SUM(CASE WHEN promotion_flag IS NULL THEN 1 ELSE 0 END) AS missing_promotion_flag,
    SUM(CASE WHEN delivery_days IS NULL THEN 1 ELSE 0 END) AS missing_delivery_days,
    SUM(CASE WHEN stock_available IS NULL THEN 1 ELSE 0 END) AS missing_stock_available,
    SUM(CASE WHEN delivered_qty IS NULL THEN 1 ELSE 0 END) AS missing_delivered_qty,
    SUM(CASE WHEN units_sold IS NULL THEN 1 ELSE 0 END) AS missing_units_sold
FROM fmcg_data;


-- Check ranges for numeric columns
SELECT
    MIN(price_unit) AS min_price_unit,
    MAX(price_unit) AS max_price_unit,
    MIN(delivery_days) AS min_delivery_days,
    MAX(delivery_days) AS max_delivery_days,
    MIN(stock_available) AS min_stock,
    MAX(stock_available) AS max_stock,
    MIN(delivered_qty) AS min_delivered_qty,
    MAX(delivered_qty) AS max_delivered_qty,
    MIN(units_sold) AS min_units_sold,
    MAX(units_sold) AS max_units_sold
FROM fmcg_data;


-- Check for zero or negative values in key numeric columns
SELECT *
FROM fmcg_data
WHERE price_unit <= 0
   OR units_sold <= 0
   OR delivered_qty < 0;


-- Check distinct values in categorical columns
SELECT DISTINCT brand FROM fmcg_data ORDER BY brand;
SELECT DISTINCT segment FROM fmcg_data ORDER BY segment;
SELECT DISTINCT category FROM fmcg_data ORDER BY category;
SELECT DISTINCT channel FROM fmcg_data ORDER BY channel;
SELECT DISTINCT region FROM fmcg_data ORDER BY region;
SELECT DISTINCT pack_type FROM fmcg_data ORDER BY pack_type;
SELECT DISTINCT promotion_flag FROM fmcg_data ORDER BY promotion_flag;


-- Check date range for transactions
SELECT
    MIN(date) AS earliest_transaction,
    MAX(date) AS latest_transaction
FROM fmcg_data;


