data "aws_eks_cluster" "eks_cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
}

resource "kubernetes_namespace" "harness_delegate" {
  metadata {
    name = "harness-delegate"
  }
}

resource "null_resource" "install_delegate" {
  depends_on = [kubernetes_namespace.harness_delegate]

  provisioner "remote-exec" {
    inline = [
      "curl -o install-delegate.sh https://app.harness.io/public/shared/delegates/install-kubernetes-delegate.sh",
      "chmod +x install-delegate.sh",
      "./install-delegate.sh --accountId axO8S93qRGqqf1tlBaonnQ --delegateToken OWYyNDYzMjVlODVkZTJlY2RiZmFlZjM2NmEzMDk3N2Y= --namespace harness-delegate"
    ]
  }
}
