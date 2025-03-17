/*
  Objectives:
  1. Create a view (gold.report_products) to report aggregated product performance.
  2. Retrieve and combine product and sales data by joining the fact_sales and dim_products tables.
  3. Filter out records with null order dates to ensure data quality.
  4. Calculate product-level metrics such as lifespan, last sale date, total orders, total customers, total sales, total quantity, and average selling price.
  5. Segment products into categories (High-Performer, Mid-Range, Low-Performer) based on total sales.
  6. Compute additional metrics including recency in months, average order revenue, and average monthly revenue.
*/

CREATE VIEW gold.report_products AS
WITH base_query AS(
SELECT
    f.order_number,
    f.order_date,
    f.customer_key, 
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE order_date IS NOT NULL
),

-- Calculate product-level metrics such as lifespan, last sale date, total orders, total customers, total sales, total quantity, and average selling price.

product_aggregations AS(
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) AS avg_selling_price
FROM base_query

GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)

-- Segment products into categories (High-Performer, Mid-Range, Low-Performer) based on total sales.
-- Compute additional metrics including recency in months, average order revenue, and average monthly revenue.

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM product_aggregations