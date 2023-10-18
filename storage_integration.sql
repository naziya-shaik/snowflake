create or replace storage integration s3_init
TYPE = External_stage
storage_provider = s3
enabled=True
storage_aws_role_ARN='arn:aws:iam::004115969825:role/snowflake-s3-connection'
storage_allowed_locations=('s3://snowflakebaucket4')
comment='Creating connection to S3'

DESC integration s3_init;

CREATE OR REPLACE TABLE FIRST_DB.PUBLIC.ORDERS_S3_INT (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

// Create file format object
CREATE OR REPLACE file format MANAGE_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;

// Create stage object with integration object & file format object
CREATE OR REPLACE stage MANAGE_DB.external_stages.csv_folder
    URL = 's3://snowflakebaucket4/OrderDetails.csv'
    STORAGE_INTEGRATION = s3_init
    FILE_FORMAT = MANAGE_DB.file_formats.csv_fileformat


//Load data using copy command

COPY INTO FIRST_DB.PUBLIC.ORDERS_S3_INT
    FROM @MANAGE_DB.external_stages.csv_folder;

SELECT * FROM FIRST_DB.PUBLIC.ORDERS_S3_INT;
