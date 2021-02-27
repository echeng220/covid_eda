/*Get top 5 age groups with highest case count*/
select Age_group, count(*) as cases from covid.ontario 
group by Age_Group
order by cases desc limit 5;

/*Get case count broken out by age and gender*/
select Client_Gender, Age_Group, count(*) as cases from covid.ontario
group by Client_Gender, Age_Group
order by cases desc;

/*Get deaths for each age group*/
select Age_Group, Client_Gender, count(*) as deaths from covid.ontario
where Outcome1 = 'Fatal'
group by Client_Gender, Age_Group
order by deaths desc;

/*Get fatality rate for each age group/gender in Ontario*/
select c.Age_Group, c.Client_Gender, c.cases, d.deaths, cast((d.deaths / c.cases) as decimal(8,6)) as death_rate 
from ( select Age_Group, Client_Gender, count(*) as cases 
from covid.ontario group by Client_Gender, Age_Group) as c
join
( select Age_Group, Client_Gender, count(*) as deaths from covid.ontario
where Outcome1 = 'Fatal' group by Client_Gender, Age_Group) as d
on c.Age_Group = d.Age_Group and c.Client_Gender = d.Client_Gender
order by death_rate desc;

/*Get overall death rate in Ontario*/
select ((select count(*) from covid.ontario where Outcome1 = 'Fatal') / count(*)) as overall_death_rate from covid.ontario;

/*Get percentage of population that has been infected for 20 largest cities in Ontario*/
select d.GEO_NAME, o.cases, d.population, o.cases / d.population as infection from
(select Reporting_PHU_City, count(*) as cases from covid.ontario group by Reporting_PHU_City) as o
join
(select GEO_NAME, sum(TOTAL_SEX) as population from covid.demographics where AGE_GROUP is not null 
group by GEO_NAME order by population desc limit 20) as d
on d.GEO_NAME = o.Reporting_PHU_City 
order by infection desc;

/*Get percentage of each age group that has been infected in Ontario*/
select o.Age_Group, o.cases, d.population, o.cases / d.population as age_infection_rate from
(select Age_Group, count(*) as cases from covid.ontario 
group by Age_Group) as o
join
(select AGE_GROUP, sum(TOTAL_SEX) as population from covid.demographics 
where AGE_GROUP is not null
group by AGE_GROUP) as d
on d.AGE_GROUP = o.Age_Group 
order by age_infection_rate desc;

/*Get most common transmission mechanism for each age group in Ontario*/
/*https://stackoverflow.com/questions/12102200/get-records-with-max-value-for-each-group-of-grouped-sql-results*/
select o1.* from 
(select Age_Group, Case_AcquisitionInfo, count(*) as cases from covid.ontario 
where Age_Group is not null and Age_Group <> '' and Age_Group <> 'UNKNOWN'
group by Age_Group, Case_AcquisitionInfo order by Age_Group, cases desc) as o1
join
(select Age_Group, Case_AcquisitionInfo, count(*) as cases from covid.ontario 
where Age_Group is not null and Age_Group <> '' and Age_Group <> 'UNKNOWN'
group by Age_Group, Case_AcquisitionInfo order by Age_Group, cases desc) as o2
on o1.Age_Group = o2.Age_Group and o1.cases > o2.cases
group by Age_Group order by o1.Age_Group;

/*Get most common transmission mechanism for each city in Ontario*/
select o1.* from 
(select Reporting_PHU_City, Case_AcquisitionInfo, count(*) as cases from covid.ontario 
group by Reporting_PHU_City, Case_AcquisitionInfo order by cases desc) as o1
join
(select Reporting_PHU_City, Case_AcquisitionInfo, count(*) as cases from covid.ontario 
group by Reporting_PHU_City, Case_AcquisitionInfo order by cases desc) as o2
on o1.Reporting_PHU_City = o2.Reporting_PHU_City and o1.cases > o2.cases
group by Reporting_PHU_City order by o2.cases desc limit 10;

/*Get population distributions for all cities*/
select GEO_NAME, AGE_GROUP, sum(TOTAL_SEX) as group_pop from covid.demographics
where AGE_GROUP is not null
group by GEO_NAME, AGE_GROUP order by GEO_NAME, AGE_GROUP;

/*Get total population for each city*/
select GEO_NAME, sum(TOTAL_SEX) as city_pop from covid.demographics
where AGE_GROUP is not null
group by GEO_NAME order by city_pop desc;

/*Get percent of population for each age group for 5 largest cities in Ontario*/
select a.GEO_NAME, a.AGE_GROUP, a.group_pop, t.city_pop, (a.group_pop / t.city_pop * 100) as pct_pop from
(select GEO_NAME, AGE_GROUP, sum(TOTAL_SEX) as group_pop from covid.demographics
where AGE_GROUP is not null and GEO_NAME in ('Windsor', 'Toronto', 'Guelph', 'Kingston')
group by GEO_NAME, AGE_GROUP order by GEO_NAME, AGE_GROUP) as a
left join
(select GEO_NAME, sum(TOTAL_SEX) as city_pop from covid.demographics
where AGE_GROUP is not null and GEO_NAME in ('Windsor', 'Toronto', 'Guelph', 'Kingston')
group by GEO_NAME order by city_pop desc) as t
on a.GEO_NAME = t.GEO_NAME
order by t.city_pop desc, a.GEO_NAME, a.AGE_GROUP;

/*Get population distribution for Ontario overall*/
select AGE_GROUP, sum(TOTAL_SEX) / (select sum(TOTAL_SEX) from covid.demographics where AGE_GROUP is not null) * 100 as on_pct_pop 
from covid.demographics
where AGE_GROUP is not null
group by AGE_GROUP order by AGE_GROUP;

/*Get total reported cases per month in 2020, broken out by select cities*/
select date_format(Case_Reported_Date, "%Y-%m") ym, Reporting_PHU_City, count(*) as cases 
from covid.ontario 
where Reporting_PHU_City in ('Windsor', 'Toronto', 'Guelph', 'Kingston') and year(Case_Reported_Date) = '2020'
group by Reporting_PHU_City, ym order by ym;

/*Get difference between reported case date and estimated onset date for each month*/
select date_format(Case_Reported_Date, "%Y-%m") as crd, date_format(Accurate_Episode_Date, "%Y-%m") as aed,
avg(datediff(Case_Reported_Date, Accurate_Episode_Date)) as avg_diff
from covid.ontario
group by crd
order by crd;

/*Get difference between reported case date and estimated onset date by city*/
select Reporting_PHU_City, date_format(Case_Reported_Date, "%Y-%m") as crd, date_format(Accurate_Episode_Date, "%Y-%m") as aed,
avg(datediff(Case_Reported_Date, Accurate_Episode_Date)) as avg_diff
from covid.ontario
where Reporting_PHU_City in ('Toronto', 'Mississauga', 'Windsor', 'Guelph', 'Ottawa', 'Hamilton', 'Kingston')
group by Reporting_PHU_City, crd
order by crd;

/*Get difference between reported case date and estimated onset date for each month by age group*/
select Age_Group, date_format(Case_Reported_Date, "%Y-%m") as crd, date_format(Accurate_Episode_Date, "%Y-%m") as aed,
avg(datediff(Case_Reported_Date, Accurate_Episode_Date)) as avg_diff
from covid.ontario
group by Age_Group, crd
order by crd;

/*Take random sample of 100 cases in Toronto*/
select t.Age_Group, count(*) from 
(select * from covid.ontario
where Age_Group <> 'UNKNOWN' and Age_group is not null and Age_Group <> '' and Reporting_PHU_City = 'Toronto'
order by rand()
limit 100) as t
group by t.Age_Group;

/*Take random sample of 100 cases in Toronto*/
select w.Age_Group, count(*) from 
(select * from covid.ontario
where Age_Group <> 'UNKNOWN' and Age_group is not null and Age_Group <> '' and Reporting_PHU_City = 'Toronto'
order by rand()
limit 100) as w
group by w.Age_Group;