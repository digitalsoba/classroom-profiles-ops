import json
import boto3

client = boto3.client('s3')
data = client.get_object(Bucket='matabit', Key='api/roster.json')
body = data['Body'].read().decode('utf-8')

def lambda_handler(event, context):
    # TODO implement
    return {
      'statusCode': 200,
      'body': body
    }