# CI/CD Evolution — From Startup to Enterprise

A hands-on project demonstrating how CI/CD pipelines evolve as a company grows — built with Node.js, Docker, GitHub Actions, AWS EKS, and full observability with Prometheus + Grafana.

---

## What Is This Project?

Most developers know how to write code. Fewer know how to **ship it reliably at scale.**

This project uses a simple Node.js/Express REST API as the foundation and demonstrates **4 stages of CI/CD maturity** — from a zero-config startup pipeline all the way to an enterprise-grade setup running on AWS EKS with self-hosted runners, OIDC authentication, security scanning, and real-time observability.

Same app. Same goal. The "engine room" gets more powerful at each stage.

---

## The Application

A simple REST API with the following endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Server health check |
| GET | `/api/users` | Get all users |
| GET | `/api/users/:id` | Get a single user |
| POST | `/api/users` | Create a new user |
| DELETE | `/api/users/:id` | Delete a user |
| GET | `/api/version` | Get deployed version + build info |

---

## Project Structure

```
cicd-evolution-api/
├── src/
│   ├── index.js                      # Entry point
│   ├── app.js                        # Express app + middleware
│   └── routes/
│       ├── health.js                 # Health check route
│       ├── users.js                  # Users CRUD routes
│       └── version.js                # Version + build metadata route
├── tests/
│   ├── health.test.js                # Health route tests
│   ├── users.test.js                 # Users route tests
│   └── version.test.js               # Version route tests
├── .github/
│   ├── dependabot.yml                # Auto-updates for actions + npm
│   └── workflows/
│       ├── stage1-basic.yml          # Stage 1 — Basic CI
│       ├── stage2-optimized.yml      # Stage 2 — Caching + parallel jobs
│       ├── stage3-self-hosted.yml    # Stage 3 — ARC on EKS + ECR
│       └── stage4-enterprise.yml    # Stage 4 — Enterprise hardening
├── infra/
│   ├── versions.tf                   # Provider versions + S3 backend
│   ├── variables.tf                  # Input variables
│   ├── locals.tf                     # Naming + common tags
│   ├── vpc.tf                        # VPC + subnets + NAT gateway
│   ├── eks.tf                        # EKS cluster + node groups
│   ├── ecr.tf                        # Private Docker registry
│   ├── irsa.tf                       # IAM role for ARC runners
│   ├── oidc.tf                       # GitHub Actions OIDC provider
│   └── outputs.tf                    # Terraform outputs
├── Dockerfile                        # Multi-stage Docker build
├── .dockerignore
├── .env.example
└── package.json
```

---

## The 4 CI/CD Stages

### Stage 1 — Basic CI (Early Startup)
> "Just make it work"

- Runs on GitHub-hosted runners (`ubuntu-latest`)
- Installs dependencies → runs tests → builds Docker image
- Smoke tests the container after build
- Zero infrastructure to manage
- Triggers on: `stage-1` branch

### Stage 2 — Optimized CI (Growing Startup)
> "Make it faster and cheaper"

- Same GitHub-hosted runners but smarter
- npm dependency caching (skip reinstalling unchanged packages)
- Docker layer caching (skip rebuilding unchanged layers)
- Parallel jobs (lint and test run simultaneously)
- Pushes image to GitHub Container Registry (GHCR)
- Triggers on: `stage-2` branch

### Stage 3 — Self-Hosted Runners on AWS EKS (Mid-Size)
> "Run it on our own infrastructure"

- Ephemeral runners via Actions Runner Controller (ARC) on EKS
- Runners live inside Kubernetes pods, destroyed after each job
- Pushes Docker image to AWS ECR (private registry inside your VPC)
- Runners stay inside your VPC — can access private services
- Full control over runner environment and secrets
- Triggers on: `stage-3` branch

### Stage 4 — Enterprise Hardening
> "Lock it down and observe everything"

- Everything from Stage 3, plus:
- OIDC authentication — no AWS keys stored anywhere, temporary credentials only
- Security scanning with Trivy (filesystem + Dockerfile misconfiguration scan)
- Build metadata injected into every image (commit, actor, date, pipeline)
- Cost attribution labels on every Docker image
- Deployment summary visible in GitHub Actions UI
- Dependabot auto-updates for Actions versions and npm packages
- Triggers on: `stage-4` branch

---

## Observability

Full monitoring stack running inside the EKS cluster:

### Prometheus
- Collects metrics every 15 seconds
- Node CPU + memory via Node Exporter
- Pod health + restart counts via kube-state-metrics
- 3 day metric retention

### Grafana
- Real-time dashboards powered by Prometheus
- Custom PromQL dashboards for:
  - Node CPU usage %
  - Node memory usage %
  - Pod CPU + memory per pod
  - Pod restart counts
  - Running pod count (stat panel)


## Infrastructure (Terraform)

All AWS infrastructure is managed as code:

```
VPC (10.0.0.0/16)
├── 2 public subnets  (us-east-1a, us-east-1b)
└── 2 private subnets + NAT gateway

EKS Cluster (cicd-evolution-dev-eks, k8s 1.30)
├── Node group: system   (1-2 × t3.small) ← ARC controller, Prometheus, Grafana
└── Node group: runners  (1-3 × t3.small) ← GitHub Actions runner pods

ECR Repository
└── cicd-evolution-dev-api (scan on push, keep last 10 images)

IAM
├── ARC runner role (IRSA — pod-level AWS auth)
└── GitHub Actions role (OIDC — workflow-level AWS auth, no keys)
```

### Node Separation Strategy
```
System node  → ARC controller, Prometheus, Grafana (cluster infrastructure)
Runner node  → GitHub Actions runner pods (CI workloads)
```
Runner node has a taint (`runner=true:NoSchedule`) so only CI pods schedule there.

---

## Getting Started

### Prerequisites
- Node.js v20+
- Docker Desktop
- AWS CLI + configured credentials
- Terraform >= 1.3
- kubectl
- Helm

### Run Locally

```bash
# Clone the repo
git clone https://github.com/piyush0742/CI-CD-Evolution.git
cd CI-CD-Evolution

# Install dependencies
npm install

# Set up environment
cp .env.example .env

# Start the server
node src/index.js
```

Visit `http://localhost:3000/health`

### Run Tests

```bash
./node_modules/.bin/jest --coverage
```

Expected:
```
Test Suites: 3 passed, 3 total
Tests:       19 passed, 19 total
```

### Run with Docker

```bash
docker build -t cicd-evolution-api .
docker run -p 3000:3000 cicd-evolution-api
```


## Tech Stack

| Tool | Purpose |
|------|---------|
| Node.js + Express | REST API |
| Jest + Supertest | Testing (19 tests) |
| Docker | Multi-stage containerization |
| GitHub Actions | CI/CD pipelines |
| AWS EKS | Kubernetes cluster for self-hosted runners |
| AWS ECR | Private Docker image registry |
| ARC | Actions Runner Controller (ephemeral runners) |
| Terraform | Infrastructure as Code |
| Helm | Kubernetes package manager |
| Trivy | Container vulnerability scanning |
| OIDC | Keyless AWS authentication |
| Dependabot | Automated dependency updates |
| Prometheus | Metrics collection |
| Grafana | Observability dashboards |

---

## Key Concepts Demonstrated

- **CI/CD evolution** — how pipelines change as teams grow
- **Ephemeral runners** — clean environment per job, no state leakage
- **Multi-stage Docker builds** — tests baked into the build process
- **Node taints + labels** — isolate CI workloads from cluster infrastructure
- **IRSA** — pod-level AWS auth using Kubernetes service accounts
- **OIDC** — workflow-level AWS auth with zero stored credentials
- **Shift-left security** — vulnerability scanning before image push
- **PromQL** — custom metrics queries for observability dashboards
- **Cost attribution** — label every artifact back to the team that built it

---

## Branch Strategy

```
main     → stable code, documentation
stage-1  → triggers Stage 1 workflow (basic CI)
stage-2  → triggers Stage 2 workflow (optimized)
stage-3  → triggers Stage 3 workflow (self-hosted + ECR)
stage-4  → triggers Stage 4 workflow (enterprise)
```

---

## Project Status

- [x] Stage 1 workflow — Basic CI on GitHub-hosted runners
- [x] Stage 2 workflow — Optimized with caching + GHCR
- [x] Terraform — VPC, EKS, ECR, IAM, OIDC
- [x] ARC — Self-hosted ephemeral runners on EKS
- [x] Stage 3 workflow — Self-hosted runners + AWS ECR
- [x] Stage 4 workflow — Enterprise hardening complete
- [x] Observability — Prometheus + Grafana with custom dashboards

---

## Author

Built by [Piyush Panchal](https://github.com/piyush0742) — AWS DevOps Engineer Professional | AWS Solutions Architect | HashiCorp Terraform Associate

[LinkedIn](https://linkedin.com/in/piyushpanchal0742) · [GitHub](https://github.com/piyush0742)
