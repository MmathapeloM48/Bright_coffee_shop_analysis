-- Databricks notebook source
------------------BIG CODE: FULL CLEAN TABLE---------------------

CREATE OR REPLACE TABLE bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_clean
AS
SELECT
  transaction_id,
  CAST(transaction_date AS DATE) AS transaction_date,
  CASE DAYOFWEEK(CAST(transaction_date AS DATE))
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
  END AS day_name,
  DAYOFWEEK(CAST(transaction_date AS DATE)) AS day_number,
  DATE_FORMAT(CAST(transaction_date AS DATE), 'MMMM') AS month_name,
  MONTH(CAST(transaction_date AS DATE)) AS month_number,
  YEAR(CAST(transaction_date AS DATE)) AS year,
  CASE
    WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN '06:00–09:00'
    WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN '09:00–12:00'
    WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN '12:00–15:00'
    WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN '15:00–18:00'
    WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN '18:00–21:00'
    ELSE '21:00–00:00'
  END AS time_of_day,
  CASE
    WHEN HOUR(transaction_time) BETWEEN 7 AND 9 THEN 'Morning'
    WHEN HOUR(transaction_time) BETWEEN 10 AND 12 THEN 'Afternoon'
    WHEN HOUR(transaction_time) BETWEEN 13 AND 15 THEN 'Evening'
    WHEN HOUR(transaction_time) BETWEEN 16 AND 18 THEN 'Night'
    WHEN HOUR(transaction_time) >= 19 AND HOUR(transaction_time) <= 20 THEN 'Closing hours'
    ELSE 'Night'
  END AS Time_bucket,
  transaction_qty,
  store_id,
  store_location,
  product_id,
  product_category,
  product_type,
  product_detail,
  unit_price,
  ROUND(unit_price * transaction_qty, 2) AS total_amount
FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_analysis;

SELECT * FROM bright_coffee_shop.bright_coffee_dataset.bright_coffee_shop_clean
LIMIT 5;
