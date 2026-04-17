# CI/CD Evolution — From Startup to Enterprise

A hands-on project demonstrating how CI/CD pipelines evolve as a company grows — built with Node.js, Docker, GitHub Actions, and AWS EKS.

---

## What Is This Project?

Most developers know how to write code. Fewer know how to **ship it reliably at scale.**

This project uses a simple Node.js/Express REST API as the foundation and demonstrates **4 stages of CI/CD maturity** — from a zero-config startup pipeline all the way to an enterprise-grade setup running on AWS EKS with self-hosted runners.

Same app. Same goal. The "engine room" gets more powerful at each stage.

---

## The Application

A simple REST API with 4 endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Server health check |
| GET | `/api/users` | Get all users |
| GET | `/api/users/:id` | Get a single user |
| POST | `/api/users` | Create a new user |
| DELETE | `/api/users/:id` | Delete a user |
| GET | `/api/version` | Get deployed version info |

---

## Project Structure

```
cicd-evolution-api/
├── src/
│   ├── index.js              # Entry point
│   ├── app.js                # Express app + middleware
│   └── routes/
│       ├── health.js         # Health check route
│       ├── users.js          # Users CRUD routes
│       └── version.js        # Version info route
├── tests/
│   ├── health.test.js        # Health route tests
│   ├── users.test.js         # Users route tests
│   └── version.test.js       # Version route tests
├── .github/
│   └── workflows/
│       ├── stage1-basic.yml          # Stage 1 — Basic CI
│       ├── stage2-optimized.yml      # Stage 2 — Caching + parallel jobs
│       ├── stage3-self-hosted.yml    # Stage 3 — ARC on EKS
│       └── stage4-enterprise.yml    # Stage 4 — Enterprise hardening
├── infra/
│   ├── eks/                  # Terraform for EKS cluster
│   └── arc/                  # ARC Helm chart values
├── Dockerfile                # Multi-stage Docker build
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
- Zero infrastructure to manage
- Perfect for teams of 1–20 engineers

### Stage 2 — Optimized CI (Growing Startup)
> "Make it faster and cheaper"

- Same GitHub-hosted runners but smarter
- npm dependency caching (skip reinstalling unchanged packages)
- Docker layer caching (skip rebuilding unchanged layers)
- Parallel jobs (lint, test, build run simultaneously)
- Typically cuts build time by 40–70%

### Stage 3 — Self-Hosted Runners on AWS EKS (Mid-Size)
> "Run it on our own infrastructure"

- Ephemeral runners via Actions Runner Controller (ARC) on EKS
- Runners live inside Kubernetes pods, destroyed after each job
- Pushes Docker image to AWS ECR (private registry)
- Runners stay inside your VPC — can access private services
- Full control over runner environment and secrets

### Stage 4 — Enterprise Hardening
> "Lock it down and observe everything"

- Everything from Stage 3, plus:
- Security scanning with Trivy (vulnerability detection)
- OIDC-based AWS authentication (no long-lived credentials)
- Custom hardened runner images
- Build metadata tagging for cost attribution
- Full audit trail of every deployment

---

## Getting Started

### Prerequisites

- Node.js v20+
- Docker Desktop
- Git

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

Visit `http://localhost:3000/health` — you should see:
```json
{
  "status": "ok",
  "uptime": 5.3,
  "timestamp": "2024-01-01T00:00:00.000Z",
  "environment": "development"
}
```

### Run Tests

```bash
./node_modules/.bin/jest --coverage
```

Expected output:
```
Test Suites: 3 passed, 3 total
Tests:       19 passed, 19 total
```

### Run with Docker

```bash
# Build the image
docker build -t cicd-evolution-api .

# Run the container
docker run -p 3000:3000 cicd-evolution-api
```

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Node.js + Express | REST API |
| Jest + Supertest | Testing |
| Docker | Containerization |
| GitHub Actions | CI/CD pipelines |
| AWS EKS | Kubernetes cluster for self-hosted runners |
| AWS ECR | Private Docker image registry |
| ARC | Actions Runner Controller (ephemeral runners on k8s) |
| Terraform | Infrastructure as Code for EKS setup |
| Trivy | Container vulnerability scanning |
| Helm | Kubernetes package manager for ARC |

---

## Key Concepts Demonstrated

- **Why CI/CD matters** — automated testing prevents broken code from reaching production
- **Pipeline evolution** — how infrastructure needs change as teams grow
- **Docker multi-stage builds** — lean production images with tests baked in
- **Ephemeral runners** — clean environment per job, no state leakage
- **OIDC authentication** — secure cloud access without hardcoded secrets
- **Shift-left security** — vulnerability scanning as part of the build process

---

## Author

Built by [Piyush Panchal](https://github.com/piyush0742) as a learning and portfolio project demonstrating real-world CI/CD practices.
