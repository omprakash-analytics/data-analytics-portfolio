create database olist;
use olist;
SET autocommit = 0;
select count(*) from product_category_name_translation;
select count(*) from olist_customers_dataset;
SET autocommit = 1;

# KPI NO 1 Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
# for the number of value
    SELECT 
    CASE 
        WHEN DAYNAME(o.order_purchase_timestamp) IN ('Saturday', 'Sunday')
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    SUM(p.payment_value) AS total_payment,
    AVG(p.payment_value) AS avg_payment

FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id

GROUP BY day_type;

# for percentage
SELECT 
    CONCAT(
        ROUND(
            COUNT(CASE 
                WHEN DAYOFWEEK(order_purchase_timestamp) NOT IN (1,7) 
                THEN 1 
            END) * 100.0 / COUNT(*), 0
        ), '%'
    ) AS weekday_percent,

    CONCAT(
        ROUND(
            COUNT(CASE 
                WHEN DAYOFWEEK(order_purchase_timestamp) IN (1,7) 
                THEN 1 
            END) * 100.0 / COUNT(*), 0
        ), '%'
    ) AS weekend_percent

FROM olist_orders_dataset;

# KPI NO 2  Orders with review = 5 & credit card
SELECT 
    COUNT(DISTINCT o.order_id) AS q2_orders
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r 
    ON o.order_id = r.order_id
JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE r.review_score = 5
AND p.payment_type = 'credit_card';


#🐶 KPI NO 3 . Pet Shop Avg Delivery Days

SELECT 
    p.product_category_name,
    ROUND(
        AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 0
    ) AS avg_shipping_days

FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi 
    ON o.order_id = oi.order_id
JOIN olist_products_dataset p 
    ON oi.product_id = p.product_id

WHERE p.product_category_name = 'pet_shop'
AND o.order_delivered_customer_date IS NOT NULL

GROUP BY p.product_category_name;



# 🌆 ✅ KPI NO 4 São Paulo Avg Price & Payment
SELECT 
    AVG(oi.price) AS avg_price,
    AVG(p.payment_value) AS avg_payment
FROM olist_orders_dataset o
JOIN olist_customers_dataset c 
    ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset oi 
    ON o.order_id = oi.order_id
JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE c.customer_city = 'sao paulo';



# 📈 ✅ KPI NO 5 . RELATIONSHIP 	Shipping Days vs Review Score
SELECT 
    r.review_score,
    COUNT(*) AS total_orders,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) 
        AS avg_shipping_days
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r 
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;

# other kpi 
# 📊 ✅ 6) Total Sales, Profit, Sellers
SELECT 
CONCAT('₹ ',ROUND(SUM(p.payment_value),0)) AS total_sales,
CONCAT('₹ ',ROUND(SUM(oi.price) - SUM(oi.freight_value),0)) AS total_profit,
COUNT(DISTINCT oi.seller_id) AS total_sellers

FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
JOIN olist_order_items_dataset oi 
    ON o.order_id = oi.order_id;

# ❌ ✅ 7. Late Delivery %
SELECT 
    COUNT(CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date 
        THEN 1 END) * 100.0 / COUNT(*) AS late_delivery_percentage
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL;

# TOTAL CUSTOMER
SELECT 
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset;