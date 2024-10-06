-- Amazon S3
copy into mytable from s3://mybucket/data/files credentials=(aws_key_id='$AWS_ACCESS_KEY_ID' aws_secret_key='$AWS_SECRET_ACCESS_KEY') file_format = (format_name = my_csv_format);

-- Google Cloud Storage
copy into mytable from gcs://mybucket/data/files file_format = (format_name = my_csv_format);

-- Microsoft Azure
copy into mytable from 'azure://myaccount.blob.core.windows.net/mycontainer/data/files' credentials=(azure_sas_token='?sv=2016-05-31&ss=b&srt=sco&sp=rwdl&se=2018-06-27T10:05:50Z&st=2017-06-27T02:05:50