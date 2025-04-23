provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "../modules/vpc"
  env        = var.env
  vpc_cidr   = var.vpc_cidr
  azs        = var.azs
}



module "ec2" {
  source     = "../modules/ec2"
  env        = var.env
  ami_id     = var.ami_id
  instance_type = "t3.micro"
  key_name   = var.key_name
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnets[0]
}


module "eks" {
  source        = "../modules/eks"
  env           = var.env
  subnet_ids    = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  eks_role_arn  = var.eks_role_arn
}

module "nodegroup" {
  source        = "../modules/nodegroup"
  env           = var.env
  cluster_name  = module.eks.cluster_name
  subnet_ids    = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  node_role_arn = var.node_role_arn
}

# 👇 OIDC Provider Data for IRSA
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

data "aws_iam_openid_connect_provider" "eks_oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

module "cluster_autoscaler" {
  source              = "../modules/helm-addons/cluster_autoscaler"
  cluster_name        = module.eks.cluster_name
  env                 = var.env
  oidc_provider_url   = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  oidc_provider_arn   = data.aws_iam_openid_connect_provider.eks_oidc.arn
}

module "aws_lb_controller" {
  source              = "../modules/helm-addons/aws_lb_controller"
  cluster_name        = module.eks.cluster_name
  region              = var.region
  env                 = var.env
  vpc_id              = module.vpc.vpc_id
  oidc_provider_url   = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  oidc_provider_arn   = data.aws_iam_openid_connect_provider.eks_oidc.arn
}

module "nginx_ingress" {
  source = "../modules/helm-addons/nginx_ingress"
  env    = var.env
}

module "cert_manager" {
  source = "../modules/helm-addons/cert_manager"
}

module "metrics_server" {
  source = "../modules/helm-addons/metrics_server"
}

module "openid_connector" {
  source        = "../modules/helm-addons/openid_connector"
  client_id     = var.oidc_client_id
  client_secret = var.oidc_client_secret
  issuer_url    = var.oidc_issuer_url
}
