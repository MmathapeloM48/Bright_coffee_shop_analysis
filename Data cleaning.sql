-- Databricks notebook source
SELECT * FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
LIMIT 5;

---------Checking NULLS-------

SELECT 
  COUNT(*) AS total_rows,
  COUNT(*) - COUNT(transaction_id) AS null_ids,
  COUNT(*) - COUNT(unit_price) AS null_price,
  COUNT(*) - COUNT(transaction_qty) AS null_qty,
  COUNT(DISTINCT transaction_id) AS unique_ids
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

-------Checking values------------

SELECT DISTINCT unit_price 
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
ORDER BY unit_price
LIMIT 20;

----------------checking product types--------------

SELECT DISTINCT product_category
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

------------ Cleaning Product Category----------------

SELECT DISTINCT
product_category,
CASE
WHEN product_category IS NULL THEN 'unknown'
WHEN TRIM(product_category) = '' THEN 'unknown'
ELSE product_category
END AS Product_cat
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

---------------Inspecting Product Type--------

SELECT DISTINCT product_type
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

--------------Cleaning Product Type---------------

SELECT DISTINCT
product_type,
CASE
WHEN product_type IS NULL THEN 'unknown'
WHEN TRIM(product_type) = '' THEN 'unknown'
ELSE product_type
END AS Product_type
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

--------Calculating total revenue by category------------------

SELECT product_category, ROUND(SUM(unit_price*transaction_qty),2) AS Total_revenue
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
GROUP BY product_category
ORDER BY Total_revenue DESC;

-------------------------------DATA CLEANING---------------------------

-------------FINAL CODE FOR CHECKING DUPLICATE transaction_id-----------------

SELECT transaction_id,
COUNT(*) AS Duplicate_cnt
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY Duplicate_cnt DESC;

-------------FINAL CODE FOR CHECKING DUPLICATES FOR ALL COLUMNS-----------------

SELECT *,
COUNT(*) OVER (PARTITION BY transaction_id, transaction_date, transaction_time, transaction_qty, store_id, store_location, product_id, unit_price, product_category, product_type, product_detail) AS Duplicate_cnt
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
QUALIFY Duplicate_cnt > 1;

--------------Checking the date column----------------------

SELECT DISTINCT transaction_date
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

SELECT DISTINCT DATE_FORMAT(transaction_date, 'MMMM') AS Month_name
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

-----------------Date range checks-------------

SELECT MIN(transaction_date) AS Earliest_date, MAX(transaction_date) AS Latest_date
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

--------------Checking transaction time column----------------------

SELECT DISTINCT transaction_time
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

SELECT DISTINCT DATE_FORMAT(transaction_time, 'HH:mm:ss') AS Time
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

------------------Creating time buckets---------------------

SELECT
CASE
WHEN HOUR(transaction_time) BETWEEN 7 AND 9 THEN 'Morning'
WHEN HOUR(transaction_time) BETWEEN 10 AND 12 THEN 'Afternoon'
WHEN HOUR(transaction_time) BETWEEN 13 AND 15 THEN 'Evening'
WHEN HOUR(transaction_time) BETWEEN 16 AND 18 THEN 'Night'
WHEN HOUR(transaction_time) >= 19 AND HOUR(transaction_time) <= 20 THEN 'Closing hours'
ELSE 'Night'
END AS Time_bucket
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

--------------------------Checking best selling product---------------------

SELECT
product_category,
product_type,
product_detail,
unit_price,
SUM(transaction_qty) AS total_transaction_qty,
ROUND(SUM(transaction_qty * unit_price), 2) AS total_price
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
GROUP BY
product_category,
product_type,
product_detail,
unit_price
ORDER BY total_price DESC;

-----------Analysing revenue by time bucket---------------------

SELECT
CASE
WHEN HOUR(transaction_time) BETWEEN 7 AND 9 THEN 'Morning'
WHEN HOUR(transaction_time) BETWEEN 10 AND 12 THEN 'Afternoon'
WHEN HOUR(transaction_time) BETWEEN 13 AND 15 THEN 'Evening'
WHEN HOUR(transaction_time) BETWEEN 16 AND 18 THEN 'Night'
WHEN HOUR(transaction_time) >= 19 AND HOUR(transaction_time) <= 20 THEN 'Closing hours'
ELSE 'Night'
END AS Time_bucket,
SUM(unit_price * transaction_qty) AS Total_revenue
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
GROUP BY Time_bucket
ORDER BY Total_revenue DESC;

---------------checking total revenue per store location-------------------

SELECT store_location, SUM(unit_price * transaction_qty) AS Total_revenue
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
GROUP BY store_location
ORDER BY Total_revenue DESC;

-------Total units sold by product type---------------

SELECT product_type, SUM(transaction_qty) AS Total_units_sold
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
GROUP BY product_type
ORDER BY Total_units_sold DESC;

-------Total units sold by product category (NEW)---------------

SELECT product_category, SUM(transaction_qty) AS Total_units_sold
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
GROUP BY product_category
ORDER BY Total_units_sold DESC;

-----------Total revenue by product type--------------

SELECT product_type, SUM(unit_price * transaction_qty) AS Total_revenue
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
GROUP BY product_type
ORDER BY Total_revenue DESC;

---------GROUPING product type and time bucket------------

SELECT
CASE
WHEN HOUR(transaction_time) BETWEEN 7 AND 9 THEN 'Morning'
WHEN HOUR(transaction_time) BETWEEN 10 AND 12 THEN 'Afternoon'
WHEN HOUR(transaction_time) BETWEEN 13 AND 15 THEN 'Evening'
WHEN HOUR(transaction_time) BETWEEN 16 AND 18 THEN 'Night'
WHEN HOUR(transaction_time) >= 19 AND HOUR(transaction_time) <= 20 THEN 'Closing hours'
ELSE 'Night'
END AS Time_bucket,
product_type,
SUM(transaction_qty) AS Total_units_sold,
SUM(unit_price * transaction_qty) AS Total_revenue
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
GROUP BY Time_bucket, product_type
ORDER BY Time_bucket, Total_units_sold DESC;

---------------Checking the days-------------

SELECT
CASE
WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Sunday'
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
END AS Day_type
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

------------------CREATING CTE TABLE---------------------

WITH sales_cte AS (
SELECT
*,
CASE
WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Sunday'
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
END AS Day_of_week,
CASE
WHEN HOUR(transaction_time) BETWEEN 7 AND 12 THEN 'Morning'
WHEN HOUR(transaction_time) BETWEEN 13 AND 15 THEN 'Afternoon'
WHEN HOUR(transaction_time) BETWEEN 16 AND 18 THEN 'Evening'
WHEN HOUR(transaction_time) >= 19 AND HOUR(transaction_time) <= 20 THEN 'Closing hours'
ELSE 'Night'
END AS Time_bucket
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis
)
SELECT *
FROM sales_cte;