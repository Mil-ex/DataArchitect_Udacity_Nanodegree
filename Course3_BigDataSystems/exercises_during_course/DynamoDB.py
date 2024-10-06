# That is over the CLI
#!/bin/sh
aws dynamodb create-table --table-name sampledata \
--attribute-definitions AttributeName=PK,AttributeType=S AttributeName=GSI_1_PK,AttributeType=S \
--key-schema AttributeName=PK,KeyType=HASH \
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
--tags Key=workshop-design-patterns,Value=targeted-for-cleanup \
--global-secondary-indexes "IndexName=GSI_1,\
KeySchema=[{AttributeName=GSI_1_PK,KeyType=HASH}],\
Projection={ProjectionType=INCLUDE,NonKeyAttributes=['bytessent']},\
ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}"


boto_args = {'service_name': 'dynamodb'}


from __future__ import print_function # Python 2/3 compatibility
import boto3
import time
import csv
import sys
from lab_config import boto_args


def import_csv(tableName, fileName, attributesNameList, attributesTypeList):
    dynamodb = boto3.resource(**boto_args)
    dynamodb_table = dynamodb.Table(tableName)
    count = 0

    servererror = False
    time1 = time.time()
    with open(fileName, 'r', encoding="utf-8") as csvfile:
        myreader = csv.reader(csvfile, delimiter=',')
        for row in myreader:
            count += 1
            newitem = {}
            for colunm_number, colunm_name in enumerate(attributesNameList):
                newitem[colunm_name] = attributesTypeList[colunm_number](row[colunm_number])
            # Create primary keys
            newitem["PK"] = "request#{}".format(newitem['requestid'])
            newitem["GSI_1_PK"] = "host#{}".format(newitem['host'])

            if newitem['responsecode'] == 500:
                newitem['servererror'] = '5xx'

            item = dynamodb_table.put_item(Item=newitem)

            if count % 100 == 0:
                time2 = time.time() - time1
                print("row: %s in %s" % (count, time2))
                time1 = time.time()
    return count

if __name__ == "__main__":
    args = sys.argv[1:]
    tableName = args[0]
    fileName = args[1]

    attributesNameList = ['requestid','host','date','hourofday','timezone','method','url','responsecode','bytessent','useragent']
    attributesTypeList = [int,str,str,int,str,str,str,int,int,str]

    begin_time = time.time()
    count = import_csv(tableName, fileName, attributesNameList, attributesTypeList)

    # print summary
    print('RowCount: %s, Total seconds: %s' %(count, (time.time() - begin_time)))



#!/bin/sh
aws dynamodb update-table --table-name sampledata \
--provisioned-throughput ReadCapacityUnits=100,WriteCapacityUnits=100



wget https://video.udacity-data.com/topher/2020/November/5fb2b679_capacity-demo/capacity-demo.zip
unzip capacity-demo.zip

## Create table by executing the following command
./create-table.sh
**NOTE**: If the script does not execute, try to add "execute" permissions on all the script files by running the following command on Cloud 9 Console

The below command recursively adds execute permission to all the script files in the present working directory. 
chmod -R 744 *.sh
## (OPTIONAL) Validate table status by executing following command
aws dynamodb describe-table --table-name sampledata --query "Table.TableStatus"

## (OPTIONAL) See complete table information by executing this command
aws dynamodb describe-table --table-name sampledata

## Load data into table using following command
python load_ddb_sampledata.py sampledata data/sampledata_small.csv

## Load time for small file: 16 seconds (with 5 RCU and 5 WCU)

## Load data into table using following command
python load_ddb_sampledata.py sampledata data/sampledata_large.csv

## Load time for large file: 115 seconds (with 5 RCU and 5 WCU)

./update_table.sh

python load_ddb_sampledata.py sampledata data/logfile_large2.csv
## Load time for large file: 15 seconds (with 100 RCU and 100 WCU)

aws dynamodb delete-table --table-name sampledata


## Programatic Access (AWS Cloud9 Environment -> Linux based terminal over web browser):
aws dynamodb create-table \
    --table-name Movies \
    --attribute-definitions \
        AttributeName=Actor,AttributeType=S \
        AttributeName=MovieTitle,AttributeType=S \
    --key-schema \
        AttributeName=Actor,KeyType=HASH \
        AttributeName=MovieTitle,KeyType=RANGE \
--provisioned-throughput \
        ReadCapacityUnits=10,WriteCapacityUnits=5


aws dynamodb put-item \
--table-name Movies  \
--item \
    '{"Actor": {"S": "Brad Pitt"}, "MovieTitle": {"S": "A River Runs Through It"}, "StudioTitle": {"S": "Western Studios"}, "Awards": {"N": "2"}}'


aws dynamodb put-item \
--table-name Movies  \
--item \
    '{"Actor": {"S": "Brad Pitt"}, "MovieTitle": {"S": "Once Upon a Time in Hollywood"}, "StudioTitle": {"S": "NBJ Studios"}, "Awards": {"N": "1"}}'

aws dynamodb put-item \
    --table-name Movies \
    --item \
    '{"Actor": {"S": "Saoirse Ronan"}, "MovieTitle": {"S": "Little Women"}, "StudioTitle": {"S": "NewFlux Studios"}, "Awards": {"N": "3"} }'

aws dynamodb put-item \
--table-name Movies  \
--item \
    '{"Actor": {"S": "CYNTHIA ERIVO"}, "MovieTitle": {"S": "Harriet Tubman"}, "StudioTitle": {"S": "Century Studios"}, "Awards": {"N": "4"}}'

aws dynamodb put-item \
    --table-name Movies \
    --item \
    '{"Actor": {"S": "Feras Fayyad"}, "MovieTitle": {"S": "The Cave"}, "StudioTitle": {"S": "Bloom Studios"}, "Awards": {"N": "7"} }'



aws dynamodb get-item --consistent-read \
--table-name Movies \
--key '{ "Actor": {"S": "Brad Pitt"}, "MovieTitle": {"S": "Once Upon a Time in Hollywood"}}'


aws dynamodb query \
--table-name Movies \
--key-condition-expression "Actor = :name" \
--expression-attribute-values  '{":name":{"S":"Brad Pitt"}}'

aws dynamodb update-item \
    --table-name Movies \
    --key '{ "Actor": {"S": "Brad Pitt"}, "MovieTitle": {"S": "Once Upon a Time in Hollywood"}}' \
    --update-expression "SET StudioTitle = :newval" \
    --expression-attribute-values '{":newval":{"S":"Happy Days Studio"}}' \
    --return-values ALL_NEW


This exercise is the same as exercise 1 of this course. However, with one major difference. In exercise 1, you used the AWS Console GUI to complete the tasks. While Console is great to get started, in the real world you will use AWS CLI to perform or even automate some of those operations.

In this exercise, you will use AWS CLI commands to complete the tasks provided below. Please note that you will need an AWS Cloud9 environment to execute the commands. Please see the exercise starter video to learn how to create a Cloud9 environment.

AWS DynamoDB CLI is well documented here(opens in a new tab)

Please refer to the documentation above to build the commands to complete the tasks provided.

Task 1: Create DynamoDB table
aws dynamodb create-table \
    --table-name Orders \
    --attribute-definitions \
        AttributeName=UserId,AttributeType=S \
        AttributeName=OrderId,AttributeType=S \
    --key-schema \
        AttributeName=UserId,KeyType=HASH \
        AttributeName=OrderId,KeyType=RANGE \
--provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5

Task 2: Load 5 items in DynamoDB table
aws dynamodb put-item \
--table-name Orders  \
--item \
    '{"UserId": {"S": "doug"}, "OrderId": {"S": "8yq9d"}, "Status": {"S": "PLACED"}, "City": {"S": "Chicago"}, "CreatedAt": {"S": "2020-10-14"}, "FullName": {"S": "Doug Smith"}}'


aws dynamodb put-item \
--table-name Orders  \
--item \
    '{"UserId": {"S": "bob"}, "OrderId": {"S": "dv8a3"}, "Status": {"S": "PLACED"}, "City": {"S": "New York"}, "CreatedAt": {"S": "2020-09-14"}, "FullName": {"S": "Bob Jones"}}'


aws dynamodb put-item \
--table-name Orders  \
--item \
    '{"UserId": {"S": "su"}, "OrderId": {"S": "n335v"}, "Status": {"S": "PLACED"}, "City": {"S": "Dallas"}, "CreatedAt": {"S": "2020-08-14"}, "FullName": {"S": "Suzane Anderson"}}'


aws dynamodb put-item \
--table-name Orders  \
--item \
    '{"UserId": {"S": "doug"}, "OrderId": {"S": "ynr83"}, "Status": {"S": "SHIPPED"}, "City": {"S": "Chicago"}, "CreatedAt": {"S": "2020-9-14"}, "FullName": {"S": "Doug Smith"}}'


aws dynamodb put-item \
--table-name Orders  \
--item \
    '{"UserId": {"S": "doug"}, "OrderId": {"S": "ynr83"}, "Status": {"S": "FILLED"}, "City": {"S": "Chicago"}, "CreatedAt": {"S": "2020-01-22"}, "FullName": {"S": "Doug Smith"}}'


Task 3: Write and execute command to list the table in your AWS account
aws dynamodb list-tables


Task 4: Write and execute command to describe the table in your AWS account
aws dynamodb describe-table --table-name orders


Task 5: Write and execute command to query the data to find all the orders from user "doug"
aws dynamodb get-item --consistent-read \
--table-name Orders \
--key '{ "userId": {"S": "Doug"}, "OrderId": {"S": "8yq9d"}}'


Task 6: Write and execute command to query the data to find all the orders from user "doug"
aws dynamodb query \
--table-name Orders \
--key-condition-expression "UserId = :uid" \
--expression-attribute-values  '{":uid":{"S":"doug"}}'