CREATE DATABASE UdacityExercise2;
USE DATABASE UdacityExercise2;
CREATE SCHEMA staging;
USE SCHEMA staging;
SHOW DATABASES;
CREATE TABLE Floors (
    FloorID INT,
    FloorName STRING,
    BuildingID INT
);
CREATE TABLE Rooms (
    RoomID INT,
    RoomName STRING,
    FloorID INT,
    BuildingID INT,
    Total_Area FLOAT,
    Cleaned_Area FLOAT
);
CREATE OR REPLACE FILE FORMAT CSVFormatObject
TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1
NULL_IF = ('NULL', 'null');

CREATE OR REPLACE STAGE my_csv_stage FILE_FORMAT = CSVFormatObject;
PUT file://C:\Users\alexa\Documents\01_git\PostGreSQL\DesigningDataSystems_DataWarehouse\floors.csv @my_csv_stage;
PUT file://C:\Users\alexa\Documents\01_git\PostGreSQL\DesigningDataSystems_DataWarehouse\rooms.csv @my_csv_stage;
COPY INTO Floors FROM @my_csv_stage/floors.csv.gz FILE_FORMAT = CSVFormatObject ON_ERROR = 'skip_file';
COPY INTO Rooms FROM @my_csv_stage/rooms.csv.gz FILE_FORMAT = CSVFormatObject ON_ERROR = 'skip_file';
SELECT * FROM Floors;
SELECT * FROM Rooms;


-- SOLUTION:
-- / *Create a new database or use an existing database* /
CREATE DATABASE UDACITYEXERCISE;
SHOW DATABASES;
USE DATABASE UDACITYEXERCISE;

-- / *Create a schema or use an existing schema* /
CREATE SCHEMA STAGING;
-- / *Full qualifiying name* /
CREATE SCHEMA "UDACITYEXERCISE"."STAGING";
USE SCHEMA STAGING;

-- / *Drop if exists* /
DROP TABLE IF EXISTS LargeDataTable; 
-- / *Create a new table. You can choose full qualifiying name or just the table name* /
CREATE TABLE "UDACITYEXERCISE"."STAGING"."FLOORS" ("FLOORID" INTEGER, "FLOORNAME" STRING, "BUILDINGID" INTEGER);

-- / *Create a simple file format*/
create or replace file format mycsvformat  type='CSV' compression='auto' field_delimiter=',' record_delimiter = '\n' skip_header=1 error_on_column_count_mismatch=true null_if = ('NULL', 'null') empty_field_as_null = true;
-- / *If you wish to add more options to the file format* /
CREATE FILE FORMAT "UDACITYEXERCISE"."STAGING".MYCSVFILEFORMAT TYPE = 'CSV' COMPRESSION = 'AUTO' FIELD_DELIMITER = ',' RECORD_DELIMITER = '\n' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' TRIM_SPACE = FALSE ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE ESCAPE = 'NONE' ESCAPE_UNENCLOSED_FIELD = '\134' DATE_FORMAT = 'AUTO' TIMESTAMP_FORMAT = 'AUTO' NULL_IF = ('\\N');
-- / *Create a staging area* /
create or replace stage my_csv_stage file_format = mycsvformat;

-- / *Put the file from local to the staging area* /
-- / *Change the path of the floors.csv, as applicable to you* /
PUT file:///Users/udacity/Downloads/floors.csv @MY_CSV_STAGE AUTO_COMPRESS=TRUE;

-- / *Copy data from the staging area to the table* /
copy into floors from @my_csv_stage/floors.csv.gz file_format=mycsvformat ON_ERROR = 'CONTINUE' PURGE = TRUE;

DROP TABLE IF EXISTS rooms; 
-- / *Assuming you are in "UDACITYEXERCISE"."STAGING". If not use the qualified name of the table* /
CREATE TABLE "UDACITYEXERCISE"."STAGING"."ROOMS" ("ROOMID" INTEGER, "ROOMNAME" STRING, "FLOORID" INTEGER, "BUILDINGID" INTEGER, "TOTALAREA" DOUBLE, "CLEANEDAREA" DOUBLE);

-- / *Assuming `mycsvformat` and `my_csv_stage` are already in place.* /
-- / *Put the file from local to the staging area* /
put file:///Users/udacity/Downloads/rooms.csv @my_csv_stage auto_compress=true;

copy into rooms from @my_csv_stage/rooms.csv.gz file_format=mycsvformat ON_ERROR = 'CONTINUE' PURGE = TRUE;

-- / *List all tables*/
SHOW TABLES;
-- / *Show content of a single table.* /
SELECT * FROM FLOORS;