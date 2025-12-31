* `import` block**
  * Used to bring an **existing resource** under Terraform management
  * Written **inside `.tf` files**
  * Imports resource **into state only** not there config.
  * Applied using `terraform apply`
  * Requires the **resource block to already exist**
  * Available from **Terraform v1.5+**
  * Use to import multiple resource at once.

* **Short difference: `import` block vs `terraform import` command**
  * `import` block → **Declarative**, code-based, version-controlled
  * `terraform import` → **Imperative**, CLI-based, one-time action
  * `import` block → Runs during `terraform apply`
  * `terraform import` → Runs as a separate command
  * `import` block → Easy to reuse, review, and share
  * `terraform import` → Manual, not tracked in code
  * Both → **Only update state**, do not change real infrastructure.
  * `import command` import one resource at a time while `import block` can import multiple resources at a time.

```bash
terraform import <resource_type>.<resource_name> <resource_id>
terraform apply
terraform plan
terraform state list
terraform state show <resource_type>.<resource_name>
terraform plan -generate-config-out="generated.tf" #Experimental ---> Give error ---> Remove config
terraform plan
terraform validate
```
