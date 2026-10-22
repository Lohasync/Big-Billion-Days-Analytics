-- q12: Which contribution tier does each product fall into?
SELECT item,
       SUM(amount) AS total_revenue,
       CASE
         WHEN SUM(amount) >= 60000 THEN 'High'
         WHEN SUM(amount) >= 15000 THEN 'Medium'
         ELSE 'Low'
       END AS contribution_tier
FROM orders
WHERE status = 'completed'
GROUP BY item
ORDER BY SUM(amount) DESC;
