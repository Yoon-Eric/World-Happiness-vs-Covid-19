SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

-- to select all the data needed

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioPractice..CovidDeaths
--ORDER BY 1,2

-- seeing at total cases vs total deaths

--SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) AS [Death Percentage]
--FROM CovidDeaths
--ORDER BY 1,2

-- states
--SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) AS [Death Percentage]
--FROM CovidDeaths
--WHERE Location like '%states%'
--ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths, (total_cases/population * 100) AS [Case Percentage]
FROM CovidDeaths
--WHERE Location like '%states%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as [highest cases], MAX(total_cases/population * 100) AS [Highest Case Percentage]
FROM CovidDeaths
GROUP BY location, population
ORDER BY [Highest Case Percentage] DESC

-- Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as [Total Death Count]
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY [Total Death Count] DESC

-- by continent
SELECT continent, MAX(cast(total_deaths as int)) as [Total Death Count]
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY [Total Death Count] DESC

-- Global number
SELECT date, SUM(new_cases) as [Total New Cases], SUM(CAST(new_deaths as int)) as [Total New Deaths],
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as [Death Percentage]
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- Total population vs vaccinations

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations as int)) OVER (Partition by death.Location) AS [Total People Vaccinated]
FROM CovidDeaths death
JOIN CovidVaccinations vaccine
	ON death.location = vaccine.location
	and death.date = vaccine.date
WHERE death.continent is not null
ORDER BY 2,3

--USE CTE (Common Table Expression)

WITH PopulationvsVaccine (Continent, Location, Date, Population, new_vaccinations, [Total People Vaccinated])
AS
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations as int)) OVER (Partition by death.Location) AS [Total People Vaccinated]
FROM CovidDeaths death
JOIN CovidVaccinations vaccine
	ON death.location = vaccine.location
	and death.date = vaccine.date
WHERE death.continent is not null
--ORDER BY 2,3
)

SELECT *
FROM PopulationvsVaccine

-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations as int)) OVER (Partition by death.Location) AS [Total People Vaccinated]
FROM CovidDeaths death
JOIN CovidVaccinations vaccine
	ON death.location = vaccine.location
	and death.date = vaccine.date
WHERE death.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- create view to store data for later visualizations
DROP VIEW IF exists PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations as int)) OVER (Partition by death.Location ORDER BY death.location, death.Date)
AS [Total People Vaccinated]
FROM CovidDeaths death
JOIN CovidVaccinations vaccine
	ON death.location = vaccine.location
	and death.date = vaccine.date
WHERE death.continent is not null
