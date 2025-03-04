provider "aws" {
  region = "us-west-1"
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "my-eks-cluster"
  node_group_name = "my-node-group"
  instance_types  = ["t3.medium"]
}

# Fetch EKS cluster details dynamically
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    token                  = data.aws_eks_cluster_auth.eks_auth.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  }
}

# Create Harness Delegate Namespace
resource "kubernetes_namespace" "harness_delegate" {
  metadata {
    name = "harness-delegate-ng"
  }
}

module "delegate" {
  source          = "harness/harness-delegate/kubernetes"
  version         = "0.1.8"

  account_id      = "axO8S93qRGqqf1tlBaonnQ"
  delegate_token  = "OWYyNDYzMjVlODVkZTJlY2RiZmFlZjM2NmEzMDk3N2Y="
  delegate_name   = "terraform-delegate"
  deploy_mode     = "KUBERNETES"
  namespace       = kubernetes_namespace.harness_delegate.metadata[0].name
  manager_endpoint = "https://app.harness.io"
  delegate_image  = "harness/delegate:25.02.85300"
  replicas        = 1
  upgrader_enabled = true

  depends_on = [module.eks, kubernetes_namespace.harness_delegate]
}
