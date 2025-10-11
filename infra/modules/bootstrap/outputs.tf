output "role_arns" {
  value = {
    terraform  = aws_iam_role.github["terraform"].arn
    app_deploy = aws_iam_role.github["app-deploy"].arn
    web_deploy = aws_iam_role.github["web-deploy"].arn
  }
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
