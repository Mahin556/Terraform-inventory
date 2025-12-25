### References:-
- https://spacelift.io/blog/terraform-workspaces

* Workspaces allow users to manage different sets of infrastructure using the same configuration by isolating state files.
* Using terraform workspaces we can create infra on multiple environment using a same configuration
* Environments can be:
    * Multi envs
    * Multi region
    * Multi account
* Each workspace have a saperate state file.

```bash
terraform workspace --help
Usage: terraform [global options] workspace

  new, list, show, select, and delete Terraform workspaces.

Subcommands:
    delete    Delete a workspace
    list      List Workspaces
    new       Create a new workspace
    select    Select a workspace
    show      Show the name of the current workspace
```
```bash
$ terraform workspace show
default

$ terraform workspace list
* default

$ terraform workspace new test_workspace #Create and select workspace
Created and switched to workspace "test_workspace"!

$ terraform.exe workspace list
  default
* test_workspace

$ terraform.exe workspace show
test_workspace
```
 
---

* WHERE IS THIS STATE STORED (IN REMOTE BACKEND)?
```bash
# Using AWS S3 backend as example.
#
# Default workspace:
#     <bucket>/terraform.tfstate
#
# New workspace:
#     <bucket>/env:/test_workspace/terraform.tfstate
#
# Backend must support workspaces (S3, GCS, Azure Storage, Terraform Cloud).

# Workspace names are mapped to directories under:
#     env:/<workspace>/
# This ensures COMPLETE isolation between environments.
# The state of “default” workspace is NEVER mixed with “test_workspace”.
```

* NEW WORKSPACE STATE FILE CONTENTS
```bash
# Before applying anything, workspace-specific state is empty:
# {
#   "version": 4,
#   "terraform_version": "1.2.3",
#   "serial": 0,
#   "lineage": "c1aa5782-da15-419e-70f8-7024cadd0cfe",
#   "outputs": {},
#   "resources": []
# }
#
# This confirms:
#   • No resources known to this workspace
#   • Terraform treats this as a brand-new environment
```

* WHAT HAPPENS WHEN YOU RUN `terraform plan` IN A NEW WORKSPACE?
```bash
# Terraform uses ONLY the state of the currently selected workspace.
#
# Since the new workspace has NO resources in its tfstate:
#     → Terraform assumes nothing exists
#     → It shows Plan: 1 to add (for example, a new EC2 instance)
#
# Even if the DEFAULT workspace already created the same EC2,
# the new workspace does NOT know about it and will create another.
```

* WORKSPACE ISOLATION IS WHY THIS HAPPENS
```bash
# -------------------------------------------
# Workspaces do NOT share:
#   • resources
#   • state files
#   • outputs
#   • resource lineage
#
# Each workspace = a separate environment.
#
# This is why workspaces are ideal for:
#   • dev / test / staging environments
#   • playing with new changes safely
#   • avoiding accidental modification of production resources
```

* IMPORTANT WARNING ABOUT APPLY
```bash
# Terraform DOES NOT show the workspace name inside the plan output.
# Example: `terraform plan` will NOT say “using workspace test_workspace”.
#
# This means:
#   • If you forget which workspace you are in → very dangerous
#   • You may apply changes to the wrong environment
#
# ALWAYS run:
#     terraform workspace show
# before apply.
```

---

#### HOW TO DELETE A TERRAFORM WORKSPACE — WITH THEORY AS COMMENTS
* YOU CANNOT DELETE THE CURRENTLY SELECTED WORKSPACE
    ```bash
    # Terraform will NOT allow deleting the workspace you are currently in.
    # Therefore, first switch to another workspace (usually "default"):
    terraform workspace select default
    # → Switches to default workspace successfully
    ```

* DELETE THE TARGET WORKSPACE
    ```bash
    # Once inside a different workspace, delete the unwanted one:
    terraform workspace delete test_workspace
    # → Terraform deletes the workspace metadata
    # → Also deletes the corresponding state folder in the remote backend (e.g., S3)
    # In S3 Backends:
    #     env:/test_workspace/terraform.tfstate  → removed
    #     env:/test_workspace/                   → removed
    ```

* WORKSPACE CANNOT BE DELETED IF IT STILL TRACKS RESOURCES
    ```bash
    # If the workspace has existing resources in its tfstate, deletion fails:
    terraform workspace delete test_workspace
    # ERROR:
    # Workspace is not empty
    # It is still tracking:
    #   - aws_instance.my_vm
    #
    # Terraform stops deletion to prevent:
    #   • orphaned infrastructure
    #   • losing track of managed resources
    #   • state corruption
    ```

* USING -force (NOT RECOMMENDED)
    ```bash
    # Terraform allows forced deletion:
    terraform workspace delete -force test_workspace
    # BUT THIS IS DANGEROUS:
    #   • Terraform forgets all resources in that workspace
    #   • The real cloud resources (EC2, S3, RDS, etc.) STILL EXIST
    #   • You must delete them manually later
    #   • High risk of orphaned & unmanaged infrastructure
    ```

* SAFEST WAY TO DELETE A WORKSPACE WITH RESOURCES
    ```bash
    # ✔ Step 1: Switch into the workspace:
    terraform workspace select test_workspace

    # ✔ Step 2: Destroy all resources tracked by that workspace:
    terraform destroy

    # ✔ Step 3: Switch back to default:
    terraform workspace select default

    # ✔ Step 4: Delete the workspace safely:
    terraform workspace delete test_workspace

    # → This ensures the state file is empty → safe to delete.
    ```

* THE DEFAULT WORKSPACE CANNOT BE DELETED
    ```bash
    # Terraform protects the default workspace because:
    #   • It is the root workspace
    #   • Required for Terraform operations
    #   • Used when workspaces are not explicitly used
    ```

* REMOTE BACKEND EFFECT
    ```bash
    # Deleting a workspace automatically deletes its corresponding state file path.
    # Example in S3 backend:
    #   env:/test_workspace/terraform.tfstate
    # → Removed automatically.
    ```


---

### HOW TO MANAGE VARIABLES WITH TERRAFORM WORKSPACES — THEORY IN COMMENTS

    ```hcl
    # 1️⃣ WHY VARIABLES NEED SPECIAL HANDLING WITH WORKSPACES
    # -------------------------------------------------------
    # Each workspace (dev, test, stage, prod) represents an independent environment.
    # Usually each environment:
    #   • uses different instance sizes
    #   • has different scaling limits
    #   • has different tags
    #   • uses different VPCs, subnets, AMIs
    
    # Therefore, variable values must change based on the active workspace.

    # 2️⃣ APPROACH 1: USE SEPARATE TFVARS FILES FOR EACH WORKSPACE (BEST PRACTICE)
    # ----------------------------------------------------------------------------
    # Declare variables normally:
       variable "instance_type" {}
       variable "env_name"      {}

    # Create one tfvars file per environment:
       vars_dev.tfvars
       vars_test.tfvars
       vars_stage.tfvars
       vars_prod.tfvars
    
    # Example vars_dev.tfvars:
       instance_type = "t2.micro"
       env_name      = "dev"

    # Apply using the correct var-file based on workspace:
       terraform workspace select dev
       terraform apply -var-file=vars_dev.tfvars

    # This ensures:
    #   • correct variables per environment
    #   • easy separation of configs
    #   • no mixing of values between workspaces

    # 3️⃣ APPROACH 2: CONDITIONAL VARIABLE VALUES BASED ON WORKSPACE
    # --------------------------------------------------------------
    # Terraform exposes the current workspace via: terraform.workspace
    # You can use it to conditionally set local variables:

       locals {
         instance_type = terraform.workspace == "prod" ? "t2.large" : "t2.micro"
       }

    # Meaning:
    #   • If workspace = prod → instance_type = t2.large
    #   • Else → instance_type = t2.micro (dev, test, stage, etc.)

    # This avoids needing separate tfvars files for simple differences.

    # 4️⃣ APPROACH 3: EXTERNAL SCRIPTING (NOT RECOMMENDED)
    # ----------------------------------------------------
    # You *can* use bash, PowerShell, or Python to export environment variables:
    
    # Example (bash):
    #   if [[ $TF_WORKSPACE == "prod" ]]; then
    #       export TF_VAR_instance_type="t2.large"
    #   else
    #       export TF_VAR_instance_type="t2.micro"
    #   fi
    
    # BUT THIS IS NOT IDEAL:
    #   • adds complexity
    #   • harder to maintain
    #   • error-prone
    
    # Terraform-built methods (tfvars + locals) are cleaner.

    # 5️⃣ BEST PRACTICE: USE DEFAULT VALUES IN VARIABLE DEFINITIONS
    # --------------------------------------------------------------
    # Example:
       variable "instance_type" {
         type    = string
         default = "t2.micro"
       }

    # Default values:
    #   • prevent errors when a tfvars value is missing
    #   • reduce repetition across tfvars files
    #   • make configuration more stable and predictable
    ```

---

### TERRAFORM WORKSPACES INTERPOLATION — THEORY IN COMMENTS

    ```hcl
    # 1️⃣ WHY USE WORKSPACE INTERPOLATION?
    # ------------------------------------
    # When multiple workspaces (default, test, prod, etc.) use the SAME Terraform
    # configuration, Terraform will create multiple copies of the same resources.

    # Without unique tags/names, you cannot easily identify:
    #   • which EC2 belongs to dev
    #   • which EC2 belongs to test
    #   • which EC2 belongs to prod

    # Terraform solves this using workspace interpolation:
            ${terraform.workspace}

    # This returns the *current* workspace name and allows you to customize:
    #       • resource names
    #       • tags
    #       • bucket names
    #       • IAM policies
    #       • etc.

    # 2️⃣ BASIC INTERPOLATION SYNTAX
    # ------------------------------
    # Newer Terraform versions allow direct usage:
        terraform.workspace

    # This returns:
    #   • "default"
    #   • "test"
    #   • "prod"
    #   • etc.

    # 3️⃣ USING INTERPOLATION IN TAGS (COMMON USE CASE)
    # -------------------------------------------------
    # Variables:
    variable "name_tag" {
        type        = string
        description = "Name of the EC2 instance base label"
        default     = "EC2"
    }

    # Resource configuration:
    resource "aws_instance" "my_vm" {
        ami           = var.ami
        instance_type = var.instance_type

        tags = {
            # format("%s_%s", var.name_tag, terraform.workspace)
            # Example: EC2_default, EC2_test, EC2_prod
            Name = format("%s_%s", var.name_tag, terraform.workspace)
        }
    }

    # Why format()?
    #   • It concatenates strings cleanly
    #   • Avoids awkward quoting
    #   • Ensures valid tag formatting

    # 4️⃣ RUNNING APPLY IN DIFFERENT WORKSPACES
    # -----------------------------------------
    # Workspace: default
        terraform workspace select default
        terraform apply
    # → Creates EC2 named: EC2_default

    # Workspace: test
        terraform workspace new test
        terraform apply
    # → Creates EC2 named: EC2_test

    # Each workspace:
    #   • Has its own isolated state
    #   • Sees no resources created in other workspaces
    #   • Applies interpolation to produce unique resource names

    # 5️⃣ WHY DOES THIS WORK PERFECTLY WITH WORKSPACES?
    # -------------------------------------------------
    # Each workspace has its OWN tfstate file:
        default → terraform.tfstate
        test    → env:/test/terraform.tfstate

    # Even though the configuration is identical:
    #   • Terraform sees zero resources in "test"
    #   • Proposes to create a brand new EC2 instance

    # The workspace name is embedded into resource names via interpolation.

    # 6️⃣ VALIDATION IN AWS CONSOLE
    # -----------------------------
    # After applying in both workspaces → AWS EC2 dashboard shows:
    #   • EC2_default  (instance from default workspace)
    #   • EC2_test     (instance from test workspace)

    # This allows instant visual identification and eliminates confusion.

    # 7️⃣ BENEFITS OF USING terraform.workspace IN TAGS
    # -------------------------------------------------
    # ✔ Prevents naming conflicts between environments
    # ✔ Makes visual identification easier in the AWS console
    # ✔ Helps debugging — logs, metrics, alarms show workspace-specific names
    # ✔ Useful for cost segregation per environment
    # ✔ Supports multi-environment deployment using one configuration
    ```

---

### ENVIRONMENT-SPECIFIC RESOURCE REQUIREMENTS USING TERRAFORM WORKSPACES
    ```bash
    # 1️⃣ WHAT THIS TECHNIQUE SOLVES
    # ------------------------------
    # Every environment (dev, test, stage, prod) needs DIFFERENT amounts of resources.

    # Example:
    #   • prod  → 3 EC2 instances (for load + HA)
    #   • dev   → 1 EC2 instance
    #   • test  → 1 EC2 instance

    # Using Terraform workspaces + interpolation allows:
    #   • SAME Terraform code
    #   • DIFFERENT number of resources per workspace
    #   • Lower cost in non-production
    #   • No duplication of .tf files

    # 2️⃣ USING WORKSPACE VALUE INSIDE COUNT ARGUMENT
    # -----------------------------------------------
    # terraform.workspace returns:
    #   • "default"
    #   • "test"
    #   • "prod"

    # Using it in a conditional expression:
    #     terraform.workspace == "default" ? 3 : 1

    # Meaning:
    #   • If workspace = "default" → create 3 instances
    #   • Else (test, stage, dev) → create only 1

    variable "name_tag" {
    type        = string
    description = "Name of the EC2 instance"
    default     = "EC2"
    }

    # 3️⃣ RESOURCE CONFIGURATION THAT CHANGES PER ENVIRONMENT
    # -------------------------------------------------------
    resource "aws_instance" "my_vm" {

    # Count is determined by workspace name
    count         = terraform.workspace == "default" ? 3 : 1
    ami           = var.ami
    instance_type = var.instance_type

    # Tags include workspace + index so each instance gets a unique identity
    tags = {
        Name = format("%s_%s_%s", var.name_tag, terraform.workspace, count.index)
        # Examples produced:
        #   EC2_default_0
        #   EC2_default_1
        #   EC2_default_2
        #   EC2_test_0
    }
    }

    # 4️⃣ WHY INCLUDE count.index IN THE TAG?
    # --------------------------------------
    # count.index = 0, 1, 2, ...
    # Without count.index:
    #   Terraform would try to give all 3 EC2 instances the SAME Name tag.
    # The format() ensures uniqueness:
    #   EC2_default_0, EC2_default_1, EC2_default_2, etc.

    # 5️⃣ RESULT AFTER APPLYING IN MULTIPLE WORKSPACES
    # ------------------------------------------------
    # Workspace: default
    # → 3 instances created:
    #     EC2_default_0
    #     EC2_default_1
    #     EC2_default_2

    # Workspace: test
    # → 1 instance created:
    #     EC2_test_0

    # Both sets of resources are managed independently because workspaces maintain
    # separate TF state files.

    # 6️⃣ WHY THIS IS EXTREMELY USEFUL
    # --------------------------------
    # ✔ Prevents unnecessary cloud cost in test/dev environments  
    # ✔ Cleanly separates environments without separate Terraform folders  
    # ✔ Uses SAME configuration for ALL environments (DRY principle)  
    # ✔ Workspaces + interpolation = dynamic infra scaling per environment  
    ```

### GIT BRANCHES VS TERRAFORM WORKSPACES — DO NOT CONFUSE THEM
    ```bash
    # 7️⃣ KEY DIFFERENCE
    # ------------------
    # Git Branches:
    #   • Hold code versions  
    #   • Used for development, new features, experiments  
    #   • Do NOT isolate infrastructure  

    # Terraform Workspaces:
    #   • Hold STATE FILES  
    #   • Isolate resources of each environment  
    #   • Allow same code to deploy multiple isolated environments  

    # 8️⃣ WHY YOU MUST NOT MIX THEM WRONG
    # -----------------------------------
    # Deploying from a *feature branch* into the *default workspace* is dangerous:
    #   • feature branch may contain half-built code
    #   → That may destroy or break production.

    # Recommended Matrix:
    # -------------------
    # Git Main Branch + Default Workspace  
    #   → Correct, stable production deployment

    # Git Main Branch + Test Workspace  
    #   → Scaled-down safe replica for debugging/testing

    # Git Feature Branch + Default Workspace  
    #   → STRICTLY NO. Highly risky for production.

    # Git Feature Branch + Test Workspace  
    #   → Possible, but may interfere with teammates' dev work  
    #   → Better to create a new workspace (workspace-per-feature)

    # 9️⃣ IMPORTANT NOTE
    # ------------------
    # When you use Terraform workspaces:
    #   → WORKSPACE SELECTION takes precedence over Git branch
    #   → Because workspace determines which STATE FILE Terraform uses

    # Meaning:
    #   The same Git code can produce completely different infrastructure
    #   depending on the selected workspace.
    ```

### TERRAFORM WORKSPACES — BEST PRACTICES

* WORKSPACES ARE NOT A FULL ENVIRONMENT-MANAGEMENT SYSTEM
    ```hcl
    # Many teams incorrectly use workspaces as:
    #   • dev
    #   • test
    #   • stage
    #   • prod
    #
    # THIS IS NOT RECOMMENDED.
    # Why?
    #   • Workspaces only separate *state files*, not infrastructure repos.
    #   • Organizations typically need STRICT, PHYSICAL separation of environments.
    #   • Workspaces are meant for *temporary testing*, not long-term multi-env setup.
    # Best practice:
    #   ✔ Use workspaces for previewing/testing infra changes before prod deployment
    #   ✔ Do NOT use them as permanent environment boundaries
    ```

* WORKSPACES + GIT BRANCHES = HIGH HUMAN-ERROR RISK
    ```hcl
    # Workspaces isolate *state*, while Git branches isolate *code*.
    # If developers forget:
    #   • which workspace they are in
    #   • which branch they are deploying from
    # It can cause:
    #   ❌ accidental production updates
    #   ❌ wrong environment deployments
    #   ❌ mismatched resource creation
    # Best practice:
    #   ✔ Always run `terraform workspace show` before apply
    #   ✔ Protect prod workspace with CI/CD approval gates
    #   ✔ Avoid manual applies when possible
    ```

* EACH WORKSPACE HAS ITS OWN CACHED MODULES/PLUGINS
    ```hcl
    # Terraform maintains:
    #   • .terraform directory
    #   • downloaded providers
    #   • downloaded modules
    # For EACH workspace, these caches are stored separately.
    # This causes:
    #   • more storage usage on backend
    #   • unnecessary network bandwidth consumption
    #   • clutter when many team members create lots of temporary workspaces
    # Best practice:
    #   ✔ Keep workspace count low
    #   ✔ Clean up unused workspaces regularly
    #   ✔ Restrict workspace creation permissions in CI/CD
    ```

* WORKSPACES SHOULD BE TEMPORARY
    ```hcl
    # Workspaces shine in scenarios like:
    #   • testing a scaled-down replica before production
    #   • dry-run validations
    #   • debugging changes safely
    # But they should NOT be used for:
    #   ❌ long-term dev / test / stage / prod environments
    #   ❌ managing strict compliance environments
    #   ❌ multi-team multi-environment structures
    # Reason:
    #   • workspaces all share the SAME codebase
    #   • risk of accidental cross-environment deployment
    #   • difficult to scale in enterprise infra
    # Best practice:
    #   ✔ Use separate folders/repos for real environments (e.g., env/dev, env/prod)
    #   ✔ Use workspaces ONLY for temporary sandbox validation
    ```

* BETTER ALTERNATIVES FOR MULTI-ENVIRONMENTS
    ```hcl
    # For stable environments, use:
    #   • separate Terraform root modules (env/dev, env/stage, env/prod)
    #   • separate Git repos or branches per environment
    #   • separate state backends per environment
    #   • separate CI/CD pipelines per environment
    # Workspaces should augment—not replace—environment structure.
    ```

* CLEANUP OF UNUSED WORKSPACES
    ```hcl
    # Each workspace:
    #   • consumes remote backend storage (state files)
    #   • caches plugins/modules again
    #   • causes duplication of data
    # Best practice:
    #   ✔ Destroy infra inside temp workspaces
    #   ✔ Then delete workspace:
    #        terraform workspace delete <name>
    # This prevents remote backend clutter.
    ```

* BE CAREFUL WITH `-force` DURING WORKSPACE DELETION
    ```hcl
    # terraform workspace delete -force
    # will remove the workspace *without destroying its resources*.
    # This creates:
    #   • orphaned AWS resources
    #   • unmanaged infrastructure
    # Best practice:
    #   ✔ Never use -force unless you WANT to intentionally abandon resources
    #   ✔ Destroy resources first using: terraform destroy
    ```

* WORKSPACES TAKE PRECEDENCE OVER GIT BRANCHES
    ```hcl
    # If both change state/code independently:
    #   • workspace determines which state is used
    #   • branch determines which logic is applied
    # Mismatch can create:
    #   ❌ state drift
    #   ❌ infra misalignment
    #   ❌ broken environments
    # Best practice:
    #   ✔ Define team standards: which branches + which workspaces are allowed
    #   ✔ Avoid using feature branches in default workspace
    #   ✔ Use CI pipelines to enforce correct workspace selection
    ```

* TERRAFORM LICENSING NOTE
    ```hcl
    # Terraform 1.5.x and below = open-source.
    # Terraform 1.6+ = BUSL license (not OSS).
    # OpenTofu = fully open-source fork of Terraform 1.5.6
    # Supported by Linux Foundation.
    # Best practice:
    #   ✔ Use OpenTofu if you want:
    #       – fully open-source infra-as-code
    #       – community governance
    #       – Terraform-compatible syntax
    ```

