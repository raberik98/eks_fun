// https://registry.terraform.io/providers/hashicorp/kubernetes/2.36.0/docs?utm_content=documentLink&utm_medium=Visual+Studio+Code&utm_source=terraform-ls#exec-plugins
provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name, "--profile", ]
      command     = "aws"
    }
}

// https://registry.terraform.io/providers/hashicorp/helm/latest/docs#credentials-config
provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name, "--profile", var.aws_profile]
      command     = "aws"
    }
  }
}

/*
  IMPORTANT!!!

  YOU DON'T NEED THE 

            "--profile", var.aws_profile
            
   ARGUMENTS IN THE PROVIDER ARGUMENTS FOR AUTHENTICATION, YOU SHOULD DELETE THESE TWO FROM THE args LIST.
   I NEED IT BECAUSE I CAN ACCESS YOUR MEMBER ACCOUNTS BY ASSUMING A ROLE!

   SO LINE 7 AND 19 SHOULD LOOK LIKE THIS FOR YOU:

   args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name]
*/