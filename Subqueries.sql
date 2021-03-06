#Find the AVG event for each channel

SELECT AVG(event_count) as avg_event, channel
FROM
	(SELECT COUNT(*) as event_count, DATE_TRUNC('day', occurred_at) as day, channel
	FROM web_events
	GROUP BY 2, 3) sub
GROUP BY 2
ORDER BY 1;

#Find orders that took place in the same month as the first order. Pull the average for each type of papers that month.

SELECT AVG(standard_qty) avg_qty, AVG(gloss_qty) avg_gloss, AVG(poster_qty) avg_poster
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
	(SELECT DATE_TRUNC('month', MIN(occurred_at)) min_month
	FROM orders)

#Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

SELECT MAX(total_sales), region_name
FROM (SELECT r.name region_name, s.name sales_rep_name, SUM(o.total_amt_usd) total_sales
	FROM orders o 
	JOIN accounts a
		ON o.account_id = a.id
	JOIN sales_reps s
		ON a.sales_rep_id = s.id
	JOIN region r
		ON s.region_id = r.id
	GROUP BY 1, 2) sub
GROUP BY 2
ORDER BY 1 DESC;

#For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
SELECT COUNT(o.total) total_order, r.name
FROM sales_reps s
	JOIN accounts a
		ON a.sales_rep_id = s.id
	JOIN orders o
		ON o.account_id = a.id
	JOIN region r
		ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(total_amt_usd) = (
	SELECT MAX(total_sales)
	FROM (SELECT r.name region_name, 					SUM(o.total_amt_usd) total_sales
		    FROM orders o 
		    JOIN accounts a
		    ON o.account_id = a.id
		    JOIN sales_reps s
		    ON a.sales_rep_id = s.id
		    JOIN region r
		    ON s.region_id = r.id
		    GROUP BY 1) sub);

#For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

SELECT a.name, w.channel, COUNT(*) web_count
FROM accounts a
JOIN web_events w
ON w.account_id = a.id AND a.id = (SELECT id
                                   FROM(
                                        SELECT SUM(o.total_amt_usd) total_usd, a.name, a.id
                                        FROM accounts a
                                        JOIN orders o
                                        ON o.account_id = a.id
                                        GROUP BY 2, 3
                                        ORDER BY 1 DESC
                                        LIMIT 1)sub)
GROUP BY 1,2
ORDER BY 3;

#What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

SELECT AVG(total)
FROM (
      SELECT a.name, SUM(o.total_amt_usd) total
      FROM accounts a
      JOIN orders o
      ON o.account_id = a.id
      GROUP BY 1
      ORDER BY 2 DESC
      LIMIT 10)sub;

#What is the lifetime average amount spent in terms of total_amt_usd for only the companies that spent more than the average of all orders.

SELECT AVG(avg_af)
FROM(
	SELECT o.account_id, AVG(o.total_amt_usd) avg_af
	FROM orders o
	GROUP BY 1
	HAVING AVG(o.total_amt_usd) > 			
		(SELECT AVG(o.total_amt_usd) avg_total
		FROM accounts a

#Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales

WITH t1 AS (
		SELECT s.name sales_rep_name, r.name region_name, SUM(o.total_amt_usd) total_sales
		FROM orders o
			JOIN accounts a
			ON o.account_id = a.id
			JOIN sales_reps s
			ON a.sales_rep_id = s.id
			JOIN region r
			ON s.region_id = r.id
		GROUP BY 1, 2
ORDER BY 3 DESC),

t2 AS (
SELECT MAX(total_sales) total_sales, region_name
FROM t1
GROUP BY 2)

SELECT t1.sales_rep_name, t1.region_name, t1.total_sales
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_sales = t2.total_sales

#For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?

WITH t1 AS (

		SELECT SUM(o.total_amt_usd) total_s, a.name, a.id
		FROM orders o
			JOIN accounts a
			ON o.account_id = a.id
		GROUP BY 2, 3
		ORDER BY 1 DESC
LIMIT 1)

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id = (SELECT id FROM t1)
GROUP BY 1,2
ORDER BY 3 DESC;
