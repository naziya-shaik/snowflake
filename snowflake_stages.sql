create or replace database manage_db;
create or replace schema external_stages;
-- creating external stages
create or replace stage manage_db.external_stages.aws_stage
url="s3://petrol-consumption/petrol_consumption.csv"
CREDENTIALS=(AWS_KEY_ID='<aws-key-id>' AWS_SECRET_KEY='<aws-secret-key>');

-- description of external stage
DESC stage manage_db.external_stage.aws_stage;

-- alter External stage
Alter stage aws_stage
set CREDENTIALS=(AWS_KEY_ID='<YZ_DUMMY_ID>' AWS_SECRET_KEY='<987xyz>');

-- publicly acessible staging area
create or replace stage  manage_db.external_stage.aws_stage
url="s3://petrol-consumption";

-- to know info of files in s3 bucket
list @ aws_stage;

-- creating table 
create or replace table petrol_consumption (
Petrol_tax float,
Average_income int, 
Paved_Highways	int,
Population_Driver_licence float,
Petrol_Consumption int
);
select * from petrol_consumption;

-- copy the data
COPY INTO petrol_consumption
FROM '@aws_stage'
FILE_FORMAT = (TYPE = 'CSV'field delimter="," skip_header=1);
files=("petrol_consumption.csv");

-- transformatio in snowflake while loading 
create or replace table petrol (
Petrol_tax float,
Average_income int
);
-- copy the data
copy into manage_db.eternal_stage.petrol
from (select s.$1,s.$2 from @manage_db.external_stages.aws_stage s)
FILE_FORMAT = (TYPE = 'CSV'field delimter="," skip_header=1);
files=("petrol_consumption.csv");
 select * from petrol;
-- in transformation we can add extra column also 
create or replace table petrol_ex1 (
Petrol_tax float,
Average_income int,
category varchar(400));
 -- copy the data 
 copy into manage_db.external_stage.petrol_ex1
 from(select s..$1,s.$2 case when cast(s.$2 as int)<0 then "no profit" else "profit" end
 from @manage_db.external_stages.aws_stage s)
 FILE_FORMAT = (TYPE = 'CSV'field delimter="," skip_header=1);
 files=("petrol_consumption.csv");










