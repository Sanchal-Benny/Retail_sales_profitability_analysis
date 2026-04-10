USE superstore;
-- DATA UNDERSTANDING AND VALIDATION

--Checking sum of rows in the dataset
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT row_id) AS unique_row_ids
FROM superstore_full;

--Comparing total rows with distinct order IDs
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders
FROM superstore_full;

--Identifying sample orders with more than one line item
SELECT 
    order_id,
    COUNT(*) AS line_count
FROM superstore_full
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY line_count DESC
LIMIT 10;

--checking for missing values in key columns
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

--reviewing min and max values of key numeric fields
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

--checking for invalid ship dates
SELECT 
    COUNT(*) AS invalid_ship_records
FROM superstore_full
WHERE ship_date < order_date;

--Listing all unique category and sub category combinations
SELECT DISTINCT
    category,
    sub_category
FROM superstore_full
ORDER BY category, sub_category;

--KPI summary
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full;

--Yearly sales and profit performance
SELECT
    YEAR(order_date) AS order_year,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY YEAR(order_date)
ORDER BY order_year;

--Yearly sales and profit growth rates
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

--Category level performance
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

--Sub-category performance
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

-- Top ten products by sales
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

-- Top ten products by profit
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

-- Worst ten products by profit
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

-- Top ten products profit concentration
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


-- Top customers by sales
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

-- Top customers by profit
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

-- Top ten customers profit concentration
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

-- Customer segment performance
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


-- Regional performance
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

-- State level performance
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

-- Top states by profit
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

-- Worst states by profit
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


-- Performance by discount level
SELECT
    discount,
    COUNT(*) AS transaction_lines,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_percent
FROM superstore_full
GROUP BY discount
ORDER BY discount;

-- Category performance across discount levels
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

-- Sub category performance across discount levels
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

-- Average discount and profitability by state
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

-- Weakest category and state combinations
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


-- Monthly sales and profit trends
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

-- Best and worst performing months overall
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

-- Quarter wise performance
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

-- Revenue from repeat vs one time buyers
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

-- Top repeat customers by number of orders
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


-- High risk products with high discount and negative profit
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

-- Sub categories with highest return risk
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

-- States with highest concentration of return risk orders
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
