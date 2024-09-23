--CREATE TABLE
CREATE TABLE retail_sales
	      (
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id INT,
				gender VARCHAR(15),
				age INT,
				category VARCHAR(15),
				quantiy INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
)

SELECT * FROM retail_sales
LIMIT 10;


DESCRIBE retail_sales
--DATA EXPLORATION AND CLEANING
--Verification des données manquante
--Vérifier si certaines colonnes contiennent des valeurs nulles :
SELECT COUNT(*) AS total_rows, 
		SUM(CASE WHEN transactions_id IS NULL THEN 1 ELSE 0 END  ) AS transactions_id_missing,
		SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) AS sale_date_missing,
  		SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_missing,
  		SUM(CASE WHEN total_sale IS NULL THEN 1 ELSE 0 END) AS total_sale_missing
FROM retail_sales

--détection des outliers (Elle le fait en se basant sur une règle courante en statistiques : tout point de données qui est à plus de 3 écart-types (standard deviations) au-dessus ou en dessous de la moyenne est souvent considéré comme un outlier.)
SELECT *
FROM retail_sales
WHERE total_sale > (SELECT AVG(total_sale)+3*STDDEV(total_sale) FROM retail_sales) 
	  OR total_sale < (SELECT AVG(total_sale) - 3 * STDDEV(total_sale) FROM retail_sales)
--Cette requête sélectionne toutes les transactions de vente où la valeur totale (total_sale) est significativement plus élevée ou plus basse que la moyenne (à plus de 3 écart-types). Ces transactions peuvent représenter des valeurs aberrantes ou des anomalies.

--Si tu vois des résultats, il est probable que ce soit des ventes très atypiques (par exemple, des ventes exceptionnellement grandes ou petites).

--REWARD COUNT:
SELECT COUNT(*) FROM retail_sales

--Custumer count:Find out how many unique custumer are in the dataset
SELECT count(DISTINCT customer_id) FROM retail_sales

--Category count : identify all unique product in the dataset 
SELECT DISTINCT CATEGORY FROM retail_sales

--Null value check : check for any null value in the dataset and delete record with missing data
-- here we don't have any info to replace null values so we will gonna delete it
SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
 WHERE 
 sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
 gender IS NULL OR age IS NULL OR category IS NULL OR 
 quantiy IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

--DATA ANALYSIS AND BUSINESS KEY PROBLEMS :


--Q1 A queury to receive all columns for sales mas on '2022-11-05'
SELECT * FROM retail_sales
WHERE sale_date= '2022-11-05'


--Q2  Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
SELECT * FROM retail_sales
WHERE category='Clothing' AND quantiy>=4 AND sale_date  BETWEEN '2022-11-01' and '2022-11-30'
  --or:
SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantiy >= 4

--Q3 Write a SQL query to calculate the total sales (total_sale) for each category.:
SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1

--Q4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
SELECT AVG(age)::INT AS avg_Customer_age FROM retail_sales
WHERE category='Beauty'

--Q5:Write a SQL query to find all transactions where the total_sale is greater than 1000.:
SELECT * FROM retail_sales
where total_sale >= 1000


--Q6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
SELECT category, gender ,count(transactions_id) 
FROM retail_sales
GROUP BY category, gender
ORDER BY category


--Q7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
--average sale for each month
SELECT year_sale,month_sale, total_sale_avg 
FROM
(SELECT EXTRACT(YEAR FROM sale_date) AS year_sale, EXTRACT(MONTH FROM sale_date) AS month_SALE, AVG(total_sale) AS total_sale_avg , rank() over(Partition by EXTRACT(YEAR FROM sale_date) Order by AVG(total_sale) desc) as ranks
FROM retail_sales
GROUP BY year_sale,month_SALE
ORDER BY year_sale,month_SALE) tmp
where tmp.ranks=1



--Q8:**Write a SQL query to find the top 5 customers based on the highest total sales **:
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5

--Q9 Write a SQL query to find the number of unique customers who purchased items from each category.:
SELECT category, count(DISTINCT customer_id)
from retail_sales
GROUP BY category


--Q10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
WITH hourly_sale --CTE : table temporaire
AS
(SELECT * , 
	CASE WHEN EXTRACT (HOUR FROM sale_time) <12 THEN 'Morning'
    WHEN EXTRACT (HOUR FROM sale_time) Between 12 and 17 THEN 'Afternoon'
    WHEN EXTRACT (HOUR FROM sale_time) >17 THEN 'Evening'
	END AS shift
FROM retail_sales) 
SELECT shift , count(*) as total_order
FROM hourly_sale
GROUP BY shift
--OU:
SELECT shift, count(*)
FROM  
(SELECT * , 
	CASE WHEN EXTRACT (HOUR FROM sale_time) <12 THEN 'Morning'
    WHEN EXTRACT (HOUR FROM sale_time) Between 12 and 17 THEN 'Afternoon'
    WHEN EXTRACT (HOUR FROM sale_time) >17 THEN 'Evening'
	END AS shift
FROM retail_sales) 
GROUP BY shift