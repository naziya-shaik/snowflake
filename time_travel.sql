create or replace table First_db.public.test(
id int,
first_name string,
last_ame string,
email string,
location string,
department string
)
select * from test;
// creating file_format
CREATE OR REPLACE file format MANAGE_DB.file_formts.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;
// creating stage
CREATE OR REPLACE stage MANAGE_DB.external_stages.time_travel_stage
    URL ='s3://snowflakebaucket4/time_travel/'
    STORAGE_INTEGRATION = s3_init
    FILE_FORMAT = MANAGE_DB.file_formts.csv_fileformat  
   
LIST @MANAGE_DB.external_stages.time_travel_stage

COPY INTO FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('employee_data_1.csv')

select *from test;
// Use-case: Update data (by mistake)

UPDATE FIRST_DB.public.test
SET FIRST_NAME = 'Naziya' 
// // // Using time travel: Method 1 - 2 minutes back
SELECT * FROM FIRST_DB.public.test at (OFFSET => -60*1.5)
 
 truncate table test;
 // copy the data from time_travel_stage to test table
//select * from test;
 // for getting current timestamp value
alter session  set timezone='UTC';
select CURRENT_TIMESTAMP;
 // 2023-10-21 03:57:23.784 +0000

 UPDATE FIRST_DB.public.test
SET location = 'Guntur'
 
 select * from test;

// // // Using time travel: Method 2 - before timestamp
SELECT * FROM FIRST_DB.public.test before (timestamp => '2023-10-20 03:53:23.966'::timestamp)

truncate table test;
// setting up table test

COPY INTO FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('employee_data_1.csv')

// // // Using time travel: Method 3 - before Query ID

// Altering table (by mistake)
UPDATE FIRST_DB.public.test
SET EMAIL = null

SELECT * FROM FIRST_DB.public.test
// from query history of aciity section copy the query id  

SELECT * FROM FIRST_DB.public.test before (statement => '01afc449-0000-7a12-0005-cae6000112d2')

// to recover data using time travel
//1) bad method
create or replace table first_db.public.test as
SELECT * FROM FIRST_DB.public.test before (statement => '01afc449-0000-7a12-0005-cae6000112d2')
select * from test;

// not available previous data bcz it will erase all data before creating a table using queryid

SELECT * FROM FIRST_DB.public.test before (statement => '01afc449-0000-7a12-0005-cae6000112d2')
 // 2) good method
 //create dummy table
 create or replace table first_db.public.test_1 as
SELECT * FROM FIRST_DB.public.test before (statement => '01afc458-0000-7a12-0005-cae600011346')

select * from test_1;

truncate table test;
insert into test 
select * from test_1;

select * from test;









 





    