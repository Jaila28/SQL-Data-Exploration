--SELECT*
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4 

SELECT*
FROM PortfolioProject..CovidVaccinations
Where Continent is not null
ORDER BY 3,4 

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
and continent is not null
ORDER BY 1,2 

--Looking at the Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your Country

SELECT location, date, total_cases, total_deaths, (total_deaths/TOTAL_CASES)*100 AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
and continent is not null
ORDER BY 1,2

----Looking at Total Cases Vs the population
----Shows what percentage of population

--SELECT location, date, Total_cases, (Total_cases/population)*100 as Percentpopulationinfected
--Where location like '%states%'
--ORDER BY 1,2 

--Looking at countries with highest infection rate compared to population
--What countries has the highest or the lowest percntage of population infected

SELECT location, population, MAX(total_cases) as highestinfectioncount, MAX((Total_Cases/population))*100 as Percentpopulationinfected
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
Group by Location, Population
ORDER by PercentPopulationInfected desc


--Lets break things down by continent-
---Showing the continent with the highest death counts

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by continent
ORDER by TotalDeathCount desc

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by location
ORDER by TotalDeathCount desc


--Global Numbers
--How Many people have died across the globe
SELECT SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by date
ORDER BY 1,2


--Total Cases,Total Deaths, and Death Percentage Per Date
SELECT date, SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
--Group by date
ORDER BY 1,2

--Looking at Total Population vs Vaccinated 
--What is the total amount of people in the world that have been vaccinated?


--Always specify table name.column
Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM  PortfolioProject..CovidDeaths dea -- an alias so that we do not have to type out the table name each time
join PortfolioProject..CovidVaccinations vac -- an alias so that we do not have to type out the table name each time
	On dea.location = vac.location 
	and dea.date =vac.date
	Where dea.continent is not null
	Order by 1,2,3

---New Vaccinations Per Day
Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) Over(Partition by dea.location)--to break the numbers up by location with the date
FROM PortfolioProject..CovidDeaths dea -- an alias so that we do not have to type out the table name each time
join PortfolioProject..CovidVaccinations vac -- an alias so that we do not have to type out the table name each time
	On dea.location = vac.location 
	and dea.date =vac.date
	Where dea.continent is not null
	Order by 1,2,3

	---New Vaccinations Per Day
Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, 
dea.date)as RollingPeopleVaccinated, 
--(RollingPeopleVaccinated/population)*100--to break the numbers up by location with the date
From PortfolioProject..CovidDeaths dea -- an alias so that we do not have to type out the table name each time
join PortfolioProject..CovidVaccinations vac -- an alias so that we do not have to type out the table name each time
	On dea.location = vac.location 
	and dea.date =vac.date
	Where dea.continent is not null
	Order by 2,3


	--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(	
Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, 
dea.date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea -- an alias so that we do not have to type out the table name each time
Join PortfolioProject..CovidVaccinations vac -- an alias so that we do not have to type out the table name each time
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3--
)
Select*, (RollingPeopleVaccinated/population*100)  --How many people in "Blank" Country is vaccinated?
From PopvsVac


--Temp Table
--Create new Table and Columns

Create Table #PercentPolpulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date datetime, 
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPolpulationVaccinated
Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, 
dea.date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea -- an alias so that we do not have to type out the table name each time
Join PortfolioProject..CovidVaccinations vac -- an alias so that we do not have to type out the table name each time
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3--

Select*, (RollingPeopleVaccinated/population*100)  
From PercentPolpulationVaccination

--What if I want to change something in the new table I created, Drop the Table with an IF STATEMENT

DROP Table if exists #PercentPolpulationVaccinated 
--The DROP querie tells the DB that if the table exsist then remove it as its adding another one
Create Table #PercentPolpulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date datetime, 
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPolpulationVaccinated
Select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, 
dea.date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea -- an alias so that we do not have to type out the table name each time
Join PortfolioProject..CovidVaccinations vac -- an alias so that we do not have to type out the table name each time
	On dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3--

Select*, (RollingPeopleVaccinated/population*100)  
From #PercentPolpulationVaccinated


--Creating Views to store data for later visualizations
Create View PercentPolpulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, 
dea.date)as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea -- an alias so that we do not have to type out the table name each time
Join PortfolioProject..CovidVaccinations vac -- an alias so that we do not have to type out the table name each time
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3--


Select *
From PercentPolpulationVaccinated
