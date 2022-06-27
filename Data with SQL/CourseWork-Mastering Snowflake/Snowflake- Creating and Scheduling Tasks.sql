
--- Creating Tasks
--- Only execute a single SQL statement (Inclduing Stored Procedure)


CREATE OR REPLACE TRANSIENT DATABASE TASK_DB;

// Prepare table
CREATE OR REPLACE TABLE CUSTOMERS (
    CUSTOMER_ID INT AUTOINCREMENT START = 1 INCREMENT =1,
    FIRST_NAME VARCHAR(40) DEFAULT 'JENNIFER' ,
    CREATE_DATE DATE)
    
    
// Create task
CREATE OR REPLACE TASK CUSTOMER_INSERT
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'
    AS 
    INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(CURRENT_TIMESTAMP);
    

SHOW TASKS;

// Task starting and suspending
ALTER TASK CUSTOMER_INSERT RESUME;
ALTER TASK CUSTOMER_INSERT SUSPEND;


SELECT * FROM CUSTOMERS

---------------------Using CRON 


CREATE OR REPLACE TASK CUSTOMER_INSERT
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '60 MINUTE'
    AS 
    INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(CURRENT_TIMESTAMP);
  
  
  
  
CREATE OR REPLACE TASK CUSTOMER_INSERT
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 7,10 * * 5L UTC'
    AS 
    INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(CURRENT_TIMESTAMP);
    

# __________ minute (0-59)
# | ________ hour (0-23)
# | | ______ day of month (1-31, or L)
# | | | ____ month (1-12, JAN-DEC)
# | | | | __ day of week (0-6, SUN-SAT, or L)
# | | | | |
# | | | | |
# * * * * *




// Every minute
SCHEDULE = 'USING CRON * * * * * UTC'


// Every day at 6am UTC timezone
SCHEDULE = 'USING CRON 0 6 * * * UTC'

// Every hour starting at 9 AM and ending at 5 PM on Sundays 
SCHEDULE = 'USING CRON 0 9-17 * * SUN America/Los_Angeles'


CREATE OR REPLACE TASK CUSTOMER_INSERT
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 9,17 * * * UTC'
    AS 
    INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(CURRENT_TIMESTAMP);
  
  
 -----------Creating trees of tasks
 
 USE TASK_DB;
 
SHOW TASKS;

SELECT * FROM CUSTOMERS;

// Prepare a second table
CREATE OR REPLACE TABLE CUSTOMERS2 (
    CUSTOMER_ID INT,
    FIRST_NAME VARCHAR(40),
    CREATE_DATE DATE)
    
    
// Suspend parent task first before adding child tasks
ALTER TASK CUSTOMER_INSERT SUSPEND;
    
// Create a child task
CREATE OR REPLACE TASK CUSTOMER_INSERT2
    WAREHOUSE = COMPUTE_WH
    AFTER CUSTOMER_INSERT
    AS 
    INSERT INTO CUSTOMERS2 SELECT * FROM CUSTOMERS;
    
    
// Prepare a third table
CREATE OR REPLACE TABLE CUSTOMERS3 (
    CUSTOMER_ID INT,
    FIRST_NAME VARCHAR(40),
    CREATE_DATE DATE,
    INSERT_DATE DATE DEFAULT DATE(CURRENT_TIMESTAMP))    
    

// Create a child task
CREATE OR REPLACE TASK CUSTOMER_INSERT3
    WAREHOUSE = COMPUTE_WH
    AFTER CUSTOMER_INSERT2
    AS 
    INSERT INTO CUSTOMERS3 (CUSTOMER_ID,FIRST_NAME,CREATE_DATE) SELECT * FROM CUSTOMERS2;


SHOW TASKS;

ALTER TASK CUSTOMER_INSERT 
SET SCHEDULE = '1 MINUTE'

// Resume tasks (first root task)
ALTER TASK CUSTOMER_INSERT RESUME;
ALTER TASK CUSTOMER_INSERT2 RESUME;
ALTER TASK CUSTOMER_INSERT3 RESUME;


SELECT * FROM CUSTOMERS2

SELECT * FROM CUSTOMERS3

// Suspend tasks again
ALTER TASK CUSTOMER_INSERT SUSPEND;
ALTER TASK CUSTOMER_INSERT2 SUSPEND;
ALTER TASK CUSTOMER_INSERT3 SUSPEND;


-----------------------------Calling a stored procedure 

// Create a stored procedure
USE TASK_DB;

SELECT * FROM CUSTOMERS



CREATE OR REPLACE PROCEDURE CUSTOMERS_INSERT_PROCEDURE (CREATE_DATE varchar)
    RETURNS STRING NOT NULL
    LANGUAGE JAVASCRIPT
    AS
        $$
        var sql_command = 'INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(:1);'
        snowflake.execute(
            {
            sqlText: sql_command,
            binds: [CREATE_DATE]
            });
        return "Successfully executed.";
        $$;
        
        
    
CREATE OR REPLACE TASK CUSTOMER_TAKS_PROCEDURE
WAREHOUSE = COMPUTE_WH
SCHEDULE = '1 MINUTE'
AS CALL  CUSTOMERS_INSERT_PROCEDURE (CURRENT_TIMESTAMP);


SHOW TASKS;

ALTER TASK CUSTOMER_TAKS_PROCEDURE RESUME;


SELECT * FROM CUSTOMERS;

------------------Task history and error handling
------------------Task can be created with condition, with WHEN 

SHOW TASKS;


// Use the table function "TASK_HISTORY()"
select *
  from table(information_schema.task_history())
  order by scheduled_time desc;
  
  
  
  
// See results for a specific Task in a given time
select *
from table(information_schema.task_history(
    scheduled_time_range_start=>dateadd('hour',-4,current_timestamp()),
    result_limit => 5,
    task_name=>'CUSTOMER_INSERT2'));
  
  
 
// See results for a given time period
select *
  from table(information_schema.task_history(
    scheduled_time_range_start=>to_timestamp_ltz('2022-06-22 11:28:32.776 -0700'),
    scheduled_time_range_end=>to_timestamp_ltz('2022-06-28 11:35:32.776 -0700')));  
  
SELECT TO_TIMESTAMP_LTZ(CURRENT_TIMESTAMP)  
  
  
 