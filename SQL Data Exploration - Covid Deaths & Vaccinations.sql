SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--select *
--from PortfolioProject1..CovidVaccinations
--order by 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying from Covid (in the US)

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Percentage of population infected with Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS population_infected_percent
FROM PortfolioProject1..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2


-- Countries with the highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population)*100) AS population_infected_percent
FROM PortfolioProject1..CovidDeaths
--WHERE Location like '%states%'
GROUP BY Location, population
ORDER BY population_infected_percent DESC


-- Countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject1..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY total_death_count DESC


-- BREAKDOWN BY CONTINENT 


-- Continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject1..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC


-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Using CTE to perform Calculation on Partition By
-- Percentage of rolling people vaccinated by country

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS percentage_roll_people_vac
FROM PopvsVac


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 