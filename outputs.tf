# =============================================================================
# Lambda Privilege Escalation Lab - Outputs
# =============================================================================

output "scenario_name" {
  description = "Name of the deployed scenario"
  value       = var.scenario_name
}

output "aws_account_id" {
  description = "AWS Account ID where resources are deployed"
  value       = data.aws_caller_identity.current.account_id
}

output "chris_access_key_id" {
  description = "Access Key ID for chris user (starting point)"
  value       = aws_iam_access_key.chris.id
}

output "chris_secret_access_key" {
  description = "Secret Access Key for chris user (starting point)"
  value       = aws_iam_access_key.chris.secret
  sensitive   = true
}

output "chris_username" {
  description = "Username for chris"
  value       = aws_iam_user.chris.name
}

output "lambda_manager_role_arn" {
  description = "ARN of the Lambda Manager role (can be assumed by chris)"
  value       = aws_iam_role.lambda_manager.arn
}

output "debug_role_arn" {
  description = "ARN of the Debug role (has AdministratorAccess, can be passed to Lambda)"
  value       = aws_iam_role.debug_role.arn
}

output "scenario_goal" {
  description = "Objective of this scenario"
  value       = "Acquire full admin privileges starting as the low-privileged 'chris' user"
}

output "start_instructions" {
  description = "Instructions to begin the scenario"
  value       = <<-EOT
    
    ============================================================
    Lambda Privilege Escalation Lab
    ============================================================
    
    GOAL: Acquire full admin privileges
    
    STARTING POINT:
    You have access keys for the 'chris' user who has limited IAM 
    read permissions and the ability to assume certain roles.
    
    TO BEGIN:
    1. Configure AWS CLI with chris's credentials:
       aws configure --profile chris
       
    2. Verify your identity:
       aws sts get-caller-identity --profile chris
    
    3. Start exploring! Hints:
       - What policies does chris have?
       - What roles exist in this account?
       - Can chris assume any roles?
    
    To get chris's secret key, run:
       terraform output -raw chris_secret_access_key
    
    ============================================================
  EOT
}
