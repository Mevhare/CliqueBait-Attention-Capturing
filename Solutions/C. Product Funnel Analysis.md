#  Case Study #6 - Clique Bait

## Solution 
### C. Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:
- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

```sql
-- First, drop the existing table if it exists
DROP TABLE IF EXISTS clique_bait.product_performance_report;

-- Then, create the new table
CREATE TABLE clique_bait.product_performance_report (
  product VARCHAR(14),
  page_view INT,
  cart_adds INT,
  abandoned INT,
  purchases INT
);
INSERT INTO clique_bait.product_performance_report (product, page_view, cart_adds, abandoned, purchases)

WITH purchase_visit_id AS (
SELECT DISTINCT(visit_id)
FROM clique_bait.events
WHERE event_type = 3
),
view_cart AS (
SELECT a.visit_id,
		b.page_name, 
		SUM(CASE WHEN a.event_type = 1 THEN 1 ELSE 0 END) AS page_view,
		SUM(CASE WHEN a.event_type = 2 THEN 1 ELSE 0 END) AS add_to_cart
FROM clique_bait.events AS a
JOIN clique_bait.page_hierarchy AS b
USING (page_id)
WHERE b.product_id IS NOT NULL
GROUP BY a.visit_id, b.page_name
),
product_performance AS (
SELECT  visit_id, 
		page_name, 
		page_view, 
		add_to_cart, 
		CASE WHEN pv.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
FROM view_cart AS vc
LEFT JOIN purchase_visit_id AS pv
USING (visit_id)
)
SELECT  page_name AS product, 
		SUM(page_view) AS page_view,
		SUM(add_to_cart) AS cart_adds,
		SUM(CASE WHEN add_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
		SUM(CASE WHEN add_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM product_performance
GROUP BY page_name
ORDER BY product;
```
![]()



Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
```sql
-- First, drop the existing table if it exists
DROP TABLE IF EXISTS clique_bait.product_category_performance_report;

-- Then, create the new table
CREATE TABLE clique_bait.product_category_performance_report (
  product_category VARCHAR(9),
  page_view INT,
  cart_adds INT,
  abandoned INT,
  purchases INT
);
INSERT INTO clique_bait.product_category_performance_report (product_category, page_view, cart_adds, abandoned, purchases)

WITH purchase_visit_id AS (
SELECT DISTINCT(visit_id)
FROM clique_bait.events
WHERE event_type = 3
),
view_cart AS (
SELECT a.visit_id,
		b.page_name,
		b.product_category, 
		SUM(CASE WHEN a.event_type = 1 THEN 1 ELSE 0 END) AS page_view,
		SUM(CASE WHEN a.event_type = 2 THEN 1 ELSE 0 END) AS add_to_cart
FROM clique_bait.events AS a
JOIN clique_bait.page_hierarchy AS b
USING (page_id)
WHERE b.product_id IS NOT NULL
GROUP BY a.visit_id, b.page_name, b.product_category
),
product_performance AS (
SELECT  visit_id, 
		page_name,
		product_category, 
		page_view, 
		add_to_cart, 
		CASE WHEN pv.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
FROM view_cart AS vc
LEFT JOIN purchase_visit_id AS pv
USING (visit_id)
)
SELECT  product_category, 
		SUM(page_view) AS page_view,
		SUM(add_to_cart) AS cart_adds,
		SUM(CASE WHEN add_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
		SUM(CASE WHEN add_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM product_performance
GROUP BY product_category
ORDER BY product_category;
```

Use your 2 new output tables - answer the following questions:

- Which product had the most views, cart adds and purchases?

```sql
SELECT product, page_view, cart_adds, purchases
FROM clique_bait.product_performance_report	
ORDER BY page_view DESC
LIMIT 1;
```
Oyster has the most views.

```sql
SELECT product, page_view, cart_adds, purchases
FROM clique_bait.product_performance_report	
ORDER BY cart_adds DESC
LIMIT 1;
```
Lobster has the most cart adds and purchases.
	


- Which product was most likely to be abandoned?

```sql
SELECT product, ROUND(abandoned/page_view::numeric,2) AS abandonment_prob
FROM clique_bait.product_performance_report
ORDER BY abandonment_prob DESC
LIMIT 1;
```
 Russian Caviar was the most likely to be abandoned.

-- Which product had the highest view to purchase percentage?

```sql
SELECT product, ROUND(100*(purchases/page_view::numeric),2) AS view_to_purchase_percentage
FROM clique_bait.product_performance_report
ORDER BY view_to_purchase_percentage DESC
LIMIT 1;
```

Lobster has the highest view to purchase percentage

- What is the average conversion rate from view to cart add?

```sql
SELECT ROUND(100 * AVG(cart_adds/page_view::numeric),2) AS avg_view_to_cart_add 
FROM clique_bait.product_performance_report;
```

- What is the average conversion rate from cart add to purchase?
```sql
SELECT ROUND(100 * AVG(purchases/cart_adds::numeric),2) AS avg_view_to_cart_add 
FROM clique_bait.product_performance_report;
```
