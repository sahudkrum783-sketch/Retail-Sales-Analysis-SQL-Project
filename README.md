# Retail Sales Analysis – SQL Project

## Project Overview

**Project Title:** Retail Sales Analysis
**Level:** Beginner to Intermediate
**Database:** PostgreSQL
**Dataset:** Retail Sales Transactions

This project demonstrates SQL skills used by data analysts to explore, clean, and analyze retail sales data. The project includes database creation, data cleaning, exploratory data analysis (EDA), and solving business problems using SQL queries.

The goal is to generate meaningful insights such as customer behavior, category performance, revenue trends, and profitability.

This project is designed to showcase **SQL querying, analytical thinking, and business insight generation**.

---

# Objectives

The main objectives of this project are:

1. **Database Setup**

   * Create a structured database to store retail sales data.

2. **Data Cleaning**

   * Detect and handle missing values and duplicates.

3. **Exploratory Data Analysis (EDA)**

   * Understand dataset structure, customers, and product categories.

4. **Business Analysis**

   * Use SQL queries to solve real-world business problems.

---

# Database Setup

### Table Creation

```sql
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(50),
    age INT,
    category VARCHAR(50),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);
```

This table stores transactional retail sales data including:

* Transaction details
* Customer information
* Product category
* Sales revenue
* Cost of goods sold (COGS)

---

# Data Cleaning

Data cleaning ensures the dataset is reliable before performing analysis.

### Duplicate Check

```sql
SELECT transactions_id, COUNT(*)
FROM retail_sales
GROUP BY transactions_id
HAVING COUNT(*) > 1;
```

### Null Value Detection

```sql
SELECT *
FROM retail_sales
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
    total_sale IS NULL;
```

### Handling Missing Values

Age values were missing in some records. These were replaced using the **average age**.

```sql
UPDATE retail_sales
SET age = (
    SELECT AVG(age) FROM retail_sales
)
WHERE age IS NULL;
```

### Removing Invalid Records

```sql
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
    total_sale IS NULL;
```

---

# Exploratory Data Analysis (EDA)

### Total Sales Records

```sql
SELECT COUNT(*) FROM retail_sales;
```

### Unique Customers

```sql
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
```

### Product Categories

```sql
SELECT DISTINCT category FROM retail_sales;
```

---

# Data Analysis & Business Questions

### 1. Retrieve sales made on a specific date

```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

---

### 2. Clothing transactions with quantity ≥ 4 in November 2022

```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
AND TO_CHAR(sale_date,'YYYY-MM') = '2022-11'
AND quantity >= 4;
```

---

### 3. Total sales and total orders for each category

```sql
SELECT category,
       SUM(total_sale) AS total_sales,
       COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```

---

### 4. Average age of customers who bought Beauty products

```sql
SELECT ROUND(AVG(age),0)
FROM retail_sales
WHERE category = 'Beauty';
```

---

### 5. Transactions with sales greater than 1000

```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

---

### 6. Total transactions by gender in each category

```sql
SELECT category, gender, COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;
```

---

### 7. Best selling month in each year (based on average sales)

```sql
SELECT year, month, avg_sales
FROM
(
SELECT EXTRACT(YEAR FROM sale_date) AS year,
       EXTRACT(MONTH FROM sale_date) AS month,
       AVG(total_sale) AS avg_sales,
       RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date)
       ORDER BY AVG(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY year, month
)
WHERE rnk = 1;
```

---

### 8. Top 5 customers based on highest total sales

```sql
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

---

### 9. Unique customers per category

```sql
SELECT category,
       COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;
```

---

### 10. Orders by shift (Morning / Afternoon / Evening)

```sql
WITH hourly_sales AS
(
SELECT *,
CASE
WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
ELSE 'Evening'
END AS shift
FROM retail_sales
)
SELECT shift, COUNT(*)
FROM hourly_sales
GROUP BY shift;
```

---

# Advanced Business Insights

### Revenue & Profit by Category

```sql
SELECT category,
       SUM(total_sale) AS total_revenue,
       SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;
```

---

### Rank Categories by Revenue

```sql
SELECT category,
       SUM(total_sale),
       RANK() OVER(ORDER BY SUM(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY category;
```

---

### Highest Selling Category Each Year

```sql
SELECT *
FROM
(
SELECT EXTRACT(YEAR FROM sale_date) AS year,
       category,
       SUM(total_sale),
       RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date)
       ORDER BY SUM(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY year, category
) t
WHERE rnk = 1;
```

---

### Category Revenue Contribution

```sql
SELECT category,
ROUND(
(SUM(total_sale) * 100.0 /
SUM(SUM(total_sale)) OVER())::NUMERIC,
2
) AS revenue_percentage
FROM retail_sales
GROUP BY category;
```

---

### Most Profitable Category

```sql
SELECT category,
ROUND(SUM(total_sale - cogs)::NUMERIC,2) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC
LIMIT 1;
```

---

### Repeat vs One-Time Customers

```sql
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
```

---

### Average Spending by Gender

```sql
SELECT gender,
ROUND(AVG(total_sale)::NUMERIC,2) AS avg_spending
FROM retail_sales
GROUP BY gender;
```

---

### Revenue by Age Group

```sql
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
```

---

### Revenue by Sales Shift

```sql
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
```

---

# Key Findings

Some important insights discovered from the analysis:

* Certain **product categories generate higher revenue and profit**.
* **Top customers contribute a significant portion of total sales**.
* **Repeat customers form a valuable segment** of the business.
* Sales vary significantly across **time shifts (morning, afternoon, evening)**.
* Different **age groups contribute differently to total revenue**.
* Monthly analysis helps identify **peak sales periods**.

---

# Tools & Technologies Used

* **PostgreSQL**
* **SQL**
* **Data Cleaning**
* **Window Functions**
* **Common Table Expressions (CTEs)**
* **Aggregation Functions**

---

# Conclusion

This project demonstrates how SQL can be used to transform raw transactional data into actionable business insights. The analysis highlights key revenue drivers, customer segments, and sales patterns that can support business decision-making.

The project showcases important SQL concepts including:

* Data cleaning
* Aggregations
* Window functions
* Ranking
* Customer segmentation
* Business analytics

---

- LinkedIn: [https://www.linkedin.com/in/your-linkedin-username](https://www.linkedin.com/in/anushkasahu783/)
