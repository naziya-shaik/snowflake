create or replace  schema first_db.snowpipe
// creating  table
create or replace table first_db.snowpipe.employees(
id int,
first_name string,
last_ame string,
email string,
location string,
department string
)
select * from employees;

//creating file_format object
CREATE OR REPLACE file format MANAGE_DB.file_formts.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;
    
// Create stage object with integration object & file format object
CREATE OR REPLACE stage MANAGE_DB.external_stages.csv_folder
    URL ='s3://snowflakebaucket4/snowpipe/'
    STORAGE_INTEGRATION = s3_init
    FILE_FORMAT = MANAGE_DB.file_formts.csv_fileformat
   
// Create stage object with integration object & file format object
LIST @MANAGE_DB.external_stages.csv_folder  
  
// Create schema to keep things organized
CREATE OR REPLACE SCHEMA MANAGE_DB.pipes

// Define pipe
CREATE OR REPLACE pipe MANAGE_DB.pipes.employee_pipe
auto_ingest = TRUE
AS
COPY INTO FIRST_DB.snowpipe.employees
FROM @MANAGE_DB.external_stages.csv_folder  

// Describe pipe get the notification_channel and copy it for S3 event 
DESC pipe employee_pipe
    
SELECT * FROM first_db.snowpipe.employees

-- Manage pipes -- 

DESC pipe MANAGE_DB.pipes.employee_pipe;

SHOW PIPES;

SHOW PIPES like '%employee%'

SHOW PIPES in database MANAGE_DB

SHOW PIPES in schema MANAGE_DB.pipes

SHOW PIPES like '%employee%' in Database MANAGE_DB







