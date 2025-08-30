resource "aws_eks_cluster" "this" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  // It's a good idea to pin a specific version for better reproducability.
  // aws eks describe-addon-versions --query 'addons[0].addonVersions[0].compatibilities[].clusterVersion' --output text
  version = "1.28"

  // Default is true, it determines if you want EKS to install aws-cni, kube-proxy, and CoreDNS by default or if you want to do so manually
  // False will disable automatic installs so you have to do it on your own.
  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids         = [var.public_subnet_id, var.private_subnet_id]
    security_group_ids = [aws_security_group.eks_cluster.id]
  }

  # Encrypt etcd data at rest, you can optionally add configmaps too but usually it's not necessarry
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  # Modern authentication approach
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  // https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy
  ]
}

# resource "aws_iam_openid_connect_provider" "eks" {
#   url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
# }



# resource "aws_eks_node_group" "ingress" {
#   cluster_name    = aws_eks_cluster.this.name
#   node_group_name = "ingress-nodes"
#   node_role_arn   = aws_iam_role.eks_node.arn
#   subnet_ids      = [var.public_subnet_id]

#   scaling_config {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 1
#   }

#   instance_types = ["t3.medium"]

#   labels = {
#     "node-type" = "ingress-nodes"
#   }

#   tags = {
#     Name = "ingress-nodes"
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_worker_policy,
#     aws_iam_role_policy_attachment.eks_vpc_resource_controller,
#     aws_iam_role_policy_attachment.ecr_read_policy
#   ]
# }


// Automate local kubectl configuration
resource "terraform_data" "configure_kubectl" {
  count = var.configure_kubectl ? 1 : 0
  depends_on = [aws_eks_cluster.this]

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.this.name} --profile ${var.aws_cli_profile}
    EOT
  }
}
