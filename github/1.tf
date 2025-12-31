terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "github" {
  # Configuration options
  token = var.token
}

variable "token" {}

resource "github_repository" "my-git-repo" {
  name        = "example"
  description = "My awesome code"
  visibility  = "public"
  auto_init   = true
}

output "git_repo_url" {
  value = github_repository.my-git-repo.html_url
}

output "git_clone_url" {
  value = github_repository.my-git-repo.ssh_clone_url
}
