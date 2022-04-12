
WITH hotels as ( SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'])

-- Display revenue of the hotels per year 
SELECT
arrival_date_year,hotel,
ROUND(SUM((stays_in_week_nights+stays_in_weekend_nights)*adr),2) AS revenue FROM hotels
GROUP BY arrival_date_year,hotel


-- Display week nights stay and weekend night stay ratio
-- Lower weekend stay rate maybe increased by special deal on weekends per certain month / season
SELECT arrival_date_month,hotel,
ROUND(SUM(stays_in_week_nights)/SUM(stays_in_weekend_nights),2) AS weeknights_weekend_ratio FROM hotels
GROUP BY arrival_date_month,hotel 
ORDER BY weeknights_weekend_ratio DESC

--Display when adults travel the most with their children and babies for special deal !

SELECT arrival_date_month, hotel, 

SUM(adults)+SUM(children)+SUM(babies) AS all_customers,
SUM(children)/(SUM(adults)+SUM(children)+SUM(babies)) AS childeren_rate,
SUM(babies)/(SUM(adults)+SUM(children)+SUM(babies)) AS baby_rate FROM hotels
GROUP BY arrival_date_month, hotel
ORDER BY childeren_rate DESC


--Joining 2018-2020 tables for vizualization


WITH hotels as ( SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'])

SELECT * FROM hotels
JOIN dbo.market_segment$
ON hotels.market_segment = market_segment$.market_segment
JOIN dbo.meal_cost$
ON meal_cost$.meal = hotels.meal
