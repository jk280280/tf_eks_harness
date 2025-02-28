# ✅ Fetch EKS Cluster Information
data "aws_eks_cluster" "eks_cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks_auth" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

# ✅ Configure Kubernetes Provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
}

# ✅ Create a Namespace for the Harness Delegate
resource "kubernetes_namespace" "harness_delegate" {
  metadata {
    name = "harness-delegate"
  }
}

# ✅ Deploy Harness Delegate Using a Kubernetes Manifest
resource "kubernetes_manifest" "harness_delegate" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "harness-delegate"
      namespace = kubernetes_namespace.harness_delegate.metadata[0].name
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "harness-delegate"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "harness-delegate"
          }
        }
        spec = {
          containers = [
            {
              name  = "harness-delegate"
              image = "harness/delegate:latest"
              env = [
                {
                  name  = "ACCOUNT_ID"
                  value = "axO8S93qRGqqf1tlBaonnQ"
                },
                {
                  name  = "DELEGATE_TOKEN"
                  value = "OWYyNDYzMjVlODVkZTJlY2RiZmFlZjM2NmEzMDk3N2Y="
                },
                {
                  name  = "DELEGATE_NAME"
                  value = "eks-delegate"
                }
              ]
            }
          ]
        }
      }
    }
  }
}
