-- d1: Which regions earned more than INR 80,000 in completed order revenue?
-- Aggregate by the customer's region; pending and disputed orders are excluded.
SELECT c.region AS region,
       SUM(o.amount) AS revenue
FROM orders o
JOIN customers c
  ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
GROUP BY c.region
HAVING SUM(o.amount) > 80000
ORDER BY SUM(o.amount) DESC, c.region ASC;
