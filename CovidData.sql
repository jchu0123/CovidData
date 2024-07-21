Select * 
From PortfolioProject..CovidDeaths
Where continent Is Not Null
Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

-- Select data that will be used

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths
-- Percentage of death among cases

Select Location, date, total_cases, total_deaths, (PARSE(total_deaths As Float) / PARSE(total_cases As Float)) * 100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states'
Order by 1,2

-- Total Cases vs Population
-- Percentage of cases in population

Select Location, date, population, total_cases, (PARSE(total_cases As Float) / population) * 100 As CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%states'
Order by 1,2

-- Countries with highest infection rate

Select Location, Population, MAX(total_cases), MAX(PARSE(total_cases As Float) / population) * 100 As CasePercentage
From PortfolioProject..CovidDeaths
--Where location like '%states'
Group by Location, Population
Order by CasePercentage Desc

-- Countries with highest death count

Select Location, MAX(PARSE(total_deaths As Int)) As DeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states'
Where continent Is Not Null
Group by Location
Order by DeathCount Desc

-- Continents with highest death count

Select continent, MAX(PARSE(total_deaths As Int)) As DeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states'
Where continent Is Not Null
Group by continent
Order by DeathCount Desc

-- Global numbers

Select SUM(new_cases) As total_cases, SUM(new_deaths) As total_deaths, SUM(new_deaths) / NULLIF(Sum(new_cases),0) * 100 As DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states'
Where continent Is Not Null
--Group by date
Order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(PARSE(vac.new_vaccinations As Float)) Over (Partition By dea.location 
Order By dea.location, dea.date) As RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent Is Not Null
Order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, popuplation, new_vaccinations, RollingVacCount)
As 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(PARSE(vac.new_vaccinations As Float)) Over (Partition By dea.location 
Order By dea.location, dea.date) As RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent Is Not Null
--Order by 2,3
)

Select *, (RollingVacCount/ popuplation) * 100
From PopvsVac

-- Temp Table

Drop Table If Exists #PercentVac
Create Table #PercentVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingVacCount numeric
)

Insert into #PercentVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(PARSE(vac.new_vaccinations As Float)) Over (Partition By dea.location 
Order By dea.location, dea.date) As RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent Is Not Null
--Order by 2,3

Select *, (RollingVacCount/ population) * 100
From #PercentVac

-- Create View for data

Create View PercentVac As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(PARSE(vac.new_vaccinations As Float)) Over (Partition By dea.location 
Order By dea.location, dea.date) As RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent Is Not Null

Select * 
From PercentVac