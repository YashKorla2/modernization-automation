# -------------------------------------------------------------------------------------------------------------
# This file creates the IAM role and assigns all the required policies.
# -------------------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------
# Gets the current AWS account ID
# -------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# -------------------------------------------------------------------------------------------------------------
# Creates the IAM role named "lambda-code-transform-role".
# Assigns access to AWS Lambda
# -------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "lambda-code-transform-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect    = "Allow"
    }]
  })
}

# -------------------------------------------------------------------------------------------------------------
# Creates inline policy for the IAM policy named "lambda_codestar_policy".
# Policy assigns access to Listing CodeConnections
# -------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "lambda_codestar_policy" {
  name   = "LambdaCodeStarAccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codeconnections:GetConnection"
        ],
        Resource = "arn:aws:codestar-connections:${var.region}:${data.aws_caller_identity.current.account_id}:connection/*"
        # For tighter security, replace * with your specific connection ID
      }
    ]
  })
}

# -------------------------------------------------------------------------------------------------------------
# Attaches the above policy to the IAM Role.
# -------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_codestar_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_codestar_policy.arn
}

# -------------------------------------------------------------------------------------------------------------
# Attaches Lambda policy to IAM Role.
# -------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# -------------------------------------------------------------------------------------------------------------
# Creates inline policy to allow invoking another Lambda and disabling its own EventBridge rule
# -------------------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "lambda_manage_trigger_policy" {
  name = "LambdaManageTriggerPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = var.transform_trigger_arn
      },
      {
        Effect = "Allow",
        Action = [
          "events:DisableRule"
        ],
        Resource = var.poll_connection_schedule_arn
      }
    ]
  })
}

# -------------------------------------------------------------------------------------------------------------
# Attach the above policy to the Lambda role
# -------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_manage_trigger_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_manage_trigger_policy.arn
}

# -------------------------------------------------------------------------------------------------------------
# This block will allow the IAM Role to creates AWS Transform jobs, but at the moment this is not allowed by
# AWS, hence the block is commented. Uncomment the block of code and modify according to updated AWS Transform
# documentation.
# -------------------------------------------------------------------------------------------------------------
/*
resource "aws_iam_role_policy_attachment" "transform_access" {
  name       = "lambda-transform-access"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSTransformFullAccess"
}
*/

# -------------------------------------------------------------------------------------------------------------
# Outputs the lambda role ARN.
# -------------------------------------------------------------------------------------------------------------
output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

# -------------------------------------------------------------------------------------------------------------
# Outputs the lambda role name.
# -------------------------------------------------------------------------------------------------------------
output "lambda_role_name" {
  value = aws_iam_role.lambda_role.name
}
