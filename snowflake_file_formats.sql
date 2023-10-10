create or replace schema manage_db.file_formats;
-- create file format object
create or replace file format manage_db.file_formats.my_file_format;
// to see the properties of file format
DESC file format manage_db.file_formats.my_file_format;
//Altering file format object 
alter file format manage_db.file_formats.my_file_format
set skip_header=1;
//defining properties on creation of file format object
create or replace file format manage_db.file_formats.my_file_format
type=JSON
time_format=AUTO;

create or replace file format manage_db.file_formats.csv_file_format
type=csv
field_delimiter=","
skip_header=1;
 DESC file format manage_db.file_formats.csv_file_format;
 
Truncate manage_db.external_stages.petrol_consumption;
 -- copy data
copy into manage_db.external_stage.petrol_consumption
from @manage_db.eternal_stages.aws_stage
file_format=(format_name=manage_db.file_formats.csv_file_format)
files=("petrol_consumption.csv");

select * from petrol_consumption;


