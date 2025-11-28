```bash
terraform version

Terraform v1.12.2
on windows_amd64

Your version of Terraform is out of date! The latest version
is 1.13.4. You can update by downloading from https://developer.hashicorp.com/terraform/install

terraform --version
terraform -v
```
```bash
terraform -h
terraform -help
terraform --help
```
```bash
terraform init #Run in the project directory, download provider plugins

terraform plan

terraform apply #Give plan,review plan, approve(yes)

terraform destroy #Remove resource created by terraform, all reources in cofiguration

terraform validate

terraform providers	#Lists all providers used in the configuration.
terraform providers mirror <dir>	#Downloads providers locally for offline installation.
terraform init -upgrade	#Updates all provider plugins to the latest allowed versions.
terraform state list	#Lists all managed resources by provider.
```

# 🟩 **1. TERRAFORM TOP-LEVEL COMMANDS (CORE)**

```
terraform init
terraform plan
terraform apply
terraform destroy
terraform fmt
terraform validate
terraform graph
terraform output
terraform providers
terraform show
terraform version
terraform get
terraform refresh (deprecated)
```

---

### Provider Version
```bash
$ ls .terraform/providers/registry.terraform.io/hashicorp/
aws/  azurerm/

$ ls .terraform/providers/registry.terraform.io/hashicorp/aws/
5.100.0/

$ terraform providers
Providers required by configuration:
├── provider[registry.terraform.io/hashicorp/azurerm] 4.54.0
└── provider[registry.terraform.io/hashicorp/aws] ~> 5.0

terraform providers | grep aws
```


# 🟦 **2. TERRAFORM PROJECT COMMANDS**

### ✔ `terraform init` 
* https://spacelift.io/blog/terraform-init
* Clone a code from the VCS/SCM.
* First command we run.
* Initializes working directory for terraform.
* Perform:
    * Backend Initializations.
    * Child Module Installation.
    * Plugins Installation.

```bash
Options:
  -backend=false          Disable backend or HCP Terraform initialization
                          for this configuration and use what was previously
                          initialized instead.

                          aliases: -cloud=false

  -backend-config=path    Configuration to be merged with what is in the
                          configuration file's 'backend' block. This can be
                          either a path to an HCL file with key/value
                          assignments (same format as terraform.tfvars) or a
                          'key=value' format, and can be specified multiple
                          times. The backend type must be in the configuration
                          itself.

  -force-copy             Suppress prompts about copying state data when
                          initializating a new state backend. This is
                          equivalent to providing a "yes" to all confirmation
                          prompts.

  -from-module=SOURCE     Copy the contents of the given module into the target
                          directory before initialization.

  -get=false              Disable downloading modules for this configuration.

  -input=false            Disable interactive prompts. Note that some actions may
                          require interactive prompts and will error if input is
                          disabled.

  -lock=false             Don't hold a state lock during backend migration.
                          This is dangerous if others might concurrently run
                          commands against the same workspace.

  -lock-timeout=0s        Duration to retry a state lock.

  -no-color               If specified, output won't contain any color.

  -json                   If specified, machine readable output will be
                          printed in JSON format.

  -plugin-dir             Directory containing plugin binaries. This overrides all
                          default search paths for plugins, and prevents the
                          automatic installation of plugins. This flag can be used
                          multiple times.

  -reconfigure            Reconfigure a backend, ignoring any saved
                          configuration.

  -migrate-state          Reconfigure a backend, and attempt to migrate any
                          existing state.

  -upgrade                Install the latest module and provider versions
                          allowed within configured constraints, overriding the
                          default behavior of selecting exactly the version
                          recorded in the dependency lockfile.

  -lockfile=MODE          Set a dependency lockfile mode.
                          Currently only "readonly" is valid.

  -ignore-remote-version  A rare option used for HCP Terraform and the remote backend
                          only. Set this to ignore checking that the local and remote
                          Terraform versions use compatible state representations, making     
                          an operation proceed even when there is a potential mismatch.       
                          See the documentation on configuring Terraform with
                          HCP Terraform or Terraform Enterprise for more information.

  -test-directory=path    Set the Terraform test directory, defaults to "tests".
```

```bash
terraform init #Initialize the working directory, install required provider plugins and modules, and set up the backend.

$ terraform.exe init
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider  
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when   
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see  
any changes that are required for your infrastructure. All Terraform commands  
should now work.

If you ever set or change modules or backend configuration for Terraform,      
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

terraform init -upgrade #Ensure you’re using the latest compatible versions of your providers
#Check the Terraform Registry for newer versions of all providers and modules.
#Upgrade to the latest version allowed by your version constraints in required_providers.
#Update .terraform.lock.hcl to reflect the new versions.
#It never ignores your version constraints.
#version = "~> 5.0" --> Minimum: 5.0.0, Maximum: < 6.0.0, Terraform will upgrade AWS to the latest 5.x version, not 6.x.
#version = "5.0" --> This is a fixed, strict version pin, No upgrades allowed.

#It is always safe to run terraform init. It will never modify the configuration or destroy any resources. If it is run multiple times, it will simply update the working directory with the changes in the configuration. This will be required if the configuration changes include the addition of a new provider block or a change to the backend storage location, for example.

terraform init -reconfigure #Use the -reconfigure flag to force Terraform to forget any previous configuration and reinitialize.

terraform init -get=false #Disable downloading modules for this configuration

terraform init -plugin-dir=/path/to/custom/plugins #Point Terraform to custom or manually downloaded provider plugins

terraform init -input  #Provide values for required input variables during initialization

terraform init -backend-config=<path>

terraform init -lock=false #Initialize the Terraform working directory without acquiring a state lock during backend migration.
#Normally, Terraform locks the state so that no other user or automation can modify it while initialization or backend migration happens.
#Example locks:
    #S3 DynamoDB lock
    #Consul lock
    #Local .terraform.tfstate.lock.info
#Terraform will:
    #NOT try to acquire a lock on the remote backend state
    #NOT wait if another lock already exists
    #NOT prevent others from writing the state at the same time
```
* `terraform init -input=false`
  * By default, Terraform may ask for user input during terraform init.
  * Typical prompts:
    * Asking whether to migrate state to a new backend.
    * Asking for missing variables.
    * Asking to confirm backend configuration.
    * Asking for credentials if not set in environment variables.
  * Used:
    * CI/CD & Automation (Jenkins, GitLab, GitHub Actions).
    * Backend migrations that must run automatically.
  * A CI/CD pipeline (GitHub Actions, GitLab CI, Jenkins, Azure DevOps) cannot answer these, so it will:   
    * Hang
    * Eventually time out
  * Show non-deterministic failures With `-input=false`, instead of hanging, Terraform will fail fast.


```bash
terraform init -migrate-state #Initialize Terraform and migrate your existing LOCAL state into the new REMOTE backend
#This is the command used only when you added a new backend block (like S3 + DynamoDB) and want Terraform to move your local state file (terraform.tfstate) into that backend.
#Steps
    # Check the backend block you added
    # Connect to the new backend (S3, GCS, Azure, Consul, etc.)
    # Detect that you previously used a local state
    # Copy the entire local terraform.tfstate to the remote backend
    # Update metadata + lock information
    # Remove or rename local state
    # Switch Terraform to remote backend completely

terraform init -migrate-state -lock=false #Prevent lock acquisition (rare cases)

terraform init -reconfigure -migrate-state #Reconfigure backend and migrate state

terraform init -migrate-state -input=false  #Initialize the Terraform working directory and disable all interactive prompts
#Terraform WILL NOT ask: `Do you want to copy state to the new backend?`
```

Here is a **clean, polished, professional version** of your entire explanation of **Terraform init options** — rewritten for clarity, correctness, and easy reading.

You can use this directly in documentation, notes, or training material.

---

# ✔ **Terraform `init` Options (Clean & Complete Guide)**

Terraform provides many options for the `terraform init` command. These help control provider installation, state backend behavior, prompts, locking, upgrades, and automation workflows.

Below are the **most useful and commonly used options**, cleanly explained.

---

## **1. `terraform init -backend=false`**

Disables backend or Terraform Cloud (HCP Terraform) initialization.

* Terraform **does not initialize the backend block** in the configuration.
* Useful when you only want to test or validate code without touching remote state.
* Alias: `-cloud=false`
* Does **not** create a local backend automatically.

---

## **2. `terraform init -backend-config=PATH`**

Merges backend configuration from a separate file or key/value pairs.

* Useful for separating **sensitive backend values** from main Terraform code.
* Allows dynamic injection of backend settings.

### Example:

```bash
terraform init -backend-config=backend.hcl
```

---

## **3. `terraform init -force-copy`**

Suppresses prompts when switching backends.

* Automatically copies state from the old backend to the new backend.
* Used when you want backend migration **without interactive confirmation**.
* Risky if misconfigured → could cause accidental state overwrites.

Best for automation workflows.

---

## **4. `terraform init -from-module=SOURCE`**

Initializes the working directory with the contents of a given module.

### Examples:

```bash
terraform init -from-module=github.com/user/module
terraform init -from-module=./existing-module
```

Useful when bootstrapping a new working directory from a module.

---

## **5. `terraform init -get=false`**

Prevents downloading child modules.

* Initializes providers only.
* Useful when:

  * You want manual control over when modules update.
  * Your working directory was previously initialized and modules already exist.

---

## **6. `terraform init -input=false`**

Disables interactive prompts.

* MUST be used in CI/CD pipelines.
* If Terraform requires input (missing variable, backend confirm), it **fails fast** instead of hanging.

Prevents stuck pipelines.

---

## **7. `terraform init -lock=false`**

Disables state lock during initialization.

* Useful when the state file is stuck in a locked state.
* **Not recommended** during normal operation—risk of concurrent state writes.

Better fix:

* Break Azure blob lease
* Delete DynamoDB lock
* Run `terraform force-unlock <ID>`

---

## **8. `terraform init -lock-timeout=<duration>`**

Defines how long Terraform should wait to acquire a state lock.

### Example:

```bash
terraform init -lock-timeout=120s
```

Useful in environments where multiple pipelines hit the same state file.

---

## **9. `terraform init -no-color`**

Removes ANSI color codes from output.

* Required for CI platforms like Azure DevOps which break when color codes appear.
* Output becomes plain-text only.

---

## **10. `terraform init -plugin-dir=PATH`**

Use a custom directory for provider plugins.

* Useful in offline or air-gapped environments.
* Terraform loads providers from this directory instead of downloading them.

```bash
terraform init -plugin-dir=/opt/tf-providers
```

---

## **11. `terraform init -upgrade`**

Forces Terraform to upgrade providers and modules.

* Useful when provider version constraints have changed.
* Terraform searches for newer compatible versions.
* Without `-upgrade`, Terraform uses the version already installed.

Example:

* If `azuread = 2.17.0` was installed earlier
* And you remove version constraints
* Terraform will keep using 2.17.0 unless you run `-upgrade`

---

## **12. `terraform init -migrate-state`**

Migrates existing state to a new backend.

* Used when switching from **local → S3**, **local → Azure Blob**, etc.
* Prompts for confirmation unless combined with `-force-copy`.

### Example:

```bash
terraform init -migrate-state
```

---

## **13. `terraform init -reconfigure`**

Reconfigures the backend and ignores stored backend settings.

Use when:

* Backend configuration has changed
* You want to force Terraform to read backend settings from `.tf` files again
* You need to switch between multiple backends

---

## **14. `terraform init -ignore-remote-version`**

Ignores version mismatch between local Terraform and remote (HCP Terraform/Terraform Cloud).

* Rarely used.
* Allows operations even when versions differ.
* Only use when you fully understand the implications.


---

### ✔ `terraform validate`

Syntax validation.
```bash
terraform.exe validate --help
Usage: terraform [global options] validate [options]

  Validate the configuration files in a directory, referring only to the
  configuration and not accessing any remote services such as remote state,
  provider APIs, etc.

  Validate runs checks that verify whether a configuration is syntactically
  valid and internally consistent, regardless of any provided variables or
  existing state. It is thus primarily useful for general verification of
  reusable modules, including correctness of attribute names and value types.

  It is safe to run this command automatically, for example as a post-save
  check in a text editor or as a test step for a re-usable module in a CI
  system.

  Validation requires an initialized working directory with any referenced
  plugins and modules installed. To initialize a working directory for
  validation without accessing any configured remote backend, use:
      terraform init -backend=false

  To verify configuration in the context of a particular run (a particular
  target workspace, input variable values, etc), use the 'terraform plan'
  command instead, which includes an implied validation check.

Options:

  -json                 Produce output in a machine-readable JSON format,
                        suitable for use in text editor integrations and other
                        automated systems. Always disables color.

  -no-color             If specified, output won't contain any color.

  -no-tests             If specified, Terraform will not validate test files.

  -test-directory=path  Set the Terraform test directory, defaults to "tests".
```

```bash
terraform validate
terraform validate -json
terraform validate -no-color
terraform validate -no-tests
terraform validate -test-directory=path
```

---

### ✔ `terraform fmt`

Format *.tf files.

```
terraform fmt
terraform fmt -recursive
terraform fmt -diff
terraform fmt -check
```

---

### ✔ `terraform plan`

Preview infrastructure changes.
Create a Execution Plan.

```
terraform plan
terraform plan -out=plan.out
terraform plan -var="x=1"
terraform plan -var-file="vars.tfvars"
terraform plan -target=aws_instance.ec2
terraform plan -refresh=false
terraform plan -destroy
terraform plan -parallelism=50
```

---

### ✔ `terraform apply`

Applies infrastructure.

```bash
terraform apply
terraform apply plan.out

-auto-approve          Skip interactive approval of plan before applying.

  -backup=path           Path to backup the existing state file before
                         modifying. Defaults to the "-state-out" path with
                         ".backup" extension. Set to "-" to disable backup.

  -compact-warnings      If Terraform produces any warnings that are not
                         accompanied by errors, show them in a more compact
                         form that includes only the summary messages.

  -destroy               Destroy Terraform-managed infrastructure.
                         The command "terraform destroy" is a convenience alias
                         for this option.

  -lock=false            Don't hold a state lock during the operation. This is
                         dangerous if others might concurrently run commands
                         against the same workspace.

  -lock-timeout=0s       Duration to retry a state lock.

  -input=true            Ask for input for variables if not directly set.

  -no-color              If specified, output won't contain any color.

  -parallelism=n         Limit the number of parallel resource operations.
                         Defaults to 10.

  -replace=resource      Terraform will plan to replace this resource instance
                         instead of doing an update or no-op action.

  -state=path            Path to read and save state (unless state-out
                         is specified). Defaults to "terraform.tfstate".

  -state-out=path        Path to write state to that is different than
                         "-state". This can be used to preserve the old
                         state.

  -var 'foo=bar'         Set a value for one of the input variables in the root
                         module of the configuration. Use this option more than
                         once to set more than one variable.

  -var-file=filename     Load variable values from the given file, in addition
                         to the default files terraform.tfvars and *.auto.tfvars.
                         Use this option more than once to include more than one
                         variables file.
```

---

### ✔ `terraform destroy`

Destroys resources.

```
terraform destroy
terraform destroy -target=aws_s3_bucket.demo
terraform destroy -target=aws_instance.backend_instance
terraform destroy -auto-approve
terraform destroy -var-file="vars.tfvars"
```

---

### ✔ `terraform show`

Show human-readable or JSON state.

```
terraform show
terraform show -json
terraform show plan.out
```

---

### ✔ `terraform graph`

Outputs dependency graph.

```
terraform graph
terraform graph -draw-cycles
```

---

### ✔ `terraform output`

View output values.

```
terraform output
terraform output -json
terraform output public_ip
```

---

# 🟨 **3. PROVIDERS COMMANDS (FULL LIST)**

```bash
terraform providers #Shows all providers used with their versions.
$ terraform providers
Providers required by configuration:
.
├── provider[registry.terraform.io/hashicorp/azurerm] 4.54.0
└── provider[registry.terraform.io/hashicorp/aws] ~> 5.0

terraform providers mirror <directory>
terraform providers schema
terraform providers schema -json
```

---

# **4. TERRAFORM STATE COMMANDS (FULL SET)**

```bash
#==========================================================================================
# 1. terraform state list
# ------------------------------------------------------------------------------------------
# PURPOSE:
#   - Lists ALL resources Terraform is currently tracking in the state file.
#   - Shows the “inventory” Terraform knows about.
#   - Very useful for debugging drift & confirming infra mapping.
#
# WHEN TO USE:
#   - After `terraform apply`
#   - Before refactoring (moving resources into modules)
#   - When something exists in cloud but Terraform doesn't know / vice-versa
# ==========================================================================================
terraform state list

# Example Output:
#   aws_instance.web
#   aws_s3_bucket.logs
#   module.vpc.aws_subnet.public[0]


# ==========================================================================================
# 2. terraform state show <address>
# ------------------------------------------------------------------------------------------
# PURPOSE:
#   - Shows FULL saved attributes of a resource from the state file.
#   - Equivalent to reading the JSON inside terraform.tfstate.
#   - Extremely useful to inspect hidden attributes (IDs, ARNs, public IPs).
#
# WHEN TO USE:
#   - Debugging mismatched values
#   - Extracting resource IDs/ARNs
#   - Understanding provider-computed properties
# ==========================================================================================
terraform state show aws_instance.web


# ==========================================================================================
# 3. terraform state rm <address>
# ------------------------------------------------------------------------------------------
# PURPOSE:
#   - Removes a resource ONLY from Terraform state.
#   - DOES NOT delete the real infrastructure.
#
# WHEN TO USE:
#   - Resource was created manually outside Terraform
#   - Removing imported resources
#   - Fixing "already exists" or duplicate resource issues
#   - Resolving inconsistent / corrupted state entries
#
# WARNING:
#   - After removal, Terraform may try to recreate the resource on next apply.
# ==========================================================================================
terraform state rm aws_s3_bucket.demo


# ==========================================================================================
# 4. terraform state mv <source> <destination>
# ------------------------------------------------------------------------------------------
# PURPOSE:
#   - Moves/renames a resource inside the state file.
#   - NO CHANGE happens in cloud. Only the TF state updates.
#   - Useful for refactoring or module restructuring.
#
# WHEN TO USE:
#   - Renaming resources
#   - Moving resource to a module:
#       aws_instance.web --> module.vpc.aws_instance.web
#   - Extracting resources OUT of a module
#   - Changing index notation (e.g., list to map)
#
# SAFE:
#   - Yes. No infra is recreated or destroyed.
# ==========================================================================================
terraform state mv aws_instance.web module.vpc.aws_instance.web
terraform state mv aws_security_group.old aws_security_group.new


# ==========================================================================================
# 5. terraform state replace-provider <old> <new>
# ------------------------------------------------------------------------------------------
# PURPOSE:
#   - Updates provider reference inside state.
#   - Needed during provider namespace changes.
#
# EXAMPLES OF USE:
#   - Migrating from:
#       registry.terraform.io/-/aws → registry.terraform.io/hashicorp/aws
#   - Fixing provider upgrade failures.
#
# WHEN YOU SEE ERRORS LIKE:
#   "provider registry.terraform.io/-/aws is deprecated"
# ==========================================================================================
terraform state replace-provider \
  registry.terraform.io/-/aws \
  registry.terraform.io/hashicorp/aws


# ==========================================================================================
# 6. terraform state pull
# ------------------------------------------------------------------------------------------
# PURPOSE:
#   - Downloads the CURRENT state file (JSON format).
#   - Works even with remote backends (S3, Consul, GCS).
#
# WHEN TO USE:
#   - Debugging remote backend issues
#   - Taking manual backups
#   - Inspecting raw state data
# ==========================================================================================
terraform state pull > backup.tfstate


# ==========================================================================================
# 7. terraform state push <file>
# ------------------------------------------------------------------------------------------
# PURPOSE:
#   - Uploads a state file to the backend.
#   - Overwrites remote state.
#
# DANGEROUS:
#   - Can overwrite good state with bad data.
#
# WHEN TO USE:
#   - Restoring a backup
#   - Replacing corrupted state
#   - Backend migrations (local → remote or remote → remote)
# ==========================================================================================
terraform state push backup.tfstate


# ==========================================================================================
# 8. Summary Table (Quick Reference)
# ------------------------------------------------------------------------------------------
# COMMAND                        PURPOSE                                 SAFETY
# ------------------------------------------------------------------------------------------
# terraform state list           Show all tracked resources              SAFE
# terraform state show           View attributes of resource             SAFE
# terraform state rm             Remove entry from state                 RISKY
# terraform state mv             Move/rename state entries               SAFE
# terraform state replace        Update provider namespace               SAFE
# terraform state pull           Download state JSON                     SAFE
# terraform state push           Upload/overwrite state                  VERY RISKY
# ------------------------------------------------------------------------------------------
############################################################################################
```

---

# 🟫 **5. TERRAFORM WORKSPACE COMMANDS**

```
terraform workspace list
terraform workspace show
terraform workspace new <name>
terraform workspace select <name>
terraform workspace delete <name>
```

Examples:

```
terraform workspace new dev
terraform workspace select prod
terraform workspace list
```

---

# 🟪 **6. TERRAFORM IMPORT COMMAND**

```
terraform import
terraform import -allow-missing-config
terraform import aws_instance.myec2 i-0ac56d9ce
```

---

# 🟦 **7. TERRAFORM DEBUG / UTILITY COMMANDS**

### ✔ `terraform version`

Shows Terraform version.

```
terraform version
terraform version -json
```

### ✔ `terraform login`

Login to Terraform Cloud.

```
terraform login
terraform login hostname
```

### ✔ `terraform logout`

Logout from Terraform Cloud.

```
terraform logout
terraform logout hostname
```

### ✔ `terraform force-unlock`

Manually remove state lock.

```
terraform force-unlock <LOCK-ID>
terraform force-unlock -force <LOCK-ID>
```

### ✔ `terraform upload`

(Not commonly used — uploads state to TFC.)

```
terraform upload path
```

---

# 🟧 **8. CLOUD COMMANDS (TERRAFORM CLOUD / ENTERPRISE)**

```
terraform login
terraform logout
terraform cloud init
terraform cloud prep
terraform cloud run
terraform cloud apply
terraform cloud plan
terraform cloud destroy
```

---

# 🟩 **9. TERRAFORM CONFIG COMMANDS (rare)**

These manage CLI config files.

```
terraform config list
terraform config set <key> <value>
terraform config get <key>
```

---

# 🟦 **10. TERRAFORM BUNDLE COMMANDS (for air-gapped environments)**

```
terraform providers mirror
terraform providers sync
```

---

# 🟥 **11. TERRAFORM PROVIDER COMMANDS (LOW LEVEL)**

```
terraform providers lock
terraform providers mirror
terraform providers schema
terraform providers schema -json
terraform providers schema -validate
```

---

# 🟪 **12. TERRAFORM INIT (ALL OPTIONS COMPLETE)**

```
terraform init
terraform init -backend=false
terraform init -backend-config="key=value"
terraform init -get=false
terraform init -force-copy
terraform init -from-module=<MODULE>
terraform init -input=false
terraform init -lock=true
terraform init -lock-timeout=20s
terraform init -no-color
terraform init -plugin-dir=PATH
terraform init -reconfigure
terraform init -upgrade
terraform init -verify-plugins=false
```

---

# 🚀 **13. TERRAFORM PLAN (ALL OPTIONS COMPLETE)**

```bash
terraform plan
terraform plan -destroy
terraform plan -out=plan.out #Save plane in a file
terraform plan -var="x=1"
terraform plan -var-file=file.tfvars
terraform plan -parallelism=20
terraform plan -refresh=false
terraform plan -replace="aws_instance.example"
terraform plan -compact-warnings
terraform plan -input=false
terraform plan -target=aws_vpc.main
terraform plan -lock=false
terraform plan -lock-timeout=20s
```

---

# 🚀 **14. TERRAFORM APPLY (ALL OPTIONS COMPLETE)**

```
terraform apply
terraform apply plan.out
terraform apply -auto-approve
terraform apply -var-file=prod.tfvars
terraform apply -parallelism=30
terraform apply -lock=false
terraform apply -refresh=false
terraform apply -input=false
terraform apply -replace="aws_s3_bucket.demo"
```

---

# 🚀 **15. TERRAFORM DESTROY (ALL OPTIONS COMPLETE)**

```
terraform destroy
terraform destroy -auto-approve
terraform destroy -target=aws_security_group.main
terraform destroy -var-file=prod.tfvars
terraform destroy -refresh=false
terraform destroy -parallelism=20
terraform destroy -lock=false
```

---

# 🚀 **16. TERRAFORM TEST**

```bash
$ terraform test --help
Usage: terraform [global options] test [options]

  Executes automated integration tests against the current Terraform
  configuration.

  Terraform will search for .tftest.hcl files within the current configuration
  and testing directories. Terraform will then execute the testing run blocks
  within any testing files in order, and verify conditional checks and
  assertions against the created infrastructure.

  This command creates real infrastructure and will attempt to clean up the
  testing infrastructure on completion. Monitor the output carefully to ensure
  this cleanup process is successful.

Options:

  -cloud-run=source     If specified, Terraform will execute this test run
                        remotely using HCP Terraform or Terraform Enterprise.
                        You must specify the source of a module registered in a private module registry as the argument to this flag. This allows Terraform to associate the cloud run with the correct HCP Terraform or Terraform Enterprise module and organization.

  -filter=testfile      If specified, Terraform will only execute the test files
                        specified by this flag. You can use this option multiple
                        times to execute more than one test file.

  -json                 If specified, machine readable output will be printed in
                        JSON format

  -junit-xml=path       Saves a test report in JUnit XML format to the specified
                        file. This is currently incompatible with remote test
                        execution using the the -cloud-run option. The file path
                        must be relative or absolute.

  -no-color             If specified, output won't contain any color.

  -parallelism=n        Limit the number of concurrent operations within the
                                                plan/apply operation of a test run. Defaults to 10.

  -test-directory=path  Set the Terraform test directory, defaults to "tests".

  -var 'foo=bar'        Set a value for one of the input variables in the root
                        module of the configuration. Use this option more than
                        once to set more than one variable.

  -var-file=filename    Load variable values from the given file, in addition
                        to the default files terraform.tfvars and *.auto.tfvars.
                        Use this option more than once to include more than one
                        variables file.

  -verbose              Print the plan or state for each test run block as it
                        executes.
```

---

# ✅ If you want, I can also provide:

### ✔ Full Terraform interview cheat sheet

### ✔ Full Terraform Associate Exam Guide

### ✔ Full Terraform AWS project

### ✔ Full Terraform Kubernetes project

### ✔ Full Terraform Azure/GCP project

### ✔ Terraform best practices

Just tell me which one you want!
