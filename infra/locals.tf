locals {
  name = "cicd-evolution-${var.environment}"

  tags = {
    Project     = "cicd-evolution"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}