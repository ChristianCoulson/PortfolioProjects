-- DATA CLEANING

-- 1. Creating Table

CREATE TABLE chernobyl(
	country VARCHAR(250),
	code NUMERIC,
	town VARCHAR(250),
	latitude NUMERIC,
	longitude NUMERIC,
	date VARCHAR(250),
	end_of_sampling TIME,
	duration NUMERIC,
	iodine_131 VARCHAR(250),
	caesium_134 VARCHAR(250),
	caesium_137 VARCHAR(250)
)

-- 2. Converting Country Abbreviation to Name

UPDATE chernobyl
SET country =
	CASE
		WHEN country = 'SE' THEN 'Sweden'
		WHEN country = 'DE' THEN 'Germany'
		WHEN country = 'F'  THEN 'France'
		WHEN country = 'IR' THEN 'Ireland'
		WHEN country = 'IT' THEN 'Italy'
		WHEN country = 'NL' THEN 'Netherlands'
		WHEN country = 'GR' THEN 'Greece'
		WHEN country = 'UK' THEN 'United Kingdom'
		WHEN country = 'BE' THEN 'Belgium'
		WHEN country = 'ES' THEN 'Spain'
		WHEN country = 'CH' THEN 'Switzerland'
		WHEN country = 'AU' THEN 'Austria'
		WHEN country = 'FI' THEN 'Finland'
		WHEN country = 'NO' THEN 'Norway'
		WHEN country = 'CZ' THEN 'Slovakia'
		WHEN country = 'HU' THEN 'Hungary'
	END

-- 3. Standardizing Town Names
-- 3.1 Removing special characters

UPDATE chernobyl
SET town = REPLACE(town, '-', '(')

UPDATE chernobyl
SET town = REPLACE(town, 'ST.', 'Saint ')

UPDATE chernobyl
SET town = REPLACE(town, '.', '(')

UPDATE chernobyl
SET town = SPLIT_PART(town, '(', 1)

-- 3.2 Capitalizing the first letter of every word

UPDATE chernobyl
SET town = INITCAP(town);

-- 4. Converting Date Column to DATE Data Type

ALTER TABLE chernobyl
ALTER COLUMN date TYPE DATE
USING TO_DATE(date, 'YY MM DD');

-- 5. Cleaning Missing and Incorrect Values
-- 5.1 Cleaning the iodine_131 column
 
UPDATE chernobyl
SET iodine_131 = NULLIF(iodine_131, 'N')

UPDATE chernobyl
SET iodine_131 = NULLIF(iodine_131, '<')

UPDATE chernobyl
SET iodine_131 = NULLIF(iodine_131, '0')

UPDATE chernobyl
SET iodine_131 = NULLIF(iodine_131, 'L')

-- 5.2 Cleaning the caesium_134 column

UPDATE chernobyl
SET caesium_134 = NULLIF(caesium_134, 'N')

UPDATE chernobyl
SET caesium_134 = NULLIF(caesium_134, '<')

UPDATE chernobyl
SET caesium_134 = NULLIF(caesium_134, '0')

-- 5.3 Cleaning the caesium_137 column

UPDATE chernobyl
SET caesium_137 = NULLIF(caesium_137, 'N')

UPDATE chernobyl
SET caesium_137 = NULLIF(caesium_137, '<')

UPDATE chernobyl
SET caesium_137 = NULLIF(caesium_137, '0')

-- 6. Converting Iodine and Caesium Columns to NUMERIC Data Type

ALTER TABLE chernobyl
ALTER COLUMN iodine_131 TYPE NUMERIC
USING iodine_131::NUMERIC

ALTER TABLE chernobyl
ALTER COLUMN caesium_134 TYPE NUMERIC
USING caesium_134::NUMERIC

ALTER TABLE chernobyl
ALTER COLUMN caesium_137 TYPE NUMERIC
USING caesium_137::NUMERIC

-- 7. Removing Unused Columns

ALTER TABLE chernobyl
DROP COLUMN end_of_sampling, 
DROP COLUMN duration

-- 8. Renaming code Column to country_code

ALTER TABLE chernobyl
RENAME COLUMN code TO country_code

-- 9. Adding Unit of Measurement to Column Name

ALTER TABLE chernobyl
RENAME COLUMN iodine_131 TO iodine_131_bqm3

ALTER TABLE chernobyl
RENAME COLUMN caesium_134 TO caesium_134_bqm3

ALTER TABLE chernobyl
RENAME COLUMN caesium_137 TO caesium_137_bqm3



-------------------------------------------------------------------------------------------




-- DATA ANALYSIS

-- 1. Which countries required protective action against high iodine-131 levels?
-- The concentration levels of iodine-131 in the air required for taking protective actions, called Derived Intervention Level (DIL), is 661.38 Bq/m3.

SELECT country, ROUND(AVG(iodine_131_bqm3), 6) AS avg_iodine_131
FROM chernobyl
GROUP BY country
HAVING ROUND(AVG(iodine_131_bqm3), 6) >= 661.38

-- Luckily, none of these countries reached a level of radiation that required protective action.

-- 2. What's the average level of radiation (I-131, Cs-134, and Cs-137) per country?

SELECT country, ROUND(AVG(iodine_131_bqm3), 6) AS iodine_131_bqm3,
				ROUND(AVG(caesium_134_bqm3), 6) AS caesium_134_bqm3, 
				ROUND(AVG(caesium_137_bqm3), 6) AS caesium_137_bqm3
FROM chernobyl
GROUP BY country

-- 3. Which country has the highest level of iodine-131?

SELECT country, ROUND(AVG(iodine_131_bqm3), 6) AS iodine_131_bqm3
FROM chernobyl
WHERE iodine_131_bqm3 IS NOT NULL
GROUP BY country
ORDER BY iodine_131_bqm3 DESC
LIMIT 1

-- 4. Show the average level of iodine-131 in each German town and order them from highest to lowest.

SELECT country, town, ROUND(AVG(iodine_131_bqm3), 6) AS iodine_131_bqm3
FROM chernobyl
WHERE iodine_131_bqm3 IS NOT NULL AND country = 'Germany'
GROUP BY country, town
ORDER BY iodine_131_bqm3 DESC

-- 5. Find the start and end date of the data collection process in Paris.

SELECT town, 
	   MIN(date) AS begin_data_collection, 
	   MAX(date) AS end_data_collection
FROM chernobyl
WHERE town = 'Paris'
GROUP BY town

-- 6. What's the correlation between iodine-131 and caesium-134?

SELECT
	CORR(iodine_131_bqm3, caesium_134_bqm3),
	CORR(iodine_131_bqm3, caesium_137_bqm3),
	CORR(caesium_134_bqm3, caesium_137_bqm3)
FROM chernobyl

-- 7. Creating a table to add isotope correlations

CREATE TABLE chernobyl_correlation(
	isotope VARCHAR(200),
	iodine_131 NUMERIC,
	caesium_134 NUMERIC,
	caesium_137 NUMERIC
)

-- 8. Adding correlations

INSERT INTO chernobyl_correlation(isotope, iodine_131, caesium_134, caesium_137)
VALUES('iodine_131', 1, 0.9469, 0.7818),
	  ('caesium_134', 0.9496, 1, 0.9965),
	  ('caesium_137', 0.7818, 0.9665, 1);