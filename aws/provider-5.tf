#EKS + IRSA (NO AWS CLI, NO ACCESS KEYS)
# Assume:
# - Terraform running inside Kubernetes pod
# - Pod has IRSA (OIDC) role
# - No AWS CLI
# - No credentials

# Terraform config:
# provider "aws" {
#   region = "ap-south-1"
# }

# Terraform execution:
# terraform apply

# What happens:
# - AWS SDK exchanges OIDC token with STS
# - Gets temporary credentials
# - Calls AWS APIs

# Used in:
# - GitOps
# - ArgoCD
# - Platform engineering