resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
  # addon_version = "v1.20.1-eksbuild.3"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
  depends_on = [ aws_eks_node_group.eks_fun_nodes ]
  # addon_version = "v1.10.1-eksbuild.38"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
  # addon_version = "v1.28.15-eksbuild.31"
}

// Above are the default addons, we can manage them manually with addon_versions fixed for better reproducability
//---------------------------------------------------------


// Predefined service account name "ebs-csi-controller-sa" in namespace "kube-system"
# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name             = aws_eks_cluster.this.name
#   addon_name              = "aws-ebs-csi-driver"
#   addon_version = "v1.48.0-eksbuild.1"
#   service_account_role_arn = aws_iam_role.ebs_csi_2.arn
# }

# resource "aws_eks_addon" "cloudwatch_observability" {
#   cluster_name = aws_eks_cluster.this.name
#   addon_name   = "amazon-cloudwatch-observability"
# }