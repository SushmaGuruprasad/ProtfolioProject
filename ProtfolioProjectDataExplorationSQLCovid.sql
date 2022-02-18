-- Select all the Columns form Covid Death table
Select *
from CovidDeaths
where continent is not null
order by location, date

-- Select all the Columns form Covid Vaccination table
Select *
from CovidVaccinations
where continent is not null
order by location, date

--Total cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathvsCasesPercentage
from CovidDeaths
where continent is not null
order by location, DeathvsCasesPercentage desc

--Total cases vs Total Deaths for U.S.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathvsCasesPercentage
from CovidDeaths
where continent is not null and location like '%states%'
order by location, DeathvsCasesPercentage desc

--Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as CasesvsPopulationPercentage
from CovidDeaths
where continent is not null
order by CasesvsPopulationPercentage desc, location

--Countries with Highest Infection Rate compared to Population
Select location, population, max(total_cases), (max(total_cases)/population)*100 as HighestInfectionvsPopulationPercentage
from CovidDeaths
where continent is not null
group by population, location
order by HighestInfectionvsPopulationPercentage desc


--Countries with Highest Death Rate compared to Population
Select location, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--Contients with Highest Death Rate compared to Population ????
Select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (sum(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by DeathPercentage

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population,vacc.new_vaccinations,
SUM(vacc.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as Dea
join CovidVaccinations as Vacc
	on Dea.location = vacc.location
	and Dea.date = Vacc.date
where dea.continent is not null
order by 2,3

--Use CTE to perform Calculation on Partition By in the previous query ????
With PopvsVacc(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vacc.new_vaccinations,
SUM(vacc.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as Dea
join CovidVaccinations as Vacc
	on Dea.location = vacc.location
	and Dea.date = Vacc.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from PopvsVacc
order by location

--Using Temp Table to perform Calucations on Partition by
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nVarchar(255),
Location nVarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vacc.new_vaccinations,
SUM(vacc.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as Dea
join CovidVaccinations as Vacc
	on Dea.location = vacc.location
	and Dea.date = Vacc.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from #PercentagePopulationVaccinated

--Creating view to store data for later Visulizations
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vacc.new_vaccinations,
SUM(vacc.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths as Dea
join CovidVaccinations as Vacc
	on Dea.location = vacc.location
	and Dea.date = Vacc.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from PercentagePopulationVaccinated