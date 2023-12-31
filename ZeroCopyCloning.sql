// Cloning

SELECT * FROM FIRST_DB.PUBLIC.test;

CREATE TABLE FIRST_DB.PUBLIC.test_Clone
CLONE FIRST_DB.PUBLIC.test;


// Validate the data
SELECT * FROM FIRST_DB.PUBLIC.test_Clone;


// Update cloned table

UPDATE FIRST_DB.public.test_CLONE
SET first_name = NULL;

SELECT * FROM FIRST_DB.PUBLIC.test ;

SELECT * FROM FIRST_DB.PUBLIC.test_clone;


// Cloning a temporary table is not possible
CREATE OR REPLACE TEMPORARY TABLE FIRST_DB.PUBLIC.TEMP_TABLE(
  id int);

CREATE OR REPLACE TEMPORARY TABLE FIRST_DB.PUBLIC.TABLE_COPY
CLONE FIRST_DB.PUBLIC.TEMP_TABLE;

SELECT * FROM FIRST_DB.PUBLIC.TABLE_COPY;  -- no result

// Cloning Schema
CREATE OR REPLACE TRANSIENT SCHEMA FIRST_DB.COPIED_SCHEMA
CLONE FIRST_DB.PUBLIC;

SELECT * FROM COPIED_SCHEMA.test


CREATE TRANSIENT SCHEMA FIRST_DB.EXTERNAL_STAGES_COPIED
CLONE MANAGE_DB.EXTERNAL_STAGES;



// Cloning Database
CREATE TRANSIENT DATABASE FIRST_DB_COPY
CLONE FIRST_DB;

DROP DATABASE FIRST_DB_COPY;
DROP SCHEMA FIRST_DB.EXTERNAL_STAGES_COPIED;
DROP SCHEMA FIRST_DB.COPIED_SCHEMA;