-- Demographic table is imported as popchar
-- FBI Crime 2015 data is saved as Crime

--Creating a table for 2015 demographic data

SELECT * FROM popchar

CREATE TABLE popchar_2015 (

state varchar(50) NOT NULL,
gender varchar (50) NOT NULL,
race varchar (50) NOT NULL,
age int NOT NULL,
population int NOT NULL ,
)
;

--CASE to replace keys to readable values
--SEX : 0= Total, 1 = Male, 2= Female
--ORIGIN: 0 = Total, 1 = Not Hispanic, 2 = Hispanic
--RACE: 
--1 = White Alone
--2 = Black or African American Alone
--3 = American Indian or Alaska Native Alone
--4 = Asian Alone
--5 = Native Hawaiian and Other Pacific Islander Alone
--6 = Two or more races

ALTER TABLE popchar
ADD sex_m VARCHAR(50) 

UPDATE popchar
SET sex_m = CASE 
    WHEN (SEX = 0 ) THEN 'TOTAL'
	WHEN (SEX = 1 ) THEN 'MALE'
	WHEN (SEX = 2 ) THEN 'FEMALE'
END
FROM popchar


ALTER TABLE popchar
ADD racem VARCHAR(50) 

UPDATE popchar

SET racem = CASE


WHEN (RACE = 1) THEN 'White Alone'
WHEN (RACE = 2) THEN 'African American Alone'
WHEN (RACE = 3) THEN 'Alaska Native Alone'
WHEN (RACE = 4) THEN 'Asian Alone'
WHEN (RACE = 5) THEN 'Pacific Islander Alone'
WHEN (RACE = 6) THEN 'one more races'
END
FROM popchar


-- Inserting 2015 state, gender, race, age and population columns to pop_2015 table
INSERT INTO popchar_2015 (state, gender, race,age, population)
SELECT NAME,sex_m, racem, AGE,POPESTIMATE2015
FROM popchar



-- Crime data modification 



-- explore total crime per state

SELECT st, (SUM(violent_crime+property_crime+burglary+larceny_theft+motor_vehicle_theft)) AS TotalCrime FROM crimedata
GROUP BY st 
ORDER BY TotalCrime DESC


--Taking care of NULL values in crime columns

UPDATE crimedata
SET violent_crime =0 WHERE violent_crime IS NULL 

UPDATE crimedata
SET property_crime =0 WHERE property_crime IS NULL

UPDATE crimedata
SET burglary =0 WHERE burglary IS NULL

UPDATE crimedata
SET larceny_theft =0 WHERE larceny_theft IS NULL


UPDATE crimedata
SET motor_vehicle_theft =0 WHERE motor_vehicle_theft IS NULL



-- Grouping crime data on state level to make a separate table to join with demographic data


-- create table for crime rate per state


CREATE TABLE crime_state (

state varchar(50),
t_pop bigint,
t_ViolentCrime bigint ,
t_PropertyCrime bigint ,
t_Burglary bigint ,
t_LarcenyTheft bigint ,
t_VehicleTheft bigint 


)

-- inserting into crime state table from group by query result 


INSERT INTO crime_state (state, t_pop,t_ViolentCrime,t_PropertyCrime,t_Burglary,t_LarcenyTheft,t_VehicleTheft)
SELECT 
st, 
SUM([population]) as t_pop,
SUM([violent_crime]) as t_ViolentCrime,
SUM([property_crime])as t_PropertyCrime,
SUM([burglary]) as t_Burglary,
SUM([larceny_theft]) as t_LarcenyTheft,
SUM([motor_vehicle_theft])as t_VehicleTheft

FROM crimedata 
GROUP BY st





-- Exploring cleaned Crime_data
-- Total Crime ratio per state has been calculated to be # of crimes / # population 
-- Applying RANK Function on each criminal cateogry 


SELECT 

state,
CrimeRatio = (SUM(t_ViolentCrime+t_PropertyCrime+t_burglary+t_LarcenyTheft+t_VehicleTheft)*0.1/ SUM(t_pop)),
ViolentCrimeRank = RANK() OVER(ORDER BY (SUM(t_ViolentCrime)*0.1 / SUM(t_pop)) DESC),
PropertyCrimeRank = RANK() OVER(ORDER BY (SUM(t_PropertyCrime)*0.1 / SUM(t_pop)) DESC),
BurglaryRank = RANK() OVER(ORDER BY (SUM(t_burglary)*0.1 / SUM(t_pop)) DESC),
LarcenyTheftRank = RANK() OVER(ORDER BY (SUM(t_LarcenyTheft)*0.1 / SUM(t_pop)) DESC),
VehicleTheftRank = RANK() OVER(ORDER BY (SUM(t_VehicleTheft)*0.1 / SUM(t_pop)) DESC)


FROM crime_state 

GROUP BY state



-- Joining Crime rank and  male population ratio to explore if there's any relationship between crime rate and male ratio per state
-- Selecting final columns to be returned from 3 joined tables


SELECT 

crimetable.state,
CrimeRatio,
ViolentCrimeRank,
PropertyCrimeRank,
BurglaryRank,
LarcenyTheftRank,
VehicleTheftRank,
MaleRatio,
MaleRatioRank 


FROM 

(
SELECT 

state,
CrimeRatio = (SUM(t_ViolentCrime+t_PropertyCrime+t_burglary+t_LarcenyTheft+t_VehicleTheft)*0.1/ SUM(t_pop)),
ViolentCrimeRank = RANK() OVER(ORDER BY (SUM(t_ViolentCrime)*0.1 / SUM(t_pop)) DESC),
PropertyCrimeRank = RANK() OVER(ORDER BY (SUM(t_PropertyCrime)*0.1 / SUM(t_pop)) DESC),
BurglaryRank = RANK() OVER(ORDER BY (SUM(t_burglary)*0.1 / SUM(t_pop)) DESC),
LarcenyTheftRank = RANK() OVER(ORDER BY (SUM(t_LarcenyTheft)*0.1 / SUM(t_pop)) DESC),
VehicleTheftRank = RANK() OVER(ORDER BY (SUM(t_VehicleTheft)*0.1 / SUM(t_pop)) DESC)

FROM crime_state 
GROUP BY state

) AS crimetable 

JOIN 

(SELECT 

one.state,
Total_Population,
MalePopulation,
MaleRatio = MalePopulation*0.1/Total_Population,
MaleRatioRank =  RANK() OVER(ORDER BY MalePopulation*0.1/Total_Population DESC) 
FROM 
( 

SELECT 
state, 
Total_Population = SUM(population) 
FROM popchar_2015
WHERE gender != 'Total'
GROUP BY state) 

AS one 
JOIN 
(
SELECT 
state,
MalePopulation = SUM(population) 
FROM popchar_2015
WHERE gender = 'MALE'
GROUP BY state) 

AS two
on one.state = two.state 
) AS three

on crimetable.state = three.state


