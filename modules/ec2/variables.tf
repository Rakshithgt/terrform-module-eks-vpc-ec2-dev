variable "ami_id" {
  type        = string
  description = "Ubuntu AMI ID"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "env" {
  type = string
}
