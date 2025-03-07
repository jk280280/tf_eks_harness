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
  name      = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks_auth" {
  name      = module.eks.cluster_name
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

resource "helm_release" "delegate" {
  name       = "harness-delegate"
  namespace  = kubernetes_namespace.harness_delegate.metadata[0].name
  repository = "https://app.harness.io/storage/harness-download/delegate-helm-chart/" 
  chart      = "harness-delegate"

  set {
    name  = "delegateName"
    value = "terraform-delegate"
  }

  depends_on = [kubernetes_namespace.harness_delegate]
}

# Create Harness Delegate Namespace
resource "kubernetes_namespace" "harness_delegate" {
  metadata {
    name = "harness-delegate-ng"
  }
}
