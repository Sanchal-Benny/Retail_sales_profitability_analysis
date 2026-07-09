USE superstore;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT row_id) AS unique_row_ids
FROM superstore_full;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders
FROM superstore_full;

SELECT 
    order_id,
    COUNT(*) AS line_count
FROM superstore_full
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY line_count DESC
LIMIT 10;

SELECT
    SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) AS null_row_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS null_discount,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM superstore_full;
SELECT
    MIN(sales) AS min_sales,
    MAX(sales) AS max_sales,
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount,
    MIN(profit) AS min_profit,
    MAX(profit) AS max_profit
FROM superstore_full;
SELECT 
    COUNT(*) AS invalid_ship_records
FROM superstore_full
WHERE ship_date < order_date;

SELECT DISTINCT
    category,
    sub_category
FROM superstore_full
ORDER BY category, sub_category;

SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full;
SELECT
    YEAR(order_date) AS order_year,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY YEAR(order_date)
ORDER BY order_year;

WITH yearly_performance AS (
    SELECT
        YEAR(order_date) AS order_year,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM superstore_full
    GROUP BY YEAR(order_date)
)
SELECT
    order_year,
    total_sales,
    total_profit,
    ROUND(
        ((total_sales - LAG(total_sales) OVER (ORDER BY order_year)) 
        / LAG(total_sales) OVER (ORDER BY order_year)) * 100, 2
    ) AS sales_growth_percent,
    ROUND(
        ((total_profit - LAG(total_profit) OVER (ORDER BY order_year)) 
        / LAG(total_profit) OVER (ORDER BY order_year)) * 100, 2
    ) AS profit_growth_percent
FROM yearly_performance
ORDER BY order_year;
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY category
ORDER BY total_sales DESC;
SELECT
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY category, sub_category
ORDER BY total_sales DESC;

SELECT
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY product_name, category, sub_category
ORDER BY total_sales DESC
LIMIT 10;

SELECT
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY product_name, category, sub_category
ORDER BY total_profit DESC
LIMIT 10;

SELECT
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY product_name, category, sub_category
ORDER BY total_profit ASC
LIMIT 10;

WITH product_performance AS (
    SELECT
        product_name,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM superstore_full
    GROUP BY product_name
),
top_10_products AS (
    SELECT *
    FROM product_performance
    ORDER BY total_profit DESC
    LIMIT 10
)
SELECT
    ROUND(SUM(total_sales), 2) AS top_10_sales,
    ROUND(SUM(total_profit), 2) AS top_10_profit,
    ROUND((SUM(total_sales) / (SELECT SUM(sales) FROM superstore_full)) * 100, 2) AS top_10_sales_share_percent,
    ROUND((SUM(total_profit) / (SELECT SUM(profit) FROM superstore_full)) * 100, 2) AS top_10_profit_share_percent
FROM top_10_products;
SELECT
    customer_id,
    customer_name,
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY customer_id, customer_name, segment
ORDER BY total_sales DESC
LIMIT 10;
SELECT
    customer_id,
    customer_name,
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY customer_id, customer_name, segment
ORDER BY total_profit DESC
LIMIT 10;
WITH customer_performance AS (
    SELECT
        customer_id,
        customer_name,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM superstore_full
    GROUP BY customer_id, customer_name
),
top_10_customers AS (
    SELECT *
    FROM customer_performance
    ORDER BY total_profit DESC
    LIMIT 10
)
SELECT
    ROUND(SUM(total_sales), 2) AS top_10_sales,
    ROUND(SUM(total_profit), 2) AS top_10_profit,
    ROUND((SUM(total_sales) / (SELECT SUM(sales) FROM superstore_full)) * 100, 2) AS top_10_sales_share_percent,
    ROUND((SUM(total_profit) / (SELECT SUM(profit) FROM superstore_full)) * 100, 2) AS top_10_profit_share_percent
FROM top_10_customers;

SELECT
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY segment
ORDER BY total_sales DESC;
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY region
ORDER BY total_sales DESC;

SELECT
    state,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY state, region
ORDER BY total_sales DESC;

SELECT
    state,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY state, region
ORDER BY total_profit DESC
LIMIT 10;
SELECT
    state,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY state, region
ORDER BY total_profit ASC
LIMIT 10;

SELECT
    discount,
    COUNT(*) AS transaction_lines,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY discount
ORDER BY discount;

SELECT
    category,
    discount,
    COUNT(*) AS transaction_lines,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY category, discount
ORDER BY category, discount;

SELECT
    category,
    sub_category,
    discount,
    COUNT(*) AS transaction_lines,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY category, sub_category, discount
ORDER BY category, sub_category, discount;

SELECT
    state,
    region,
    ROUND(AVG(discount), 2) AS average_discount,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY state, region
ORDER BY total_profit ASC;
SELECT
    state,
    region,
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY state, region, category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 15;

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

SELECT
    order_month,
    ROUND(AVG(monthly_sales), 2) AS avg_monthly_sales,
    ROUND(AVG(monthly_profit), 2) AS avg_monthly_profit
FROM (
    SELECT
        MONTH(order_date) AS order_month,
        YEAR(order_date) AS order_year,
        SUM(sales) AS monthly_sales,
        SUM(profit) AS monthly_profit
    FROM superstore_full
    GROUP BY YEAR(order_date), MONTH(order_date)
) AS monthly_data
GROUP BY order_month
ORDER BY avg_monthly_sales DESC;

SELECT
    YEAR(order_date) AS order_year,
    QUARTER(order_date) AS order_quarter,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY YEAR(order_date), QUARTER(order_date)
ORDER BY order_year, order_quarter;

-- Repeat vs one time customers
SELECT
    order_frequency,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_frequency
    FROM superstore_full
    GROUP BY customer_id
) AS customer_orders
GROUP BY order_frequency
ORDER BY order_frequency;

SELECT
    CASE 
        WHEN order_count = 1 THEN 'One Time Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_type,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(SUM(total_profit), 2) AS total_profit,
    ROUND(AVG(total_sales), 2) AS avg_sales_per_customer
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count,
        SUM(sales) AS total_sales,
        SUM(profit) AS total_profit
    FROM superstore_full
    GROUP BY customer_id
) AS customer_summary
GROUP BY customer_type
ORDER BY total_sales DESC;
SELECT
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM superstore_full
GROUP BY customer_id, customer_name, segment
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY total_orders DESC
LIMIT 10;
SELECT
    product_name,
    category,
    sub_category,
    ROUND(AVG(discount), 2) AS avg_discount,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY product_name, category, sub_category
HAVING SUM(profit) < 0 AND AVG(discount) > 0.2
ORDER BY total_profit ASC
LIMIT 15;
SELECT
    category,
    sub_category,
    ROUND(AVG(discount), 2) AS avg_discount,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY category, sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;
SELECT
    state,
    region,
    category,
    ROUND(AVG(discount), 2) AS avg_discount,
    COUNT(DISTINCT order_id) AS risky_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM superstore_full
WHERE discount > 0.2 AND profit < 0
GROUP BY state, region, category
ORDER BY total_profit ASC
LIMIT 15;
WITH product_category_performance AS (
    SELECT
        category,
        product_name,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM superstore_full
    GROUP BY category, product_name
),
ranked_products AS (
    SELECT
        category,
        product_name,
        total_sales,
        total_profit,
        RANK() OVER (PARTITION BY category ORDER BY total_profit DESC) AS profit_rank
    FROM product_category_performance
)
SELECT *
FROM ranked_products
WHERE profit_rank <= 3
ORDER BY category, profit_rank;
WITH customer_segment_performance AS (
    SELECT
        segment,
        customer_id,
        customer_name,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM superstore_full
    GROUP BY segment, customer_id, customer_name
),
ranked_customers AS (
    SELECT
        segment,
        customer_id,
        customer_name,
        total_sales,
        total_profit,
        DENSE_RANK() OVER (PARTITION BY segment ORDER BY total_sales DESC) AS sales_rank
    FROM customer_segment_performance
)
SELECT *
FROM ranked_customers
WHERE sales_rank <= 5
ORDER BY segment, sales_rank;

WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        ROUND(SUM(sales), 2) AS monthly_total
    FROM superstore_full
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    order_year,
    order_month,
    monthly_total,
    ROUND(SUM(monthly_total) OVER (ORDER BY order_year, order_month), 2) AS running_total_sales
FROM monthly_sales
ORDER BY order_year, order_month;

WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        ROUND(SUM(sales), 2) AS monthly_total
    FROM superstore_full
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    order_year,
    order_month,
    monthly_total,
    LAG(monthly_total) OVER (ORDER BY order_year, order_month) AS prev_month_sales,
    ROUND(
        ((monthly_total - LAG(monthly_total) OVER (ORDER BY order_year, order_month))
        / LAG(monthly_total) OVER (ORDER BY order_year, order_month)) * 100, 2
    ) AS mom_growth_percent
FROM monthly_sales
ORDER BY order_year, order_month;
WITH customer_ltv AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM superstore_full
    GROUP BY customer_id, customer_name, segment
)
SELECT
    customer_id,
    customer_name,
    segment,
    total_sales,
    total_profit,
    NTILE(4) OVER (ORDER BY total_sales DESC) AS sales_quartile
FROM customer_ltv
ORDER BY total_sales DESC;

WITH product_performance AS (
    SELECT
        category,
        product_name,
        ROUND(SUM(sales), 2) AS total_sales
    FROM superstore_full
    GROUP BY category, product_name
)
SELECT
    category,
    product_name,
    total_sales,
    ROUND(AVG(total_sales) OVER (PARTITION BY category), 2) AS category_avg_sales,
    ROUND(total_sales - AVG(total_sales) OVER (PARTITION BY category), 2) AS diff_from_avg
FROM product_performance
ORDER BY category, diff_from_avg DESC;
CREATE OR REPLACE VIEW vw_kpi_summary AS
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full;
CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY category;




