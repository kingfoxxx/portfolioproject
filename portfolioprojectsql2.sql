SELECT * FROM public.coviddatas
where continent is not NULL
order by 3,4;

SELECT  
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths::float / total_cases) * 100 AS DeathPercentage
FROM 
    public.coviddatas
	--group by date
ORDER BY 1,2;

--create a view for visualization
CREATE OR REPLACE VIEW death_percentage_view AS
SELECT  
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths::float / total_cases) * 100 AS DeathPercentage
FROM 
    public.coviddatas
ORDER BY 
    date, 
    total_cases;

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
ORDER BY 
    date;

--another data for visualization
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
