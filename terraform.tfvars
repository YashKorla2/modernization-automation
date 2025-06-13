# ---------------------------------------------------------------------------------------------------------------
# This file provides user values for variables declared in by variables.tf.
# ---------------------------------------------------------------------------------------------------------------

# Name of the CodeStar Connection
connection_name = "gh-conn"

# Git provider: supported values are "GitHub", "GitLab", "Bitbucket", etc.
provider_type = "GitHub"

# Full URL to the source code repository
repository_url = "https://github.com/YashKorla/mini-spring"

# The source branch to modernize
branch_name = "main"

# The output branch where the modernized code will be pushed
output_branch = "Q-TRANSFORM-Issue-1-0001"

# AWS region where resources will be created
region = "us-east-1"
