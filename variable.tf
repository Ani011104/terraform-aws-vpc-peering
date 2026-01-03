variable "primary_region" {
  type    = string
  default = "us-east-1"
}

variable "secondary_region" {
  type    = string
  default = "us-west-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "terraform-aws-day15"
}

variable "vpc_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/16", "10.1.0.0/16"]
}

variable "subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.1.0.0/24"]
}

variable "primary_key_name" {
  description = "Name of the SSH key pair for Primary VPC instance (us-east-1)"
  type        = string
  default     = ""
}

variable "secondary_key_name" {
  description = "Name of the SSH key pair for Secondary VPC instance (us-west-2)"
  type        = string
  default     = ""
}
