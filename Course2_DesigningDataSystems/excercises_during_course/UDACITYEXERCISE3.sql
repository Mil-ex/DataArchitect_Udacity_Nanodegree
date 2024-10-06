-- / *Run any of these commands, as you need them.* /
-- / *Create a new database or use an existing database* /
CREATE DATABASE UDACITYEXERCISE3;
SHOW DATABASES;
USE DATABASE UDACITYEXERCISE3;
-- / *Create a schema or use an existing schema* /
CREATE SCHEMA STAGING;
USE SCHEMA STAGING;

DROP TABLE IF EXISTS LargeDataTable; 
-- / *Create table*/
create table "LargeDataTable" ("pickup_datetime" STRING, "dropoff_datetime" STRING, "Pickup_longitude" DOUBLE, "Pickup_latitude" DOUBLE, "Dropoff_longitude" DOUBLE, "Dropoff_latitude" DOUBLE, "Trip_distance" DOUBLE, "Fare_amount" DOUBLE);

create or replace file format mycsvformat type='CSV' compression='auto'
field_delimiter=',' record_delimiter = '\n'  skip_header=1 error_on_column_count_mismatch=true null_if = ('NULL', 'null') empty_field_as_null = true;

create or replace stage my_large_data_stage file_format = mycsvformat;

-- / *Put the file from local to the staging area* /
-- / *Change the large.csv file path as present in your local machine*/
put file://C:\Users\alexa\Documents\01_git\PostGreSQL\DesigningDataSystems_DataWarehouse\large.csv @my_large_data_stage auto_compress=true parallel=4;

copy into "LargeDataTable" from @my_large_data_stage/large.csv.gz file_format=mycsvformat on_error='skip_file';