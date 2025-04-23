output "node_role_arn" {
  value = aws_iam_role.eks_nodegroup_role.arn
}

output "nodegroup_name" {
  value = aws_eks_node_group.node.node_group_name 
}

