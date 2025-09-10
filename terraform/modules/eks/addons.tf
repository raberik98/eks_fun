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

// Above are the default addons, we can manage them manually with addon_versions fixed for better reproducability
//---------------------------------------------------------




# resource "aws_eks_addon" "cloudwatch_observability" {
#   cluster_name = aws_eks_cluster.this.name
#   addon_name   = "amazon-cloudwatch-observability"
# }