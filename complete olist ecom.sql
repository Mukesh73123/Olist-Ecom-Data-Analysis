CREATE DATABASE olist_project;


USE olist_project;


select * from olist_final_master_data;


USE olist_project;
SHOW TABLES;


/* ===============================
Basic Verification (Checking if data is correct)
===============================
*/



-- 1. How many orders are there in total?
SELECT 
    COUNT(*)
FROM
    olist_final_master_data;



-- 3. Check how many unique states are there
SELECT 
    COUNT(DISTINCT customer_state)
FROM
    olist_final_master_data;




/*
KPIs
*/

-- Goal: To determine the total revenue and average order value of the business.

SELECT 
    ROUND(SUM(payment_value), 2) AS Total_Revenue,
    ROUND(AVG(payment_value), 2) AS Avg_Order_Value,
    COUNT(DISTINCT order_id) AS Total_Orders
FROM olist_final_master_data;






-- How many customers are there in every state?

SELECT customer_state, COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_final_master_data
GROUP BY customer_state
ORDER BY total_customers DESC;



-- Distribution of payment methods

SELECT payment_type, COUNT(*) AS count
FROM olist_final_master_data
GROUP BY payment_type;



-- Top 5 Product Categories:

SELECT 
    product_category_name_english, SUM(payment_value) AS revenue
FROM
    olist_final_master_data
WHERE
    product_category_name_english IS NOT NULL
GROUP BY product_category_name_english
ORDER BY revenue DESC
LIMIT 5;






-- Late Delivery Analysis:

SELECT 
    is_late, COUNT(*) AS total_count
FROM
    olist_final_master_data
GROUP BY is_late;





-- Monthly Sales Trend:

SELECT 
    is_late, COUNT(*) AS total_count
FROM
    olist_final_master_data
GROUP BY is_late;




/* ===============================
Intermediate se Advanced Level
===============================
*/


/*
 Delivery Performance (Logistics Analysis)
*/

-- Difference of Average Delivery Time (Days) and Estimated vs Actual
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date,
            order_purchase_timestamp)) AS Avg_Delivery_Days,
    AVG(DATEDIFF(order_estimated_delivery_date,
            order_delivered_customer_date)) AS Avg_Early_Delivery_Days
FROM
    olist_final_master_data
WHERE
    order_status = 'delivered';







-- Customer Behavior (City-wise Analysis)


SELECT 
    customer_city, 
    COUNT(order_id) AS total_orders,
    SUM(payment_value) AS total_revenue
FROM olist_final_master_data
GROUP BY customer_city
ORDER BY total_revenue DESC
LIMIT 10;






-- Payment Insights (Installments)

SELECT 
    payment_installments,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_value
FROM
    olist_final_master_data
GROUP BY payment_installments
ORDER BY payment_installments;





-- Sales by Day of the Week

SELECT 
    order_day, COUNT(order_id) AS total_orders
FROM
    olist_final_master_data
GROUP BY order_day
ORDER BY total_orders DESC;






-- Product Logistics (Weight vs Freight)

SELECT 
    CASE
        WHEN product_weight_g < 500 THEN 'Very Light (<500g)'
        WHEN product_weight_g BETWEEN 500 AND 2000 THEN 'Light (500g-2kg)'
        WHEN product_weight_g BETWEEN 2000 AND 5000 THEN 'Medium (2kg-5kg)'
        ELSE 'Heavy (>5kg)'
    END AS weight_category,
    ROUND(AVG(freight_value), 2) AS avg_shipping_cost
FROM
    olist_final_master_data
GROUP BY weight_category
ORDER BY avg_shipping_cost;







/* ===============================
Advanced SQL Queries
===============================
*/




-- Month-over-Month (MoM) Revenue Growth


WITH monthly_sales AS (
    SELECT 
        order_month_year, 
        SUM(payment_value) AS revenue
    FROM olist_final_master_data
    GROUP BY order_month_year
)
SELECT 
    order_month_year, 
    revenue,
    LAG(revenue) OVER (ORDER BY order_month_year) AS previous_month_revenue,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY order_month_year)) / LAG(revenue) OVER (ORDER BY order_month_year)) * 100, 2) AS growth_percentage
FROM monthly_sales;






-- Customer Retention (Repeat Customers)

SELECT 
    customer_unique_id, COUNT(order_id) AS total_orders
FROM
    olist_final_master_data
GROUP BY customer_unique_id
HAVING total_orders > 1
ORDER BY total_orders DESC;





-- Running Total of Sales (Cumulative Revenue)

SELECT 
    order_purchase_timestamp,
    payment_value,
    SUM(payment_value) OVER (ORDER BY order_purchase_timestamp) AS cumulative_revenue
FROM olist_final_master_data;




-- Top 3 Selling Products in Each Category

WITH product_ranks AS (
    SELECT 
        product_category_name_english,
        product_id,
        COUNT(order_id) AS units_sold,
        DENSE_RANK() OVER (PARTITION BY product_category_name_english ORDER BY COUNT(order_id) DESC) AS rank_in_category
    FROM olist_final_master_data
    WHERE product_category_name_english IS NOT NULL
    GROUP BY product_category_name_english, product_id
)
SELECT * FROM product_ranks WHERE rank_in_category <= 3;




-- Seller Performance Scorecard

SELECT 
    seller_id, 
    COUNT(order_id) AS total_orders,
    SUM(payment_value) AS total_revenue,
    SUM(CASE WHEN is_late = 'True' THEN 1 ELSE 0 END) AS late_deliveries
FROM olist_final_master_data
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;

