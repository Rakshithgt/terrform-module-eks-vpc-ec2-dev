output "cluster_name" {
  value = aws_eks_cluster.gtr.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.gtr.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.gtr.certificate_authority[0].data
}
