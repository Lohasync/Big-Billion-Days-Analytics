-- q06: How many orders and how much money sit in each status?
SELECT status,
       COUNT(*) AS number_of_orders,
       SUM(amount) AS total_amount
FROM orders
GROUP BY status
ORDER BY COUNT(*) DESC;
