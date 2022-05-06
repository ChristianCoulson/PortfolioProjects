-- Set-Up
-- 1. Creating Table

CREATE TABLE echo_orders (
	patient_id NUMERIC,
	order_id NUMERIC,
	ordering_physician VARCHAR(255),
	order_name VARCHAR(255),
	order_priority VARCHAR(255),
	reason_for_exam VARCHAR(255),
	order_request_date TIMESTAMP,
	order_complete_date TIMESTAMP,
	order_location VARCHAR(255),
	admit_location VARCHAR(255),
	discharge_location VARCHAR(255)
);

------------------------------------------------------

-- Data Analysis
-- 1. Number of orders placed in Altamonte

SELECT order_location, COUNT(order_location) AS total_orders
FROM echo_orders
WHERE order_location = 'ALT'
GROUP BY order_location

-- 2. Number of urgent orders placed in Altamonte

SELECT order_location, COUNT(*) AS total_orders
FROM echo_orders
WHERE order_location = 'ALT' AND order_priority = 'STAT'
GROUP BY order_location

-- 3. Percentage of urgent orders placed in Altamonte
-- Casting numeric to prevent getting 0's. 

SELECT ROUND(COUNT(*) FILTER (WHERE order_location = 'ALT' 
							  AND order_priority = 'STAT')::NUMERIC
       /
	   COUNT(*) FILTER (WHERE order_location = 'ALT')::NUMERIC
	   *
	   100,2) AS percent_STAT_ALT
FROM echo_orders

-- 4. Five most common reasons for exams

SELECT reason_for_exam, COUNT(*) AS number_of_exams
FROM echo_orders
GROUP BY reason_for_exam
ORDER BY 2 DESC
LIMIT 5;

-- 5. Percentage of patients that come in for chest pain

SELECT ROUND(COUNT(*) FILTER (WHERE reason_for_exam = 'Chest Pain')::NUMERIC
       /
	   COUNT(*)
	   *
	   100,2) AS percent
FROM echo_orders

-- 6. Top 5 patients with the most orders

SELECT patient_id, COUNT(*) AS number_of_orders
FROM echo_orders
GROUP BY patient_id
ORDER BY 2 DESC
LIMIT 5;

-- 7. Percentage of patients admitted by each location

SELECT admit_location, 
	   ROUND(COUNT(*)/90481::NUMERIC*100,2) AS admitted_percentage
FROM echo_orders
GROUP BY admit_location
ORDER BY 2 DESC

-- 8. Most common reason for exam by location

SELECT admit_location, reason_for_exam, COUNT(*)
FROM echo_orders
GROUP BY admit_location, reason_for_exam
ORDER BY 3 DESC