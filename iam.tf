# =============================================================================
# Lambda Privilege Escalation Lab - IAM Resources
# 
# This scenario demonstrates privilege escalation through Lambda and IAM PassRole
# 
# Attack path:
# 1. Start as "chris" user with limited IAM read + sts:AssumeRole permissions
# 2. Discover assumable "lambdaManager" role with Lambda + PassRole permissions
# 3. Assume lambdaManager role
# 4. Create a Lambda function that attaches AdministratorAccess to chris
# 5. Invoke the Lambda to escalate privileges
# =============================================================================

# -----------------------------------------------------------------------------
# IAM User: chris (Starting Point)
# Low-privileged user with IAM read permissions and ability to assume roles
# -----------------------------------------------------------------------------

resource "aws_iam_user" "chris" {
  name = "chris-${var.lab_id}"
  path = "/"

  tags = {
    Name = "chris-${var.lab_id}"
  }
}

resource "aws_iam_access_key" "chris" {
  user = aws_iam_user.chris.name
}

# Chris's policy - limited IAM read + sts:AssumeRole
resource "aws_iam_policy" "chris_policy" {
  name        = "chris-policy-${var.lab_id}"
  description = "Policy for chris user - IAM read and AssumeRole permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IAMReadPermissions"
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "AssumeRolePermission"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = aws_iam_role.lambda_manager.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "chris_policy_attachment" {
  user       = aws_iam_user.chris.name
  policy_arn = aws_iam_policy.chris_policy.arn
}

# -----------------------------------------------------------------------------
# IAM Role: Lambda Manager
# Role that chris can assume - has full Lambda and PassRole permissions
# This enables the privilege escalation vector
# -----------------------------------------------------------------------------

resource "aws_iam_role" "lambda_manager" {
  name = "lambdaManager-role-${var.lab_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/chris-${var.lab_id}"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "lambdaManager-role-${var.lab_id}"
  }
}

# Lambda Manager policy - Full Lambda access + PassRole
resource "aws_iam_policy" "lambda_manager_policy" {
  name        = "lambdaManager-policy-${var.lab_id}"
  description = "Full Lambda access and PassRole permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "FullLambdaAccess"
        Effect = "Allow"
        Action = "lambda:*"
        Resource = "*"
      },
      {
        Sid    = "PassRoleToLambda"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = aws_iam_role.debug_role.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_manager_policy_attachment" {
  role       = aws_iam_role.lambda_manager.name
  policy_arn = aws_iam_policy.lambda_manager_policy.arn
}

# -----------------------------------------------------------------------------
# IAM Role: Debug Role
# High-privileged role that Lambda functions can use
# Has AdministratorAccess - this is what enables the escalation
# -----------------------------------------------------------------------------

resource "aws_iam_role" "debug_role" {
  name = "debug-role-${var.lab_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "debug-role-${var.lab_id}"
  }
}

# Attach AdministratorAccess to the debug role (the vulnerability!)
resource "aws_iam_role_policy_attachment" "debug_role_admin" {
  role       = aws_iam_role.debug_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
