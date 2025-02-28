provider "aws" {
  region = "us-west-1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "my-eks-cluster"
  node_group_name = "my-node-group"
  instance_types  = ["t3.medium"]
}

module "delegate" {
  source = "harness/harness-delegate/kubernetes"
  version = "0.1.8"

  account_id = "axO8S93qRGqqf1tlBaonnQ"
  delegate_token = "OWYyNDYzMjVlODVkZTJlY2RiZmFlZjM2NmEzMDk3N2Y="
  delegate_name = "terraform-delegate"
  deploy_mode = "KUBERNETES"
  namespace = "harness-delegate-ng"
  manager_endpoint = "https://app.harness.io"
  delegate_image = "harness/delegate:25.02.85300"
  replicas = 1
  upgrader_enabled = true
}



