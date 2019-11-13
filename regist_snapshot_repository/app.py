import os
import boto3
import requests
from requests_aws4auth import AWS4Auth

host = os.environ['AES_HOST']
region = os.environ['REGION']
role_arn = os.environ['SNAPSHOT_ROLE_ARN']
snapshot_bucket = os.environ['SNAPSHOT_BUCKET']
repo_name = os.environ['SNAPSHOT_REPO_NAME']
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

def lambda_handler(event, context):
    path = f'_snapshot/{repo_name}'
    url = f'https://{host}/{path}'

    payload = {
    "type": "s3",
    "settings": {
        "bucket": snapshot_bucket,
        "region": region,
        "role_arn": role_arn
    }
    }

    headers = {"Content-Type": "application/json"}
    r = requests.put(url, auth=awsauth, json=payload, headers=headers)
    print(r.status_code)
    print(r.text)