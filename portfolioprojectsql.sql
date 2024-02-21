SELECT * FROM public.coviddatas
--where continent is not null
ORDER BY 3, 4;

-- Selecting specific columns and ordering by the 1st and 2nd columns
SELECT 
    location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM 
    public.coviddatas
ORDER BY 
    1, 
    2;
	
	--  Calculating death percentage and filtering for locations containing 'africa'
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths::float / total_cases) * 100 AS DeathPercentage
FROM 
    public.coviddatas
ORDER BY 
    location, 
    date;
	
	-- looking into total cases vs population
SELECT 
    location, 
    date, 
    total_cases, 
    population, 
    (total_cases::float / population) * 100 AS covidPercentage
FROM 
    public.coviddatas
--WHERE 
--location LIKE '%Africa%'
ORDER BY 
    location, 
    date;
	
	-- looking at countries with highest infection rates compared to populations
SELECT 
    location,  
    MAX(total_cases) as highest_infection_count, 
    population, 
    MAX((total_cases::float / population) * 100) AS percentage_population_infected
FROM 
    public.coviddatas
GROUP BY 
    location, population
ORDER BY 
    percentage_population_infected;
	
	-- show countries with highest death rate
SELECT 
    location,  
    MAX(total_deaths) AS total_death_count
FROM 
    public.coviddatas
	where continent is not null
GROUP BY 
    location
ORDER BY 
    total_death_count desc;
	
	--lets break things by continents
	SELECT 
    continent,  
    MAX(total_deaths::int) AS total_death_count
FROM 
    public.coviddatas
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    total_death_count DESC;

--global numbers
SELECT  
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths::float / total_cases) * 100 AS DeathPercentage
FROM 
    public.coviddatas
--GROUP BY date
ORDER BY 1, 2;

--total deaths summed up
SELECT  
    date, 
    SUM(total_cases) AS total_cases_sum, 
    COALESCE(SUM(total_deaths)::int, 0) AS total_deaths_sum
FROM 
    public.coviddatas
GROUP BY 
    date
ORDER BY 
    1, 2;

--adding death percentage deaths summed up
SELECT  
    date, 
    SUM(total_cases) AS total_cases_sum, 
    COALESCE(SUM(total_deaths)::int, 0) AS total_deaths_sum,
    (COALESCE(SUM(total_deaths), 0)::float / SUM(total_cases)) * 100 AS death_percentage
FROM 
    public.coviddatas
GROUP BY 
    date
ORDER BY 
    1, 2;

--total deaths and percentage without dates
SELECT   
    SUM(total_cases) AS total_cases_sum, 
    COALESCE(SUM(total_deaths)::int, 0) AS total_deaths_sum,
    (COALESCE(SUM(total_deaths), 0)::float / SUM(total_cases)) * 100 AS death_percentage
FROM 
    public.coviddatas
--GROUP BY date
ORDER BY 
    1, 2;

--moving to covidvacc and joining with coviddatas
SELECT * 
FROM public.coviddatas AS dat
JOIN public.covidvacc AS vac
ON dat.location = vac.location
AND dat.date = vac.date;

--looking at total population vs vaccinations
SELECT 
    dat.continent, 
    dat.location, 
    dat.date, 
    dat.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dat.location order by dat.location, dat.date) AS total_new_vaccinations
FROM 
    public.coviddatas AS dat
JOIN 
    public.covidvacc AS vac ON dat.location = vac.location
                             AND dat.date = vac.date
WHERE 
    dat.continent IS NOT NULL
ORDER BY 
    1, 2, 3;

	
	
-- Create a temp table
CREATE TABLE IF NOT EXISTS percentpopulationvac (
    continent VARCHAR(255),
    location VARCHAR(255),
    population NUMERIC,
    total_new_vaccinations NUMERIC
);

-- Insert data into the temp table
INSERT INTO percentpopulationvac (continent, location, population, total_new_vaccinations)
SELECT 
    dat.continent, 
    dat.location, 
    dat.population,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dat.location ORDER BY dat.date) AS total_new_vaccinations
FROM 
    public.coviddatas AS dat
JOIN 
    public.covidvacc AS vac ON dat.location = vac.location
                             AND dat.date = vac.date
WHERE 
    dat.continent IS NOT NULL;



-- Creating a view to store data for visualizations
CREATE OR REPLACE VIEW covidvaccinespercent AS
SELECT 
    dat.continent, 
    dat.location, 
    dat.population,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dat.location ORDER BY dat.date) AS total_new_vaccinations
FROM 
    public.coviddatas AS dat
JOIN 
    public.covidvacc AS vac ON dat.location = vac.location
                             AND dat.date = vac.date
WHERE 
    dat.continent IS NOT NULL;


--still creating view for past results for visualization
CREATE OR REPLACE VIEW joinedcovidvac AS
SELECT 
    dat.*, 
    vac.*
FROM 
    public.coviddatas AS dat
JOIN 
    public.covidvacc AS vac
ON 
    dat.location = vac.location
    AND dat.date = vac.date;

--another visualization
CREATE OR REPLACE VIEW covid_data_summary_view AS
SELECT  
    date, 
    SUM(total_cases) AS total_cases_sum, 
    COALESCE(SUM(total_deaths)::int, 0) AS total_deaths_sum,
    (COALESCE(SUM(total_deaths), 0)::float / SUM(total_cases)) * 100 AS death_percentage
FROM 
    public.coviddatas
GROUP BY 
    date
ORDER BY date;

--death summary visualization
CREATE OR REPLACE VIEW covid_deaths_summary_view AS
SELECT  
    date, 
    SUM(total_cases) AS total_cases_sum, 
    COALESCE(SUM(total_deaths)::int, 0) AS total_deaths_sum
FROM 
    public.coviddatas
GROUP BY 
    date
ORDER BY 
    date;


