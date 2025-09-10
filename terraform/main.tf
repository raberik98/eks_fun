module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  cluster_name = local.eks_cluster_name
  region = var.region
}

# module "db" {
#   source = "./modules/db"

#   vpc_id = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_db_subnet_ids
#   vpc_cidr_block = module.vpc.vpc_cidr_block

#   tag_name = var.project_name

# }

# module "ecr" {
#   source = "./modules/ecr"

#   region = var.region
#   project_name = var.project_name
#   profile = var.profile
# }

module "eks" {
  source = "./modules/eks"

  vpc_id = module.vpc.vpc_id

  subnet_ids = [
    module.vpc.public_subnet_ids[0],
    module.vpc.public_subnet_ids[1],
    module.vpc.private_subnet_id
  ]

  project_name = var.project_name
  aws_region = var.region
  aws_profile = var.profile
  cluster_name = local.eks_cluster_name
  aws_cli_profile = var.profile
  configure_kubectl = true
}

locals {
  eks_cluster_name = "${var.project_name}-eks-cluster"
}