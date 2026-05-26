variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  # Bumped from t3.small — t3.small caps at 11 pods and 2 GB RAM,
  # which is too tight once system pods + ARC controller are running.
  default = ["t3.medium"]
}

variable "github_org" {
  description = "Your GitHub username or organization"
  type        = string
  default     = "piyush0742"
}

variable "github_repo" {
  description = "Your GitHub repository name"
  type        = string
  default     = "CI-CD-Evolution"
}

# ── New: kept out of code, set in terraform.tfvars (gitignored) ──

variable "admin_user_arn" {
  description = "IAM user/role ARN granted cluster admin access. Set in terraform.tfvars."
  type        = string
  # No default — must be supplied explicitly so the account ID is not in code.
}

variable "cluster_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the EKS public API endpoint. Lock down to your IP /32 for dev."
  type        = list(string)
  # No default — must be supplied; '0.0.0.0/0' is no longer the silent fallback.
}
