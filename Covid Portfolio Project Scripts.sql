/*

Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--Creating Tables for each CSV File holding Covid Deaths & Vaccination Data

CREATE TABLE CovidDeaths (
	iso_code varchar(50)
	, continent char(50)
	, location char(50)
	, date date
	, population bigint
	, total_cases bigint
	, new_cases bigint
	, new_cases_smoothed decimal(10,3)
	, total_deaths bigint
	, new_deaths bigint
	, new_deaths_smoothed decimal(10,3)
	, total_cases_per_million decimal(10,3)
	, new_cases_per_million decimal(10,3)
	, new_cases_smoothed_per_million decimal(10,3)
	, total_deaths_per_million decimal(10,3)
	, new_deaths_per_million decimal(10,3)
	, new_deaths_smoothed_per_million decimal(10,3)
	, reproduction_rate decimal(10,3)
	, icu_patients bigint
	, icu_patients_per_million decimal(10,3)
	, hosp_patients bigint
	, hosp_patients_per_million decimal(10,3)
	, weekly_icu_admissions decimal(10,3)
	, weekly_icu_admissions_per_million decimal(10,3)
	, weekly_hosp_admissions decimal(10,3)
	, weekly_hosp_admissions_per_million decimal(10,3)
)
;
	
CREATE TABLE CovidVax (
	iso_code varchar(50)
	, continent char(50)
	, location char(50)
	, date date
	, new_tests bigint
	, total_tests bigint
	, total_tests_per_thousand decimal(10,3)
	, new_tests_per_thousand decimal(10,3)
	, new_tests_smoothed bigint
	, new_tests_per_thousand_smoothed decimal(10,3)
	, positive_rate decimal(10,3)
	, tests_per_case decimal(10,3)
	, tests_units varchar(255)
	, total_vaccinations bigint
	, people_vaccinated bigint
	, people_fully_vaccinated bigint
	, new_vaccinations bigint
	, new_vaccinations_smoothed bigint
	, total_vaccinations_per_hundred decimal(10,3)
	, people_vaccinated_per_hundred decimal(10,3)
	, people_fully_vaccinated_per_hundred decimal(10,3)
	, new_vaccinations_smoothed_per_million bigint
	, stringency_index decimal(10,3)
	, population_density decimal(10,3)
	, median_age decimal(10,3)
	, aged_65_older decimal(10,3)
	, aged_70_older decimal(10,3)
	, gdp_per_capita decimal(10,3)
	, extreme_poverty decimal(10,3)
	, cardiovasc_death_rate decimal(10,3)
	, diabetes_prevelance decimal(10,3)
	, female_smokers decimal(10,3)
	, male_smokers decimal(10,3)
	, handwashing_facilities decimal(10,3)
	, hospital_beds_per_thousand decimal(10,3)
	, life_expectancy decimal(10,3)
	, human_development_index decimal(10,3)
)
;


SELECT *
FROM
	coviddeaths
WHERE
	continent IS NOT NULL
ORDER BY
	3,4


-- Select data that we are going to be starting with

SELECT
	  location
	, date
	, total_cases
	, new_cases
	, total_deaths
	, population
FROM
	coviddeaths
WHERE
	continent IS NOT NULL
ORDER BY
	1,2
	
-- Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country
SELECT
	  location
	, date
	, total_cases
	, total_deaths
	, CAST(total_deaths AS float)/CAST(total_cases AS float)* 100 AS Death_Percentage
FROM
	coviddeaths
WHERE
	location ILIKE '%states%'
	AND continent IS NOT NULL
ORDER BY
	1,2
	
	
-- Total Cases vs Total Population
-- Shows percentage of population infected with covid

SELECT
	  location
	, date
	, population
	, total_cases
	, (CAST(total_cases AS float)/population)* 100 AS PercentPopulationInfected
FROM
	coviddeaths
--WHERE
	--location ILIKE '%states%'
ORDER BY
	1,2
	
	
-- Countries with the Highest Infection Rate compared to Population

SELECT
	  location
	, population
	, MAX(total_cases) AS HighestInfectionCount
	, MAX((CAST(total_cases AS float)/population))* 100 AS PercentPopulationInfected
FROM
	coviddeaths
--WHERE
	-- location ILIKE '%states%'
GROUP BY 
	location
	, population
ORDER BY
	PercentPopulationInfected DESC NULLS LAST
	
	
-- Countries with Highest Death Count per Population

SELECT
	location, MAX(total_deaths) AS total_death_count
FROM
	coviddeaths
--WHERE
	--location ILIKE '%states%'
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	total_death_count DESC NULLS LAST
	
	
--  BREAKING DATA DOWN BY CONTINENTS


-- Showing continents with the highest death count per population
SELECT
	continent, MAX(total_deaths) AS total_death_count
FROM
	coviddeaths
--WHERE
	--location ILIKE '%states%'
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	total_death_count DESC NULLS LAST
	
	
-- GLOBAL NUMBERS

SELECT
	 SUM(new_cases) AS total_cases
	, SUM(new_deaths) AS total_deaths
	, SUM(new_deaths)/SUM(new_cases)* 100 AS Death_Percentage
FROM
	coviddeaths
--WHERE
	--location ILIKE '%states%'
WHERE 
	continent IS NOT NULL
--GROUP BY
	--date
ORDER BY
	1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

SELECT 
	  cd.continent
	, cd.location
	, cd.date
	, cd.population
	, vax.new_vaccinations
	, SUM(vax.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS Rolling_People_Vaccinated
	--, (Rolling_People_Vaccinated/population)*100
FROM
	coviddeaths cd
JOIN covidvax vax ON cd.location = vax.location
				  AND cd.date = vax.date
WHERE
	CD.continent IS NOT NULL
ORDER BY
	2,3
	
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT 
	  cd.continent
	, cd.location
	, cd.date
	, cd.population
	, vax.new_vaccinations
	, SUM(vax.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS Rolling_People_Vaccinated
	--, (Rolling_People_Vaccinated/population)*100
FROM
	coviddeaths cd
JOIN covidvax vax ON cd.location = vax.location
	AND cd.date = vax.date
WHERE
	CD.continent IS NOT NULL
)
SELECT *
, (rolling_people_vaccinated/population)*100 AS Percent_Population_Vaccinated
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TEMP TABLE PercentPopulationVaccinated AS (
	SELECT 
		  cd.continent
		, cd.location
		, cd.date
		, cd.population
		, vax.new_vaccinations
		, SUM(vax.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS Rolling_People_Vaccinated
		--, (Rolling_People_Vaccinated/population)*100
	FROM
		coviddeaths cd
	JOIN covidvax vax ON cd.location = vax.location
					  AND cd.date = vax.date
	--WHERE
		--CD.continent IS NOT NULL
)

SELECT *
, (rolling_people_vaccinated/population)*100 AS Rolling_Percent_Population_Vaccinated
FROM
	PercentPopulationVaccinated
	
	
-- Creating View to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinateed AS
SELECT 
	  cd.continent
	, cd.location
	, cd.date
	, cd.population
	, vax.new_vaccinations
	, SUM(vax.new_vaccinations) OVER (Partition By cd.location Order By cd.location, cd.date) AS Rolling_People_Vaccinated
FROM
	coviddeaths cd
JOIN covidvax vax ON cd.location = vax.location
					  AND cd.date = vax.date
WHERE
cd.continent IS NOT NULL

Select *
FROM
	PercentagePopulationVaccinateed