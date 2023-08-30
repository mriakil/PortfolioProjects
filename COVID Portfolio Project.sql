

Select *
From PortfolioProjects..CovidDeaths
where continent is not NULL
order by 3, 4


--Select *
--From PortfolioProjects..CovidVaccination
--order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
where continent is not NULL
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%Bangladesh%'
and continent is not NULL
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%Bangladesh%'
order by 1,2

--Select Location, date, population, total_cases, (cast(total_cases as float) / cast(population as float))*100 as PercentPopulationInfected
--From PortfolioProjects..CovidDeaths
----Where location like '%Bangladesh%'
--order by 1,2



-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%Bangladesh%'
Group By Location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count Per Population 
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%Bangladesh%'
where continent is not NULL
Group By Location
order by TotalDeathCount desc


--Deaths By Continent

-- showing continents with the highest death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%Bangladesh%'
where continent is not NULL
Group By continent
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
--Where location like '%Bangladesh%'
where continent is not NULL
order by 1,2


-- Looking at total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.Location Order By
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.Location Order By
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
From PopvsVac


--TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinatiions numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.Location Order By
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not NULL
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
From #PercentPopulationVaccinated


--Creating view to store data for later visulaizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.Location Order By
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

Select *
From PercentPopulationVaccinated