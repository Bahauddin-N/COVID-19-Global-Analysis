-- Shows likelyhood of death if you get infected!

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from Covid_World.CovidDeaths
where location = "United States"
order by 1,2;

-- Looking at the total cases vs Population
-- Shows Percentage of pupulation infected

Select Location, date, total_cases, Population, (total_deaths / population) * 100 as TotalDeathsbyPopulation
from Covid_World.CovidDeaths
order by 1,2;

-- Looking at countries with Highest Infection Rate compared to total Population

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases) / population) * 100 as PercentofPopulationInfected
from Covid_World.CovidDeaths
group by population, location
order by PercentofPopulationInfected desc;

-- Countries with the Highes Death Count

SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathby
FROM Covid_World.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathby DESC;

-- Highest Death count by Continent

SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathby
FROM Covid_World.CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathby DESC;

-- Global Numbers

Select sum(new_cases) as Total_New_Cases, Sum(cast(total_deaths as signed)) as Max_Deaths , sum(cast(new_deaths as signed)) / sum(new_cases) * 100 as DeathPercentage
from Covid_World.CovidDeaths
where continent is not null
group by date
order by 1,2;


use covid_world;


Select * 
from covid_world.coviddeaths cd
join covid_world.covidvaccination cv
on cd.location = cv.location
and cd.date = cv.date;


-- Looking for how many people actually got vaccinated in planet

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from covid_world.coviddeaths cd
join covid_world.covidvaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3;


-- Total Population vs Vaccination
SELECT
cd.continent,
cd.location,
cd.date,    
cd.population,
cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM
covid_world.coviddeaths cd
JOIN covid_world.covidvaccination cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3;
    
-- Use CTE

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT
cd.continent,
cd.location,
cd.date,    
cd.population,
cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM
covid_world.coviddeaths cd
JOIN covid_world.covidvaccination cv 
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY 2, 3
)
select *, (RollingPeopleVaccinated / population) * 100 
from  PopvsVac;


-- Temp Table

CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATETIME,
    Population DECIMAL,
    New_Vaccinations DECIMAL,
    RollingPeopleVaccinated DECIMAL
);

INSERT INTO PercentPopulationVaccinated
SELECT
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM
    covid_world.coviddeaths cd
JOIN
    covid_world.covidvaccination cv ON cd.location = cv.location AND cd.date = cv.date
WHERE
    cd.continent IS NOT NULL;

SELECT
    *,
    (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM
    PercentPopulationVaccinated;
