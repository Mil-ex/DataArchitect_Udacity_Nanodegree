CREATE DATABASE finalproject;
USE DATABASE finalproject;
CREATE SCHEMA staging;
USE SCHEMA staging;

CREATE OR REPLACE FILE FORMAT csv_file_format 
TYPE = 'CSV'
FIELD_DELIMITER = ','
COMPRESSION = 'AUTO'
RECORD_DELIMITER = '\n'
SKIP_HEADER = 1
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
NULL_IF = ('NULL', 'null')
EMPTY_FIELD_AS_NULL = TRUE;
CREATE OR REPLACE STAGE csv_stage FILE_FORMAT = csv_file_format;

CREATE OR REPLACE FILE FORMAT json_file_format
TYPE = 'JSON'
COMPRESSION = 'AUTO'
STRIP_OUTER_ARRAY = TRUE;
CREATE OR REPLACE STAGE json_stage FILE_FORMAT = json_file_format;

CREATE OR REPLACE TABLE business (myjson VARIANT);
CREATE OR REPLACE TABLE check_in (myjson VARIANT);
CREATE OR REPLACE TABLE review (myjson VARIANT);
CREATE OR REPLACE TABLE tip (myjson VARIANT);
CREATE OR REPLACE TABLE user (myjson VARIANT);

CREATE OR REPLACE TABLE covid (myjson VARIANT);

CREATE OR REPLACE TABLE precipitation (
    date VARCHAR, precipitation VARCHAR(10), precipitation_normal FLOAT
);
CREATE OR REPLACE TABLE temperature (
    date VARCHAR, min FLOAT, max FLOAT, normal_min FLOAT, normal_max FLOAT
);

PUT file://DATA\yelp_academic_dataset_business.json @json_stage AUTO_COMPRESS=true;
PUT file://DATA\yelp_academic_dataset_checkin.json @json_stage AUTO_COMPRESS=true;
PUT file://DATA\yelp_academic_dataset_tip.json @json_stage AUTO_COMPRESS=true;
PUT file://DATA\yelp_academic_dataset_review_*.json @json_stage AUTO_COMPRESS=true PARALLEL=12;
PUT file://DATA\yelp_academic_dataset_user_*.json @json_stage AUTO_COMPRESS=true PARALLEL=12;
PUT file://DATA\covid_dataset.json @json_stage AUTO_COMPRESS=true;
PUT file://DATA\usw00023169-las-vegas-mccarran-intl-ap-precipitation-inch.csv @csv_stage AUTO_COMPRESS=true;
PUT file://DATA\usw00023169-temperature-degreef.csv @csv_stage AUTO_COMPRESS=true;

COPY INTO business FROM @json_stage/yelp_academic_dataset_business.json.gz;
COPY INTO check_in FROM @json_stage/yelp_academic_dataset_checkin.json.gz;
COPY INTO tip FROM @json_stage/yelp_academic_dataset_tip.json.gz;
COPY INTO review 
FROM @json_stage 
PATTERN = '.*yelp_academic_dataset_review_.*.json.gz';
COPY INTO user 
FROM @json_stage 
PATTERN = '.*yelp_academic_dataset_user_.*.json.gz';
COPY INTO covid FROM @json_stage/covid_dataset.json.gz;
COPY INTO precipitation FROM @csv_stage/usw00023169-las-vegas-mccarran-intl-ap-precipitation-inch.csv.gz;
COPY INTO temperature FROM @csv_stage/usw00023169-temperature-degreef.csv.gz;