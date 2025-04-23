variable "env" {
  default = "dev"
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ami_id" {
  description = "Ubuntu 24.04 AMI ID"
}

variable "key_name" {
  description = "SSH key name"
}



variable "eks_role_arn" {}
variable "node_role_arn" {}

variable "oidc_client_id" {}
variable "oidc_client_secret" {}
variable "oidc_issuer_url" {}
