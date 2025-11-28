### References:-
- http://developer.hashicorp.com/terraform/language/tests#parallel-execution

---


* Terraform now has a built-in testing framework called Terraform Test, introduced in Terraform 1.6 and improved in 1.7+.
* Just like other languages (Python → pytest, Go → go test), Terraform allows you to test your infrastructure code before deploying it.
* Terraform tests allow you to verify:
  * Resources are created with correct values
  * Variables are validated properly
  * Modules work as expected
  * Outputs contain correct values
  * Your infrastructure logic (conditions, expressions, references) is correct
  * Changes do not break the module (regression testing)
* Terraform testing is especially useful when you write Terraform modules used by teams.
* A `*.tftest.hcl` file is a Terraform test file, written in HCL syntax.
* This file contains:
  * Test cases
  * Input variables for the test
  * Assertions (expected values)
  * Custom test logic
  * Optional plan/apply sequence
  * Expected behavior (success, failure, etc.)

```bash
$ terraform test

$ terraform.exe test
tests\basic.tftest.hcl... in progress
  run "first"... pass
  run "second"... pass
tests\basic.tftest.hcl... tearing down
tests\basic.tftest.hcl... pass
Success! 2 passed, 0 failed.

$ terraform.exe test
tests\basic.tftest.hcl... in progress
  run "first"... fail
╷
│ Error: Test assertion failed
│
│   on tests\basic.tftest.hcl line 12, in run "first":
│   12:     condition     = resource.aws_instance.ec2-instance.tags["Name"] == "dev"
│     ├────────────────
│     │ Diff:
│     │ --- actual
│     │ +++ expected
│     │ - "TestInstance"
│     │ + "dev"
│
│
│ Instance Name tag should be 'dev'
╵
  run "second"... fail
╷
│ Error: Test assertion failed
│
│   on tests\basic.tftest.hcl line 19, in run "second":
│   19:     condition     = resource.aws_instance.ec2-instance.instance_type == "t3.micro"    
│     ├────────────────
│     │ Diff:
│     │ --- actual
│     │ +++ expected
│     │ - "t2.micro"
│     │ + "t3.micro"
│
│
│ Instance type should be 't3.micro'
╵
tests\basic.tftest.hcl... tearing down
tests\basic.tftest.hcl... fail
Failure! 0 passed, 2 failed.

$ terraform.exe test -junit-xml=./demo.xml

$ terraform validate -test-directory=my-tests

$ terraform validate -no-tests
```

* Default location:
    ```bash
    tests/
    ```

* `tests/basic.tftest.hcl`
    ```hcl
    test {
    parallel = true
    }

    variables {
    region = "ap-south-1"
    }

    run "first" {
    # Assertions against the planned resource values
    assert {
        condition     = resource.aws_instance.ec2-instance.tags["Name"] == "TestInstance"
        error_message = "Instance Name tag should be 'dev'"
    }
    }

    run "second" {
    assert {
        condition     = resource.aws_instance.ec2-instance.instance_type == "t2.micro"
        error_message = "Instance type should be 't3.micro'"
    }
    }
    ```

* `main.tf`
    ```hcl
    terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
    }

    provider "aws" {
    region = var.region
    }

    resource "aws_instance" "ec2-instance" {
    ami           = "ami-0521bc4c70257a054" # Amazon Linux 2 AMI
    instance_type = "t2.micro"
    tags = {
        Name = "TestInstance"
    }
    }
    ```

* `variable.tf`
    ```hcl
    variable "region" {
    default = "ap-south-1"
    }
    ```

* `demo.xml
    ```xml
    <?xml version="1.0" encoding="UTF-8"?><testsuites>
    <testsuite name="tests\basic.tftest.hcl" tests="2" skipped="0" failures="0" errors="0">
        <testcase name="first" classname="tests\basic.tftest.hcl" time="16.5697846" timestamp="2025-11-25T14:56:19Z"></testcase>
        <testcase name="second" classname="tests\basic.tftest.hcl" time="2.9781177" timestamp="2025-11-25T14:56:35Z"></testcase>
    </testsuite>
    </testsuites>
    ```


* Working
```bash
###############################################
# How Terraform Tests Work Internally (Theory)
###############################################

# When you run:
#     terraform test
#
# Terraform processes EACH .tftest.hcl file by doing
# the following steps internally:

###################################################
# 1. Create a Sandbox Directory
###################################################
# Terraform builds an isolated temporary working directory.
# This sandbox prevents any test from modifying your real project.
# No real infrastructure is touched unless you explicitly allow apply.

###################################################
# 2. Copy the Module Into the Sandbox
###################################################
# Terraform copies your module’s .tf files into the sandbox.
# Providers are installed inside sandbox.
# Variables inside test file are injected into this temporary workspace.

###################################################
# 3. Execute Test Steps (run block)
###################################################
# Terraform runs the instructions found in:
#     run "name" { ... }
#
# Each run block may include:
# - command = "plan"     (default)
# - command = "apply"    (optional)
# - variables = { ... }  (input variables for this test)
#
# "plan" runs a sandboxed terraform plan.
# "apply" creates temporary resources in the sandbox workspace.

###################################################
# 4. Evaluate Assertions
###################################################
# During or after the plan/apply, Terraform evaluates:
#
#   assert {
#     condition     = <boolean expression>
#     error_message = "message on failure"
#   }
#
# Example:
#   assert {
#     condition = module.network.vpc_id != ""
#   }
#
# If condition = false → test FAILS with your error message.
# If all assertions = true → test PASSES.

###################################################
# 5. Destroy Sandbox Resources (Cleanup)
###################################################
# After the test completes:
# - If command = "plan": nothing was created, so nothing to destroy.
# - If command = "apply": Terraform destroys all resources in sandbox.
#
# This ensures your actual cloud environment is untouched.
#
# After cleanup:
#     Success! X passed, Y failed.
#
###################################################
# Summary:
# Terraform Test = isolated module testing using plan/apply + assertions
# Sandbox prevents affecting real infrastructure
# Assertions verify module behavior safely and repeatedly
###################################################
```