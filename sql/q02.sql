-- q02: Which orders have a missing amount?
SELECT order_id, customer_id, item, status
FROM orders
WHERE amount IS NULL
ORDER BY order_id;
