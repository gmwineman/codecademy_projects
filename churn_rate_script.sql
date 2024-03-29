-- LINK TO DATA : https://docs.google.com/spreadsheets/d/1vOvJ28tJ102ReqDPXkqTwhnWWkyu07iUu6xWdAKo31g/edit#gid=0

-- Codeflix, a streaming video startup, is interested in measuring their user churn rate. In this project, you’ll be helping them answer these questions about their churn:

-- 1. Get familiar with the company.
-- How many months has the company been operating? Which months do you have enough information to calculate a churn rate?
-- What segments of users exist?

-- 2. What is the overall churn trend since the company started?

-- 3. Compare the churn rates between user segments.
-- Which segment of users should the company focus on expanding?

-- when importing the data there was an error with the two date columns. The dates were coming in as text and I was unable to change the data type prior to upload without causing an error
-- will hardcode data type changes instead
/*
UPDATE churn_subscriptions
SET subscription_start = str_to_date(subscription_start, '%Y-%m-%d') ; 

UPDATE churn_subscriptions
SET subscription_end = NULL
WHERE subscription_end = '' ;

UPDATE churn_subscriptions
SET subscription_end = str_to_date(subscription_end, '%Y-%m-%d') ;

SELECT * FROM churn_subscriptions 
;

SELECT COUNT(*)
FROM churn_subscriptions
WHERE subscription_end IS NULL ;
*/

 -- #2 Determine the range of months of data provided. Whcih months will you be able to calculate churn for?
SELECT MIN(subscription_start), MAX(subscription_start)
FROM churn_subscriptions ; 
-- can calculate churn for January through March of 2017

-- #3 create temporary table of first and last day for each month, save it as months
WITH months AS (
  SELECT 
    '2017-01-01' AS first_day, 
    '2017-01-31' AS last_day
  UNION 
  SELECT  
    '2017-02-01' AS first_day, 
    '2017-02-28' AS last_day
  UNION 
  SELECT 
    '2017-03-01' AS first_day, 
    '2018-03-31' AS last_day 
),
-- #4 create another temporary table where you cross join months with all data from subscriptions table
cross_join AS (
  SELECT *
  FROM churn_subscriptions
  CROSS JOIN months
),
-- #5 create a temporary table to determine the status (is_active) of a user 
status AS (
  SELECT 
      id, 
      first_day AS month,
      segment, -- want to be able to group by segment later on
    CASE
      WHEN (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end IS NULL)  THEN 1
      ELSE 0
    END as is_active,
-- #6 add an 'is_canceled' to status   
    CASE 
      WHEN (subscription_end BETWEEN first_day AND last_day) THEN 1
      ELSE 0 
    END as is_canceled
  FROM cross_join
),
-- #7 create a temp table that sums up active and canceled users
status_aggregate AS (
  SELECT month, segment, 
    SUM(is_active) as is_active, 
    SUM(is_canceled) as is_canceled
  FROM status
  GROUP BY month, segment
) 
-- #8 calculate churn rate over the three month period for each segment
SELECT 
  month, 
  segment, 
  1.0 * is_canceled / is_active as churn_rate
FROM status_aggregate
ORDER BY 1, 2; 