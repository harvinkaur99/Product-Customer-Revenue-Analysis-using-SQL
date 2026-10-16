-- 1. Identify data quality issues
SELECT 
  COUNT(CASE WHEN price IS NULL THEN 1 END) AS missing_prices,
  COUNT(CASE WHEN product_name IN (SELECT product_name FROM products GROUP BY product_name HAVING COUNT(*) > 1) THEN 1 END) AS duplicate_products,
  COUNT(CASE WHEN product_id NOT IN (SELECT DISTINCT product_id FROM orders WHERE product_id IS NOT NULL) THEN 1 END) AS unorderd_products
FROM products;



-- Customers with most orders
SELECT c.customer_name, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY order_count DESC
LIMIT 3;



-- Customers who spent most
SELECT c.customer_name, SUM(p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id
WHERE p.price IS NOT NULL
GROUP BY c.customer_name
ORDER BY total_spent DESC;



-- Products with least revenue
SELECT p.product_name, COALESCE(SUM(p.price), 0) AS revenue
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY revenue ASC;



-- Orders with invalid products
SELECT o.order_id, o.product_id
FROM orders o
LEFT JOIN products p ON o.product_id = p.product_id
WHERE p.product_id IS NULL OR o.product_id IS NULL;


-- Top 3 products by revenue
SELECT p.product_name, SUM(p.price) AS revenue
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 3;

-- Product categorization
SELECT product_name, price,
  CASE
    WHEN price < 1 THEN 'Cheap'
    WHEN price BETWEEN 1 AND 1.2 THEN 'Mid'
    ELSE 'Expensive'
  END AS price_category
FROM products;


SELECT
  CASE
    WHEN age < 25 THEN '<25'
    WHEN age BETWEEN 25 AND 40 THEN '25-40'
    ELSE '>40'
  END AS age_band,
  SUM(p.price) AS total_revenue
FROM (
  SELECT 
    c.customer_id,
    TIMESTAMPDIFF(YEAR, c.date_of_birth, CURDATE()) AS age
  FROM customers c
) AS customer_ages
JOIN orders o ON customer_ages.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id
WHERE p.price IS NOT NULL
GROUP BY age_band;
