############################################
# IAM Role for ARC Runners (IRSA)
# Lets runner pods push images to ECR
# without any hardcoded AWS credentials
############################################

data "aws_iam_policy_document" "arc_runner_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringLike"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:arc-runners:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "arc_runner" {
  name               = "${local.name}-arc-runner-role"
  assume_role_policy = data.aws_iam_policy_document.arc_runner_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "arc_runner_ecr" {
  name = "${local.name}-arc-runner-ecr-policy"
  role = aws_iam_role.arc_runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:DescribeRepositories"
        ]
        Resource = "*"
      }
    ]
  })
}