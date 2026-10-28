
USE ecommerce_analysis;

-- 1. Check total records in both tables
SELECT 'orders_clean' AS table_name, COUNT(*) AS total_rows
FROM orders_clean
UNION ALL
SELECT 'customers_clean', COUNT(*)
FROM customers_clean;


-- 2. Preview order data
SELECT *
FROM orders_clean
LIMIT 5;


-- 3. Preview customer data
SELECT *
FROM customers_clean
LIMIT 5;


-- 4. Calculate total revenue and average order value
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(net_amount), 2) AS total_revenue,
    ROUND(AVG(net_amount), 2) AS avg_order_value
FROM orders_clean
WHERE order_status = 'Delivered';


-- 5. Analyze monthly sales trends
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(net_amount), 2) AS revenue
FROM orders_clean
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;


-- 6. Compare revenue across product categories
SELECT
    category,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(net_amount), 2) AS revenue,
    ROUND(AVG(net_amount), 2) AS avg_order_value
FROM orders_clean
WHERE order_status = 'Delivered'
GROUP BY category
ORDER BY revenue DESC;


-- 7. Find the top 10 cities by revenue
SELECT
    c.city,
    c.city_tier,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.net_amount), 2) AS revenue
FROM orders_clean o
JOIN customers_clean c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city, c.city_tier
ORDER BY revenue DESC
LIMIT 10;


-- 8. Compare sales across city tiers
SELECT
    c.city_tier,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.net_amount), 2) AS revenue,
    ROUND(AVG(o.net_amount), 2) AS avg_order_value
FROM orders_clean o
JOIN customers_clean c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city_tier
ORDER BY revenue DESC;


-- 9. Analyze payment method usage
SELECT
    payment_method,
    COUNT(order_id) AS total_orders,
    ROUND(
        100.0 * COUNT(order_id) /
        (SELECT COUNT(*) FROM orders_clean),
        2
    ) AS percentage
FROM orders_clean
GROUP BY payment_method
ORDER BY total_orders DESC;


-- 10. Analyze order status distribution
SELECT
    order_status,
    COUNT(order_id) AS total_orders,
    ROUND(
        100.0 * COUNT(order_id) /
        (SELECT COUNT(*) FROM orders_clean),
        2
    ) AS percentage
FROM orders_clean
GROUP BY order_status
ORDER BY total_orders DESC;


-- 11. Calculate return rate by category
SELECT
    category,
    SUM(
        CASE WHEN order_status = 'Returned'
             THEN 1 ELSE 0 END
    ) AS returned_orders,
    COUNT(order_id) AS total_orders,
    ROUND(
        100.0 * SUM(
            CASE WHEN order_status = 'Returned'
                 THEN 1 ELSE 0 END
        ) / NULLIF(COUNT(order_id), 0),
        2
    ) AS return_rate_pct
FROM orders_clean
GROUP BY category
ORDER BY return_rate_pct DESC;


-- 12. Find the top 10 products by revenue
SELECT
    product_name,
    category,
    COUNT(order_id) AS times_ordered,
    SUM(quantity) AS total_units,
    ROUND(SUM(net_amount), 2) AS revenue
FROM orders_clean
WHERE order_status = 'Delivered'
GROUP BY product_name, category
ORDER BY revenue DESC
LIMIT 10;


-- 13. Analyze customer order frequency
SELECT
    order_count,
    COUNT(*) AS num_customers
FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders_clean
    GROUP BY customer_id
) AS t
GROUP BY order_count
ORDER BY order_count;


-- 14. Calculate customer RFM metrics
SELECT
    customer_id,
    DATEDIFF(
        (SELECT DATE_ADD(MAX(order_date), INTERVAL 1 DAY)
         FROM orders_clean),
        MAX(order_date)
    ) AS recency_days,
    COUNT(order_id) AS frequency,
    ROUND(SUM(net_amount), 2) AS monetary
FROM orders_clean
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY monetary DESC;


-- 15. Compare spending by gender
SELECT
    c.gender,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.net_amount), 2) AS revenue,
    ROUND(AVG(o.net_amount), 2) AS avg_order_value
FROM orders_clean o
JOIN customers_clean c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.gender
ORDER BY revenue DESC;


-- 16. Analyze sales by day of the week
SELECT
    DAYNAME(order_date) AS day_of_week,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(net_amount), 2) AS revenue
FROM orders_clean
WHERE order_status = 'Delivered'
GROUP BY DAYOFWEEK(order_date), DAYNAME(order_date)
ORDER BY total_orders DESC;
