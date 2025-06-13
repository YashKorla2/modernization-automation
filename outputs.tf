# -------------------------------------------------------------------------------------------------------------
# This file defines all the outputs that will be emitted if the script runs successfully.
# -------------------------------------------------------------------------------------------------------------

output "created_or_changed" {
  value = <<-EOT
      1 CodeConnection connection,
      1 IAM Role,
      1 EventBridge Polling Rule,
      2 Lambda functions
  EOT 
}

output "code_connection_arn" {
  value = aws_codestarconnections_connection.source_repo.arn
}

output "console_authorization_url" {
  value = <<-EOT
      Go to the link given below and authorize the connection:
      https://console.aws.amazon.com/codesuite/settings/connections
      
      Once the connection is authorized, the Lambda function will be invoked within 5 minutes and 
      start the transformation job.
  EOT
}
