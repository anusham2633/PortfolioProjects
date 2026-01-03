Select * 
from PortfolioProject..CovidDeaths$
where continent is not null --w/o this line some locations with continent names will pop, so we have to clean that 
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths$
order by 1,2 


--to find out the death % (total cases vs total deaths) 
--likelihood of dying due to covid in your country 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2 


--comparing total cases & population 
--shows what % of population got covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
order by 1,2 

--looking at countries with highest infection rate compared to population 
Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
GROUP BY location, population
order by PercentPopulationInfected desc

--to find sum of new cases according to location
Select location,population, SUM(new_cases) as new_count 
from PortfolioProject..CovidDeaths$
GROUP BY location,population
order by 1,2


--group by cases in a day
Select date, SUM(new_cases) as daily_cases, SUM(total_cases) as total_num
from PortfolioProject..CovidDeaths$ 
WHERE new_cases  IS NOT NULL AND total_cases IS NOT NULL
GROUP BY date 
order by 1,2

--trying to find how manny positive cases were found when tested
ALTER TABLE PortfolioProject..CovidDeaths$ 
ALTER COLUMN new_tests float 
SELECT location, date,(new_tests*positive_rate) as positive_cases
from PortfolioProject..CovidDeaths$
WHERE new_tests IS NOT NULL AND positive_rate IS NOT NULL
order by location, date  

--get all records for the date '2021-04-01'
SELECT *
from PortfolioProject..CovidDeaths$ 
WHERE date = '2021-04-01'

--showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null --the total is more accurate idk how that works neither does the guy so gg 
GROUP BY location
order by TotalDeathCount desc  

--sort by continent 
--continents w highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null --w/o this line some locations with continent names will pop, so we have to clean that 
GROUP BY continent
order by TotalDeathCount desc  

--if u want to view only one continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where location='Africa' --w/o this line some locations with continent names will pop, so we have to clean that 
GROUP BY location
order by TotalDeathCount desc  

-- GLOBAL NUMBERS 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as overall_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
From PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%states%'
--GROUP BY date --when you have so many things you cant group by, so use aggregate fns. 
--if i keep ^^ group by date, it will give me per day totalcase,overalldeaths
--if i remove it, it will give me the total overall number recorded till that date. 
order by 1,2  


--CTE
--CTE start
With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) 
as 
--no of columns in with and inside parenthesis should match else error
(
--looking at total population vs vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --rolling means the total no of people vac
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$  vac
	On dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
) --CTE ends here
Select * , (RollingPeopleVaccinated/Population)*100 
from PopVsVac 
 


 --TEMPTABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
 (
 continent nvarchar(225),
 location nvarchar(225),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )


 Insert into #PercentPopulationVaccinated 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated --rolling means the total no of people vac
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$  vac
	On dea.location = vac.location and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated 


--VIEW - to store data for later visulations 

CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated --rolling means the total no of people vac
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$  vac
	On dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3 


Select * from PercentPopulationVaccinated