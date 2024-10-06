-- Dimension Table: Business
USE SCHEMA DWH;
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
    review_count INTEGER,
    is_open INTEGER,
    attributes VARIANT,
    categories VARIANT,
    hours VARIANT,
    date_checkin VARCHAR,
    highlights VARIANT,
    delivery_or_takeout VARIANT,
    grubhub_enabled VARIANT,
    call_to_action_enabled VARIANT,
    request_a_quote_enabled VARIANT,
    covid_banner VARIANT,
    temporary_closed_until VARIANT,
    virtual_services_offered VARIANT
);
INSERT INTO business
SELECT
    b.business_id,
    name,
    address,
    city,
    state,
    postal_code,
    latitude,
    longitude,
    stars,
    review_count,
    is_open,
    attributes,
    categories,
    hours,
    date AS date_checkin,
    highlights,
    delivery_or_takeout,
    grubhub_enabled,
    call_to_action_enabled,
    request_a_quote_enabled,
    covid_banner,
    temporary_closed_until,
    virtual_services_offered
FROM 
    ODS.business b
    LEFT JOIN ODS.check_in AS ci ON b.business_id = ci.business_id
    LEFT JOIN ODS.covid AS cov ON b.business_id = cov.business_id;

-- Dimension Table: Weather
CREATE OR REPLACE TABLE weather (
    date DATE PRIMARY KEY,
    min FLOAT,
    max FLOAT, 
    normal_min FLOAT, 
    normal_max FLOAT,
    precipitation FLOAT, 
    precipitation_normal FLOAT
);
INSERT INTO weather
SELECT
    t.date,
    min,
    max,
    normal_min,
    normal_max,
    precipitation,
    precipitation_normal
FROM
    ODS.temperature AS t
    LEFT JOIN ODS.precipitation AS p ON t.date = p.date;

-- Dimension Table: User
CREATE OR REPLACE TABLE user CLONE ODS.user;

-- Fact Table: Review
CREATE OR REPLACE TABLE review (
    review_id VARCHAR(100) PRIMARY KEY,
    business_id VARCHAR(100),
    user_id VARCHAR(100),
    date DATE,
    stars FLOAT,
    cool INT,
    funny INT,
    useful INT,
    text VARCHAR,
    FOREIGN KEY (business_id) REFERENCES business(business_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (date) REFERENCES weather(date)
);
INSERT INTO review
SELECT * FROM ODS.review;
