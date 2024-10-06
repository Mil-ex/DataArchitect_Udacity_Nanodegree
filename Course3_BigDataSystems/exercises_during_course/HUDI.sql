-- Task 2: Download Sample Data, load data on HDFS

wget https://video.udacity-data.com/topher/2020/November/5fabec84_game-reviews.tsv/game-reviews.tsv.gz

hdfs dfs -ls /

hdfs dfs -mkdir /game_reviews/

hdfs dfs -put game-reviews.tsv.gz /game_reviews/

-- Task 3: Launch Hudi PySpark Console on AWS EMR
pyspark \
--conf "spark.serializer=org.apache.spark.serializer.KryoSerializer" \
--conf "spark.sql.hive.convertMetastoreParquet=false" \
--jars /usr/lib/hudi/hudi-spark-bundle.jar,/usr/lib/spark/external/lib/spark-avro.jar

from pyspark.sql.functions import *
import os

-- Task 4: Load the text file in Spark, Drop records with null values
game_reviews_withNulls = spark.read.options(inferSchema='True',delimiter='\t', header='True').csv("/game_reviews/")

game_reviewsDF = game_reviews_withNulls.na.drop()

--  Task 5: Write Hudi Table
## Configure Hudi options
hudiOptions = {
'hoodie.table.name': 'game_reviews_hudi_table',
'hoodie.datasource.write.recordkey.field': 'review_id',
'hoodie.datasource.write.partitionpath.field': 'product_category',
'hoodie.datasource.write.precombine.field': 'review_date',
'hoodie.datasource.hive_sync.enable': 'true',
'hoodie.datasource.hive_sync.table': 'game_reviews_hudi_table',
'hoodie.datasource.hive_sync.partition_fields': 'product_category',
'hoodie.datasource.hive_sync.partition_extractor_class': 'org.apache.hudi.hive.MultiPartKeysValueExtractor'
}

game_reviewsDF.write \
.format('org.apache.hudi') \
.option('hoodie.datasource.write.operation', 'insert') \
.options(**hudiOptions) \
.mode('overwrite') \
.save('/game_reviews_hudi')

-- Task 6: Perform UPSERT operation on HUDI table by editing one record
updateDF = game_reviewsDF.filter(col('review_id') == 'RUGCK1O1I3YAD').withColumn('product_category', lit('Video Games From 2K'))

updateDF.write \
.format('org.apache.hudi') \
.option('hoodie.datasource.write.operation', 'upsert') \
.options(**hudiOptions) \
.mode('append') \
.save('/game_reviews_hudi/')


game_reviews_hudi_DF = spark.read.format('org.apache.hudi').load('/game_reviews_hudi/*')

## Grab first record
game_reviews_hudi_DF.limit(1).show(5, truncate = False)


+-------------------+-----------------------+------------------+----------------------+------------------------------------------------------------------------+-----------+-----------+-------------+----------+--------------+----------------------------------------------------+----------------+-----------+-------------+-----------+----+-----------------+---------------+-----------+-------------------+
|_hoodie_commit_time|_hoodie_commit_seqno   |_hoodie_record_key|_hoodie_partition_path|_hoodie_file_name                                                       |marketplace|customer_id|review_id    |product_id|product_parent|product_title                                       |product_category|star_rating|helpful_votes|total_votes|vine|verified_purchase|review_headline|review_body|review_date        |
+-------------------+-----------------------+------------------+----------------------+------------------------------------------------------------------------+-----------+-----------+-------------+----------+--------------+----------------------------------------------------+----------------+-----------+-------------+-----------+----+-----------------+---------------+-----------+-------------------+
|20201114015443     |20201114015443_7_833206|RUGCK1O1I3YAD     |Video Games           |8035dd6b-6f75-4e43-835e-e253c4be0701-0_7-40-13587_20201114015443.parquet|US         |30477870   |RUGCK1O1I3YAD|B00Q4Z29H2|406337356     |Disney Infinity: 2.0 Edition Power Disc Album Bundle|Video Games     |5          |0            |0          |N   |Y                |Five Stars     |GREAT      |2015-08-31 00:00:00|
+-------------------+-----------------------+------------------+----------------------+------------------------------------------------------------------------+-----------+-----------+-------------+----------+--------------+----------------------------------------------------+----------------+-----------+-------------+-----------+----+-----------------+---------------+-----------+-------------------+

## Grab specific record from Hudi data set
game_reviewsDF.filter(col('review_id') == 'RUGCK1O

-- Task 7: Explore hudi directory on HDFS
hdfs dfs -ls /game_reviews_hudi/*

-- 
