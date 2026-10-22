-- q01: Which orders are still pending?
SELECT order_id, customer_id, item, amount
FROM orders
WHERE status = 'pending'
ORDER BY order_id ASC;
