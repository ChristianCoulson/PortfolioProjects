SELECT *
FROM covid_deaths
WHERE location = 'United States'
ORDER BY total_cases DESC

-- Total Cases vs. Total Deaths

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases::numeric*100), 1) AS death_percentage
FROM covid_deaths
WHERE location = 'United States'
ORDER BY 1,2
	
-- Total Cases vs. Population
-- (Percentage of population that has gotten COVID-19)

SELECT location, date, total_cases, population, ROUND((total_cases/population::numeric*100), 1) AS infected_percentage
FROM covid_deaths
WHERE location = 'United States'
ORDER BY 1,2

-- Infection Rate Per Country

SELECT location, population, MAX(total_cases) AS total_infections, ROUND(MAX((total_cases/population::numeric*100)),1) AS infection_rate
FROM covid_deaths
WHERE (total_deaths, continent) IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC

-- Number of Deaths Per Country

SELECT location, MAX(total_deaths) AS total_deaths
FROM covid_deaths
WHERE (total_deaths, continent) IS NOT NULL
GROUP BY location
ORDER BY MAX(total_deaths) DESC

-- Number of Deaths Per Continent

SELECT continent, MAX(total_deaths) AS total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAX(total_deaths) DESC

-- Global Cases, Deaths, and Death Percentage by Date

SELECT date, SUM(new_cases) AS global_cases, SUM(new_deaths) AS global_deaths, ROUND(SUM(new_deaths)/SUM(new_cases)::numeric*100, 1) AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total Population vs. Vaccinations (Rolling Count)

SELECT covid_deaths.continent, covid_deaths.location, covid_deaths.date, population, 
new_vaccinations, 

SUM(new_vaccinations) OVER (PARTITION BY covid_deaths.location ORDER BY covid_deaths.location, covid_deaths.date) AS total_vaccinations

FROM covid_deaths
JOIN covid_vaccinations
	ON covid_deaths.location = covid_vaccinations.location
	AND covid_deaths.date = covid_vaccinations.date
WHERE covid_deaths.continent IS NOT NULL
ORDER BY 2, 3

-- Common Table Expression (CTE)
-- Used to find the rolling percentage of vaccinated population

WITH popvsvac (continent, location, date, population, new_vaccinations, total_vaccinations) 
	AS(
		SELECT covid_deaths.continent, covid_deaths.location, covid_deaths.date, population, 
               new_vaccinations, SUM(new_vaccinations) 
				  OVER (PARTITION BY covid_deaths.location 
				  ORDER BY covid_deaths.location, covid_deaths.date) 
				  AS total_vaccinations
		FROM covid_deaths
		JOIN covid_vaccinations
			ON covid_deaths.location = covid_vaccinations.location
			AND covid_deaths.date = covid_vaccinations.date
		WHERE covid_deaths.continent IS NOT NULL
		ORDER BY 2, 3
	)
SELECT location, date, population, total_vaccinations, ROUND((total_vaccinations/population*100),1) AS percentage_vaccinated
FROM popvsvac

-- Creating a View

CREATE VIEW percentpopulationvaccinated AS
	SELECT covid_deaths.continent, covid_deaths.location, covid_deaths.date, population, 
               new_vaccinations, SUM(new_vaccinations) 
				  OVER (PARTITION BY covid_deaths.location 
				  ORDER BY covid_deaths.location, covid_deaths.date) 
				  AS total_vaccinations
		FROM covid_deaths
		JOIN covid_vaccinations
			ON covid_deaths.location = covid_vaccinations.location
			AND covid_deaths.date = covid_vaccinations.date
		WHERE covid_deaths.continent IS NOT NULL

SELECT *
FROM percentpopulationvaccinated

