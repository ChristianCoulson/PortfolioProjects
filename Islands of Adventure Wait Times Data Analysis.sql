-- Universal's Islands of Adventure Wait Times Data Analysis

-- SET-UP

-- 1. Creating Table

CREATE TABLE islands_of_adventure_wait(
	ride VARCHAR(255),
	date_time TIMESTAMP,
	wait_time NUMERIC
);

-- 2. Adding Attraction Type
/*
Since our dataset only includes ride names, date/time, and wait times data, we can include attraction types to break things down a bit further.

For this, we’ll gather the attraction type from Universal Orlando’s website.
*/

UPDATE islands_of_adventure_wait
SET attraction_type =
  CASE 
	WHEN ride = 'Caro-Seuss-el' THEN 'Kid Friendly'
	WHEN ride = 'The High in the Sky Seuss Trolley Train Ride!' THEN 'Kid Friendly'
	WHEN ride = 'Skull Island: Reign of Kong' THEN 'Motion Simulation'
	WHEN ride = 'Ollivanders Experience in Hogsmeade' THEN 'Experience'
	WHEN ride = 'The Cat in The Hat' THEN 'Motion Simulation'
	WHEN ride = 'The Amazing Adventures of Spider-Man' THEN 'Motion Simulation'
	WHEN ride = 'Storm Force Accelatron' THEN 'Kid Friendly'
	WHEN ride = 'Hagrid''s Magical Creatures Motorbike Adventure' THEN 'Roller Coaster'
	WHEN ride = 'Dudley Do-Right''s Ripsaw Falls' THEN 'Water Ride'
	WHEN ride = 'The Incredible Hulk Coaster' THEN 'Roller Coaster'
	WHEN ride = 'One Fish, Two Fish, Red Fish, Blue Fish' THEN 'Kid Friendly'
	WHEN ride = 'Hogwarts Express - Hogsmeade Station' THEN 'Kid Friendly'
	WHEN ride = 'Harry Potter and the Forbidden Journey' THEN 'Motion Simulation'
	WHEN ride = 'Poseidon''s Fury' THEN 'Show'
	WHEN ride = 'Flight of the Hippogriff' THEN 'Kid Friendly'
	WHEN ride = 'Popeye & Bluto''s Bilge-Rat Barges' THEN 'Water Ride'
	WHEN ride = 'Jurassic Park River Adventure' THEN 'Water Ride'
	WHEN ride = 'Jurassic World VelociCoaster' THEN 'Roller Coaster'
	WHEN ride = 'Doctor Doom''s Fearfall' THEN 'Drop Tower'
	WHEN ride = 'Pteranodon Flyers' THEN 'Kid Friendly'
  END;

-- EXPLORATORY DATA ANALYSIS (EDA)

-- 1. Busiest Seasons
/*
For this, we’ll label each group of months with spring, summer, fall, or winter labels.

We’ll use EXTRACT() to get the month from our date_time column and then assign them a season based on the number of the month.

Then, we’ll place everything inside a common table expression (CTE) and calculate the average wait time grouping by season.

Below is the grouping we’ll use:

- Spring: months 3, 4, 5
- Summer: months 6, 7, 8
- Fall: months 9, 10, 11
- Winter: months 12, 1, 2
*/

WITH cte AS (
SELECT *,
  TO_CHAR(date_time, 'Month') AS month,
  CASE
    WHEN EXTRACT(month FROM date_time) BETWEEN '3' AND '5' THEN 'Spring'
    WHEN EXTRACT(month FROM date_time) BETWEEN '6' AND '8' THEN 'Summer'
    WHEN EXTRACT(month FROM date_time) BETWEEN '9' AND '11' THEN 'Fall'
	ELSE 'Winter'
  END AS season
FROM islands_of_adventure_wait
ORDER BY ride, date_time
)
SELECT season, ROUND(AVG(wait_time)) AS avg_wait_time
FROM cte
GROUP BY season
ORDER BY 2 DESC;

-- 2. Months With the Longest Wait Times

SELECT TO_CHAR(date_time, 'Month') AS month,
	   ROUND(AVG(wait_time)) AS avg_wait_time
FROM islands_of_adventure_wait
GROUP BY TO_CHAR(date_time, 'Month')
ORDER BY 2 DESC;

-- 3. Most Active Days of the Week

SELECT TO_CHAR(date_time, 'Day') AS day,
	   ROUND(AVG(wait_time)) AS avg_wait_time
FROM islands_of_adventure_wait
GROUP BY TO_CHAR(date_time, 'Day')
ORDER BY 2 DESC;

-- 4. Most Popular Attraction Types

SELECT attraction_type, ROUND(AVG(wait_time))
FROM islands_of_adventure_wait
GROUP BY attraction_type
ORDER BY 2 DESC;

-- 5. Most Sought-After Attractions

SELECT ride, ROUND(AVG(wait_time),0) AS avg_wait_time_minutes
FROM islands_of_adventure_wait
GROUP BY ride
ORDER BY 2 DESC;

-- 6. Average Wait Time By Time of Day

WITH cte AS(
	SELECT EXTRACT(HOUR FROM date_time) AS hour, 
		   ROUND(AVG(wait_time)) AS wait_time
	FROM islands_of_adventure_wait
	GROUP BY EXTRACT(HOUR FROM date_time)
	HAVING EXTRACT(HOUR FROM date_time) BETWEEN 8 AND 21
)
SELECT CASE WHEN hour BETWEEN 8 AND 11 THEN hour || ' AM' 
	   		WHEN hour = 12 THEN hour || ' PM'
	      	ELSE hour-12 || ' PM' 
	   END AS hour,
	   wait_time
FROM cte