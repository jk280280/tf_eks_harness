# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}


resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn  = aws_iam_role.eks.arn
  version   = "1.31"

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks.arn
  subnet_ids = [
      us-east-1a, us-east-1b, us-east-1c, us-east-1d
    ]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }
  instance_types = var.instance_types
}


