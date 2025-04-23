variable "env" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_role_arn" {
  type = string
}
