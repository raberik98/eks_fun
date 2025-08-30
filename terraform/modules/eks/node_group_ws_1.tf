resource "aws_eks_node_group" "ws-1" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "ws_1_nodes"
  node_role_arn   = aws_iam_role.eks_node.arn

  // Multiple subnets make sense for example if you want more AZ availabilits. (AZ=Availability Zone by the way)
  subnet_ids = [var.subnet_ids[1]]

  capacity_type = "ON_DEMAND"


  // Use templates for better costumization of your nodes, see bellow.
  launch_template {
    id      = aws_launch_template.ws_1_node_template.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 2
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
    "node-type" = "ws_1_nodes"
  }

  tags = {
    Name = "ws_1_nodes"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_policy,
    aws_iam_role_policy_attachment.ecr_read_policy,
    aws_launch_template.ws_1_node_template
  ]
}


resource "aws_launch_template" "ws_1_node_template" {
  name          = "eks-ubuntu"
  description   = "Launch template for EKS Ubuntu nodes"
  image_id      = local.ubuntu_image_id
  instance_type = "t3.xlarge" # This can be overridden by node group

  cpu_options {
    core_count       = 2
    threads_per_core = 2
  }

  vpc_security_group_ids = [aws_security_group.eks_nodes.id]

  // False because most pods are going to be stateless so no EBS is needed.
  ebs_optimized                        = false
  instance_initiated_shutdown_behavior = "terminate"
  # monitoring {
  #   enabled = true
  # }

  // Only the single point of entry pod EC2 is going to have a public IP address OR a Network Loadbalancer created for it.
  network_interfaces {
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-ubuntu-node"
    }
  }

  # Important: This ensures nodes can be terminated/replaced
  lifecycle {
    create_before_destroy = true
  }
}
