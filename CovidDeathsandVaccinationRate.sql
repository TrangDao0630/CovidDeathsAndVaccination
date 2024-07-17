-- Look at Covid deaths
SELECT *
FROM mydb.covid_dealths cd 
ORDER BY 3,4

-- Look at Covid vaccination
SELECT *
FROM mydb.covid_vaccine cv 
ORDER BY 3,4

-- Select data that is going to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM mydb.covid_dealths cd 
WHERE continent != ''
ORDER BY 1,2

-- Look at total cases vs total deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM mydb.covid_dealths cd 
WHERE continent != ''
ORDER BY 1,2

-- Look at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM mydb.covid_dealths cd 
WHERE continent != ''
WHERE location like '%states%'
ORDER BY 1,2

-- Look at Total Cases vs Population
-- Show what percentage of population got Covid
SELECT location, date, population ,total_cases,(total_deaths/total_cases)*100 as DeathPercentage
FROM mydb.covid_dealths cd 
WHERE continent != ''
-- WHERE location like '%states%'
ORDER BY 1,2

-- Look at Countries with Highest Infection Rate compared to Population
SELECT location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
FROM mydb.covid_dealths cd 
WHERE continent != ''
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 

-- Show Countries with Highest Deaths Count per Population
SELECT location, max(total_deaths) as TotalDeathCount
FROM mydb.covid_dealths cd 
-- WHERE location like '%states%'
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- LET'S BREAK THINGS DOWN BY CONTINENTS

-- Show the continents with the Highest Deaths Count per population
SELECT continent, max(total_deaths) as TotalDeathCount
FROM mydb.covid_dealths cd 
WHERE continent != ''
GROUP BY continent 
ORDER BY TotalDeathCount DESC 

-- GLOBAL NUMBERS
-- Look at Toal Population vs Vaccinations
SELECT sum(new_cases) as TotalNewCases , sum(new_deaths) as TotalNewDeaths, 
SUM(new_deaths)/ sum(new_cases) *100 as DealthPercentage
FROM mydb.covid_dealths cd 
WHERE continent != ''
-- WHERE location like '%states%'
-- GROUP BY date 
ORDER BY 1,2 

-- Look at Total Population vs Vaccincations
SELECT cd.continent , cd.location , cd.date, cd.population , cv.new_vaccinations
,sum(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccincated
-- ,(RollingPeopleVaccincated/population)*100 
FROM mydb.covid_dealths cd 
JOIN mydb.covid_vaccine cv 
	ON cd.location = cv.location 
	and cd.date = cv.date
WHERE cd.continent != ''
ORDER BY 2,3

	-- USE CTE
With PopvsCv(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT cd.continent , cd.location , cd.date, cd.population , cv.new_vaccinations
,sum(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccincated
-- ,(RollingPeopleVaccincated/population)*100 
FROM mydb.covid_dealths cd 
JOIN mydb.covid_vaccine cv 
	ON cd.location = cv.location 
	and cd.date = cv.date
WHERE cd.continent != ''
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsCv

-- TEMP TABLE
DROP TABLE if EXISTS `PercentPopulationVaccinated`
CREATE TABLE `PercentPopulationVaccinated`
(
  continent NVARCHAR(255),
  location NVARCHAR(255),
  date datetime,
  population decimal,
  new_vaccinations decimal,
  RollingPeopleVaccinated decimal
)

INSERT INTO `PercentPopulationVaccinated`
SELECT 
cd.continent, 
cd.location, 
cd.date, 
cd.population, 
COALESCE(CAST(NULLIF(cv.new_vaccinations, '') AS DECIMAL(15, 2)), 0) AS new_vaccinations,
SUM(COALESCE(CAST(NULLIF(cv.new_vaccinations, '') AS DECIMAL(15, 2)), 0)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS RollingPeopleVaccinated
FROM mydb.covid_dealths cd 
JOIN mydb.covid_vaccine cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date
-- WHERE cd.continent is not NULL 

SELECT 
  *,(RollingPeopleVaccinated / population) * 100 
FROM 
  `PercentPopulationVaccinated`

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent , cd.location , cd.date, cd.population , cv.new_vaccinations
,sum(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccincated
-- ,(RollingPeopleVaccincated/population)*100 
FROM mydb.covid_dealths cd 
JOIN mydb.covid_vaccine cv 
	ON cd.location = cv.location 
	and cd.date = cv.date
WHERE cd.continent != ''
-- ORDER BY 2,3

SELECT *
FROM percentpopulationvaccinated p 























