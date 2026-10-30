variable "aws_region" {
  default = "us-east-2"
}

variable "cluster_name" {
  default = "wiz-lab"
}

variable "backup_password" {
  sensitive = true
}

variable "tasky_password" {
  sensitive = true
}

variable "github_owner" {
  description = "Your personal GitHub username (owner of the tasky-wiz repo)"
  type        = string
  default     = "joeyrogo"
}

variable "github_repo" {
  description = "Repo name from the Phase 0 walkthrough (gh repo create tasky-wiz --private)"
  default     = "tasky-wiz"
}
