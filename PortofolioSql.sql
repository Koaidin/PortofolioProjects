## Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;

## Looking at total_cases VS total_deaths
## Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentange
FROM CovidDeaths
WHERE location like 'Gree%'
ORDER BY 1,2;

## Looking at Total Cases vs Population
## Shows what percentage of population got Covid

SELECT location, date, Population, total_cases, (total_cases/population)*100 as Percentenge_of_population_infected
FROM CovidDeaths
WHERE location like 'Gree%'
ORDER BY 1,2;

## Looking at countries with Highest Infection Rate compare to Population 

SELECT location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 as Percentenge_of_population_infected
FROM CovidDeaths
##WHERE location like 'Gree%'
GROUP BY population, location
ORDER BY Percentenge_of_population_infected DESC;

## Showing countries with highest death count per population

SELECT location, MAX(CAST(Total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM CovidDeaths
## WHERE location like 'Gree%'
WHERE continent is not null
Group by location
order by TotalDeathCount Desc;


## Showing the continent with the highest deathcount per population

SELECT Continent, MAX(CAST(Total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM CovidDeaths
## WHERE location like 'Gree%'
WHERE continent is not null
Group by Continent
order by TotalDeathCount Desc;


## Global Numbers total cases vs total deaths

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentange
FROM CovidDeaths
## WHERE location like 'Gree%'
WHERE continent is not null
## GROUP BY date
ORDER BY 1,2;

## Looking at total population vs vaccinations
## Use cte

WITH PopvsVacc (continent,location,date,population,new_vaccinations,RolingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RolingPeopleVaccinated
## (RolingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN CovidVaccinations vacc 
	ON dea.location = vacc.location
    AND dea.date = vacc.date
WHERE dea.continent is not null
)
SELECT * , (RolingPeopleVaccinated/population)*100 AS PercentPopulationVaccinated
FROM PopvsVacc;


## use temp table 

DROP Table if exists PercentPopulationVaccinated;
CREATE temporary table PercentPopulationVaccinated
(
continent nvarchar(200),
location nvarchar(200),
date DATE,
Population numeric,
new_vaccinations numeric,
RolingPeopleVaccinated numeric
);
insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RolingPeopleVaccinated
## (RolingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN CovidVaccinations vacc 
	ON dea.location = vacc.location
    AND dea.date = vacc.date
WHERE dea.continent is not null;

SELECT *
FROM PercentPopulationVaccinated;

## create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RolingPeopleVaccinated
## (RolingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN CovidVaccinations vacc 
	ON dea.location = vacc.location
    AND dea.date = vacc.date
WHERE dea.continent is not null;


SELECT * 
FROM PercentPopulationVaccinated;
