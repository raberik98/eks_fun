# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name = aws_eks_cluster.this.name
#   addon_name   = "vpc-cni"
# }

# resource "aws_eks_addon" "coredns" {
#   cluster_name = aws_eks_cluster.this.name
#   addon_name   = "coredns"
# }

# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name = aws_eks_cluster.this.name
#   addon_name   = "kube-proxy"
# }

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "eks-pod-identity-agent"
}

resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  // It's a good idea to pin a specific version for better reproducability.
  // aws eks describe-addon-versions --query 'addons[0].addonVersions[0].compatibilities[].clusterVersion' --output text
  version = "1.33"

  // Default is true, it determines if you want EKS to install aws-cni, kube-proxy, and CoreDNS by default or if you want to do so manually
  // False will disable automatic installs so you have to do it on your own.
  bootstrap_self_managed_addons = true

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.eks_cluster.id]
  }

  # Encrypt etcd data at rest, you can optionally add configmaps too but usually it's not necessarry
  # You have to generate a kms key that kubernetes will use
  # encryption_config {
  #   provider {
  #     key_arn = aws_kms_key.eks.arn
  #   }
  #   resources = ["secrets"]
  # }

  # Modern authentication approach
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  // https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

resource "aws_eks_node_group" "eks_fun_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "eks_fun_nodes"
  node_role_arn   = aws_iam_role.eks_node.arn
  // Multiple subnets make sense for example if you want more AZ availabilits. (AZ=Availability Zone by the way)
  subnet_ids = [var.subnet_ids[1]]
  instance_types = [ "t3.xlarge" ]
  capacity_type = "ON_DEMAND"


  # Add SSH key directly
  # remote_access {
  #   ec2_ssh_key = "your-key-pair-name"  # Your existing key pair name
  #   # Optional: restrict SSH access to specific security groups, it makes sense to pass the security group that the bastion host will use
  #   // source_security_group_ids = []
  # }

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }


  /* 
    You can change these values from the AWS Console and from AWS CLI freely and it won't mess with your
    terraform configuration, you can change these values from terraform too at any time and then the terraform
    values will be active again. Always the last change is active.
  */
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
