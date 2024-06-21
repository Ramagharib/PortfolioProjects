select * 
from PortfolioProject..covidDeaths
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

select Location, date , total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeaths


--Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if your contract covid in your country 

select Location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from PortfolioProject..covidDeaths
where location like 'Tunisia'
order by 1,2

use PortfolioProject;

select COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='covidDeaths'

alter table covidDeaths 
alter column total_cases float;

--looking at total cases vs population 

select Location, date ,population, total_cases,  (total_cases/population)*100 as casesPercentage
from PortfolioProject..covidDeaths
order by 1,2

--looking at countries with highest infection rate copared to population

select Location,population,
max(total_cases) as HighestInfectionCount, 
max((total_cases/population))*100 as casesPercentage
from PortfolioProject..covidDeaths
Group by Location,Population
order by casesPercentage desc

-- showing the countries with the highest death count per population

select Location,
max(total_deaths) as totalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
Group by Location
order by totalDeathCount desc


--break things down by continent 

select location,
max(total_deaths) as totalDeathCount
from PortfolioProject..covidDeaths
where continent is null
Group by location
order by totalDeathCount desc

--showing  contintents with the highest death count per population

select continent,
max(total_deaths) as totalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
Group by continent
order by totalDeathCount desc

--Global numbers 

select 
	SUM(new_cases) as totalCases, 
	SUM(new_deaths) as totalDeaths, 
	SUM(new_deaths)/SUM(new_cases)*100 AS deathPercentage 
from PortfolioProject..covidDeaths 
where continent is not null



--Looking at Total Population vs Vaccinations


select dea.continent, dea.location, dea.date , 
	dea.population, vac.new_vaccinations,
	sum(convert (int,vac.new_vaccinations)) 
	OVER (Partition by dea.Location,dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE
with PopvsVac(continent ,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated )
as
(
select dea.continent, dea.location, dea.date , 
	dea.population, vac.new_vaccinations,
	sum(convert (int,vac.new_vaccinations)) 
	OVER (Partition by dea.Location,dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date , 
	dea.population, vac.new_vaccinations,
	sum(convert (int,vac.new_vaccinations)) 
	OVER (Partition by dea.Location,dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--creating View to store data for later visualizations 


 create View PercentPopulationVaccinated as 
 select dea.continent, dea.location, dea.date , 
	dea.population, vac.new_vaccinations,
	sum(convert (int,vac.new_vaccinations)) 
	OVER (Partition by dea.Location,dea.date) as RollingPeopleVaccinated
--	,(RollingPeopleVaccinated/population)*100
from PortfolioProject..covidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated