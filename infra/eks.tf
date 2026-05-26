############################################
# EKS Cluster
############################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.name}-eks"
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public access restricted to specific CIDRs (e.g. your home IP /32)
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_public_access_cidrs
  cluster_endpoint_private_access      = true

  # IRSA enables pods to assume IAM roles securely
  enable_irsa = true

  # KMS envelope encryption for Kubernetes secrets stored in etcd
  create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  # Control plane logs → CloudWatch. Pennies in cost, huge debugging value.
  cluster_enabled_log_types = ["audit", "api", "authenticator"]

  # Core EKS addons
  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {} # newer alternative to IRSA, recommended going forward
  }

  # ── Access Management ────────────────────────────────────────
  access_entries = {
    admin = {
      principal_arn = var.admin_user_arn # pulled from tfvars, no account ID in code
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  # ── Node Groups ─────────────────────────────────────────────
  eks_managed_node_groups = {

    # System node group — runs cluster components
    system = {
      instance_types = var.node_instance_types
      desired_size   = 1
      min_size       = 1
      max_size       = 2

      labels = {
        role = "system"
      }

      tags = local.tags
    }

    # Runner node group — runs GitHub Actions runner pods
    # Scaled to zero by default; ARC will trigger scale-up when jobs queue.
    runners = {
      instance_types = var.node_instance_types
      desired_size   = 0
      min_size       = 0
      max_size       = 3

      labels = {
        role = "runner"
      }

      taints = [{
        key    = "runner"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]

      tags = local.tags
    }
  }

  tags = local.tags
}
