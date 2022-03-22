SELECT * 
FROM dbo.CovidDeaths
ORDER BY 3,4


--SELECT * 
--FROM dbo.CovidVaccinations
--ORDER BY 3,4

SELECT LOCATION, DATE, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying from Covid
SELECT LOCATION, DATE, total_cases, total_deaths, ((Total_Deaths/Total_Cases)*100) as DeathPercentage
FROM CovidDeaths
WHERE Location Like '%states%'
ORDER BY 1,2

-- Looking at total cases vs poputlation 
-- Shows what percentage got Covid
SELECT LOCATION, DATE, Population, total_cases, ((Total_Cases/population)*100) as CovidPercentage
FROM CovidDeaths
--WHERE Location Like '%states%'
ORDER BY 1,2

-- Looking at Countries with highest Infection Rate compared to Population
SELECT LOCATION, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_Deaths/Population)*100) as CovidPercentage
FROM CovidDeaths
GROUP By LOCATION, Population
ORDER BY CovidPercentage DESC

-- Showing Countries with Highest Death Count per Population
SELECT LOCATION, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP By LOCATION
ORDER BY TotalDeathCount DESC

-- Breaking things down by continent 
SELECT Continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths
WHERE Continent is not null
GROUP By Continent
ORDER BY TotalDeathCount DESC

-- Showing contintents with the highest death count per population
SELECT Continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent is not null
GROUP By Continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT Date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE Location Like '%states%'
WHERE Continent is not null
GROUP BY Date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths Dea 
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.Continent is not null
ORDER BY 2,3

-- Using CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinates, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths Dea 
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.Continent is not null
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths Dea 
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.Location
	AND Dea.Date = Vac.Date
--WHERE dea.Continent is not null
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to Store Data for later visulaizations 
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths Dea 
JOIN CovidVaccinations Vac
	ON Dea.location = Vac.Location
	AND Dea.Date = Vac.Date
WHERE dea.Continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated