SELECT *
FROM coviddeaths
WHERE continent IS NOT null
ORDER BY 3,4;

SELECT *
FROM covidvaccinations
WHERE continent IS NOT null
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT null
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage 
FROM coviddeaths
WHERE location LIKE '%States%'
AND continent IS NOT null
ORDER BY 1,2;


-- looking at the Total Cases vs Population
-- shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected 
FROM coviddeaths
-- WHERE location LIKE '%States%'
ORDER BY 1,2;


-- looking at counties with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected 
FROM coviddeaths
-- WHERE location LIKE '%States%'
GROUP BY 1,2
ORDER BY percent_population_infected DESC;


-- showing the countries with the highest Death Count per Population
SELECT location, MAX(total_deaths) AS totaldeathcount
FROM coviddeaths
-- WHERE location LIKE '%States%'
WHERE continent IS NOT null
GROUP BY location
ORDER BY totaldeathcount DESC;



-- BREAKING THINGS DOWN BY CONTINENT

-- showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS totaldeathcount
FROM coviddeaths
-- WHERE location LIKE '%States%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY totaldeathcount DESC;


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS deathpercentage
FROM coviddeaths
-- WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- looking at Total Population vs Vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingpeoplevaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


-- USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) 
AS (
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingpeoplevaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM PopvsVac;


-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMP TABLE PercentPopulationVaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC, 
    rollingpeoplevaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (
        PARTITION BY cd.location 
        ORDER BY cd.date
    ) AS rollingpeoplevaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv
    ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

SELECT *, 
       (rollingpeoplevaccinated / population) * 100 AS percent_vaccinated
FROM PercentPopulationVaccinated;


-- creating view to store data for future visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (
        PARTITION BY cd.location 
        ORDER BY cd.date
    ) AS rollingpeoplevaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv
    ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL


SELECT * 
FROM percentpopulationvaccinated;
