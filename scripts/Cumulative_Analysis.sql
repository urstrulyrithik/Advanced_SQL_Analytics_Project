-- Calculate the total sales per month
-- and the running total of sales over time


SELECT

order_date, total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date) as moving_average_price
FROM
(
SELECT
CAST(DATEADD(year, DATEDIFF(year, 0, order_date), 0) AS date) as order_date,
SUM(sales_amount) as total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY CAST(DATEADD(year, DATEDIFF(year, 0, order_date), 0) AS date)
) as t



