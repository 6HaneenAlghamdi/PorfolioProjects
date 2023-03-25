select *
from PortfolioProjectCovid19..CovidDeaths
order by 3,4

select *
from PortfolioProjectCovid19..CovidVaccinations
order by 3,4


--Total Cases VS. Total Deaths
--Case Fatality (Death Percentage)
select location, date, total_cases, total_deaths
, (cast(total_deaths as decimal))/(cast (total_cases as decimal))*100 as DeathPercentage
from PortfolioProjectCovid19 .. covidDeaths
--where location like '%saudi%'
where continent is not null
order by 1,2


--List of Countries from Highest to Lowest
select location, max(cast (total_cases as decimal)) as TotalCases, max(cast (total_deaths as decimal)) as TotalDeaths
,( max(cast (total_deaths as decimal))/max(cast (total_cases as decimal)))*100 as DeathPercentage
from PortfolioProjectCovid19 .. covidDeaths
--where location like '%saudi%'
where continent is not null 
group by location
order by 4 desc


--Total cases VS. Population
--Percentage of population got infected
select location, date, population, total_cases, (total_cases/population)*100 as casesPercentage
from PortfolioProjectCovid19..CovidDeaths
--Where location like '%saudi%' 
where continent is not null
order by 1,2


--List of Countries from  Highest to Lowest infection rate 
select location, population, max (cast (total_cases as decimal)) as TotalCases
,(max (cast (total_cases as decimal))/population)*100 as PercentPopulationInfected
from PortfolioProjectCovid19..CovidDeaths
--where location like '%saudi%'
where continent is not null
group by location, population
order by 4 desc


--Countries with highest death count
select location, max (cast (total_deaths as decimal)) as TotalDeaths
from PortfolioProjectCovid19..CovidDeaths
--where location like '%saudi%'
where continent is not null
group by location
order by 2 desc


--Let's break things down by continent
--Showing continent with highest death count per population
select location, max (cast (total_deaths as decimal)) as TotalDeaths
from PortfolioProjectCovid19..CovidDeaths
where continent is null
group by location
order by 2 desc
--Some rows show income,
--delete from PortfolioProjectCovid19..CovidDeaths where location like '%income%'


--Global numbers (Death percentage across the world)
select sum(new_cases) as TotaCases, sum(new_deaths) as TotalDeaths
, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProjectCovid19 .. covidDeaths
where continent is not null


--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum (convert (bigint,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as VaccineDosesAdministered
from PortfolioProjectCovid19..CovidDeaths dea
join PortfolioProjectCovid19..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null --and dea.location like '%saudi%'
order by 2,3


--List of Countries from  Highest to Lowest vaccination rate 
--CTE
With popvsvac ( location, population, TotalPeopleVaccinated)
as (
select distinct dea.location, population
, max(convert(bigint, vac.people_vaccinated)) over (partition by dea.location
order by dea.location) as TotalPeopleVaccinated
from PortfolioProjectCovid19..CovidDeaths dea
join PortfolioProjectCovid19..CovidVaccinations vac
on dea.location = vac.location
where dea.continent is not null --and dea.location like '%saudi%'
group by dea.location, population, vac.new_vaccinations, vac.people_vaccinated
)

select *, (TotalPeopleVaccinated/population)*100 as percentage
from popvsvac
order by 4 desc


--TempTable
Create Table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum (convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProjectCovid19..CovidDeaths dea
join PortfolioProjectCovid19..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as percentage
from #percentpopulationvaccinated



--creating view to store data for later visualizations
create view VaccineDosesAdministered as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum (convert (bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as TotalDosesAdministered
from PortfolioProjectCovid19..CovidDeaths dea
join PortfolioProjectCovid19..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from VaccineDosesAdministered