# ---------------------------------------------------------------------------------------------------------------
# This file declares all the variables that the script needs.
# ---------------------------------------------------------------------------------------------------------------

variable "connection_name" {
  type        = string
  description = "Name of the CodeConnection"
}

variable "provider_type" {
  type        = string
  description = "Source provider (GitHub, GitLab, etc.)"
}

variable "repository_url" {
  type        = string
  description = "Git repository URL"
}

variable "branch_name" {
  type        = string
  description = "Branch to modernize"
}

variable "output_branch" {
  type        = string
  description = "Branch to push transformed code"
}

variable "region" {
  type        = string
  default     = "us-east-1"
}
