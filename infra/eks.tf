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

  # Public access for dev (we can hit the cluster from our laptop)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # IRSA enables pods to assume IAM roles securely
  enable_irsa = true

  # Core EKS addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  # ── Access Management ────────────────────────────────────────
  # Grant the IAM user who runs Terraform full admin access
  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::125051246466:user/User-1"
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
    runners = {
      instance_types = var.node_instance_types
      desired_size   = 1
      min_size       = 1
      max_size       = 3   # scales up when many jobs queue up

      labels = {
        role = "runner"
      }

      # Taint so only runner pods schedule here
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