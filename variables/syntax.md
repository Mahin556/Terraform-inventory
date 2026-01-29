```hcl
variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "demo-app"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances"
  default     = 2

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "description" {
  type        = string
  description = "Optional resource description"
  nullable    = true
  default     = null
}
#Allows null instead of forcing a value.

variable "enable_monitoring" {
  type        = bool
  description = "Enable CloudWatch monitoring"
  default     = true
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AZs"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  type        = map(string)
  description = "Common resource tags"
  default = {
    Environment = "dev"
    Owner       = "devops"
  }
}

variable "server_config" {
  type = object({
    instance_type = string
    disk_size     = number
    public_ip     = bool
  })

  default = {
    instance_type = "t3.micro"
    disk_size     = 20
    public_ip     = true
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}

variable "session_token" {
  type      = string
  sensitive = true
  ephemeral = true
}
#Used for temporary runtime-only values.