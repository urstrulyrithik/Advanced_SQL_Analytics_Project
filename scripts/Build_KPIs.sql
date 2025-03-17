/*
  Objectives:
  1. Retrieve and prepare sales and customer data by joining the fact_sales and dim_customers tables.
  2. Compute essential customer attributes such as age and full name.
  3. Aggregate customer-level metrics including total orders, total sales, total quantity, distinct products purchased, last order date, and customer lifespan.
  4. Segment customers into defined age groups.
  5. Classify customers into membership statuses (VIP, Regular, New) based on their lifespan and total sales.
  6. Calculate additional metrics such as recency (months since last order), average order value, and average monthly spend.
*/

CREATE VIEW gold.report_customers AS


WITH base_query AS (
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ' ,c.last_name) AS customer_name,
    DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
),

-- Aggregate customer-level metrics including total orders, total sales, total quantity, distinct products purchased, last order date, and customer lifespan.

customer_aggregation AS (
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    age
)

-- Segment customers into defined age groups.
-- Classify customers into membership statuses (VIP, Regular, New) based on their lifespan and total sales.
-- Calculate additional metrics such as recency (months since last order), average order value, and average monthly spend.

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
        WHEN age < 20 THEN 'Under 20'
         WHEN age BETWEEN 20 and 29 THEN '20-29'
         WHEN age BETWEEN 30 and 39 THEN '30-39'
         WHEN age BETWEEN 40 and 49 THEN '40-49'
         ELSE '50 and above'
    END AS age_group,   
    CASE 
        WHEN lifespan >= 12 and total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 and total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS membership_status,
    last_order,
    DATEDIFF(month, last_order, GETDATE()) AS recency,
    total_orders,
    total_sales,
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders 
    END AS avg_order_value,
    total_quantity,
    total_products,
    lifespan,
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation