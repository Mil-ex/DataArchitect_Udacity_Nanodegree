-- gather data
wget https://video.udacity-data.com/topher/2020/October/5f8f4412_bx-csv-data/bx-csv-data.zip
unzip bx-csv-data.zip

hive

CREATE DATABASE db;
USE db;

-- Create Tables with Location (HDFS)
set hive.cli.print.header=true;

CREATE DATABASE IF NOT EXISTS book_db;

CREATE EXTERNAL TABLE IF NOT EXISTS book_db.bx_users (
    userid string, location_name string, age int) 
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/bx-users/' TBLPROPERTIES ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE IF NOT EXISTS book_db.bx_books (
    isbn String,title String,author String,year_of_publication String, publisher String,image_url_s String,image_url_m String,image_url_l String) 
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'  STORED AS TEXTFILE LOCATION '/bx-books/' TBLPROPERTIES ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE IF NOT EXISTS book_db.bx_book_ratings (
    userid String, isbn String, book_rating String) 
    ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/bx-book-ratings/' TBLPROPERTIES ("skip.header.line.count"="1");


-- Load data from local Linux to tables
-- hdfs dfs -put BX-Books.csv /bx-books/
-- hdfs dfs -put BX-Users.csv /bx-users/
-- hdfs dfs -put BX-Book-Rating /bx-book-rating/
LOAD DATA LOCAL INPATH 'BX-CSV-Data/BX-Book-Ratings.csv' 
OVERWRITE INTO TABLE db.book_ratings;
LOAD DATA LOCAL INPATH 'BX-CSV-Data/BX-Books.csv' 
OVERWRITE INTO TABLE db.books;
LOAD DATA LOCAL INPATH 'BX-CSV-Data/BX-Users.csv' 
OVERWRITE INTO TABLE db.users;

-- Find the most active user (user who has provided the most ratings):
SELECT userid, COUNT(book_rating) as user_activity_rank 
FROM book_db.bx_book_ratings 
GROUP BY userid order by user_activity_rank DESC 
LIMIT 1;

-- 2. Find the total number of unique users from bx-users where age is not null:
SELECT COUNT(DISTINCT userid) 
FROM book_db.bx_users 
WHERE age IS NOT NULL or age != "NULL";

-- 3. Find the total number of users between the ages of 21 and 30:
SELECT COUNT(*) 
FROM book_db.bx_users
WHERE age >= 21 AND age <= 30;

-- 4. Find the top 5 authors in descending order based on the number of books they have published:
SELECT author, COUNT(title) as total_books_published 
FROM book_db.bx_books
GROUP BY author 
ORDER BY total_books_published DESC 
LIMIT 5;

-- PARTITIONING
wget https://video.udacity-data.com/topher/2020/November/5fabec84_game-reviews.tsv/game-reviews.tsv.gz --no-check-certificate

set hive.cli.print.header=true;
set hive.exec.dynamic.partition.mode=nonstric;
Create Database demodb;
USE DATABASE demodb;

CREATE EXTERNAL TABLE demodb.game_reviews (
    marketplace string,    
    customer_id    string, 
    review_id string,    
    product_id string,    
    product_parent string,    
    product_title string,    
    product_category string, 
    star_rating    string,
    helpful_votes string,
    total_votes    string,
    vine string,
    verified_purchase string,
    review_headline    string,
    review_body    string,
    review_date string)
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '\t'
    LOCATION '/game_reviews/'
    tblproperties ("skip.header.line.count"="1");

hdfs dfs -put game_reviews.tsv.gz /game_reviews/

CREATE EXTERNAL TABLE demodb.game_reviews_partitioned (
    marketplace string,    
    customer_id    string, 
    review_id string,    
    product_id string,    
    product_parent string,    
    product_title string,    
    product_category string, 
    star_rating    string,
    helpful_votes string,
    total_votes    string,
    vine string,
    verified_purchase string,
    review_headline    string,
    review_body    string,
    review_date string)
    PARTITIONED BY (year string)
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY '\t'
    LOCATION '/game_reviews_partitioned/';

INSERT OVERWRITE TABLE demodb.game_rating_partitioned PARTITION (year) SELECT *, year(review_date) FROM demodb.game_reviews;

hdfs dfs -ls /game_reviews_partitioned/

hive> drop table demodb.game_rating_partitioned;
hive> drop table demodb.game_rating;

hdfs shell > hdfs dfs -rm -r /game_reviews_partitioned/
hdfs shell > hdfs dfs -rm -r /game_reviews/ 