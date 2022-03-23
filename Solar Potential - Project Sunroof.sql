-- SETUP

-- Creating Table

CREATE TABLE project_sunroof (
	region VARCHAR(255),
	state VARCHAR(255),
	latitude VARCHAR(255),
	longitude VARCHAR(255),
	count_qualified INTEGER,
	percent_covered NUMERIC,
	percent_qualified NUMERIC,
	number_panels_n NUMERIC,
	number_panels_s NUMERIC,
	number_panels_e NUMERIC,
	number_panels_w NUMERIC,
	number_panels_f NUMERIC,
	number_panels_total VARCHAR(255),
	kw_total VARCHAR(255),
	yearly_sunlight_kwh_n NUMERIC,
	yearly_sunlight_kwh_2 NUMERIC,
	yearly_sunlight_kwh_e NUMERIC,
	yearly_sunlight_kwh_w NUMERIC,
	yearly_sunlight_kwh_f NUMERIC,
	yearly_sunlight_kwh_total VARCHAR(255),
	carbon_offset_metric_tons NUMERIC,
	existing_installs_count NUMERIC
)

--------------------------------------------------------------------------------------

-- DATA CLEANING

-- 1. Finding Invalid Values In Columns

-- View (number_panels_total)

SELECT state, number_panels_total, NULLIF(number_panels_total, 'NULL')
FROM project_sunroof
ORDER BY 3 DESC;

-- Update

UPDATE project_sunroof
SET number_panels_total = NULLIF(number_panels_total, 'NULL');

-- Update (kw_total)

UPDATE project_sunroof
SET kw_total = NULLIF(kw_total, 'NULL');

-- Update (yearly_sunlight_kwh_total)

UPDATE project_sunroof
SET yearly_sunlight_kwh_total = NULLIF(yearly_sunlight_kwh_total,'NULL');

-- 2. Converting Columns to the Appropriate Data Types

ALTER TABLE project_sunroof
ALTER COLUMN number_panels_total TYPE NUMERIC
USING number_panels_total::NUMERIC

ALTER TABLE project_sunroof
ALTER COLUMN kw_total TYPE NUMERIC
USING kw_total::NUMERIC

ALTER TABLE project_sunroof
ALTER COLUMN yearly_sunlight_kwh_total TYPE NUMERIC
USING yearly_sunlight_kwh_total::NUMERIC

-------------------------------------------------------------------------------------------------

-- DATA ANALYSIS

-- 1. Data Overview

SELECT 
	state, 
	SUM(count_qualified) AS count_qualified,
	ROUND(AVG(percent_covered), 1) AS percent_covered,
	ROUND(AVG(percent_qualified), 1) AS percent_qualified,
	SUM(kw_total) AS kw_total,
	ROUND(SUM(yearly_sunlight_kwh_total), 2) AS yearly_sunlight_kwh_total,
	ROUND(SUM(carbon_offset_metric_tons), 0) AS carbon_offset_metric_tons,
	SUM(existing_installs_count) AS existing_installs_count
FROM
	project_sunroof
GROUP BY state

-- 2. Which State Could Generate the Most Power?

SELECT state, ROUND(SUM(kw_total), 0) AS kw_total 
FROM project_sunroof
GROUP BY state
HAVING SUM(kw_total) IS NOT NULL
ORDER BY 2 DESC
LIMIT 1
	
-- 3. Top 20 States With the Most 100% Qualified Cities

SELECT state, COUNT(*) AS count_100p_qualified
FROM project_sunroof
GROUP BY state, percent_qualified
HAVING percent_qualified = 100
ORDER BY 2 DESC;

-- 4. Optimal Panel Direction

SELECT state, 
	   ROUND(AVG(yearly_sunlight_kwh_n), 0) AS yearly_sunlight_kwh_n,
	   ROUND(AVG(yearly_sunlight_kwh_2), 0) AS yearly_sunlight_kwh_s,
	   ROUND(AVG(yearly_sunlight_kwh_e), 0) AS yearly_sunlight_kwh_e,
	   ROUND(AVG(yearly_sunlight_kwh_w), 0) AS yearly_sunlight_kwh_w,
	   ROUND(AVG(yearly_sunlight_kwh_f), 0) AS yearly_sunlight_kwh_f
FROM project_sunroof
GROUP BY state;

-- 5. Potential Impact

SELECT state, 
	   ROUND(SUM(carbon_offset_metric_tons), 0) 
	     AS carbon_offeset_metric_tons
FROM project_sunroof
GROUP BY state
ORDER BY 2 DESC;