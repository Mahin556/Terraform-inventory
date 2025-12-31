### References:-
* https://registry.terraform.io/browse/providers
* https://spacelift.io/blog/terraform-aws-provider
* https://k21academy.com/terraform-iac/terraform-providers-overview/
* https://spacelift.io/blog/terraform-providers *

---

* A Terraform provider is a binary plugin that Terraform uses to interact with external APIs and service.
* Providers expose resources (things Terraform can create/manage) and data sources (things Terraform can read/query).
* It’s responsible for translating your Terraform code (HCL – HashiCorp Configuration Language) into API calls to create, update, or delete infrastructure resources.
* Provider specified in tearrform configuration code.
* 100+ providers.
* Not platoform specific IAC tool ---> Using porovider plugin it can work with different platforms.
* Platform-specific IAC Tool/Service, such as Microsoft Azure ARM templates or Bicep (which interact with the Azure API only), CFT.
* Terraform is the “engine”, and providers are the “drivers” that know how to talk to specific cloud platforms or services (like AWS, Azure, GCP, GitHub, Docker, Kubernetes, etc.).
* Providers are plugins that define which resources can be managed and handle the API calls to create, update, and delete resources.
* Examples:
  * aws → creates EC2, S3, VPC, etc.
  * azurerm → manages Azure resources.
  * kubernetes → deploys workloads inside a cluster.
  * local → manages local files and directories.

---

* **How Providers Work**
  * Terraform itself doesn’t know how to talk to AWS, GCP, or other APIs.
  * When you initialize (terraform init), Terraform:
      * Downloads the provider plugin (from the Terraform Registry or third party/internally).
      * Installs it into the .terraform/plugins directory.
      * Uses it to communicate with the target infrastructure’s API.

---

* **Types of Providers**

  | Provider Type | Maintainer          | Description                                                                                             |
  | ------------- | ------------------- | ------------------------------------------------------------------------------------------------------- |
  | **Official**  | HashiCorp           | Fully supported and tested by HashiCorp. (e.g. `aws`, `azurerm`, `google`)                              |
  | **Verified**  | Third-party vendors | Published by tech companies like MongoDB, Datadog, or Cisco that are **HashiCorp Technology Partners**. |
  | **Community** | Open-source users   | Created by Terraform community contributors. May not always be actively maintained.                     |
  | **Custom**    | Internal            | Custom/Private Providers You can build your own using the Terraform Plugin SDK (written in Go), Useful for internal systems or unsupported APIs. |

