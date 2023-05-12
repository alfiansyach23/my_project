--DATA PREPARATION (CLEANSING, WRANGLING, MANIPULATION, etc)
--orders table
SELECT *
FROM restaurant_recommendation.dbo.orders

--check missing value
SELECT 
    SUM(CASE WHEN RTRIM(ISNULL(order_id, '')) LIKE '' THEN 1 ELSE 0 END) AS order_id, 
    SUM(CASE WHEN RTRIM(ISNULL(customer_id, '')) LIKE '' THEN 1 ELSE 0 END) AS customer_id,
	SUM(CASE WHEN RTRIM(ISNULL(item_count, '')) LIKE '' THEN 1 ELSE 0 END) AS item_count,
	SUM(CASE WHEN RTRIM(ISNULL(grand_total, '')) LIKE '' THEN 1 ELSE 0 END) AS grand_total,
	SUM(CASE WHEN RTRIM(ISNULL(payment_mode, '')) LIKE '' THEN 1 ELSE 0 END) AS payment_mode,
	SUM(CASE WHEN RTRIM(ISNULL(is_favorite, '')) LIKE '' THEN 1 ELSE 0 END) AS is_favorite,
	SUM(CASE WHEN RTRIM(ISNULL(is_rated, '')) LIKE '' THEN 1 ELSE 0 END) AS is_rated,
	SUM(CASE WHEN RTRIM(ISNULL(driver_rating, '')) LIKE '' THEN 1 ELSE 0 END) AS driver_rating,
	SUM(CASE WHEN RTRIM(ISNULL(deliverydistance, '')) LIKE '' THEN 1 ELSE 0 END) AS deliverydistance,
	SUM(CASE WHEN RTRIM(ISNULL(vendor_id, '')) LIKE '' THEN 1 ELSE 0 END) AS vendor_id,
	SUM(CASE WHEN RTRIM(ISNULL(created_at, '')) LIKE '' THEN 1 ELSE 0 END) AS created_at,
	SUM(CASE WHEN RTRIM(ISNULL(LOCATION_NUMBER, '')) LIKE '' THEN 1 ELSE 0 END) AS LOCATION_NUMBER
FROM restaurant_recommendation.dbo.orders

--Changing Data Types
ALTER TABLE restaurant_recommendation.dbo.orders
ALTER COLUMN item_count FLOAT

ALTER TABLE restaurant_recommendation.dbo.orders
ALTER COLUMN grand_total FLOAT

--replace some caracther in order_id column
UPDATE restaurant_recommendation.dbo.orders
SET order_id = REPLACE(order_id, '.0', '')

--handling missing values order_id column with drop rows
DELETE FROM restaurant_recommendation.dbo.orders 
WHERE RTRIM(ISNULL(order_id, '')) LIKE ''

--handling missing values item_count column with mean
SELECT AVG(item_count) AS item_count
FROM restaurant_recommendation.dbo.orders

UPDATE restaurant_recommendation.dbo.orders
SET item_count = '2'
WHERE item_count = 0

--handling missing values is_favorite column with mode
SELECT TOP 1 is_favorite
FROM restaurant_recommendation.dbo.orders
WHERE RTRIM(ISNULL(is_favorite, '')) NOT LIKE ''
GROUP BY is_favorite
ORDER BY COUNT(*) DESC

UPDATE restaurant_recommendation.dbo.orders
SET is_favorite = 'No'
WHERE RTRIM(ISNULL(is_favorite, '')) LIKE ''

SELECT
  is_favorite,
  COUNT(*) AS is_favorite_values
FROM restaurant_recommendation.dbo.orders
GROUP BY is_favorite

--check duplicates
SELECT
	SUM(total) AS total_duplicate
FROM (
SELECT
	order_id,
	COUNT(*) AS total
FROM restaurant_recommendation.dbo.orders
GROUP BY
	order_id
HAVING COUNT(*) > 1
) AS subb

--check outlier
--find mean value from item_count column
SELECT
	AVG(item_count) AS avg_item_count
FROM restaurant_recommendation.dbo.orders

--find median value from item_count column
SELECT
(
	(SELECT MAX(item_count) FROM
		(SELECT top 50 percent item_count FROM restaurant_recommendation.dbo.orders ORDER BY item_count) AS one_half)
	+
	(SELECT MIN(item_count) FROM
		(SELECT top 50 percent item_count FROM restaurant_recommendation.dbo.orders ORDER BY item_count DESC) AS other_half)
) / 2 AS median

--find mean value from grand_total column
SELECT
	AVG(grand_total) AS avg_grand_total
FROM restaurant_recommendation.dbo.orders

--find median value from grand_total column
SELECT
(
	(SELECT MAX(grand_total) FROM
		(SELECT top 50 percent grand_total FROM restaurant_recommendation.dbo.orders ORDER BY grand_total) AS one_half)
	+
	(SELECT MIN(grand_total) FROM
		(SELECT top 50 percent grand_total FROM restaurant_recommendation.dbo.orders ORDER BY grand_total DESC) AS other_half)
) / 2 AS median

--Check Outliers
SELECT Q1, Q3, Q3 - Q1 AS IQR,
  Q1 - (1.5 * (Q3 - Q1)) AS lower_bound,
  Q3 + (1.5 * (Q3 - Q1)) AS upper_bound
FROM (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY grand_total) OVER() AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY grand_total) OVER() AS Q3
  FROM
    restaurant_recommendation.dbo.orders
) AS quartiles

SELECT grand_total
FROM restaurant_recommendation.dbo.orders
WHERE grand_total < -6.8 OR grand_total > 33.2
ORDER BY grand_total

--handling outlier
SELECT
	PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY grand_total) OVER() AS lower_value,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY grand_total) OVER() AS upper_value
FROM restaurant_recommendation.dbo.orders

UPDATE restaurant_recommendation.dbo.orders
SET grand_total = 
  CASE
    WHEN grand_total < 5.7 THEN 5.7
    WHEN grand_total > 28.5 THEN 28.5
    ELSE grand_total
  END
FROM restaurant_recommendation.dbo.orders

--------------------------------------------------------------------------------

--customers table
SELECT *
FROM restaurant_recommendation.dbo.customers

--check missing value
SELECT 
    SUM(CASE WHEN RTRIM(ISNULL(customer_id, '')) LIKE '' THEN 1 ELSE 0 END) AS customer_id, 
    SUM(CASE WHEN RTRIM(ISNULL(gender, '')) LIKE '' THEN 1 ELSE 0 END) AS gender,
	SUM(CASE WHEN RTRIM(ISNULL(dob, '')) LIKE '' THEN 1 ELSE 0 END) AS dob,
	SUM(CASE WHEN RTRIM(ISNULL(status, '')) LIKE '' THEN 1 ELSE 0 END) AS status,
	SUM(CASE WHEN RTRIM(ISNULL(verified, '')) LIKE '' THEN 1 ELSE 0 END) AS verified,
	SUM(CASE WHEN RTRIM(ISNULL(created_at, '')) LIKE '' THEN 1 ELSE 0 END) AS created_at,
	SUM(CASE WHEN RTRIM(ISNULL(updated_at, '')) LIKE '' THEN 1 ELSE 0 END) AS updated_at
FROM restaurant_recommendation.dbo.customers

--change data type
ALTER TABLE restaurant_recommendation.dbo.customers
ALTER COLUMN created_at DATETIME

ALTER TABLE restaurant_recommendation.dbo.customers
ALTER COLUMN updated_at DATETIME

--convert to uppercase in gender column
UPDATE restaurant_recommendation.dbo.customers
SET gender = UPPER(gender)

--check duplicates
SELECT
	SUM(total) AS total_duplicate
FROM (
SELECT
	customer_id,
	COUNT(*) AS total
FROM restaurant_recommendation.dbo.customers
GROUP BY
	customer_id
HAVING COUNT(*) > 1
) AS subb

--handling duplicates
WITH CTE(
	customer_id, 
    DuplicateCount)
AS (SELECT customer_id, 
           ROW_NUMBER() OVER(PARTITION BY customer_id
           ORDER BY customer_id) AS DuplicateCount
    FROM restaurant_recommendation.dbo.customers)
DELETE FROM CTE
WHERE DuplicateCount > 1

--calculate age customer
SELECT YEAR(GETDATE()) - YEAR(dob) AS customer_age
FROM restaurant_recommendation.dbo.customers

--------------------------------------------------------------------------------

--vendors table
SELECT *
FROM restaurant_recommendation.dbo.vendors

--check missing value
SELECT 
    SUM(CASE WHEN RTRIM(ISNULL(vendor_id, '')) LIKE '' THEN 1 ELSE 0 END) AS vendor_id, 
    SUM(CASE WHEN RTRIM(ISNULL(authentication_id, '')) LIKE '' THEN 1 ELSE 0 END) AS authentication_id,
	SUM(CASE WHEN RTRIM(ISNULL(latitude, '')) LIKE '' THEN 1 ELSE 0 END) AS latitude,
	SUM(CASE WHEN RTRIM(ISNULL(longitude, '')) LIKE '' THEN 1 ELSE 0 END) AS longitude,
	SUM(CASE WHEN RTRIM(ISNULL(vendor_category_en, '')) LIKE '' THEN 1 ELSE 0 END) AS vendor_category_en,
	SUM(CASE WHEN RTRIM(ISNULL(delivery_charge, '')) LIKE '' THEN 1 ELSE 0 END) AS delivery_charge,
	SUM(CASE WHEN RTRIM(ISNULL(serving_distance, '')) LIKE '' THEN 1 ELSE 0 END) AS serving_distance,
	SUM(CASE WHEN RTRIM(ISNULL(is_open, '')) LIKE '' THEN 1 ELSE 0 END) AS is_open,
	SUM(CASE WHEN RTRIM(ISNULL(OpeningTime, '')) LIKE '' THEN 1 ELSE 0 END) AS OpeningTime,
	SUM(CASE WHEN RTRIM(ISNULL(prepration_time, '')) LIKE '' THEN 1 ELSE 0 END) AS prepration_time,
	SUM(CASE WHEN RTRIM(ISNULL(discount_percentage, '')) LIKE '' THEN 1 ELSE 0 END) AS discount_percentage,
	SUM(CASE WHEN RTRIM(ISNULL(status, '')) LIKE '' THEN 1 ELSE 0 END) AS status,
	SUM(CASE WHEN RTRIM(ISNULL(verified, '')) LIKE '' THEN 1 ELSE 0 END) AS verified,
	SUM(CASE WHEN RTRIM(ISNULL(rank, '')) LIKE '' THEN 1 ELSE 0 END) AS rank,
	SUM(CASE WHEN RTRIM(ISNULL(vendor_rating, '')) LIKE '' THEN 1 ELSE 0 END) AS vendor_rating,
	SUM(CASE WHEN RTRIM(ISNULL(vendor_tag, '')) LIKE '' THEN 1 ELSE 0 END) AS vendor_tag,
	SUM(CASE WHEN RTRIM(ISNULL(vendor_tag_name, '')) LIKE '' THEN 1 ELSE 0 END) AS vendor_tag_name,
	SUM(CASE WHEN RTRIM(ISNULL(created_at, '')) LIKE '' THEN 1 ELSE 0 END) AS created_at,
	SUM(CASE WHEN RTRIM(ISNULL(updated_at, '')) LIKE '' THEN 1 ELSE 0 END) AS updated_at,
	SUM(CASE WHEN RTRIM(ISNULL(device_type, '')) LIKE '' THEN 1 ELSE 0 END) AS device_type
FROM restaurant_recommendation.dbo.vendors

--because the openingtime column has inconsistent values
--and not intended for later analysis
--then I will not handle the column
--and this also applies to the vendor_tag and vendor_tag_name columns

--change data type
ALTER TABLE restaurant_recommendation.dbo.vendors
ALTER COLUMN vendor_rating FLOAT

ALTER TABLE restaurant_recommendation.dbo.vendors
ALTER COLUMN discount_percentage INT

--replace some caracther in order_id column
UPDATE restaurant_recommendation.dbo.vendors
SET created_at = REPLACE(created_at, '/', '-')

UPDATE restaurant_recommendation.dbo.vendors
SET updated_at = REPLACE(updated_at, '/', '-')

--check duplicates
SELECT
	SUM(total) AS total_duplicate
FROM (
SELECT
	vendor_id,
	COUNT(*) AS total
FROM restaurant_recommendation.dbo.vendors
GROUP BY
	vendor_id
HAVING COUNT(*) > 1
) AS subb

--------------------------------------------------------------------------------

--locations table
SELECT *
FROM restaurant_recommendation.dbo.locations

--check missing value
SELECT 
    SUM(CASE WHEN RTRIM(ISNULL(customer_id, '')) LIKE '' THEN 1 ELSE 0 END) AS customer_id, 
    SUM(CASE WHEN RTRIM(ISNULL(location_number, '')) LIKE '' THEN 1 ELSE 0 END) AS location_number,
	SUM(CASE WHEN RTRIM(ISNULL(latitude, '')) LIKE '' THEN 1 ELSE 0 END) AS latitude,
	SUM(CASE WHEN RTRIM(ISNULL(longitude, '')) LIKE '' THEN 1 ELSE 0 END) AS longitude
FROM restaurant_recommendation.dbo.locations

--handling missing values latitude and longitude column with drop rows
DELETE FROM restaurant_recommendation.dbo.locations 
WHERE RTRIM(ISNULL(latitude, '')) LIKE '' OR RTRIM(ISNULL(longitude, '')) LIKE ''

--check duplicates
SELECT
	SUM(total) AS total_duplicate
FROM (
SELECT
	customer_id,
	location_number,
	latitude,
	longitude,
	COUNT(*) AS total
FROM restaurant_recommendation.dbo.locations
GROUP BY
	customer_id,
	location_number,
	latitude,
	longitude
HAVING COUNT(*) > 1
) AS subb

--------------------------------------------------------------------------------

--EXPLORATORY DATA ANALYSIS (EDA)

--what vendor categories received the most orders and total items ordered by each gender
SELECT
	v.vendor_category_en,
	c.gender,
	COUNT(o.order_id) AS total_order,
	SUM(o.item_count) AS total_item
FROM restaurant_recommendation.dbo.orders o
INNER JOIN restaurant_recommendation.dbo.vendors v
ON v.vendor_id = o.vendor_id
INNER JOIN restaurant_recommendation.dbo.customers c
ON c.customer_id = o.customer_id
GROUP BY vendor_category_en, gender
ORDER BY total_order DESC

--how the rating of each vendor category based on its total orders
SELECT
	v.vendor_category_en,
	(v.vendor_rating/10) AS rating,
	COUNT(o.order_id) AS total_order
FROM restaurant_recommendation.dbo.orders o
INNER JOIN restaurant_recommendation.dbo.vendors v
ON v.vendor_id = o.vendor_id
INNER JOIN restaurant_recommendation.dbo.customers c
ON c.customer_id = o.customer_id
GROUP BY vendor_category_en, vendor_rating
ORDER BY vendor_rating

--how many total orders per vendor category based on the order menu chosen by the customer, whether it is a favorite menu or not?
SELECT
	v.vendor_category_en,
	o.is_favorite,
	COUNT(order_id) AS total_order
FROM restaurant_recommendation.dbo.orders o
INNER JOIN restaurant_recommendation.dbo.vendors v
ON v.vendor_id = o.vendor_id
INNER JOIN restaurant_recommendation.dbo.customers c
ON c.customer_id = o.customer_id
GROUP BY vendor_category_en, is_favorite
ORDER BY total_order DESC

--when placing an order, what is the most common payment method used by customers?
SELECT
	o.payment_mode,
	COUNT(o.order_id) AS total_order
FROM restaurant_recommendation.dbo.orders o
INNER JOIN restaurant_recommendation.dbo.vendors v
ON v.vendor_id = o.vendor_id
INNER JOIN restaurant_recommendation.dbo.customers c
ON c.customer_id = o.customer_id
GROUP BY payment_mode
ORDER BY total_order DESC

--which vendors are giving discounts based on their respective vendor categories?
SELECT
	DISTINCT v.vendor_id,
	v.vendor_category_en,
	v.discount_percentage
FROM restaurant_recommendation.dbo.orders o
INNER JOIN restaurant_recommendation.dbo.vendors v
ON v.vendor_id = o.vendor_id
INNER JOIN restaurant_recommendation.dbo.customers c
ON c.customer_id = o.customer_id
WHERE discount_percentage != 0
ORDER BY discount_percentage DESC