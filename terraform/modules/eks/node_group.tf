# resource "aws_eks_node_group" "eks_fun_nodes" {
#   cluster_name    = aws_eks_cluster.this.name
#   node_group_name = "eks_fun_nodes"
#   node_role_arn   = aws_iam_role.eks_node.arn
#   // Multiple subnets make sense for example if you want more AZ availabilits. (AZ=Availability Zone by the way)
#   subnet_ids = [var.subnet_ids[1]]
#   instance_types = [ "t3.xlarge" ]
#   capacity_type = "ON_DEMAND"


#   # Add SSH key directly
#   # remote_access {
#   #   ec2_ssh_key = "your-key-pair-name"  # Your existing key pair name
#   #   # Optional: restrict SSH access to specific security groups, it makes sense to pass the security group that the bastion host will use
#   #   // source_security_group_ids = []
#   # }

#   scaling_config {
#     desired_size = 2
#     max_size     = 4
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }


#   /* 
#     You can change these values from the AWS Console and from AWS CLI freely and it won't mess with your
#     terraform configuration, you can change these values from terraform too at any time and then the terraform
#     values will be active again. Always the last change is active.
#   */
#   lifecycle {
#     ignore_changes = [
#       scaling_config[0].desired_size,
#       scaling_config[0].max_size,
#       scaling_config[0].min_size
#     ]
#   }


#   labels = {
#     "node-type" = "eks_fun_nodes"
#   }

#   tags = {
#     Name = "eks_fun_nodes"
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_worker_policy,
#     aws_iam_role_policy_attachment.ecr_read_policy,
#     aws_iam_role_policy_attachment.eks_cni_policy
#   ]
# }
