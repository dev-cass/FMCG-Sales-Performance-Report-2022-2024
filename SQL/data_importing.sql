-- Database creation
CREATE DATABASE fmcg;

-- Creating and setting schema
CREATE SCHEMA fmcg;
SET SCHEMA 'fmcg';

DROP TABLE IF EXISTS fmcg_data;
CREATE TABLE IF NOT EXISTS fmcg_data (
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
	units_sold INTEGER
);

COPY fmcg_data 
FROM 'C:/Data Projects/FMCG/dirty_FMCG.csv'
HEADER CSV 
DELIMITER ',';



