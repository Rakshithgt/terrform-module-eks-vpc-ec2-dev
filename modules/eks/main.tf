resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "EKSClusterRole"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attach" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "gtr" {
  name     = "${var.env}-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }

  access_config {
    authentication_mode = "API"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  tags = {
    Name = "${var.env}-eks"
  }
}
