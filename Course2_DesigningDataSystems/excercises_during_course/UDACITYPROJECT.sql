
-- STAGE (RAW DATA INGESTION)
CREATE SCHEMA UDACITYPROJECT.STAGING;
USE SCHEMA UDACITYPROJECT.STAGING;
CREATE OR REPLACE TABLE userdetails(userjson VARIANT);
CREATE OR REPLACE FILE FORMAT myjsonformat TYPE='JSON' STRIP_OUTER_ARRAY=true;
CREATE OR REPLACE STAGE my_json_stage file_format = myjsonformat;
PUT file://userdetails.json @my_json_stage AUTO_COMPRESS=true;
COPY INTO userdetails FROM @my_json_stage/userdetails.json.gz file_format=myjsonformat ON_ERROR='skip_file';
SELECT * FROM userdetails;

-- ODS (OLTP, RDBMS with ER Model)
CREATE SCHEMA UDACITYPROJECT.ODS;
USE SCHEMA UDACITYPROJECT.ODS;
CREATE OR REPLACE TABLE UDACITYPROJECT.ODS.USERDETAILS (
	EMAIL STRING,
	FIRST_NAME STRING,
	LAST_NAME STRING,
	PHONE INT,
	USER_ID INT
);
INSERT INTO UserDetails   
SELECT 
  userjson:emailAddress, 
  userjson:firstName, 
  userjson:lastName, 
  userjson:phoneNumber, 
  userjson:userId   
FROM UDACITYPROJECT.STAGING.UserDetails;
SELECT * FROM userdetails;


-- DWH (OLAP, Dimensional Model with STAR Schema) -> This code has been provided by Udacity... The ods tables are missing because we have no data.
create schema DWH;
create table DIMEMPLOYEE ( EMPLOYEE_ID NUMBER, FIRST_NAME STRING, LAST_NAME STRING );
create table DIMPROTOCOL( STEP_ID NUMBER, STEP_NAME string );
create table DIMHIGHTOUCHAREAS( SPOT_ID NUMBER, HIGH_TOUCH_AREA string );
create table DIMFREQUENCY( FREQUENCY_ID NUMBER, FREQUENCY NUMBER );
create table DIMROOOM( ROOM_ID NUMBER, ROOM_NAME STRING );
create table DIMFLOORS( FLOOR_ID number, FLOOR_NAME STRING );
create table DIMFACILITY ( BUILDING_ID NUMBER, BUILDING_NAME STRING );
create table DIMCOMPLEX ( COMPLEX_ID STRING, COMPLEX_NAME STRING );
create table facttable_CleaningSchedule (   
EMPLOYEE_ID NUMBER,   
FIRST_NAME STRING,   
LAST_NAME STRING,   
STEP_ID NUMBER,   
STEP_NAME string,   
SPOT_ID NUMBER,   
HIGH_TOUCH_AREA string,   
FREQUENCY_ID NUMBER,   
FREQUENCY NUMBER,   
ROOM_ID NUMBER,   
ROOM_NAME STRING,
constraint fk_EMPLOYEE_id foreign key (EMPLOYEE_id)
references DIMEMPLOYEE (EMPLOYEE_ID),   
constraint fk_SPOT_id foreign key (SPOT_id)
references DIMHIGHTOUCHAREAS (SPOT_id),   
constraint fk_FREQUENCY_id foreign key (FREQUENCY_id)
references DIMFREQUENCY(FREQUENCY_id),   
constraint fk_ROOM_id foreign key (ROOM_id)
references DIMROOOM (ROOM_id)
);

insert into DIMEMPLOYEE select distinct EMPLOYEE_ID, FIRST_NAME, LAST_NAME from ods.EMPLOYEE;
insert into DIMPROTOCOL select distinct STEP_ID, STEP_NAME from ods.PROTOCOL;
insert into DIMHIGHTOUCHAREAS select distinct SPOT_ID, HIGH_TOUCH_AREA from ods.HIGHTOUCHAREAS;
insert into DIMFREQUENCY select distinct FREQUENCY_ID, FREQUENCY from ods.FREQUENCY;
insert into DIMROOOM select distinct ROOM_ID, ROOM_NAME from ods.ROOMS;
insert into DIMFLOORS select distinct FLOOR_ID, FLOOR_NAME from ods.FLOORS;
insert into DIMFACILITY select distinct BUILDING_ID, BUILDING_NAME from ods.FACILITY;
insert into DIMCOMPLEX select distinct COMPLEX_ID, COMPLEX_NAME from ods.COMPLEX;
INSERT INTO facttable_cleaningschedule
SELECT DISTINCT E.employee_id,
                E.first_name,
                E.last_name,
                P.step_id,
                P.step_name,
                HTA.spot_id,
                HTA.high_touch_area,
                FQ.frequency_id,
                FQ.frequency,
                R.room_id,
                R.room_name
FROM   dimemployee E,
       dimfacility F,
       dimfloors FL,
       dimfrequency FQ,
       dimhightouchareas HTA,
       dimprotocol P,
       dimrooom R,
       ods.cleaningschedule S
WHERE  ( E.employee_id = S.employeeid )
       AND ( P.step_id = S.stepid )
       AND ( HTA.spot_id = S.spotid )
       AND ( FQ.frequency_id = S.frequencyid )
       AND ( R.room_id = S.roomid ); 