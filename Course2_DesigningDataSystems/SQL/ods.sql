USE SCHEMA STAGING;
UPDATE precipitation SET precipitation = NULL WHERE precipitation = 'T';

CREATE SCHEMA ODS;
USE SCHEMA ODS;

-- Precipitation Table
CREATE OR REPLACE TABLE precipitation (
    date DATE PRIMARY KEY,
    precipitation FLOAT, 
    precipitation_normal FLOAT
);
INSERT INTO precipitation(date, precipitation, precipitation_normal)
SELECT TO_DATE(date,'YYYYMMDD'), 
CAST(precipitation AS FLOAT), 
CAST(precipitation_normal AS FLOAT) 
FROM STAGING.precipitation;

-- Temperature Table
CREATE OR REPLACE TABLE temperature (
    date DATE PRIMARY KEY, 
    min FLOAT, 
    max FLOAT, 
    normal_min FLOAT, 
    normal_max FLOAT
); 
INSERT INTO temperature (date, min, max, normal_min, normal_max)
SELECT TO_DATE(date, 'YYYYMMDD'), 
    CAST(min AS FLOAT), 
    CAST(max AS FLOAT),  
    CAST(normal_min AS FLOAT),  
    CAST(normal_max AS FLOAT), 
FROM STAGING.temperature;

-- Business Table
CREATE OR REPLACE TABLE business (   
    business_id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200),
    address VARCHAR(200),
    city VARCHAR(200),
    state VARCHAR(3),
    postal_code VARCHAR(10),
    latitude FLOAT,
    longitude FLOAT,
    stars FLOAT,
    review_count INT,
    is_open INT,
    attributes VARIANT,
    categories VARIANT,
    hours VARIANT
);
INSERT INTO business 
(business_id, name, address, city, state, postal_code, latitude, longitude, stars, review_count, is_open, attributes, categories, hours)
SELECT
    PARSE_JSON(myjson):business_id,
    PARSE_JSON(myjson):name,
    PARSE_JSON(myjson):address,
    PARSE_JSON(myjson):city, 
    PARSE_JSON(myjson):state, 
    PARSE_JSON(myjson):postal_code, 
    PARSE_JSON(myjson):latitude, 
    PARSE_JSON(myjson):longitude, 
    PARSE_JSON(myjson):stars, 
    PARSE_JSON(myjson):review_count, 
    PARSE_JSON(myjson):is_open, 
    PARSE_JSON(myjson):attributes, 
    PARSE_JSON(myjson):categories, 
    PARSE_JSON(myjson):hours
FROM STAGING.business;

-- User Table
CREATE OR REPLACE TABLE user (
    user_id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200),
    review_count INT,
    yelping_since DATE,
    useful INT,
    funny INT,
    cool INT,
    elite VARCHAR,
    friends VARCHAR,
    fans INT,
    average_stars FLOAT,
    compliment_hot INT,
    compliment_more INT,
    compliment_profile INT,
    compliment_cute INT,
    compliment_list INT,
    compliment_note INT,
    compliment_plain INT,
    compliment_cool INT,
    compliment_funny INT,
    compliment_writer INT,
    compliment_photos INT
);
INSERT INTO user( user_id, name, review_count, yelping_since, useful, funny, cool, elite, friends, fans, average_stars,
compliment_hot, compliment_more, compliment_profile, compliment_cute, compliment_list, compliment_note, compliment_plain, compliment_cool, compliment_funny, compliment_writer, compliment_photos)
SELECT 
    PARSE_JSON(myjson):user_id,
    PARSE_JSON(myjson):name,
    PARSE_JSON(myjson):review_count,
    PARSE_JSON(myjson):yelping_since,
    PARSE_JSON(myjson):useful,
    PARSE_JSON(myjson):funny,
    PARSE_JSON(myjson):cool,
    PARSE_JSON(myjson):elite,
    PARSE_JSON(myjson):friends,
    PARSE_JSON(myjson):fans,
    PARSE_JSON(myjson):average_stars,
    PARSE_JSON(myjson):compliment_hot,
    PARSE_JSON(myjson):compliment_more,
    PARSE_JSON(myjson):compliment_profile,
    PARSE_JSON(myjson):compliment_cute,
    PARSE_JSON(myjson):compliment_list,
    PARSE_JSON(myjson):compliment_note,
    PARSE_JSON(myjson):compliment_plain,
    PARSE_JSON(myjson):compliment_cool,
    PARSE_JSON(myjson):compliment_funny,
    PARSE_JSON(myjson):compliment_writer,
    PARSE_JSON(myjson):compliment_photos
FROM STAGING.user;

-- Check-in Table
CREATE OR REPLACE TABLE check_in (
    business_id VARCHAR(100),
    date VARCHAR,
    PRIMARY KEY (business_id, date),
    FOREIGN KEY (business_id) REFERENCES business(business_id)
);
INSERT INTO check_in(business_id, date)
SELECT PARSE_JSON(myjson):business_id, PARSE_JSON(myjson):date 
FROM STAGING.check_in;

-- Tip Table
CREATE OR REPLACE TABLE tip(
    business_id VARCHAR(100),
    user_id VARCHAR(100),
    date DATE,
    compliment_count INT,
    text VARCHAR,
    PRIMARY KEY (business_id, user_id, date),
    FOREIGN KEY (business_id) REFERENCES business(business_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);
INSERT INTO tip(business_id, user_id, date, compliment_count, text)
SELECT PARSE_JSON(myjson):business_id,
    PARSE_JSON(myjson):user_id,
    PARSE_JSON(myjson):date,
    PARSE_JSON(myjson):compliment_count,
    PARSE_JSON(myjson):text
FROM STAGING.tip;

-- Covid Table
CREATE OR REPLACE TABLE covid (
    business_id VARCHAR(100),
    highlights VARIANT,
    delivery_or_takeout VARIANT,
    grubhub_enabled VARIANT,
    call_to_action_enabled VARIANT,
    request_a_quote_enabled VARIANT,
    covid_banner VARIANT,
    temporary_closed_until VARIANT,
    virtual_services_offered VARIANT,
    PRIMARY KEY (business_id),
    FOREIGN KEY (business_id) REFERENCES business(business_id)
);
INSERT INTO covid 
(business_id, highlights, delivery_or_takeout, grubhub_enabled, call_to_action_enabled, request_a_quote_enabled, covid_banner, temporary_closed_until, virtual_services_offered)
SELECT
    PARSE_JSON(myjson):business_id,
    PARSE_JSON(myjson):"highlights",
    PARSE_JSON(myjson):"delivery or takeout",
    PARSE_JSON(myjson):"Grubhub enabled",
    PARSE_JSON(myjson):"Call To Action enabled",
    PARSE_JSON(myjson):"Request a Quote Enabled",
    PARSE_JSON(myjson):"Covid Banner",
    PARSE_JSON(myjson):"Temporary Closed Until",
    PARSE_JSON(myjson):"Virtual Services Offered"
FROM STAGING.covid;

-- Review Table
CREATE OR REPLACE TABLE review (
    business_id VARCHAR(100),
    review_id VARCHAR(100) PRIMARY KEY,
    user_id VARCHAR(100),
    date DATE,
    stars FLOAT,
    cool INT,
    funny INT,
    useful INT,
    text VARCHAR,
    FOREIGN KEY (business_id) REFERENCES business(business_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (date) REFERENCES temperature(date),
    FOREIGN KEY (date) REFERENCES precipitation(date)
);
INSERT INTO review 
(business_id, review_id, user_id, date, stars, cool, funny, useful, text)
SELECT
    PARSE_JSON(myjson):business_id,
    PARSE_JSON(myjson):review_id,
    PARSE_JSON(myjson):user_id,
    PARSE_JSON(myjson):date,
    PARSE_JSON(myjson):stars,
    PARSE_JSON(myjson):cool,
    PARSE_JSON(myjson):funny,
    PARSE_JSON(myjson):useful,
    PARSE_JSON(myjson):text
FROM STAGING.review;

-- SQL code that shows the data is integrated in ODS schema:
SELECT 
    r.business_id,
    r.review_id,
    r.user_id,
    r.stars,
    r.text,
    r.date AS review_date,
    p.precipitation,
    p.precipitation_normal,
    t.min AS temperature_min,
    t.max AS temperature_max,
    t.normal_min AS normal_temperature_min,
    t.normal_max AS normal_temperature_max
FROM 
    ODS.review AS r
JOIN 
    ODS.precipitation AS p 
ON 
    r.date = p.date
JOIN
    ODS.temperature AS t
ON
    r.date = t.date
WHERE 
    p.precipitation IS NOT NULL
    OR t.min IS NOT NULL;

-- Show the comparison of sizes/row counts of data between raw files, staging and ODS tables.
USE SCHEMA STAGING;
LIST @json_stage;
LIST @csv_stage;
SELECT table_name, row_count, bytes 
FROM information_schema.tables 
WHERE table_schema = 'STAGING';
USE SCHEMA ODS;
SELECT table_name, row_count, bytes 
FROM information_schema.tables 
WHERE table_schema = 'ODS';
