output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "kubeconfig" {
  value = aws_eks_cluster.this.endpoint
}

output "eks_role_arn" {
  value = aws_iam_role.eks.arn
}

