SET SCHEMA 'fmcg';

SELECT *
FROM fmcg_data_staging;

-- What is the business' Order count per year and total order count

SELECT 
    COALESCE(EXTRACT(YEAR FROM date)::TEXT, 'Total Orders') AS year,
    COUNT(*) AS AOV
FROM fmcg_data_staging
GROUP BY ROLLUP(EXTRACT(YEAR FROM date))
ORDER BY year;


-- What is the business' yearly revenue and overall total

SELECT 
    COALESCE(EXTRACT(YEAR FROM date)::TEXT, 'Total Revenue') AS year,
    SUM(price_unit * units_sold) AS revenue
FROM fmcg_data_staging
GROUP BY ROLLUP(EXTRACT(YEAR FROM date))
ORDER BY year;


-- What is the business' AOV per year and overall AOV

SELECT 
    COALESCE(EXTRACT(YEAR FROM date)::TEXT, 'Total AOV') AS year,
    SUM(price_unit * units_sold)/ COUNT(sku) AS AOV
FROM fmcg_data_staging
GROUP BY ROLLUP(EXTRACT(YEAR FROM date))
ORDER BY year;


-- Products contributing 80% of revenue

WITH product_revenue AS (
    SELECT 
        sku,
        SUM(price_unit * units_sold) AS revenue
    FROM fmcg_data_staging
    GROUP BY sku
),
ranked AS (
    SELECT 
        sku,
        revenue,
        revenue * 1.0 / SUM(revenue) OVER () AS pct_of_total,
        SUM(revenue) OVER (ORDER BY revenue DESC) * 1.0 
            / SUM(revenue) OVER () AS cumulative_share 
    FROM product_revenue
)
SELECT *
FROM ranked
WHERE cumulative_share <= 0.8
ORDER BY revenue DESC;


-- Overall median price_unit across all products and years

SELECT
    EXTRACT(YEAR FROM date) AS year,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_unit) AS median_price
FROM fmcg_data_staging
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY year;


-- What are the top 10 products (SKU)

SELECT 
	sku AS product,
	SUM(price_unit * units_sold) AS revenue
FROM fmcg_data_staging
GROUP BY product
ORDER BY revenue DESC
LIMIT 10;


-- What are the top 10 low-revenue products (SKU)

SELECT 
	sku AS product,
	SUM(price_unit * units_sold) AS revenue
FROM fmcg_data_staging
GROUP BY product
ORDER BY revenue ASC
LIMIT 10;


-- Top 3 products per year by revenue

WITH product_ranked AS (
    SELECT
        EXTRACT(YEAR FROM date) AS year,
        sku,
        SUM(price_unit * units_sold) AS revenue,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM date)
            ORDER BY SUM(price_unit * units_sold) DESC
        ) AS rank
    FROM fmcg_data_staging
    GROUP BY year, sku
)
SELECT *
FROM product_ranked
WHERE rank <= 3
ORDER BY year, rank;

-- Total revenue comparison: Promotional and Non-Promotional sales

SELECT 
    promotion_flag,                          
    SUM(price_unit * units_sold) AS revenue   
FROM fmcg_data_staging
GROUP BY promotion_flag
ORDER BY revenue DESC;


-- Total order count comparison: Promotional and Non-Promotional sales

SELECT 
    promotion_flag,                          
   	COUNT(*) AS order_count
FROM fmcg_data_staging
GROUP BY promotion_flag
ORDER BY order_count DESC;



-- Total revenue accross three Channel

SELECT 
    channel,                          
    SUM(price_unit * units_sold) AS revenue   
FROM fmcg_data_staging
GROUP BY channel
ORDER BY revenue DESC;


-- Total revenue accross three Region

SELECT 
    region,
    SUM(price_unit * units_sold) AS revenue,
    ROUND(
        SUM(price_unit * units_sold) * 100.0 
        / SUM(SUM(price_unit * units_sold)) OVER (), 
        2
    ) AS pct_of_total
FROM fmcg_data_staging
GROUP BY region
ORDER BY revenue DESC;


-- Monthly revenue trend across all years

SELECT 
    TO_CHAR(date, 'YYYY-MM') AS month,
    SUM(price_unit * units_sold) AS revenue
FROM fmcg_data_staging
GROUP BY month
ORDER BY month;

