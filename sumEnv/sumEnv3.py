import json
import boto3 
import io
def lambda_handler(event, context):
    print(event);
    contents=readFile("input/triggerFile.txt"); 
    lines = contents.split('\n');
    dataLine =  lines[1];
    envs = dataLine.split('|'); 
    sum = 0;
    for env in envs:
        sum = sum + int(env);

    print("contents:\n"+contents)  ;
    
    contents = contents + '\nsum:' + str(sum); 
    results = writeFile(contents);

    print("results:\n"+contents);

    return {
        'statusCode': 200, 
        'body': results
    } 
    
s3_bucket_name='centene-sum-env3'; 

def getS3Client():
    s3_client =boto3.client('s3');
    s3 = boto3.resource('s3',
                    aws_access_key_id= 'AWS_ACCESS_KEY_ID',
                    aws_secret_access_key='AWS_SECRET_ACCESS_KEY_ID');
    return s3;
    
def readFile(file): 
    s3=getS3Client();
    my_object = s3.Object(bucket_name=s3_bucket_name, key=file);
    return my_object.get()['Body'].read().decode('utf-8');
    
    
def writeFile(contents): 
    s3=getS3Client();
    return s3.Object(s3_bucket_name, 'output/triggerFile.out').put(Body=contents);