import boto3
import os

codestar = boto3.client("codestar-connections")
lambda_client = boto3.client("lambda")
events_client = boto3.client("events")

def lambda_handler(event, context):
    connection_arn = os.environ["CONNECTION_ARN"]
    transform_lambda_name = os.environ["TRANSFORM_LAMBDA_NAME"]
    poll_rule_name = os.environ["POLL_RULE_NAME"]

    try:
        response = codestar.get_connection(ConnectionArn=connection_arn)
        status = response["Connection"]["ConnectionStatus"]
        print(f"Connection status: {status}")

        if status == "AVAILABLE":
            print("Connection is available. Invoking transform lambda...")

            # Invoke the transform lambda
            invoke_response = lambda_client.invoke(
                FunctionName=transform_lambda_name,
                InvocationType="Event"  # async
            )
            print(f"Transform lambda invoked. Response: {invoke_response['StatusCode']}")

            # Disable the polling rule
            events_client.disable_rule(Name=poll_rule_name)
            print(f"Polling rule '{poll_rule_name}' disabled.")
        else:
            print("Connection not yet authorized. Will retry later.")

    except Exception as e:
        print(f"Error checking connection status: {str(e)}")
