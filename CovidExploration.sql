/* Create database */
CREATE DATABASE CovidExploration;
GO

/* Change to the CovidExploration database */
USE CovidExploration;
GO

/* Check for proper import */

SELECT *
FROM CovidExploration..CovidDeaths
ORDER BY 3, 4

SELECT *
FROM CovidExploration..CovidVaccinations
ORDER BY 3, 4

-- Selecting data that will be used
SELECT 
   location, 
   date, 
   total_cases, 
   new_cases, 
   total_deaths, 
   population
FROM CovidExploration..CovidDeaths
ORDER By 1, 2


-- Total Cases vs Total Population, Percentage of Population Infected by COVID, Global
SELECT 
   location, 
   date, 
   total_cases, 
   population, 
   (total_cases/population)*100 AS infected_percentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
ORDER By 1, 2

-- Total Cases vs Total Population, Percentage of Population Infected by COVID, Vietnam and US
SELECT 
   location, 
   date, 
   total_cases, 
   population, 
   (total_cases/population)*100 AS infected_percentage
FROM CovidExploration..CovidDeaths
WHERE location = 'Vietnam' OR location = 'United States' AND continent IS NOT NULL
ORDER By 1, 2

-- Average percentage of population infected by COVID, Global
SELECT 
   Location, 
   AVG((total_cases/population))*100 AS infected_percentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Average percentage of population infected by COVID in US and VN
SELECT 
   Location, 
   AVG((total_cases/population))*100 AS infected_percentage
FROM CovidExploration..CovidDeaths
WHERE location = 'Vietnam' OR location = 'United States' AND continent IS NOT NULL
GROUP BY location

-- Total Cases vs Total Deaths (shows likelihood of dying if you contract COVID in these countries)
SELECT 
   location, 
   date, 
   total_cases, 
   total_deaths, 
   (total_deaths/total_cases)*100 AS death_percentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
ORDER By 5 DESC

-- Total Cases vs Total Deaths (shows likelihood of dying if you contract COVID in VN, US)
SELECT 
   location, 
   date, 
   total_cases, 
   total_deaths, 
   (total_deaths/total_cases)*100 AS death_percentage
FROM CovidExploration..CovidDeaths
WHERE location = 'Vietnam' OR location = 'United States' AND continent IS NOT NULL
ORDER By 5 DESC

-- Average percentage of deaths by COVID, Global
SELECT 
   location,
   AVG((total_deaths/total_cases))*100 AS death_percentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Average percentage of deaths by COVID in US and VN
SELECT 
   location,
   AVG((total_deaths/total_cases))*100 AS death_percentage
FROM CovidExploration..CovidDeaths
WHERE location = 'Vietnam' OR location = 'United States' AND continent IS NOT NULL
GROUP BY location

--Global Highest Infection Rate, Highest Percentage of Population Infected by COVID
SELECT 
   Location, 
   Population, 
   MAX(total_cases) AS highest_infection_count, 
   MAX((total_cases/population))*100 AS highest_infection_percentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER By infection_percentage DESC

--Global Highest Infection Rate, Percentage of Population Infected by COVID
SELECT 
   Location, 
   Population, 
   MAX(total_cases) AS highest_infection_count, 
   MAX((total_cases/population))*100 AS highest_infection_percentage
FROM CovidExploration..CovidDeaths
WHERE continent IS NOT NULL
   AND location = 'Vietnam'
   OR location = 'United States'
GROUP BY Location, Population
ORDER By infection_percentage DESC


-- Countries with highest death count per population
SELECT 
   Location,
   MAX(total_deaths) AS total_death_count
FROM CovidExploration..CovidDeaths
--WHERE Location = 'Vietnam' OR Location = 'United States' AND continent IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY Location
ORDER By total_death_count DESC

-- Countries with highest death count per population, VN and US
SELECT 
   Location,
   MAX(total_deaths) AS total_death_count
FROM CovidExploration..CovidDeaths
WHERE Location = 'Vietnam' OR Location = 'United States' AND continent IS NOT NULL
GROUP BY Location
ORDER By total_death_count DESC


/* Vaccinations */

-- Total Poplulation vs Vaccinations, JOIN CovidsDeaths and CovidVaccinations
SELECT *
FROM CovidExploration..CovidDeaths dea
JOIN CovidExploration..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date

-- Rolling count of vaccinations
SELECT
   dea.continent,
   dea.location,
   dea.date,
   dea.population,
   vac.new_vaccinations,
   SUM(vac.new_vaccinations) OVER 
    (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_new_vaccinations
FROM CovidExploration..CovidDeaths dea
JOIN CovidExploration..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
   AND dea.location = 'Vietnam'
   OR dea.location = 'United States'
ORDER BY 2,3

-- Using CTE to make further calculations
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_new_vaccinations)
AS
   (
    SELECT
      dea.continent,
      dea.location,
      dea.date,
      dea.population,
      vac.new_vaccinations,
      SUM(vac.new_vaccinations) OVER 
       (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_new_vaccinations
   FROM CovidExploration..CovidDeaths dea
   JOIN CovidExploration..CovidVaccinations vac
      ON dea.location = vac.location
      AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL 
      AND dea.location = 'Vietnam'
      OR dea.location = 'United States'
   )
SELECT *, (rolling_new_vaccinations/population)*100 AS new_vaccinated_percentage
FROM PopvsVac
ORDER BY 7 DESC





