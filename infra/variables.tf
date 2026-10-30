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
