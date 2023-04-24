--How many users are there?

SELECT COUNT(*) AS no_of_users
FROM clique_bait.users


-- How many cookies does each user have on average?

WITH cookies AS (
SELECT user_id, COUNT(cookie_id) AS cookie_count
FROM clique_bait.users
GROUP BY user_id
)
SELECT ROUND(AVG(cookie_count),2) AS avg_no_cookies_per_user
FROM cookies


-- What is the unique number of visits by all users per month?

SELECT EXTRACT(month from event_time) AS month, COUNT(DISTINCT(visit_id)) AS no_of_visits
FROM clique_bait.events
GROUP BY EXTRACT(month from event_time)
ORDER BY month

-- What is the number of events for each event type?

SELECT a.event_type, b.event_name, COUNT(a.*) AS no_of_events
FROM clique_bait.events AS a
JOIN clique_bait.event_identifier AS b
USING (event_type)
GROUP BY a.event_type, b.event_name
ORDER BY event_type


-- What is the percentage of visits which have a purchase event?

SELECT 
FROM clique_bait.


-- What is the percentage of visits which view the checkout page but do not have a purchase event?

SELECT
FROM clique_bait.


-- What are the top 3 pages by number of views?

SELECT
FROM clique_bait.


-- What is the number of views and cart adds for each product category?

SELECT
FROM clique_bait.


-- What are the top 3 products by purchases?

SELECT
FROM clique_bait.