# ---------------------------------------------------------------------------------------------------------------
# This file is the entry point of the whole process.
# The flow it follows is: 
#   -> Create CodeConnection connection (CodeStarConnections connection)
#   -> Create IAM Role 
#   -> Create EventBridge Rule (with 5 minute schedule rate)
#   -> Create Lambda Function for Polling (invoked by EventBridge rule to check for connection status)
#   -> Create Lambda Function for Transform Job Creation (invoked by polling function when connection available)
# ---------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------
# Get account identity for dynamically naming resources
# ---------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

locals {
  raw_user_suffix = replace(data.aws_caller_identity.current.arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:", "")
  user_suffix     = replace(replace(replace(local.raw_user_suffix, "/", "-"), ".", "-"), "@", "-")
}

# ---------------------------------------------------------------------------------------------------------------
# Registers the "iam" module and passes the "region" value.
# Creates the IAM Role for performing other actions in the process.
# ---------------------------------------------------------------------------------------------------------------
module "iam" {
  source                       = "./modules/iam"
  region                       = var.region
  transform_trigger_arn       = module.lambda.transform_trigger_arn
  poll_connection_schedule_arn = module.lambda.poll_connection_schedule_arn
  user_suffix                 = local.user_suffix
}

# ---------------------------------------------------------------------------------------------------------------
# Registers the "lambda" module and passes "repository_url", "branch_name" and "output_branch" values.
# Creates the lambda functions.
# ---------------------------------------------------------------------------------------------------------------
module "lambda" {
  source          = "./modules/lambda"
  repository_url  = var.repository_url
  branch_name     = var.branch_name
  output_branch   = var.output_branch
  connection_arn  = aws_codestarconnections_connection.source_repo.arn
  lambda_role_arn = module.iam.lambda_role_arn
  user_suffix     = local.user_suffix
}

# ---------------------------------------------------------------------------------------------------------------
# Defines AWS as the service provider for the whole process. This will be used to download the 
# provider files when doing "terraform init".
# ---------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = var.region
}

# ---------------------------------------------------------------------------------------------------------------
# Creates the CodeConnection connection (CodeStar Connection). 
# Uses the variables.tf and terraform.tfvars files to pass the values for the connection. 
# ---------------------------------------------------------------------------------------------------------------
resource "aws_codestarconnections_connection" "source_repo" {
  name          = "${var.connection_name}-${local.user_suffix}"
  provider_type = var.provider_type
}
