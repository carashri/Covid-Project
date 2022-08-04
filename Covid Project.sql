Select *
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project].dbo.CovidVaccinations
--order by 3,4

-- Select Data we are going to be using

--Select Location,date, total_cases, new_cases, total_deaths, population
--From [Portfolio Project].dbo.CovidDeaths
--order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract Covid in your country
Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
Where location like '%states%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of the population got Covid
Select Location,date, total_cases, population, (total_cases/population)*100 AS PercentCovid
From [Portfolio Project].dbo.CovidDeaths
Where location like '%states%'
order by 1,2

-- Countries with highest infection rates compared with population

Select Location,Population, max(total_cases) AS HighestInfectionCt, max((total_cases/population))*100 AS PercentPopInfected
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentPopInfected DESC

-- Showing countries with the highest death count per population
Select Location, max(cast(total_deaths as int)) AS TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount DESC

-- Breaking things down by continent:continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) AS TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount DESC


--Global Numbers: Percent death across the world by date

Select date, SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2


--Global Numbers: Percent death across the world overall: 2.11% death rate

Select SUM(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
order by 1,2


-- Total Population vs. Vaccinations

--Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinated) 
as 
(

Select dea.continent, dea.population, dea.location, dea.date, dea.population, vac.new_vaccinations as new_vaccinations_per_day, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccinated
--, (total_vaccinated/population)*100

from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (total_vaccinated/population)*100 as rolling_pct_vaccinated
from PopvsVac


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as new_vaccinations_per_day, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccinated
--, (total_vaccinated/population)*100

from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (total_vaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated7 
as
Select dea.continent, dea.population, dea.location, dea.date, vac.new_vaccinations --as new_vaccinations_per_day--, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as total_vaccinated
--, (total_vaccinated/population)*100

from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--order by 2,3