select * 
FROM dbo.CovidDeaths
where continent is not null
order by 3,4;


--select * 
--FROM dbo.CovidVaccinations
--order by 3,4;

-- Select the columns tha we would be using
select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2;

  -- Looking at the Total cases vs Total Deaths
  -- Getting the likelihood of dieing if infected with covid 
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%states%'
order by 1,2;



-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from dbo.CovidDeaths
order by 1,2;


-- Looking at countries with highest infection rate compared to population
select location, population , max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from dbo.CovidDeaths
group by location, population
order by PercentPopulationInfected desc;


-- Showing countries with Highest Death counts per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENTS

-- Showing the Continents with the highest Death Counts

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
-- Percentage of Total Deaths per Total cases each day
select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by date 
order by 1,2;

-- Percentage of Total Deaths accross the world
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null 
-- group by date
order by 1,2; --2.112%

-- THE COVID VACCINATION TABLE
-- Joined both tables

-- Looking at Total Population vs Vaccination (To get total number of people in the world that as been vaccinated)


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- because we want the count to start over whenever it gets to a new location
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- We want to use the MAX number from our rolling count and divide it by population to know the number of people vaccinated in a location

--USING CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- because we want the count to start over whenever it gets to a new location
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;

-- TEMP TABLE
DROP table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into  #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- because we want the count to start over whenever it gets to a new location
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;


-- Creating views to store data for later Visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated -- because we want the count to start over whenever it gets to a new location
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated;



