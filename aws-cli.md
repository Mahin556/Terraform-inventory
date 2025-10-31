### References:
- https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html

---

### **1. Terraform does not *require* AWS CLI to run**

* Terraform interacts with AWS through the **AWS provider plugin**, not directly through the CLI.
* You can use Terraform with AWS even if the AWS CLI is not installed.
* As long as your **AWS credentials** (Access Key ID and Secret Access Key) are available — either:

  * in environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`),
    * vim `.env`
      ```bash
      export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
      export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
      export AWS_REGION=us-west-2 #Optional can be set in terraform config
      ```
      ```bash
      source .env
      echo "source .env" >> .bashrc

      aws iam list-usess
      ```
  * in the `~/.aws/credentials` file,
    ```bash
    aws configure
    ```
  * or through an IAM role (on EC2 or Cloud9) —
    Terraform can authenticate and work fine.

---

### **2. Why AWS CLI is still important and useful**

* **Credential setup:**
  Using `aws configure` is the easiest way to set up credentials and region defaults.
  Terraform automatically reads them from `~/.aws/credentials` and `~/.aws/config`.

* **Verification and troubleshooting:**
  You can quickly test credentials or confirm AWS environment with commands like:

  ```bash
  aws sts get-caller-identity
  aws ec2 describe-instances
  ```

* **Manual management tasks:**
  Sometimes you need to check resource details or clean up manually.
  CLI makes this easy when Terraform state is outdated or partially applied.

* **Scripting and automation:**
  AWS CLI is often used with shell scripts or CI/CD pipelines that also run Terraform.

---

### **3. Best practice**

* Install both **Terraform** and **AWS CLI**.
* Use `aws configure` to set up credentials.
* Verify with:

  ```bash
  aws sts get-caller-identity
  ```
* Then run Terraform commands as usual:

  ```bash
  terraform init
  terraform plan
  terraform apply
  ```

---

### ✅ **In short**

| Tool          | Required?      | Purpose                                                           |
| ------------- | -------------- | ----------------------------------------------------------------- |
| **Terraform** | ✅ Yes          | To create/manage AWS infrastructure as code                       |
| **AWS CLI**   | ⚙️ Recommended | To configure credentials, verify access, and perform quick checks |
