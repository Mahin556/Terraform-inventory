```json
variable "region" {
    description = "value of region"
    type = string
    default = "ap-south-1"
}

provider "aws" {
    region = var.region
}
```