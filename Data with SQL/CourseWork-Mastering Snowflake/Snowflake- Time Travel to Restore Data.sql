//Using Time Travel 

// Setting up table

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string)
    


CREATE OR REPLACE FILE FORMAT MANAGE_DB.file_formats.csv_file
    type = csv
    field_delimiter = ','
    skip_header = 1
    
CREATE OR REPLACE STAGE MANAGE_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = MANAGE_DB.file_formats.csv_file;
    


LIST @MANAGE_DB.external_stages.time_travel_stage



COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv')


SELECT * FROM OUR_FIRST_DB.public.test

// Use-case: Update data (by mistake)

UPDATE OUR_FIRST_DB.public.test
SET FIRST_NAME = 'Joyen' 



// // // Using time travel: Method 1 - 2 minutes back
// using at & offset for time travel

SELECT * FROM OUR_FIRST_DB.public.test at (OFFSET => -60*1.5)








// // // Using time travel: Method 2 - before timestamp
SELECT * FROM OUR_FIRST_DB.public.test before (timestamp => '2021-04-15 17:47:50.581'::timestamp)


-- Setting up table
CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);

COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv');


SELECT * FROM OUR_FIRST_DB.public.test;


2021-04-17 08:16:24.259

-- Setting up UTC time for convenience


ALTER SESSION SET TIMEZONE ='UTC'
SELECT DATEADD(DAY, 1, CURRENT_TIMESTAMP)



UPDATE OUR_FIRST_DB.public.test
SET Job = 'Data Scientist'


SELECT * FROM OUR_FIRST_DB.public.test;

SELECT * FROM OUR_FIRST_DB.public.test before (timestamp => '2021-04-16 07:30:47.145'::timestamp)








// // // Using time travel: Method 3 - before Query ID

// Preparing table
CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Phone string,
  Job string)

COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv')


SELECT * FROM OUR_FIRST_DB.public.test


// Altering table (by mistake)
UPDATE OUR_FIRST_DB.public.test
SET EMAIL = null



SELECT * FROM OUR_FIRST_DB.public.test

SELECT * FROM OUR_FIRST_DB.public.test before (statement => '01a50fc0-0004-247a-000f-7f070002623e')





//Restoring data - to restore it to original table 
// Setting up table

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
    

COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv');

SELECT * FROM OUR_FIRST_DB.public.test;

// Use-case: Update data (by mistake)


UPDATE OUR_FIRST_DB.public.test
SET LAST_NAME = 'Tyson';


UPDATE OUR_FIRST_DB.public.test
SET JOB = 'Data Analyst';

SELECT * FROM OUR_FIRST_DB.public.test before (statement => '01a50fcc-0004-247d-000f-7f070002a0b6')



// // // Bad method

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test as
SELECT * FROM OUR_FIRST_DB.public.test before (statement => '01a50fcc-0004-247d-000f-7f070002a0b6')


SELECT * FROM OUR_FIRST_DB.public.test


CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test as
SELECT * FROM OUR_FIRST_DB.public.test before (statement => '01a50fcc-0004-247d-000f-7f070002a0b6')
// Recreating or droping table -> losing the capability to restore table brings the error as below
//Time travel data is not available for table TEST. The requested time is either beyond the allowed time travel period or before the object creation time.




// // // Good method - -> instead of using replace command use truncate 

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test_backup as
SELECT * FROM OUR_FIRST_DB.public.test before (statement => '019b9ef0-0500-8473-0043-4d830007309a')

TRUNCATE OUR_FIRST_DB.public.test

INSERT INTO OUR_FIRST_DB.public.test
SELECT * FROM OUR_FIRST_DB.public.test_backup



SELECT * FROM OUR_FIRST_DB.public.test 


//Undropping the table       
// Setting up table

CREATE OR REPLACE STAGE MANAGE_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = MANAGE_DB.file_formats.csv_file;
    

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.customers (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
    

COPY INTO OUR_FIRST_DB.public.customers
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv');

SELECT * FROM OUR_FIRST_DB.public.customers;


// UNDROP command - Tables

DROP TABLE OUR_FIRST_DB.public.customers;

SELECT * FROM OUR_FIRST_DB.public.customers;

UNDROP TABLE OUR_FIRST_DB.public.customers;


// UNDROP command - Schemas

DROP SCHEMA OUR_FIRST_DB.public;

SELECT * FROM OUR_FIRST_DB.public.customers;

UNDROP SCHEMA OUR_FIRST_DB.public;


// UNDROP command - Database

DROP DATABASE OUR_FIRST_DB;

SELECT * FROM OUR_FIRST_DB.public.customers;

UNDROP DATABASE OUR_FIRST_DB;





// Restore replaced table 


UPDATE OUR_FIRST_DB.public.customers
SET LAST_NAME = 'Tyson';


UPDATE OUR_FIRST_DB.public.customers
SET JOB = 'Data Analyst';



// // // Undroping a with a name that already exists

CREATE OR REPLACE TABLE OUR_FIRST_DB.public.customers as
SELECT * FROM OUR_FIRST_DB.public.customers before (statement => '019b9f7c-0500-851b-0043-4d83000762be')


SELECT * FROM OUR_FIRST_DB.public.customers

//Undropping after a table being replaced will cause an error because the table exists, so need to change the name
UNDROP table OUR_FIRST_DB.public.customers;


ALTER TABLE OUR_FIRST_DB.public.customers
RENAME TO OUR_FIRST_DB.public.customers_wrong;


DESC table OUR_FIRST_DB.public.customers
    


//Retention period can be viewed from below command
//Retention period can be altered using alter function or can be set in the begining of table creation
SHOW TABLES LIKE'%CUSTOMERS%'

ALTER TABLE OUR_FIRST_DB.PUBLIC.CUSTOMERS
SET DATA_RETENTION_TIME_IN_DAYS = 2


//Time travel cost 

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE ORDER BY USAGE_DATE DESC;


SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

// Query time travel storage
SELECT 	ID, 
		TABLE_NAME, 
		TABLE_SCHEMA,
        TABLE_CATALOG,
		ACTIVE_BYTES / (1024*1024*1024) AS STORAGE_USED_GB,
		TIME_TRAVEL_BYTES / (1024*1024*1024) AS TIME_TRAVEL_STORAGE_USED_GB
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
ORDER BY STORAGE_USED_GB DESC,TIME_TRAVEL_STORAGE_USED_GB DESC;



//Fail Safe 
//Protection of historical data in case of disaster
//Non-configurable 7 day period for permanent tables
//Period starts immediately after time travel period ends

// Storage usage on account level

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE ORDER BY USAGE_DATE DESC;


// Storage usage on account level formatted

SELECT 	USAGE_DATE, 
		STORAGE_BYTES / (1024*1024*1024) AS STORAGE_GB,  
		STAGE_BYTES / (1024*1024*1024) AS STAGE_GB,
		FAILSAFE_BYTES / (1024*1024*1024) AS FAILSAFE_GB
FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE ORDER BY USAGE_DATE DESC;


// Storage usage on table level

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;


// Storage usage on table level formatted

SELECT 	ID, 
		TABLE_NAME, 
		TABLE_SCHEMA,
		ACTIVE_BYTES / (1024*1024*1024) AS STORAGE_USED_GB,
		TIME_TRAVEL_BYTES / (1024*1024*1024) AS TIME_TRAVEL_STORAGE_USED_GB,
		FAILSAFE_BYTES / (1024*1024*1024) AS FAILSAFE_STORAGE_USED_GB
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
ORDER BY FAILSAFE_STORAGE_USED_GB DESC;