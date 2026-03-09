-- Creating Table retail_sales

CREATE TABLE retail_sales
(
		transactions_id	INT PRIMARY KEY,
		sale_date DATE,
		sale_time TIME,
		customer_id INT,	
		gender VARCHAR(50),
		age	INT,
		category VARCHAR(50),
		quantity INT,
		price_per_unit FLOAT,
		cogs FLOAT,
		total_sale FLOAT
);

SELECT * from retail_sales;

SELECT COUNT(*) FROM retail_sales ; 

/* DATA CLEANING */

-- Checking duplicate transactions

SELECT transactions_id, COUNT(*)
FROM retail_sales
GROUP BY transactions_id
HAVING COUNT(*) > 1;

-- Checking if there are any null values 

SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL OR
	sale_date IS NULL OR 
	sale_time IS NULL OR 
	customer_id IS NULL OR 
	gender IS NULL OR 
	category IS NULL OR 
	quantity IS NULL OR
	price_per_unit IS NULL OR 
	cogs IS NULL OR 
	total_sale IS NULL ;


-- Handled Null values in age column by imputing mean age

UPDATE retail_sales
SET age = (
			SELECT AVG(age) FROM retail_sales
)
WHERE age IS NULL;

-- 	Deleting Rows containing Null values 

DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL OR
	sale_date IS NULL OR 
	sale_time IS NULL OR 
	customer_id IS NULL OR 
	gender IS NULL OR 
	category IS NULL OR 
	quantity IS NULL OR
	price_per_unit IS NULL OR 
	cogs IS NULL OR 
	total_sale IS NULL ;

 



/* DATA EXPLORATION */

-- How many sales records we have ?

SELECT COUNT(*) FROM retail_sales;

-- How many unique customers we have ?

SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

-- How many unique categories we have ?

SELECT DISTINCT category FROM retail_sales;

/* Data Analysis & Key Business Problems With Solutions */

-- 1. Retrieve all columns for sale records on '2022-11-05'

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- 2. Retrive all transactions where category is 'Clothing' and quantity sold is more than 10 in the month of Nov-2022

SELECT *
FROM retail_sales
WHERE category = 'Clothing' AND 
	  TO_CHAR(sale_date,'YYYY-MM') = '2022-11' AND 
	  quantity >=4;

-- 3. Calculate total sales and total orders for each category

SELECT category, 
		SUM(total_sale) AS total_sales,
		COUNT(*) AS total_orders	
FROM retail_sales
GROUP BY category ;

-- 4. Find average age of customers who purchased items from the 'Beauty Category'

SELECT ROUND(AVG(age),0)
FROM retail_sales
WHERE category = 'Beauty';

-- 5. Retrieve all the transactions where total sale is greater than 1000

SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- 6. Total no. of transactions by each gender in each category 

SELECT category, gender, COUNT(*) as total_transactions
FROM retail_sales
GROUP BY category, gender 
ORDER BY category, gender;

-- 7. Calculate avg sale for each month. Find out the best selling_month in each year

SELECT year, month, avg_sales
FROM
(
SELECT 	EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		AVG(total_sale) AS avg_sales,
		RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY year, month
)
WHERE rnk = 1;

-- 8. Retrieve Top 5 Customers based on highest total sales

SELECT customer_id, SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC 
LIMIT 5;

-- 9. Find the no. of unique customers who purchased items from each category

SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY  category;

-- 10. Create each shift & no. of orders in each shift [Example : Morning <=12, Afternoon between 12 & 17, Evening > 17]

WITH hourly_sales
AS
(
SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS Shift
FROM retail_sales
)
SELECT Shift, COUNT(*) FROM hourly_sales
GROUP BY Shift;

-- 11. Calculate total revenue and profit for each category.

SELECT 	category, 
		SUM(total_sale) AS total_revenue, 
		SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;

-- 	12. Rank categories based on total revenue.

SELECT 	category,
		SUM(total_sale),
	   	RANK() OVER(ORDER BY SUM(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY category;

-- 	13. Find the highest selling category in each year.

SELECT * 
FROM
(
SELECT
	EXTRACT(YEAR FROM sale_date) AS year,
	category,
	SUM(total_sale),	
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY SUM(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY year, category
) t
WHERE rnk = 1;

-- 14. Find percentage contribution of each category to total revenue.

SELECT 	category,
		ROUND(
		(SUM(total_sale) * 100.0 / SUM(SUM(total_sale)) OVER()) :: NUMERIC,
		2
		) AS revenue_percentage
FROM retail_sales
GROUP BY category;

-- 15. Find the most profitable category.

SELECT category,
	   ROUND(SUM(total_sale - cogs):: NUMERIC ,2) AS total_profit
FROM retail_sales
GROUP BY category 
ORDER BY total_profit DESC
LIMIT 1;

-- 	16. Find total spending by each customer.

SELECT customer_id,
		SUM(total_sale) AS total_spending
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spending DESC;

-- 	17. Retrieve Top 5 customers based on total spending.

SELECT customer_id,
		SUM(total_sale) AS total_spending
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spending DESC 
LIMIT 5;

-- 18. Find how many customers are repeat customers and how many are one-time customers in the retail_sales table.

WITH customer_orders AS
(
SELECT customer_id,
	COUNT(*) AS order_count
FROM retail_sales
GROUP BY customer_id
)
SELECT 
	CASE
		WHEN order_count = 1 THEN 'One-Time Customer'
		ELSE 'Repeat Customer'
		END AS customer_type,
		COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_type;

-- 	19. Find average spending per gender.

SELECT 
	gender,
	ROUND(AVG(total_sale) :: NUMERIC,2) AS Avg_spending_per_gender
FROM retail_sales
GROUP BY gender;

-- 	20. Create age groups (18–25, 26–35, 36–50, 50+) and calculate total revenue per age group.

SELECT 
	CASE
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '50+'
		END AS age_group,
		SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY age_group
ORDER BY total_revenue DESC;

SELECT * FROM retail_sales;

-- 21. Calculate monthly revenue and find best selling month in each year.

SELECT *
FROM
(
SELECT
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	SUM(total_sale) AS total_revenue,
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY SUM(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY year, month
)t
WHERE rnk = 1;

-- 	22. Categorize each order into shifts:  Morning (≤12)  Afternoon (12–17)  Evening (>17).Then calculate total revenue 
-- per shift.

SELECT 
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
		END AS shift,
		SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY shift
ORDER BY total_revenue DESC;


