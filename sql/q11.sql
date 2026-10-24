-- q11: Completed revenue by customer region and month.
-- INNER JOIN is appropriate because only orders with matching customers are needed
-- (the seed has a customer for every order); DISTINCT avoids counting a customer
-- multiple times if that customer places multiple orders in the same month.
SELECT c.region,
       o.order_month,
       COUNT(*) AS number_of_orders,
       COUNT(DISTINCT o.customer_id) AS number_of_customers,
       SUM(o.amount) AS total_revenue,
       AVG(o.amount) AS average_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY c.region, o.order_month
ORDER BY c.region, o.order_month;
