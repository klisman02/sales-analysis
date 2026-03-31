/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\Users\NOTE\Desktop\Microsoft SQL Server\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.dim_customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\Users\NOTE\Desktop\Microsoft SQL Server\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.dim_products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\Users\NOTE\Desktop\Microsoft SQL Server\sql-data-analytics-project\sql-data-analytics-project\datasets\csv-files\gold.fact_sales.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO


----------------------------##################################################-----------------------------------------------
--Going after high level overview insights to helo with strategic decisions
SELECT 
	YEAR(order_date) AS 'Order by Year', 
	SUM(sales_amount) AS 'Total Sales',
	COUNT(DISTINCT customer_key) as 'Total of Customers',
	SUM(quantity) as 'Quantity'
FROM 
	gold.fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY 
	YEAR(order_date)
ORDER BY 
	YEAR(order_date)


	-- Giving even more specific analysis

SELECT 
	YEAR(order_date) AS 'Order by Year', 
	MONTH(order_date) AS 'Order by Month', 
	SUM(sales_amount) AS 'Total Sales',
	COUNT(DISTINCT customer_key) as 'Total of Customers',
	SUM(quantity) as 'Quantity'
FROM 
	gold.fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY 
	YEAR(order_date), MONTH(order_date)
ORDER BY 
	YEAR(order_date), MONTH(order_date)

	-- High-level overview: resumo anual para decisões estratégicas
SELECT 
	DATETRUNC(month, order_date) AS 'Order by Date', 
	SUM(sales_amount) AS 'Total Sales',
	COUNT(DISTINCT customer_key) as 'Total of Customers',
	SUM(quantity) as 'Quantity'
FROM 
	gold.fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY 
	 DATETRUNC(month, order_date)
ORDER BY 
	 DATETRUNC(month, order_date)

	-- Same idea as the previous query, but using DATETRUNC for a cleaner time-series format
SELECT 
	DATETRUNC(month, order_date) AS 'Order by Date', 
	SUM(sales_amount) AS 'Total Sales',
	COUNT(DISTINCT customer_key) as 'Total of Customers',
	SUM(quantity) as 'Quantity'
FROM 
	gold.fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY 
	 DATETRUNC(month, order_date)
ORDER BY 
	 DATETRUNC(month, order_date)

	 -- Duplicate of the previous query — same logic, same output
SELECT 
	FORMAT(order_date, 'yyyy- MMM') AS 'Order by Date', 
	SUM(sales_amount) AS 'Total Sales',
	COUNT(DISTINCT customer_key) as 'Total of Customers',
	SUM(quantity) as 'Quantity'
FROM 
	gold.fact_sales
WHERE 
	order_date IS NOT NULL
GROUP BY 
	 FORMAT(order_date, 'yyyy- MMM')
ORDER BY 
	 FORMAT(order_date, 'yyyy- MMM');


----------------------------##################################################-----------------------------------------------
-- CULMULATIVE ANALYSIS = aggregating data progressively over time
-- Calculating the total sales per month and the running total of sales over time
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(PARTITION BY order_date ORDER BY order_date) AS 'Running Total Sales' 
FROM (
	SELECT 
		DATETRUNC(month, order_date) AS order_date, 
		SUM(sales_amount) AS total_sales
	FROM
		gold.fact_sales
	WHERE 
		order_date IS NOT NULL
	GROUP BY 
		DATETRUNC(month, order_date)
) AS t
ORDER BY
	order_date;

	-- This second keeps summing the previous value with next and printing the total until the last.
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS 'Running Total Sales',
	AVG(avg_price) OVER(ORDER BY order_date) AS 'Moving Average Price'
FROM (
	SELECT 
		DATETRUNC(YEAR, order_date) AS order_date, 
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM
		gold.fact_sales
	WHERE 
		order_date IS NOT NULL
	GROUP BY 
		DATETRUNC(YEAR, order_date)
) AS t
ORDER BY
	order_date;

----------------------------##################################################-----------------------------------------------
-- PERFOMANCE ANALYSIS
-- Comparing the current value with to a target value
WITH yearly_product_sales AS (
	SELECT 
		YEAR(f.order_date) AS order_date,
		p.product_name,
		SUM(f.sales_amount) AS sales_amount
	FROM 
		gold.fact_sales f
	LEFT JOIN 
		gold.dim_products p
	ON 
		f.product_key = p.product_key
	WHERE order_date IS NOT NULL 
	GROUP BY
		YEAR(f.order_date),
		p.product_name
)

SELECT
	order_date,
	product_name,
	sales_amount,
	AVG(sales_amount) OVER (PARTITION BY product_name) AS avg_sales,
	sales_amount - AVG(sales_amount) OVER (PARTITION BY product_name) AS diff_avg,

	CASE WHEN sales_amount - AVG(sales_amount) OVER (PARTITION BY product_name) > 0 THEN 'ABOVE AVERAGE'
		 WHEN sales_amount - AVG(sales_amount) OVER (PARTITION BY product_name) < 0 THEN 'BELOW AVERAGE'
		 ELSE 'AVERAGE'
	END avg_change,

	--YEAR OVER YEAR Analysis

	LAG(sales_amount) OVER (PARTITION BY product_name ORDER BY order_date) AS py_sales,
	sales_amount - LAG(sales_amount) OVER (PARTITION BY product_name ORDER BY order_date) as diff_py,

	CASE WHEN sales_amount - LAG(sales_amount) OVER (PARTITION BY product_name ORDER BY order_date) > 0 THEN 'INCREASE'
		 WHEN sales_amount - LAG(sales_amount) OVER (PARTITION BY product_name ORDER BY order_date) < 0 THEN 'DECREASE'
		 ELSE 'NO CHANGE'
	END py_sales

FROM
	yearly_product_sales
ORDER BY 
	product_name, order_date 

-- PART TO WHOLW ANALYSIS (Proportional Analysis)
-- Which categories contribute the most to overall sales?
WITH category_sales AS 
(
SELECT
	category,
	SUM(sales_amount) AS total_sales
FROM 
	gold.fact_sales f
LEFT JOIN gold.dim_products p
ON
	p.product_key = f.product_key
GROUP BY
	category
)

SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100,2), '%') AS percentage_of_total
FROM
	category_sales
ORDER BY
	total_sales DESC

-- DATA SEGMENTATION
WITH product_segments AS(
SELECT 
	product_key,
	product_name,
	cost,
CASE WHEN cost < 100 THEN 'BELOW 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'ABOVE ONE THOUSAND'
END cost_range
FROM
	gold.dim_products)

SELECT 
	cost_range,
	COUNT(product_key) AS total_products
FROM
	product_segments
GROUP BY
	cost_range

	/* Group costumers into three segments based on their spending behavior
		- VIP: Costumers with at least 12 months of history and spending more than E$ 5000 euros.
		- REGULAR: Costumers with at least 12 months of history but spending E$5,000 or less
		- NEW: Costumers with a lifespan less than 12 months.
	And find the total number of customers by each group
	*/

	WITH customer_spending AS (
    SELECT
        f.customer_key, -- Grouping by the foreign key in sales is safer
        SUM(f.sales_amount) AS total_spending, 
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order, 
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_customers c 
        ON f.customer_key = c.customer_key 
    GROUP BY f.customer_key
)

SELECT
    customer_segment, -- Fixed spelling
    COUNT(customer_key) AS total_customers -- Fixed spelling
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) t
GROUP BY customer_segment
ORDER BY total_customers DESC; -- Added DESC to see the biggest groups first