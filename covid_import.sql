/*LOAD COVID DATA*/
/*https://www.mysqltutorial.org/import-csv-file-mysql-table/*/

create table covid.ontario (
	Row_ID INT,
    Accurate_Episode_Date DATE,
    Case_Reported_Date DATE,
    Test_Reported_Date DATE,
    Specimen_Date DATE,
    Age_Group TEXT,
    Client_Gender TEXT,
    Case_AcquisitionInfo TEXT,
    Outcome1 TEXT,
    Outbreak_Related TEXT NULL,
    Reporting_PHU_ID INT,
    Reporting_PHU TEXT,
    Reporting_PHU_Address TEXT,
    Reporting_PHU_City TEXT,
    Reporting_PHU_Postal_Code TEXT,
    PRIMARY KEY (Row_ID)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/conposcovidloc.csv' 
INTO TABLE covid.ontario
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Row_ID, @Accurate_Episode_Date, @Case_Reported_Date, @Test_Reported_Date, @Specimen_Date, Age_Group, Client_Gender, Case_AcquisitionInfo, Outcome1, Outbreak_Related, Reporting_PHU_ID, Reporting_PHU, Reporting_PHU_Address, Reporting_PHU_City, Reporting_PHU_Postal_Code)
SET 
	Accurate_Episode_Date = str_to_date(@Accurate_Episode_Date, '%m/%d/%Y'),
	Case_Reported_Date = str_to_date(@Case_Reported_Date, '%m/%d/%Y'),
	Test_Reported_Date = str_to_date(@Test_Reported_Date, '%m/%d/%Y'),
	Specimen_Date = str_to_date(@Specimen_Date, '%m/%d/%Y');

/*LOAD DEMOGRAPHIC DATA*/
/*https://www12.statcan.gc.ca/census-recensement/2016/dp-pd/prof/search-recherche/lst/results-resultats.cfm?Lang=E&TABID=1&G=1&Geo1=&Code1=&Geo2=&Code2=&GEOCODE=35&type=0*/

create table covid.demographics (
	CENSUS_YEAR INT,
    GEO_NAME TEXT,
    AGE_DESCRIPTION TEXT,
    MEMBER_ID INT,
    TOTAL_SEX TEXT,
    MALE TEXT,
    FEMALE TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ontario_demographics_2020.csv' 
INTO TABLE covid.demographics
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

delete from covid.demographics 
where GEO_NAME not in (
	'Barrie', 
    'Belleville', 
    'Brantford', 
    'Brockville', 
    'Chatham', 
    'Cornwall',
    'Guelph',
    'Hamilton',
    'Kenora',
    'Kingston',
    'London',
    'Mississauga',
    'New Liskeard',
    'Newmarket',
    'North Bay',
    'Oakville',
    'Ottawa',
    'Owen Sound',
    'Pembroke',
    'Peterborough',
    'Point Edward',
    'Port Hope',
    'Sault Ste. Marie',
    'Simcoe',
    'St. Thomas',
    'Stratford',
    'Sudbury',
    'Thorold',
    'Thunder Bay',
    'Timmins',
    'Toronto',
    'Waterloo',
    'Whitby',
    'Windsor'
);

select distinct(AGE_DESCRIPTION) from covid.demographics;

delete from covid.demographics where AGE_DESCRIPTION not like "%year%";
delete from covid.demographics where AGE_DESCRIPTION like "Total%";
delete from covid.demographics where length(AGE_DESCRIPTION) > 25;
delete from covid.demographics where AGE_DESCRIPTION like '%(%)';

select distinct(AGE_DESCRIPTION) from covid.demographics;

select AGE_DESCRIPTION,
case
when (AGE_DESCRIPTION like '0%' and AGE_DESCRIPTION not like '%(%)') or (AGE_DESCRIPTION like '10 %') then '<20'
when AGE_DESCRIPTION like '2%' and AGE_DESCRIPTION not like '%44%' then '20s'
when AGE_DESCRIPTION like '3%' then '30s'
when AGE_DESCRIPTION like '4_ to%' then '40s'
when AGE_DESCRIPTION like '5_ to%' then '50s'
when AGE_DESCRIPTION like '6_ to%' then '60s'
when AGE_DESCRIPTION like '7%' then '70s'
when AGE_DESCRIPTION like '8_ to%' then '80s'
when AGE_DESCRIPTION like '9%' then '90s'
else null
end as AGE_GROUP
from covid.demographics group by AGE_DESCRIPTION order by AGE_GROUP DESC;

alter table covid.demographics
add column AGE_GROUP TEXT after AGE_DESCRIPTION;

update
	covid.demographics
set AGE_GROUP = case when (AGE_DESCRIPTION like '0%' and AGE_DESCRIPTION not like '%(%)') or (AGE_DESCRIPTION like '10 %') then '<20'
when AGE_DESCRIPTION like '2%' and AGE_DESCRIPTION not like '%44%' then '20s'
when AGE_DESCRIPTION like '3%' then '30s'
when AGE_DESCRIPTION like '4_ to%' then '40s'
when AGE_DESCRIPTION like '5_ to%' then '50s'
when AGE_DESCRIPTION like '6_ to%' then '60s'
when AGE_DESCRIPTION like '7%' then '70s'
when AGE_DESCRIPTION like '8_ to%' then '80s'
when AGE_DESCRIPTION like '9%' then '90s'
else null
end;

delete from covid.demographics where MALE = '...' or FEMALE = '...';

ALTER TABLE covid.demographics MODIFY TOTAL_SEX INTEGER;
ALTER TABLE covid.demographics MODIFY MALE INTEGER;
ALTER TABLE covid.demographics MODIFY FEMALE INTEGER;

delete from covid.demographics where MEMBER_ID = 35;
delete from covid.demographics where MEMBER_ID = 9 or MEMBER_ID = 863 or MEMBER_ID = 853;
delete from covid.demographics where MEMBER_ID = 10 or MEMBER_ID = 864 or MEMBER_ID = 854;
delete from covid.demographics where MEMBER_ID = 12 or MEMBER_ID = 849;