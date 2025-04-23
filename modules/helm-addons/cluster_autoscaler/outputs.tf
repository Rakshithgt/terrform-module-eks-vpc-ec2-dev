output "autoscaler_role" {
  value = aws_iam_role.autoscaler_irsa.arn
}
