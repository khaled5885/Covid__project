select*from project..CovidDeaths$
order by 3,4


select location , date,total_cases,new_cases,total_deaths,population
from project..CovidDeaths$
order by 1,2


select location , date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from project..CovidDeaths$
where location like '%Egypt%'
order by 1,2


select location , date,total_cases,population,(total_cases/population)*100 as population_infected_percentage
from project..CovidDeaths$
order by 1,2

select location ,Max (total_cases)as maxcase,population,max(total_cases/population)*100 as population_infected_percentage
from project..CovidDeaths$
group by location,population
order by population_infected_percentage desc


select location,max(cast(total_deaths as int))as deaths
from project..CovidDeaths$
where continent is not null 
group by location
order by deaths desc


select location,max(cast(total_deaths as int))as deaths
from project..CovidDeaths$
where continent is  null 
group by location
order by deaths desc


select date,sum(new_cases)as cases,sum(cast(new_deaths as int))as deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from project..CovidDeaths$
where continent is not null
group by date
order by 1,2


select sum(new_cases)as cases,sum(cast(new_deaths as int))as deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from project..CovidDeaths$
where continent is not null
order by 1,2


select*
from project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations  ))over(PARTITION by dea.location order by dea.location,dea.date)as vaccinated
from project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3


with popvsvac(continent,location,date,population,new_vaccinations,vaccinated)
as
(
select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations  ))over(PARTITION by dea.location order by dea.location,dea.date)as vaccinated

from project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
)
select*,(vaccinated/population)*100 as vaccin
from popvsvac


drop Table if exists #vaccine_percent
create table #vaccine_percent
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations  numeric,
vaccinated numeric

)
insert into #vaccine_percent
select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations  ))over(PARTITION by dea.location order by dea.location,dea.date)as vaccinated

from project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
select*,(vaccinated/population)*100 as vaccin
from #vaccine_percent


create view vaccine_percent as
select dea.continent ,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations  ))over(PARTITION by dea.location order by dea.location,dea.date)as vaccinated

from project..CovidDeaths$ dea
join project..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 


select*
from vaccine_percent
