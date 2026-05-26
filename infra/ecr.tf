############################################
# ECR Repository
# Private Docker image registry
############################################
resource "aws_ecr_repository" "app" {
  name = "${local.name}-api"
  # IMMUTABLE prevents overwriting existing tags — forces unique tags
  # (typically the git SHA) and removes "why did prod change silently" mysteries.
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true # scans every pushed image for vulnerabilities
  }

  tags = local.tags
}

# Auto-delete old images — keeps last 10 only
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
