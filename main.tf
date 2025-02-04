provider "aws" {
  region = "us-east-1"
}


module "eks" {
  source          = "./modules/eks"
  cluster_name    = "my-eks-cluster"
  node_group_name = "my-node-group"
  instance_types  = ["t3.medium"]
}



