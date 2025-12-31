```
==================== PREVENTING TERRAFORM DRIFT ====================
        TFSTATE vs ACTUAL INFRASTRUCTURE (DETAILED + PRACTICAL)
==================================================================
```

### What is Drift?

* **Drift** happens when **real infrastructure changes outside Terraform**
* Terraform state (`tfstate`) no longer matches reality
* Causes:
  * Manual console changes
  * Auto-scaling actions
  * CI/CD pipelines
  * External tools (kubectl, aws cli, scripts)

Terraform always tries to enforce:

> **State file = single source of truth**

---

## 1️⃣ Never Change Infra Manually (Golden Rule)

**Best practice**
* All changes must go through Terraform
* Lock down cloud console access
* Use IAM least privilege

**Behind the scenes**
* Terraform detects diffs during `plan`
* Manual changes cause unexpected replacements

---

## 2️⃣ Use `terraform plan` Regularly (Drift Detection)
```
terraform plan
```
**What it does**
* Compares:
  * tfstate
  * Terraform config
  * Live infrastructure
* Shows drift clearly

**Production best practice**
* Run `terraform plan`:
  * Nightly
  * On PR
  * Before every deploy

---

## 3️⃣ Use `terraform refresh` (State Sync)
```
terraform refresh
```
or (recommended):
```
terraform apply -refresh-only
```

**What happens**
* Updates tfstate to match real infra
* Does NOT change infra

**Use case**

* Infra changed outside Terraform
* Want state to reflect reality

---

## 4️⃣ Use `lifecycle ignore_changes` (Controlled Drift)

```
lifecycle {
  ignore_changes = [desired_capacity]
}
```

**Why**

* Some attributes change automatically
* Terraform should not fight autoscaling

**Common fields to ignore**

* ASG desired_capacity
* Tags added by AWS
* Kubernetes-managed fields

⚠️ Use carefully — too much ignoring = blind Terraform

---

## 5️⃣ Remote Backend + State Locking (CRITICAL)

```
backend "s3" {
  bucket         = "tf-state"
  key            = "prod/terraform.tfstate"
  region         = "ap-south-1"
  dynamodb_table = "tf-lock"
}
```

**Why**

* Prevents:

  * Parallel applies
  * State corruption
* Ensures single writer

---

## 6️⃣ Enable Drift Detection in CI/CD

Example:

```
terraform plan -detailed-exitcode
```

Exit codes:

* `0` → no changes
* `2` → drift detected
* `1` → error

**Automate alerts**

* Slack
* Email
* PR comments

---

## 7️⃣ Use `terraform import` for Existing Changes

```
terraform import aws_instance.example i-012345
```

**Use case**

* Infra exists or changed manually
* Bring it back under Terraform control

---

## 8️⃣ Use Policy-as-Code (Advanced)

Tools:

* Sentinel
* OPA
* Terraform Cloud

**Enforce rules**

* Block manual changes
* Force Terraform-only updates

---

## 9️⃣ Use Terraform Cloud / Enterprise

Benefits:

* Automatic drift detection
* Remote execution
* State locking
* Audit logs

---

## 🔟 Know When Drift Is ACCEPTABLE

Acceptable drift:

* Auto scaling
* Kubernetes controllers
* Cloud-managed services

Unacceptable drift:

* Security groups
* IAM policies
* Databases
* Networking

---

## Best Practice Summary

| Method            | Purpose             |
| ----------------- | ------------------- |
| No manual changes | Avoid drift         |
| plan regularly    | Detect drift        |
| refresh-only      | Sync state          |
| ignore_changes    | Controlled drift    |
| Remote backend    | Prevent corruption  |
| CI checks         | Automated detection |
| import            | Reconcile infra     |

---

## Interview-Ready Answer (One-Liner)

> “Terraform drift is prevented by avoiding manual changes, using remote backends with locking, running terraform plan regularly, syncing state with refresh-only, and selectively using lifecycle ignore_changes for auto-managed resources.”

---

If you want next:

* Drift demo with ASG
* CI pipeline for drift detection
* Drift vs configuration change
* Real production drift incidents

Just say 👍
