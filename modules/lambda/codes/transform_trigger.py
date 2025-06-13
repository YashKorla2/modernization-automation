import boto3
import os

# def lambda_handler(event, context):
#     client = boto3.client('codetransform')
#     response = client.start_transformation_job(
#         connectionArn=os.environ['CONNECTION_ARN'],
#         repositoryName=os.environ['REPOSITORY_NAME'],
#         branchName=os.environ['BRANCH_NAME'],
#         outputBranch=os.environ['OUTPUT_BRANCH'],
#         transformationType='MODERNIZE'
#     )
#     return {"jobId": response["jobId"]}

def lambda_handler(event, context):
    print("Event received:", event)
    # Here you will trigger the AWS CodeTransform job via boto3
    return {
        'statusCode': 200,
        'body': 'Triggered CodeTransform job'
    }
