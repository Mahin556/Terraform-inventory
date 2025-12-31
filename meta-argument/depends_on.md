* Terraform manages the order in which resources are created, updated, and destroyed using a dependency graph, which is built using both implicit and explicit dependencies. 
* **Implicit Dependencies**:- Implicit dependencies are automatically detected by Terraform when one resource's argument references an attribute of another resource. Terraform analyzes these references to build the correct operational order. 
    * **Example**: An EC2 instance uses the ID of a security group. Terraform implicitly understands the security group must be created first. 
    ```hcl
    resource "aws_security_group" "web_sg" {
        # ... configuration ...
    }

    resource "aws_instance" "web_server" {
        # ... configuration ...
        vpc_security_group_ids = [aws_security_group.web_sg.id] # Implicit dependency here
    }
    ```
* **Explicit Dependencies**:- Explicit dependencies are manually defined using the depends_on meta-argument within a resource block. This is used when a resource relies on another's behavior or side effects, but there is no direct attribute reference for Terraform to automatically detect. 
    ```hcl
    resource "aws_iam_role" "db_access_role" {
        # ... configuration ...
    }

    resource "aws_iam_role_policy_attachment" "db_policy" {
        # ... configuration ...
        role       = aws_iam_role.db_access_role.name
        # ...
    }

    resource "aws_db_instance" "database" {
        # ... configuration ...
        depends_on = [
            aws_iam_role_policy_attachment.db_policy
        ] # Explicit dependency ensures policy is attached first
    }
    ```

```hcl
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"

  tags = {
    Name = "aman-vpc"
    Env  = "dev"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id #Implicit Dependency
  tags = {
    Name = "aman-igw"
    env  = "dev"
  }

  depends_on = [aws_vpc.vpc] <= This resource will be created after vpc only.
}
```

