variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "The first value should be the public subnet"
  type = list(string)
}

variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_cli_profile" {
  type = string
}

variable "configure_kubectl" {
  type = bool
  default = true
}

variable "aws_profile" {
  type = string
}

variable "cluster_name" {
  type = string
}
