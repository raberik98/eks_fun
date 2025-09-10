resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "eks-pod-identity-agent"
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version = "1.33"

  bootstrap_self_managed_addons = true

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.eks_cluster.id]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

resource "aws_eks_node_group" "eks_fun_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "eks_fun_nodes"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids = [var.subnet_ids[2]]
  instance_types = [ "t3.xlarge" ]
  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size,
      scaling_config[0].max_size,
      scaling_config[0].min_size
    ]
  }


  labels = {
    "node-type" = "eks_fun_nodes"
  }

  tags = {
    Name = "eks_fun_nodes"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_policy,
    aws_iam_role_policy_attachment.ecr_read_policy,
    aws_iam_role_policy_attachment.eks_cni_policy
  ]
}


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
