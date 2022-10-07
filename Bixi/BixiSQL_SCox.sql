-- BIXI Bikes Analysis of 2016/2017 Trip Data for BrainStation Data Science Bootcamp
-- Deliverable 1
-- Analyst: Spencer Cox

-- Set Bixi as default schema
USE bixi;

-- Question 1
-- Find the amount of trips in 2016

SELECT 
	COUNT(*)
FROM trips
WHERE YEAR(start_date) = 2016;

-- Find the amount of trips in 2017

SELECT 
	COUNT(*)
FROM trips
WHERE YEAR(start_date) = 2017;

-- Trips in 2016 broken down by month

SELECT
	MONTH(start_date),
    COUNT(*)
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY MONTH(start_date);

-- Trips in 2017 broken down by month

SELECT
	MONTH(start_date),
    COUNT(*)
FROM trips
WHERE YEAR(start_date) = 2016
GROUP BY MONTH(start_date);

-- Creating working_table1, average number of trips a day for each year-month combination

CREATE TABLE working_table1
AS
SELECT
	AVG(tripsperday) AS avg_tripsperday,
	month,
	year
FROM
(
SELECT
	COUNT(*) AS tripsperday,
    DAY(start_date) AS day,
    MONTH(start_date) AS month,
    YEAR(start_date) AS year
FROM trips
GROUP BY day, month, year
) AS tot_tripsperday
GROUP BY month, year;

-- Examine working_table1

SELECT *
FROM working_table1;

-- Question 2 and Question 3 (see write up for question 3 answers)
-- Total number of trips broken down by membership status

SELECT 
	COUNT(*),
    is_member
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY is_member;

-- Percentage of total trips by members for 2017 broken down by month. Created and joined two tables, one with memberrides per month, the other with total rides per month, then joined and found ratio
SELECT
	z.memberrides/x.totalrides AS ratiomember,
    x.month
FROM
(
SELECT
	COUNT(*) AS memberrides,
	MONTH(start_date) AS month
FROM trips
WHERE YEAR(start_date) = 2017 AND is_member = 1
GROUP BY month
ORDER BY month ASC) AS z
INNER JOIN
(SELECT
	COUNT(*) AS totalrides,
	MONTH(start_date) AS month
FROM trips
WHERE YEAR(start_date) = 2017 
GROUP BY month
ORDER BY month ASC) AS x
ON x.month = z.month;

-- Question 4
-- Find the five most popular sharing stations w/out subquery

SELECT
	COUNT(*) AS tripsstarted,
    start_station_code,
    name
FROM trips
	LEFT JOIN stations
		ON trips.start_station_code = stations.code  
GROUP BY start_station_code
ORDER BY tripsstarted DESC;

-- Find the five most popular stations with subquery, the faster and less computationally intensive route

SELECT 
	tripsbystation.tripsstarted, 
    stations.name
FROM
(
SELECT
	COUNT(*) AS tripsstarted,
    start_station_code
FROM trips
GROUP BY start_station_code
ORDER BY tripsstarted DESC
) AS tripsbystation
LEFT JOIN stations
	ON tripsbystation.start_station_code = stations.code;

-- Question 5
-- Starts distributed during the day at Mackay/de Maisonneuve, results exported to excel for graphing

SELECT
COUNT(*), 
CASE
	WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN 'morning'
    WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN 'afternoon'
    WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN 'evening'
    ELSE 'night'
END AS starts_timeofday
FROM trips
GROUP BY starts_timeofday;

-- Ends distributed during the day at Mackay/de Maisonneuve, results exported to excel for graphing

SELECT
COUNT(*),
CASE
	WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN 'morning'
    WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN 'afternoon'
    WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN 'evening'
    ELSE 'night'
END AS ends_timeofday
FROM trips
GROUP BY ends_timeofday;

-- Question 6 
-- all stations where at least 10% of trips are round trips (start and end at the same location)

-- Number of starting trips per station
 
SELECT
	COUNT(*) AS tripsstarted,
    start_station_code
FROM trips
GROUP BY start_station_code;

-- Number of Round Trips per Station

SELECT
	COUNT(*) AS roundtrips,
    start_station_code
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code;

-- Combine results
SELECT
	z.start_station_code,
    roundtrips / tripsstarted
FROM
(
SELECT 
	COUNT(*) AS roundtrips,
    start_station_code
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code) AS z
INNER JOIN tripsbystation
	ON z.start_station_code = tripsbystation.start_station_code;

-- Filtered to stations with at least 500 trips and at least 10% round trip, with station ID names.
SELECT
	z.start_station_code,
    tripsstarted,
    stations.name,
    roundtrips / tripsstarted AS prct_roundtrip
FROM
(
SELECT 
	COUNT(*) AS roundtrips,
    start_station_code
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code) AS z
INNER JOIN 
	(
    SELECT
		COUNT(*) AS tripsstarted,
		start_station_code
	FROM trips
	GROUP BY start_station_code) AS tripsbystation
	ON z.start_station_code = tripsbystation.start_station_code
INNER JOIN stations
	ON z.start_station_code = stations.code
WHERE tripsstarted >= 500
HAVING prct_roundtrip >= .1
ORDER BY tripsstarted DESC;

-- All done! Sweet. Email the analyst Spencer Cox at scox0520@gmail.com with questions or clarifications.