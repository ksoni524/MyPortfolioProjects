/*
Covid 19 Data Exploration 

Skills used in my Queries: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Selecting all CovidDeaths DATA

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Selecting Data that we are interested in.

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths of Canada.
-- Shows likelihood of dying if you contract covid in any specificed country

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
Where location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Population of each country
-- Shows what percentage of population infected with Covid

SELECT  location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%Canada%'
ORDER BY 1,2


-- Showing all Countries with Highest Infection Rate compared to Population in order

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent iS NOT NULL
-- AND location like '%Canada%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population ordered by most deaths

SELECT location, MAX(total_deaths) AS TotalDeathCount, population, MAX(total_deaths/population) *100 AS PercentPopulationDied
FROM CovidDeaths
--Where location like '%Canada%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(Total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- !!! GLOBAL NUMBERS !!!

-- Global DAILY total cases vs total deaths

SELECT date, SUM(new_cases) AS Global_total_cases, SUM(new_deaths) AS Global_total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 AS GlobalDeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY  1,2

-- Global total cases vs total deaths

SELECT SUM(new_cases) AS Global_total_cases, SUM(new_deaths) AS Global_total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 AS GlobalDeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY  1,2

-- Total Population vs Vaccinations
-- Showing the population of each country and the nex vaccinations given out per day,
-- Also performing a Running total function to demonstrate the the total vaccines to date per country.

SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations
, SUM( vaxx.new_vaccinations ) OVER (PARTITION BY death.Location ORDER BY death.location, death.date) AS RunningPeopleVaccinated
FROM CovidDeaths death
JOIN CovidVaccinations vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS  NOT NULL
ORDER BY 2,3

-- !!! CTE !!!
-- Example of using CTE  to show the Percentage of the people vaccinated of each country per day

WITH POPvsVAXX(continent, location, date, population, new_vaccinations, RunningPeopleVaccinated)
AS
(
SELECT  death.continent, death.location, death.date, death.population, vaxx.new_vaccinations
, SUM( vaxx.new_vaccinations ) OVER (PARTITION BY death.Location ORDER BY death.location, death.date) AS RunningPeopleVaccinated
FROM CovidDeaths death
JOIN CovidVaccinations vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS  NOT NULL 
)
SELECT *,  (RunningPeopleVaccinated/population)*100 AS PercentagePeopleVaccinatedPerCountry
FROM POPvsVAXX

-- Creating View to store data for later visuualizations (Essentially Creates another table that we can query from)

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaxx.new_vaccinations
, SUM( vaxx.new_vaccinations ) OVER (PARTITION BY death.Location ORDER BY death.location, death.date) AS RunningPeopleVaccinated
FROM CovidDeaths death
JOIN CovidVaccinations vaxx
	ON death.location = vaxx.location
	AND death.date = vaxx.date
WHERE death.continent IS  NOT NULL









