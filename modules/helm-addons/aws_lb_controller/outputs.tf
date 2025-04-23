output "lb_role" {
  value = aws_iam_role.lb_controller_irsa.arn
}
