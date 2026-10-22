-- q08: What does the customer base look like in each region?
SELECT region,
       COUNT(*) AS number_of_customers,
       AVG(age) AS average_age,
       MIN(age) AS min_age,
       MAX(age) AS max_age
FROM customers
GROUP BY region
ORDER BY region;
