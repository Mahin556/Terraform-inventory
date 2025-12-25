When you created the environment using Terraform, what components did you set up using Terraform?
How do you make changes to the configuration of already created resources using Terraform?
When the Terraform state file is created, what do you do with that state file and where do you store and find it?
How do you resolve the issue if you lose the Terraform state file?
What are the major features you have found in Terraform that you can talk about?
What are the major features you have found in Terraform that you can talk about?
What is the `terraform validate` command used for, and can you provide an example?
Have you ever heard about the lifecycle in Terraform? Can you talk more about it?
Have you worked with tools like CloudFormation, Ansible, or anything similar?
Do you have any experience with Ansible?
If you had to choose between Ansible and Terraform, which one would you prefer and why?
In your current organization, which tool are you using: Ansible, Terraform, or Pulumi?
Can you talk about any features of Pulumi that you find particularly useful or impressive?
Have you ever heard about Bicep or ARM templates?
In a scenario where you have 20 resources running on a public cloud (AWS or Azure) and you want to destroy just one resource, how would you go about doing that?
Have you ever preserved a key that you created using Terraform?
What happens if you delete the Terraform state file and then run the `terraform apply` or `terraform plan` command?
Have you ever worked with modules in Terraform?
What are the different types of modules in Terraform?
The module that gets called is what: a parent module or a child module?
From where we call a module, what is that module called?
Have you ever heard about remote backends in Terraform? Do you have any ideas or experience with them?
How can you provide variable values at runtime in Terraform?
In an organization, how do you manage multiple environments in Terraform?
Why do we call Terraform "Infrastructure as Code" (IaC)? Is there a particular reason for this?
Can you explain some drawbacks or challenges you have faced in your career?
Which version of Terraform are you using?

```hcl
###############################################################
# TERRAFORM INTERVIEW SCENARIOS — FULL SUMMARY (DAY 8)
###############################################################

# -------------------------------------------------------------
# ⭐ SCENARIO 1 — Migrate Existing AWS Resources to Terraform
# -------------------------------------------------------------
Task: AWS resources already exist (e.g., EC2 created via CloudFormation/UI).
Now team has shifted to Terraform. How to import everything?

# ✔ Problem:
• No Terraform files exist
• No state file exists
• Terraform does NOT know existing resources
• Writing 100s of resources manually is impossible

# ✔ Solution: terraform import + generate config
1. Create empty folder:
   day8/scenario1/

2. Write main.tf with provider + import block (Terraform 1.5+):

provider "aws" {
  region = "us-east-1"
}

import {
  id = "i-0123456789abcd"    # EC2 instance ID
  to = aws_instance.example
}

resource "aws_instance" "example" {
  # placeholder, will be replaced
}

3. Initialize:
   terraform init

4. Auto-generate full config:
   terraform plan -generate-config-out=generated.tf

→ Terraform creates a new TF file containing **all required + optional fields**  
  for that EC2 instance.

5. Copy the generated resource block into main.tf  
   (delete generated.tf afterward).

6. Import into state:
   terraform import aws_instance.example i-0123456789abcd

7. Test:
   terraform plan
   → Output: **No changes**, meaning import worked.

# ✔ What Terraform Does:
• Reads AWS resource → generates full configuration  
• Populates terraform.tfstate  
• After import, Terraform manages that resource

# ✔ Challenges (mention in interview):
• Generated config is huge → must clean unused fields  
• Resources referencing other resources will cause failures  
• Must repeat per resource type  
• Time-consuming for large infra  
• Missing dependencies must be manually added later

# -------------------------------------------------------------
# ⭐ SCENARIO 2 — Drift Detection (Manual Changes in AWS Console)
# -------------------------------------------------------------
Problem: 
Terraform creates 1000s of resources.  
One engineer logs into AWS manually and changes an S3 lifecycle or EC2 config.  
Terraform does NOT know unless you run terraform plan.

This mismatch = **DRIFT**.

# ✔ Two ways to detect drift:

---------------------------------------------------------------
# ✔ Method 1 — terraform refresh (traditional way)
---------------------------------------------------------------
• Run periodically (cron job)
• terraform refresh updates state file based on real AWS values
• If drift occurs → terraform refresh will update state

Cron example (every 1 hour):
0 * * * * terraform refresh && terraform plan

Limitations:
• refresh is being deprecated in future Terraform
• Not automatic unless scheduled

---------------------------------------------------------------
# ✔ Method 2 — AWS Audit Logs + Lambda (BEST PRACTICE)
---------------------------------------------------------------
Workflow:
1. Enable CloudTrail (audit logs)
2. Each AWS resource API call is logged:
   • WHO changed?
   • WHAT changed?
   • WHEN changed?

3. Create Lambda function:
   • Reads CloudTrail events
   • Checks if the changed resource is “managed by Terraform”
     (e.g., tag = terraform=true)
   • If manual IAM user changed it:
     → Send alert to Slack/Email

4. Benefits:
   • Real-time detection
   • Detects EXACT user that made manual change
   • Prevents silent drift

---------------------------------------------------------------
# ✔ Extra Preventive Measures:
• Strict IAM: DevOps users CANNOT change AWS console directly  
• Only Terraform role allowed to modify infra  
• Mandatory approval before AWS console login

---------------------------------------------------------------
# ⭐ Interview Summary for Scenario 2:
• Drift = actual infra ≠ state file  
• Terraform cannot detect drift automatically  
• terraform refresh (cron) → periodic detection  
• Audit logs + Lambda → real-time detection with alerts  
• IAM restrictions → prevent drift completely

###############################################################
# FINAL TAKEAWAY
• Scenario 1 = Migration + terraform import + generate-config  
• Scenario 2 = Drift detection using refresh OR audit logs  
These two scenarios are VERY COMMON in Terraform interviews.
###############################################################
```