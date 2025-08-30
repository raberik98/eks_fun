# Docs and how to check what kind of code you should be producing:

## [aws_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)
- Don't separate the node_groups from the eks_cluster, keep them tightly coupled
- Pin kuberentes_version for better reproducability

To get supported Kubernetes versions
```bash
    aws eks describe-addon-versions --query 'addons[0].addonVersions[0].compatibilities[].clusterVersion' --output text | tr '\t' '\n' | sort -V | uniq
```

To get the available Kuberentes versions for EKS
```bash
    aws eks describe-addon-versions --query 'addons[0].addonVersions[0].compatibilities[].clusterVersion' --output text
```

## [aws_eks_addon](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon)
- Pin addon version for better reproducability

To get the addon version.
```bash
    aws eks describe-addon-versions --addon-name kube-proxy --kubernetes-version 1.28 --query 'add
    ons[0].addonVersions[0].addonVersion' --output text
```

## [eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group)
- Check that the recommended basic policies are included in the example snippet, you can give further policies as you need. For example you will need an ECR read policy.

## [aws_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template)
- Launch templates were specifically made for autoscaling groups for example or for general EC2 usage and it's perfectly compatible with EKS too.
- Since we are using an EKS optimized AMI, there is no need for a process called **bootstrapping**.
- **Bootstrapping** is when you attach the created EC2 to the Kuberentes cluster, for EKS optimized images it's already automated for you, otherwise you can do it in a few lines of code, but you have to do it yourself.

