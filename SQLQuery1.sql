
-- Select Data that we are going to use 
 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


--Looking at total cases vs. total deaths 
--Shows likelihood of dying if you get covid in your country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
and continent is not null 
order by 1,2

--Looking at the total cases vs the population 
--Shows what % of population got covid 

SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
Where continent is not null 
order by 1,2


--Looking at countries with highest infection rate compared to population
SELECT Location, MAX(total_cases) as HighestInfectionCount, Population,  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
Where continent is not null 
Group by population,Location
order by 4 desc


--break things down by continent 
--Showing Continents with highest death counts per population 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases,SUM(cast (new_deaths as int)) as total_deaths, (SUM(cast (new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
--group by date 
order by 1,2



--Looking at total population vs vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast (vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.Location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
order by 2,3


--Use a CTE 
	WITH PopvsVac (continent, Location, date, Population,new_vaccinations , RollingPeopleVaccinated)
	as (
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(cast (vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.Location, dea.date)
	as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
	Where dea.continent is not null 
	--order by 2,3
	)
	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac


-- Temp Tables

--Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast (vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.Location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 
order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated