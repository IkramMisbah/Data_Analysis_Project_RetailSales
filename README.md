# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis    
**Database**: `p1_retail_db`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `p1_retail_db`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE p1_retail_db;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.
- **Detection of outliers**: (It is based on a common rule in statistics: any data point that is more than 3 standard deviations above or below the mean is often considered an outlier.)
```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

SELECT *
FROM retail_sales
WHERE total_sale > (SELECT AVG(total_sale)+3*STDDEV(total_sale) FROM retail_sales) 
	  OR total_sale < (SELECT AVG(total_sale) - 3 * STDDEV(total_sale) FROM retail_sales)
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift
```

## Findings
Insight 1: Total number of unique customers

Analysis: The total number of unique customers was extracted to measure the customer base size.
Business Impact: This helps evaluate market reach and customer engagement. Based on this, the company can decide whether to launch customer loyalty programs or focus on acquiring new customers.
Insight 2: Sales on November 5, 2022

Analysis: Transactions for a specific day were analyzed to gain a detailed understanding of daily sales.
Business Impact: By analyzing specific daily data, the company can detect seasonal fluctuations or the impact of flash promotions and adjust future sales strategies accordingly.
Insight 3: Clothing transactions with more than 4 units sold in November 2022

Analysis: High-quantity clothing sales were identified for deeper analysis.
Business Impact: Identifying popular clothing items enables the company to target promotions or adjust inventory to maximize sales in that category.
Insight 4: Total sales by category

Analysis: Total sales and the number of orders were analyzed for each product category.
Business Impact: The company can prioritize top-performing product categories (e.g., "Electronics" and "Clothing") to optimize marketing campaigns and inventory management.
Insight 5: Average age of customers in the "Beauty" category

Analysis: The average age of customers purchasing from a specific category was studied to understand the demographic profile.
Business Impact: The company can tailor its communication and advertising strategies to better engage this age group or adjust offers to attract a different demographic.
Insight 6: Transactions with more than 1000 units sold

Analysis: Large transactions were identified to understand the distribution of high-scale sales.
Business Impact: By focusing on high-value sales, the company can develop strategies like VIP programs or bulk purchase discounts to encourage more large-scale transactions.
Insight 7: Transactions by gender and category

Analysis: The distribution of transactions by customer gender was analyzed for each product category.
Business Impact: This information allows the company to fine-tune its marketing campaigns by targeting popular products for each gender, maximizing the impact of promotions.
Insight 8: Best sales month

Analysis: The months with the highest average sales performance were identified.
Business Impact: Knowing peak months allows the company to plan seasonal promotions or increase inventory to meet high demand periods.
Insight 9: Top 5 customers with the highest sales

Analysis: The most profitable customers, generating the highest sales, were identified.
Business Impact: Focusing on these customers allows the company to offer exclusive benefits or loyalty programs, encouraging them to maintain their high purchase levels.
Insight 10: Number of unique customers by category

Analysis: The popularity of different categories in terms of customer diversity was measured.
Business Impact: This allows the company to adjust its strategy based on the customer diversity for each category, focusing efforts on categories that attract a broad audience.
Insight 11: Sales distribution by time of day

Analysis: The distribution of sales by time shows a majority of purchases occurring in the evening.
Business Impact: The company can allocate more resources (staff, promotions) during peak times to maximize sales during those periods.
- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Recommendations:

Sales Optimization: Leverage the insights to adjust the sales strategy, such as focusing on the most profitable products and peak sales periods.

Next Steps: Propose actions based on these insights, like adjusting inventory for popular products, offering personalized deals for top customers, or running promotions during peak hours to maximize sales.

## Reports


-**Sales Summary Report**:

    Objective: Summarize key sales metrics, including total sales per category, customer demographics (age, gender), and overall performance.
    What to Include:
    Total sales by product category.
    Breakdown of sales by customer gender and age group.
    Insights on which categories perform best.
-**Trend Analysis Report**:

    Objective: Provide a detailed analysis of sales trends over time.
    What to Include:
    Monthly and daily sales trends.
    Peak sales shifts (morning, afternoon, evening).
    Best-selling months, product categories, and their patterns.
-**Customer Insights Report**:

Objective: Focus on customer behavior and profiles.
    What to Include:
    List of top 5 customers by total sales.
    Count of unique customers per category.
Insights on customer preferences and how they correlate with sales performance (age, category preferences, etc.).
## How to Build These Reports:
Tools: Use Power BI or any other reporting tool to create interactive dashboards. You can visualize the data through bar charts, line graphs, and pie charts to make trends and customer insights clearer.
Data: Extract the relevant data from your SQL queries (e.g., customer count, sales totals, category breakdown) and integrate them into your reports.
Presentation: Make the reports user-friendly and ensure key insights are easily accessible for stakeholders to make quick decisions.
                
## Conclusion

This project serves as a comprehensive  to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `analysis_queries.sql` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Misbah Ikram

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media and join our community:

- **LinkedIn**: [Connect with me professionally](www.linkedin.com/in/ikram-misbah-348314232)

Thank you for your support, and I look forward to connecting with you!
