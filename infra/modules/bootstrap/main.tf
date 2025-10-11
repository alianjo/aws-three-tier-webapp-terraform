locals {
  name_prefix = "${var.project_name}-${var.environment}"
  repo_ref_patterns = [
    "repo:${var.github_repository}:ref:refs/heads/main",
    "repo:${var.github_repository}:ref:refs/heads/dev",
    "repo:${var.github_repository}:ref:refs/tags/*",
    "repo:${var.github_repository}:pull_request"
  ]

  role_definitions = {
    terraform = {
      description = "GitHub Actions role for Terraform operations"
      policy      = data.aws_iam_policy_document.terraform.json
    }
    app-deploy = {
      description = "GitHub Actions role for ECS application deployments"
      policy      = data.aws_iam_policy_document.app_deploy.json
    }
    web-deploy = {
      description = "GitHub Actions role for static web deployments"
      policy      = data.aws_iam_policy_document.web_deploy.json
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  tags            = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = locals.repo_ref_patterns
    }
  }
}

data "aws_iam_policy_document" "terraform" {
  statement {
    sid     = "TerraformInfrastructure"
    effect  = "Allow"
    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "ecs:*",
      "rds:*",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "logs:*",
      "secretsmanager:*",
      "s3:*",
      "cloudfront:*",
      "ecr:*",
      "sts:GetCallerIdentity",
      "acm:RequestCertificate",
      "acm:DescribeCertificate"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "app_deploy" {
  statement {
    sid    = "ECRPush"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECSDeploy"
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:ListTaskDefinitions"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "PassRoles"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "web_deploy" {
  statement {
    sid    = "S3Sync"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "InvalidateCache"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetDistribution",
      "cloudfront:ListDistributions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "github" {
  for_each           = locals.role_definitions
  name               = "${locals.name_prefix}-${each.key}"
  description        = each.value.description
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "inline" {
  for_each = locals.role_definitions
  name     = "${locals.name_prefix}-${each.key}"
  role     = aws_iam_role.github[each.key].id
  policy   = each.value.policy
}
