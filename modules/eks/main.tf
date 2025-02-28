# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch subnets of the default VPC in specific availability zones
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-west-1a", "us-west-1b", "us-west-1c"]
  }
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
  subnet_ids      = data.aws_subnets.default.ids
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = var.instance_types
}

