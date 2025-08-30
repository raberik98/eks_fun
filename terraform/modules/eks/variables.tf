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

locals {
  # ubuntu_image_id = "ami-04e33358385599285"
  # ubuntu_ami_name = "ubuntu-eks/k8s_1.28/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-20250527"
}


# Check for any Ubuntu AMIs with EKS in the name

# aws ec2 describe-images \
#   --owners 099720109477 \
#   --filters "Name=name,Values=*ubuntu*eks*" \
#   --query 'Images[*].[ImageId,Name,CreationDate]' \
#   --output table
