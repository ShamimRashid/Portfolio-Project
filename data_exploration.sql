Select *
From portfolio_project..Covid_Deaths$
Where continent is not null
order by 1,2



-- Select Data that we are going to use 
Select location,date, total_cases, new_cases, total_deaths, population
From portfolio_project..Covid_Deaths$
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid-19
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From portfolio_project..Covid_Deaths$
where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 AS covidPecentage
From portfolio_project..Covid_Deaths$
where location like '%states%'
order by 1,2

-- Looking at Countries and highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) *100 AS percentPopulationInfected
From portfolio_project..Covid_Deaths$
--where location like '%states%'
Group by location, population
order by 1,2


-- Showing countries with highest death count by population
Select location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population)) *100 AS percentPopulationDeath
From portfolio_project..Covid_Deaths$
--where location like '%states%'
Group by location, population
order by 1,2


Select location, MAX(total_deaths) AS TotalDeathCount
From portfolio_project..Covid_Deaths$
--where location like '%states%'
Group by location
order by TotalDeathCount desc

-- Showing countries with highest death count

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolio_project..Covid_Deaths$
--where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing continents with highest death count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolio_project..Covid_Deaths$
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing countries with highest death count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolio_project..Covid_Deaths$
--where location like '%states%'
Where continent is  null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From portfolio_project..Covid_Deaths$
where continent is not null
Group by date
order by 1,2


-- Total population vs Vaccination
--Shows percentage of population that has received at least on covid vacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..Covid_Deaths$ dea
Join portfolio_project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition by in previous query

With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..Covid_Deaths$ dea
Join portfolio_project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsVac

GO

--Creating a Temp table to perform calculation on Partition by in previous query
DROP Table if exists #percpopulationvaccinated
Create Table #percpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

--inserting from the CTE
Insert into #percpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..Covid_Deaths$ dea
Join portfolio_project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #percpopulationvaccinated



GO

--Creating view to store data for later visualizations

GO

Create View percpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..Covid_Deaths$ dea
Join portfolio_project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
GO

 SELECT *FROM percpopulationvaccinated

