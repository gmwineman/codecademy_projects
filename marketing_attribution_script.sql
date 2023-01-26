-- Project Assignment: Marketing Attribution

-- CoolTShirts, an innovative apparel shop, is running a bunch of marketing campaigns. In this project, you’ll be helping them answer these questions about their campaigns:

-- 1. Get familiar with the company.
-- How many campaigns and sources does CoolTShirts use and how are they related? Be sure to explain the difference between utm_campaign and utm_source.
-- What pages are on their website?

-- 2. What is the user journey?
-- How many first touches is each campaign responsible for?
-- How many last touches is each campaign responsible for?
-- How many visitors make a purchase?
-- How many last touches on the purchase page is each campaign responsible for?
-- What is the typical user journey?

-- 3. Optimize the campaign budget.
-- CoolTShirts can re-invest in 5 campaigns. Which should they pick and why?

-- LINK TO DATA : https://docs.google.com/spreadsheets/d/1XU9VYJPCYKzTJjespcehhEEUFVfzsYtETo06cHM2RVI/edit?usp=sharing
-- note: you will have to adjust timestamp column to make it compatible 

-- importing timeseries data has resulted in errors, had to separate date and time into two columns to avoid issues when uploading.
-- can only upload date and time columns as text data types

/*
SELECT * FROM page_visits LIMIT 10;
-- need to rejoin the two separate columns 
SELECT page_name, concat(date," ",time), user_id, utm_campaign, utm_source
FROM page_visits; 

UPDATE page_visits
SET date = concat(date," ",time) ; 
ALTER TABLE page_visits
DROP COLUMN time ; 
ALTER TABLE page_visits
RENAME COLUMN date TO timestamp ; 

SELECT * FROM page_visits ; 
*/

-- #1 How many campaigns and sources does CoolTShirts use? Which source is used for each campaign?
SELECT COUNT(DISTINCT utm_campaign)
FROM page_visits; 

SELECT COUNT(DISTINCT utm_source)
FROM page_visits; 

SELECT distinct utm_campaign, utm_source
FROM page_visits 
ORDER BY 2; 

-- #2 What are the pages on the CoolTShirts website?
SELECT DISTINCT page_name
FROM page_visits ; 

-- #3 How many first touches is each campagin responsible for?
WITH first_touch AS (
	SELECT 
		user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id
), 
ft_attr AS (
	SELECT 
		ft.user_id, 
        ft.first_touch_at, 
        pv.utm_source,
        pv.utm_campaign
	FROM first_touch as ft
	JOIN page_visits as pv 
		ON  ft.user_id = pv.user_id
		AND ft.first_touch_at = pv.timestamp
)
SELECT ft_attr.utm_source,
       ft_attr.utm_campaign,
       COUNT(*) AS 'first_touches_generated'
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC; 

-- #4 How many last touches is each campaign responsible for?
WITH last_touch AS (
	SELECT 
		user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id
), 
lt_attr AS (
	SELECT 
		lt.user_id, 
        lt.last_touch_at, 
        pv.utm_source,
        pv.utm_campaign
	FROM last_touch as lt
	JOIN page_visits as pv 
		ON  lt.user_id = pv.user_id
		AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source, 
	lt_attr.utm_campaign, 
    COUNT(*) AS 'last_touches_genereated'
FROM lt_attr 
GROUP BY 1, 2
ORDER BY 3 DESC; 

-- #5 How many visitors make a purchase?
SELECT COUNT(DISTINCT user_id) AS 'total_to_purchase_page'
FROM page_visits
WHERE page_name LIKE '%4 - purchase' 
; 

-- #6 How many last touches on the 'purchase page' is each campaign responsible for?
WITH last_touch AS (
	SELECT 
		user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    WHERE page_name LIKE '%4 - purchase' -- adding this line of code to the previous last_touch query
    GROUP BY user_id
), 
lt_attr AS (
	SELECT 
		lt.user_id, 
        lt.last_touch_at, 
        pv.utm_source,
        pv.utm_campaign
	FROM last_touch as lt
	JOIN page_visits as pv 
		ON  lt.user_id = pv.user_id
		AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source, 
	lt_attr.utm_campaign, 
    COUNT(*) AS 'last_touch_to_purchase'
FROM lt_attr 
GROUP BY 1, 2
ORDER BY 3 DESC ;

SELECT distinct utm_source, utm_campaign
FROM page_visits 
; 
-- #7 CoolTShirts can reinvest in 5 campaigns. Given your findings, which ones should they pick and why?
-- medium and nytimes generate the most first_touches for the website, but generage some of the least last touches
-- email and facebook sources generate the most amount of last touches, and ultimately the most purchases
-- I would recommend reinvesting in the minterview-with-cool-tshirts-founder, getting-to-know-cool-tshirts, ten-crazy-cool-tshirts-facts  campaigns as they generate the most first touches for the busines
-- I would also recommend reinvesting in the weekly-newsletter and retargetting-ad campaigns as they genereate the most purchases