variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
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

data "aws_ssm_parameter" "eks_ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/eks/22.04/1.29/stable/current/amd64/hvm/ebs-gp2/ami-id"
  #      /aws/service/canonical/ubuntu/eks/VERSION/K8S_VERSION/stable/current/ARCH/hvm/ebs-gp2/ami-id
}