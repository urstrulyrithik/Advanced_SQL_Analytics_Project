-- CHANGE OVER TIME

--Month Wise Aggregation of total sales using YEAR and MONTH functions

SELECT
YEAR(order_date) as order_year,
MONTH(order_date) as order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

--Month Wise Aggregation of total sales using DATEADD and DATEDIFF functions

SELECT
    DATEADD(month, DATEDIFF(month, 0, order_date), 0) as order_date,
    SUM(sales_amount) as total_sales,
    COUNT(DISTINCT customer_key) as total_customers,
    SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEADD(month, DATEDIFF(month, 0, order_date), 0)
ORDER BY DATEADD(month, DATEDIFF(month, 0, order_date), 0);

--Month Wise Aggregation of total sales using FORMAT function

SELECT
FORMAT(order_date, 'yyyy-MMM') as order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')
