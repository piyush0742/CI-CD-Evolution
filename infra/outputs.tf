############################################
# Outputs
# These values are needed for next steps:
# - connecting kubectl
# - configuring Stage 3 workflow
############################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker image pushes"
  value       = aws_ecr_repository.app.repository_url
}

output "arc_runner_role_arn" {
  description = "IAM role ARN for ARC runners"
  value       = aws_iam_role.arc_runner.arn
}

output "kubeconfig_command" {
  description = "Run this to connect kubectl to your cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC — use in workflow"
  value       = aws_iam_role.github_actions.arn
}