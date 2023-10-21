// Setting up table

CREATE OR REPLACE STAGE MANAGE_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = MANAGE_DB.file_formts.csv_file;
    

CREATE OR REPLACE TABLE FIRST_DB.public.employees (
id int,
first_name string,
last_ame string,
email string,
location string,
department string);
    

COPY INTO FIRST_DB.public.employees
from @MANAGE_DB.external_stages.time_travel_stage
files = ('employee_data_1.csv');

SELECT * FROM FIRST_DB.public.employees;


// UNDROP command - Tables

DROP TABLE FIRST_DB.public.employees;

SELECT * FROM FIRST_DB.public.employees;

UNDROP TABLE FIRST_DB.public.employees;


// UNDROP command - Schemas

DROP SCHEMA FIRST_DB.public;

SELECT * FROM FIRST_DB.public.employees;

UNDROP SCHEMA FIRST_DB.public;


// UNDROP command - Database

DROP DATABASE FIRST_DB;

SELECT * FROM FIRST_DB.public.employees;

UNDROP DATABASE FIRST_DB;


// Restore replaced table 


UPDATE FIRST_DB.public.employees
SET LAST_NAME = 'Tyson';


UPDATE FIRST_DB.public.employees
SET JOB = 'Data Analyst';



// // // Undroping a with a name that already exists

CREATE OR REPLACE TABLE FIRST_DB.public.employees as
SELECT * FROM FIRST_DB.public.employees before (statement => '019b9f7c-0500-851b-0043-4d83000762be')


SELECT * FROM FIRST_DB.public.employees

UNDROP table FIRST_DB.public.employees;

ALTER TABLE FIRST_DB.public.employees
RENAME TO FIRST_DB.public.employees_wrong;

DESC table FIRST_DB.public.employees
    
