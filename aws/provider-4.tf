#CI/CD PIPELINE (GITHUB ACTIONS / JENKINS)
# Assume:
# - Docker container
# - Only terraform binary present
# - No aws cli package installed

# Pipeline env vars:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION

# Terraform step:
# terraform init
# terraform plan
# terraform apply -auto-approve

# What happens:
# - Terraform reads env vars
# - AWS provider signs API requests
# - Infrastructure created

# Why companies do this:
# - Smaller images
# - Fewer attack vectors
# - Faster pipelines