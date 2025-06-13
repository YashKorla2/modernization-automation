# -------------------------------------------------------------------------------------------------------------
# Creates the Lambda Function for Transform Job creation. 
# Uses the lambda.zip file for the code.
#
# --- Setting up zip.exe
# Download the zip.exe file from: http://stahlworks.com/dev/index.php?tool=zipunzip
# Unzip the zip file and add the folder to environment variables
#
# --- Creating zip file
#   -> Open cmd 
#   -> run command "cd modules/lambda/codes" 
#   -> run command "zip.exe lambda.zip transform_trigger.py"
# Move the zip file to the root folder.
# -------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "transform_trigger" {
  filename         = "lambda.zip"
  function_name    = "trigger-code-transform-${var.user_suffix}"
  role             = var.lambda_role_arn
  handler          = "transform_trigger.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      CONNECTION_ARN   = var.connection_arn
      REPOSITORY_NAME  = var.repository_url
      BRANCH_NAME      = var.branch_name
      OUTPUT_BRANCH    = var.output_branch
    }
  }
}

# -------------------------------------------------------------------------------------------------------------
# Creates the Lambda Function for Polling the CodeConnection. 
# Uses the lambda.zip file for the code.
#
# --- Creating zip file
#   -> Open cmd 
#   -> run command "cd modules/lambda/codes" 
#   -> run command "zip.exe lambda_status.zip poll_connection_status.py"
# Move the zip file to the root folder.
# -------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "poll_connection_status" {
  filename         = "lambda_status.zip"
  function_name    = "poll-connection-status-${var.user_suffix}"
  role             = var.lambda_role_arn
  handler          = "poll_connection_status.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda_status.zip")

  environment {
    variables = {
      CONNECTION_ARN      = var.connection_arn
      TRANSFORM_LAMBDA_NAME = aws_lambda_function.transform_trigger.function_name
      POLL_RULE_NAME        = aws_cloudwatch_event_rule.poll_connection_schedule.name
    }
  }
}


# -------------------------------------------------------------------------------------------------------------
# Creates the EventBridge Rule for the Lambda Function for Polling the CodeConnection. 
# Sets the polling rate to 5 minutes.
# -------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "poll_connection_schedule" {
  name                = "poll-connection-status-${var.user_suffix}"
  schedule_expression = "rate(5 minutes)"
}

# -------------------------------------------------------------------------------------------------------------
# Sets the Polling Lambda Function created above as the target for the EventBridge Rule.
# -------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "poll_target" {
  rule = aws_cloudwatch_event_rule.poll_connection_schedule.name
  arn  = aws_lambda_function.poll_connection_status.arn
}

# -------------------------------------------------------------------------------------------------------------
# Allows the EventBridge Rule to invoke the Lambda Function.
# -------------------------------------------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_scheduled_poll" {
  statement_id  = "AllowScheduledInvoke-${var.user_suffix}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.poll_connection_status.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.poll_connection_schedule.arn
}

output "transform_trigger_arn" {
  value = aws_lambda_function.transform_trigger.arn
}

output "poll_connection_schedule_arn" {
  value = aws_cloudwatch_event_rule.poll_connection_schedule.arn
}