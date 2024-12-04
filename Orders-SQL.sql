select * from df_orders;


-- find top 10 highest revenue generating products
SELECT top 10 product_ID, sum(sale_price) Top_revenues
from df_orders
GROUP BY product_ID
ORDER BY Top_revenues desc;


-- find top 5 highest selling products in each region
WITH RankedSales AS (
	SELECT 
		region, 
		product_ID, 
		SUM(sale_price) sales,
		ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS rank
	FROM 
		DF_ORDERS
	GROUP BY 
		region, product_ID
)
SELECT 
	region, product_ID, sales
FROM
	RankedSales
where rank <= 5
ORDER BY region, rank

-- full expression
WITH RankedSales2 AS (
	SELECT 
		region, 
		product_ID, 
		SUM(sale_price) sales
	FROM 
		DF_ORDERS
	GROUP BY 
		region, product_ID
)
SELECT * FROM (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rank
	FROM
		RankedSales2) as results
	where rank <= 5


-- find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
WITH cte AS (
	SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month,
	SUM(sale_price) AS sales
FROM
	df_orders
GROUP BY
	YEAR(order_date), MONTH(order_date)
	)
SELECT order_month,
	SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
	SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month

-- for each category, which month had the highest sales
WITH cte as (
SELECT  category, FORMAT(order_date,'yyyy-MM') AS order_month, SUM(sale_price) AS sales
FROM df_orders
GROUP BY category, FORMAT(order_date,'yyyy-MM')
--ORDER BY category, FORMAT(order_date,'yyyy-MM')
)
SELECT * FROM(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales desc) as rank
FROM cte
) a
WHERE rank = 1

-- which sub category had the highest growth by profit in 2023 compare to 2022
WITH cte  AS (
SELECT sub_category, YEAR(order_date) AS order_year, SUM(profit) AS Total_profit
FROM df_orders
GROUP BY sub_category, YEAR(order_date)
--ORDER BY sub_category, YEAR(order_date)
),
cte2 as (
SELECT sub_category,
	SUM(CASE WHEN order_year = 2022 THEN Total_profit ELSE 0 END) AS Year_2022,
	SUM(CASE WHEN order_year = 2023 THEN Total_profit ELSE 0 END) AS Year_2023
FROM
	cte
GROUP BY sub_category
)
SELECT top 10 *, ((Year_2023-Year_2022)/Year_2022)*100 as growth
FROM cte2
ORDER BY growth	desc

