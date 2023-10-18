create database cache_db;
create schema external_stage;


// creating stage  
create or replace stage cache_stage
url="s3://snowflakebaucket4"
CREDENTIALS=(AWS_KEY_ID='<AKIAQB5KUW4QU6MLV3VR>' AWS_SECRET_KEY='<WBj68rgP43pATWuLU/Wrlar+BNxgrhLH4d2rTWnM>');

// List files in stage
list @cache_stage;
-- description of stage
DESC stage cache_db.external_stage.cache_stage;

CREATE OR REPLACE TABLE FIRST_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

    
//Load data using copy command

COPY INTO FIRST_DB.PUBLIC.ORDERS
    FROM @cache_db.external_stage.cache_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*OrderDetails.*';
    

// Create table
CREATE OR REPLACE TABLE ORDERS_CACHING (
ORDER_ID	VARCHAR(30)
,AMOUNT	NUMBER(38,0)
,PROFIT	NUMBER(38,0)
,QUANTITY	NUMBER(38,0)
,CATEGORY	VARCHAR(30)
,SUBCATEGORY	VARCHAR(30)
,DATE DATE)  ;  


INSERT INTO ORDERS_CACHING 
SELECT
t1.ORDER_ID
,t1.AMOUNT	
,t1.PROFIT	
,t1.QUANTITY	
,t1.CATEGORY	
,t1.SUBCATEGORY	
,DATE(UNIFORM(1500000000,1700000000,(RANDOM())))
FROM ORDERS t1
CROSS JOIN (SELECT * FROM ORDERS) t2
CROSS JOIN (SELECT TOP 100 * FROM ORDERS) t3


// Query Performance before Cluster Key
SELECT * FROM ORDERS_CACHING  WHERE DATE = '2020-06-10'


// Adding Cluster Key & Compare the result
ALTER TABLE ORDERS_CACHING CLUSTER BY ( DATE ) 

SELECT * FROM ORDERS_CACHING  WHERE DATE = '2020-01-09'


// Not ideal clustering & adding a different Cluster Key using function
SELECT * FROM ORDERS_CACHING  WHERE MONTH(DATE)=11

ALTER TABLE ORDERS_CACHING CLUSTER BY ( MONTH(DATE) )