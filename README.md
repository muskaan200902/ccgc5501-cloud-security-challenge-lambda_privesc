# Lambda Privilege Escalation Lab

## Overview

**Scenario**: `lambda_privesc`  
**Difficulty**: Easy/Medium  
**Goal**: Acquire full admin privileges  

Starting as the IAM user **Chris**, the attacker discovers that they can assume a role that has full Lambda access and pass role permissions. The attacker can then perform privilege escalation using these new permissions to obtain full admin privileges.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         AWS Account                                      │
│                                                                          │
│  ┌──────────────┐                                                       │
│  │  IAM User:   │                                                       │
│  │    chris     │─────────┐                                             │
│  │              │         │ sts:AssumeRole                              │
│  │ Permissions: │         │                                             │
│  │ - iam:Get*   │         ▼                                             │
│  │ - iam:List*  │   ┌───────────────────┐                               │
│  │ - AssumeRole │   │   IAM Role:       │                               │
│  └──────────────┘   │ lambdaManager     │                               │
│                     │                   │                               │
│                     │ Permissions:      │                               │
│                     │ - lambda:*        │─────────┐                     │
│                     │ - iam:PassRole    │         │ iam:PassRole        │
│                     └───────────────────┘         │                     │
│                                                   ▼                     │
│                                           ┌───────────────────┐         │
│                                           │   IAM Role:       │         │
│                                           │   debug           │         │
│                                           │                   │         │
│                                           │ Attached Policy:  │         │
│                                           │ AdministratorAccess│        │
│                                           │                   │         │
│                                           │ Trust: Lambda     │         │
│                                           └───────────────────┘         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- An AWS account with permissions to create IAM resources

## Deployment

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the plan

```bash
terraform plan
```

### 3. Deploy the scenario

```bash
# Using default profile
terraform apply

# Or specify a profile
terraform apply -var="profile=your-profile-name"

# Or specify a custom lab_id for unique naming
terraform apply -var="lab_id=mytest123"
```

### 4. Get the starting credentials

```bash
# Get chris's access key ID
terraform output chris_access_key_id

# Get chris's secret access key
terraform output -raw chris_secret_access_key
```
## Cleanup

### Manual cleanup (if you created Lambda functions)

Before running `terraform destroy`, remove any manually created resources:

### Destroy Terraform resources

```bash
terraform destroy
```

## Learning Objectives

This scenario demonstrates:

1. **IAM Enumeration**: How attackers discover permissions and roles in an AWS environment
2. **Role Assumption**: Using `sts:AssumeRole` to gain additional permissions
3. **Lambda Privilege Escalation**: Exploiting overly permissive Lambda execution roles
4. **IAM PassRole Abuse**: How `iam:PassRole` can be leveraged for privilege escalation

## Mitigations

- **Principle of Least Privilege**: Don't attach `AdministratorAccess` to Lambda execution roles
- **Restrict PassRole**: Limit which roles can be passed to Lambda functions
- **Monitor AssumeRole Events**: Set up CloudTrail alerts for role assumption
- **Use Service Control Policies**: Prevent attachment of admin policies at the organization level

## References

- [AWS IAM PassRole Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html)
- [Lambda Execution Roles](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
