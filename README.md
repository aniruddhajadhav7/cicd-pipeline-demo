# 🚀 End-to-End CI/CD Pipeline with Docker, GitHub Actions & Kubernetes

<div align="center">

![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18-339933?style=for-the-badge&logo=node.js&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

**A production-grade DevOps project demonstrating a fully automated CI/CD pipeline
from code commit to live Kubernetes deployment.**

[Architecture](#-architecture) • [Quick Start](#-quick-start) • [Pipeline](#-cicd-pipeline-deep-dive) • [Kubernetes](#-kubernetes-deployment) • [Testing](#-testing-the-application)

</div>

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#-architecture)
- [Technologies Used](#-technologies-used)
- [Prerequisites](#-prerequisites)
- [Repository Structure](#-repository-structure)
- [Installation Steps](#-installation-steps)
- [How to Run Locally](#-how-to-run-locally)
- [How to Build the Docker Image](#-how-to-build-the-docker-image)
- [How to Push Image to Docker Hub](#-how-to-push-image-to-docker-hub)
- [GitHub Repository Setup](#-github-repository-setup)
- [Configuring GitHub Secrets](#-configuring-github-secrets)
- [CI/CD Pipeline Deep Dive](#-cicd-pipeline-deep-dive)
- [Kubernetes Deployment](#-kubernetes-deployment)
- [Testing the Application](#-testing-the-application)
- [Screenshots](#-screenshots)
- [Troubleshooting](#-troubleshooting)
- [Future Improvements](#-future-improvements)

---

## 📖 Project Overview

This project demonstrates a **complete, production-style DevOps workflow** that every modern engineering team uses:

1. A developer pushes code to the `main` branch on GitHub.
2. **GitHub Actions** automatically detects the push and kicks off the pipeline.
3. The pipeline **runs automated tests** — if they fail, deployment is blocked.
4. On success, **Docker** builds a multi-stage, optimised container image.
5. The image is **pushed to Docker Hub** with versioned tags.
6. **Kubernetes** pulls the new image and performs a **zero-downtime rolling deployment**.
7. The live application is accessible via a Kubernetes Service endpoint.

This is exactly the workflow used by real-world DevOps and platform engineering teams.

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Developer Workstation                           │
│                                                                         │
│   git push origin main                                                  │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        GitHub (Source Control)                          │
│                                                                         │
│   Repository: cicd-pipeline-demo                                        │
│   Branch:     main                                                      │
│                                                                         │
│   Triggers GitHub Actions Workflow on push event ──────────────────┐    │
└────────────────────────────────────────────────────────────────────┼─── ┘
                                                                     │
                                                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       GitHub Actions (CI/CD Runner)                     │
│                                                                         │
│   ┌──────────────┐    ┌───────────────────┐    ┌────────────────────┐   │
│   │  Job 1       │    │  Job 2            │    │  Job 3             │   │
│   │  🧪 TEST     │───▶│  🐳 BUILD & PUSH  │───▶│  ☸️  DEPLOY       │   │
│   │              │    │                   │    │                    │   │
│   │ npm install  │    │ docker build      │    │ kubectl apply      │   │
│   │ npm test     │    │ docker push       │    │ rollout status     │   │
│   └──────────────┘    └─────────┬─────────┘    └────────────────────┘   │
└─────────────────────────────────┼───────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          Docker Hub (Registry)                          │
│                                                                         │
│   yourname/cicd-pipeline-demo:latest                                    │
│   yourname/cicd-pipeline-demo:sha-a1b2c3d                               │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │  image pull
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       Kubernetes Cluster                                │
│                                                                         │
│   Namespace: default                                                    │
│                                                                         │
│   ┌──────────────────────────────────────────────┐                      │
│   │  Deployment: cicd-pipeline-demo              │                      │
│   │                                              │                      │
│   │   ┌──────────────┐  ┌──────────────┐         │                      │
│   │   │  Pod 1       │  │  Pod 2       │  ···   │                       │
│   │   │  Node.js App │  │  Node.js App │         │                      │
│   │   │  Port 3000   │  │  Port 3000   │         │                      │
│   │   └──────────────┘  └──────────────┘         │                      │
│   └──────────────────────────────────────────────┘                      │
│                                                                         │
│   ┌──────────────────────────────────────────────┐                      │
│   │  Service: cicd-pipeline-demo-service         │                      │
│   │  Type: LoadBalancer  Port: 80 → 3000         │                      │
│   └──────────────────────────────────────────────┘                      │
│                                                                         │
│   ┌──────────────────────────────────────────────┐                      │
│   │  HPA: cicd-pipeline-demo-hpa                 │                      │
│   │  Min: 2 replicas  Max: 10  CPU target: 70%   │                      │
│   └──────────────────────────────────────────────┘                      │
└──────────────────────────────────────────────────┬──────────────────────┘
                                                   │
                                                   ▼
                                        🌐 External Traffic
                                        http://<EXTERNAL-IP>:80
```

### How it works — step by step

| Step | Actor | What happens |
|------|-------|-------------|
| 1 | Developer | Pushes code to `main` on GitHub |
| 2 | GitHub Actions | Detects push event, spins up a Ubuntu runner |
| 3 | Runner — Job 1 | Installs Node.js deps, runs Jest tests with coverage |
| 4 | Runner — Job 2 | Builds multi-stage Docker image, pushes to Docker Hub with `latest` + `sha-<hash>` tags |
| 5 | Runner — Job 3 | Writes kubeconfig, patches deployment manifest with new image tag, runs `kubectl apply` |
| 6 | Kubernetes | Pulls new image, performs rolling update (zero downtime), health probes verify each pod |
| 7 | User | Hits the LoadBalancer IP — served by the updated application |

---

## 🛠 Technologies Used

| Technology | Version | Purpose |
|---|---|---|
| **Node.js** | 18 LTS | Application runtime |
| **Express.js** | 4.x | HTTP web framework |
| **Jest** | 29.x | Unit testing |
| **Supertest** | 6.x | HTTP integration testing |
| **Docker** | 24+ | Containerisation — multi-stage build |
| **Docker Hub** | — | Container image registry |
| **GitHub Actions** | — | CI/CD automation |
| **Kubernetes** | 1.28+ | Container orchestration |
| **Minikube / Kind** | Latest | Local Kubernetes cluster |
| **kubectl** | Latest | Kubernetes CLI |

---

## ✅ Prerequisites

Before you start, make sure the following tools are installed on your machine.

### 1. Git

```bash
# Check if Git is installed
git --version

# Install on Ubuntu / Debian
sudo apt update && sudo apt install -y git

# Install on macOS (via Homebrew)
brew install git
```

### 2. Node.js (v18+)

```bash
# Check version
node --version   # must be ≥ 18
npm --version

# Install via nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
```

### 3. Docker

```bash
# Check if Docker is installed
docker --version

# Install on Ubuntu
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER   # run Docker without sudo
newgrp docker

# Install on macOS — download Docker Desktop from:
# https://www.docker.com/products/docker-desktop/
```

### 4. Kubernetes — Minikube (local cluster)

> Use **Minikube** for local development. For cloud deployments, you'd use GKE, EKS, or AKS.

```bash
# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start the cluster (uses Docker as the driver)
minikube start --driver=docker

# Verify it's running
minikube status
```

### 5. kubectl

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify
kubectl version --client
kubectl cluster-info
```

### 6. Accounts Required

- **GitHub account** — [github.com](https://github.com)
- **Docker Hub account** — [hub.docker.com](https://hub.docker.com)

---

## 📁 Repository Structure

```
cicd-pipeline-project/
│
├── app/                          # Node.js application
│   ├── src/
│   │   └── index.js              # Express server — main entry point
│   ├── tests/
│   │   └── app.test.js           # Jest + Supertest test suite
│   └── package.json              # npm manifest & scripts
│
├── k8s/                          # Kubernetes manifests
│   ├── deployment.yaml           # Deployment — how to run the app
│   └── service.yaml              # Service — how to expose the app + HPA
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml             # GitHub Actions pipeline definition
│
├── Dockerfile                    # Multi-stage Docker build
├── .dockerignore                 # Files excluded from Docker context
├── .gitignore                    # Files excluded from git
└── README.md                     # You are here
```

---

## 🛠 Installation Steps

### Step 1 — Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/cicd-pipeline-demo.git
cd cicd-pipeline-demo
```

### Step 2 — Install Node.js dependencies

```bash
cd app
npm install
```

This reads `package.json` and installs all dependencies into `app/node_modules/`.

---

## 💻 How to Run Locally

```bash
# From the app/ directory
npm start
```

The server starts on `http://localhost:3000`.

Test the endpoints:

```bash
# Home route
curl http://localhost:3000/
# Expected: { "message": "🚀 CI/CD Pipeline App — Running Successfully!", ... }

# Health check
curl http://localhost:3000/health
# Expected: { "status": "healthy", "uptime": ..., "timestamp": ... }

# System info
curl http://localhost:3000/info
# Expected: { "app": "cicd-pipeline-demo", "node_version": "v18.x.x", ... }
```

Run tests locally:

```bash
npm test
```

You should see output like:

```
PASS  tests/app.test.js
  GET /
    ✓ should return 200 with a success message
    ✓ should return a version field
    ✓ should return a timestamp field
  GET /health
    ✓ should return 200 with status healthy
    ✓ should include uptime in the response
  GET /info
    ✓ should return 200 with app info
  Unknown routes
    ✓ should return 404 for an unknown route

Test Suites: 1 passed, 1 total
Tests:       7 passed, 7 total
```

---

## 🐳 How to Build the Docker Image

> Run these commands from the **project root** (not inside `app/`).

### Step 1 — Build the image

```bash
docker build -t cicd-pipeline-demo:latest .
```

**What this does:**
- Docker reads the `Dockerfile` in the current directory.
- Stage 1 (`deps`) installs only production npm packages.
- Stage 2 (`builder`) installs all packages and **runs the tests** — the build aborts if tests fail.
- Stage 3 (`production`) assembles a lean final image with only what's needed to run.

### Step 2 — Verify the image was built

```bash
docker images | grep cicd-pipeline-demo
```

### Step 3 — Run the container locally

```bash
docker run -p 3000:3000 \
  -e NODE_ENV=production \
  --name cicd-demo \
  cicd-pipeline-demo:latest
```

Open `http://localhost:3000` in your browser or run:

```bash
curl http://localhost:3000/health
```

### Step 4 — Stop and remove the container

```bash
docker stop cicd-demo
docker rm cicd-demo
```

---

## 📦 How to Push Image to Docker Hub

### Step 1 — Log in to Docker Hub

```bash
docker login
# Enter your Docker Hub username and password when prompted
```

### Step 2 — Tag the image

Docker images need a tag that includes your Docker Hub username so Docker knows where to push them.

```bash
docker tag cicd-pipeline-demo:latest YOUR_DOCKERHUB_USERNAME/cicd-pipeline-demo:latest
```

**Explanation:**
- `cicd-pipeline-demo:latest` → local image name
- `YOUR_DOCKERHUB_USERNAME/cicd-pipeline-demo:latest` → the full Docker Hub path

Also tag with a version:

```bash
docker tag cicd-pipeline-demo:latest YOUR_DOCKERHUB_USERNAME/cicd-pipeline-demo:1.0.0
```

### Step 3 — Push the image

```bash
# Push the latest tag
docker push YOUR_DOCKERHUB_USERNAME/cicd-pipeline-demo:latest

# Push the versioned tag
docker push YOUR_DOCKERHUB_USERNAME/cicd-pipeline-demo:1.0.0
```

### Step 4 — Verify on Docker Hub

Visit `https://hub.docker.com/r/YOUR_DOCKERHUB_USERNAME/cicd-pipeline-demo` — you should see both tags.

---

## 🐙 GitHub Repository Setup

### Step 1 — Create a new repository on GitHub

1. Go to [github.com/new](https://github.com/new)
2. Repository name: `cicd-pipeline-demo`
3. Set visibility: **Public** (so recruiters can see it)
4. **Do NOT** initialise with README, .gitignore, or a license — we'll push our own.
5. Click **Create repository**

### Step 2 — Initialise git locally

```bash
# Navigate to the project root
cd cicd-pipeline-demo

# Initialise a new git repository
git init
```

### Step 3 — Stage all files

```bash
git add .
```

### Step 4 — Create the first commit

```bash
git commit -m "feat: initial commit — CI/CD pipeline with Docker, GitHub Actions & Kubernetes"
```

### Step 5 — Rename the default branch to main

```bash
git branch -M main
```

### Step 6 — Add the GitHub remote

```bash
git remote add origin https://github.com/YOUR_USERNAME/cicd-pipeline-demo.git
```

Replace `YOUR_USERNAME` with your actual GitHub username.

### Step 7 — Push to GitHub

```bash
git push -u origin main
```

The `-u` flag sets `origin/main` as the default upstream so future pushes only need `git push`.

---

## 🔐 Configuring GitHub Secrets

The CI/CD pipeline uses **Secrets** to store sensitive values safely — they are never visible in logs.

### Secrets you need to add

| Secret name | Value |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | A Docker Hub Access Token (see below) |
| `KUBECONFIG` | Your kubeconfig file, base64-encoded (see below) |

### How to create a Docker Hub Access Token

1. Log in at [hub.docker.com](https://hub.docker.com)
2. Click your avatar → **Account Settings** → **Security**
3. Click **New Access Token**
4. Name it `github-actions`, grant **Read & Write** scope
5. Copy the token — you will only see it once

### How to get your kubeconfig (base64-encoded)

```bash
# This exports and base64-encodes your kubeconfig in one command
cat ~/.kube/config | base64 -w 0
```

Copy the entire output string.

### How to add secrets to GitHub

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret name and value from the table above

### Update the Kubernetes deployment image

Before pushing, replace `YOUR_DOCKERHUB_USERNAME` in `k8s/deployment.yaml`:

```bash
# Replace on Linux/macOS
sed -i 's/YOUR_DOCKERHUB_USERNAME/your_actual_username/g' k8s/deployment.yaml
```

Then commit and push:

```bash
git add k8s/deployment.yaml
git commit -m "chore: set docker hub username in deployment manifest"
git push
```

---

## ⚙️ CI/CD Pipeline Deep Dive

The pipeline is defined in `.github/workflows/ci-cd.yml`.

### What triggers it?

```yaml
on:
  push:
    branches: [main]      # Triggers on every commit merged to main
  pull_request:
    branches: [main]      # Triggers on PRs targeting main (runs tests only)
```

### Job 1 — 🧪 Test

**Purpose:** Validate that all tests pass before any deployment happens.

```
ubuntu-latest runner starts
        │
        ▼
Checkout code (actions/checkout@v4)
        │
        ▼
Set up Node.js 18 with npm cache
        │
        ▼
npm ci  ← installs exact versions from package-lock.json
        │
        ▼
npm test ← runs Jest; pipeline FAILS HERE if any test fails
        │
        ▼
Upload coverage report as build artifact
```

**Key points:**
- `npm ci` is used instead of `npm install` — it's faster and guarantees reproducible installs.
- If even one test fails, Jobs 2 and 3 never run. This **prevents broken code from being deployed**.
- Coverage reports are saved as downloadable artifacts for 7 days.

### Job 2 — 🐳 Build & Push

**Purpose:** Build a production Docker image and push it to Docker Hub.

```
Runs only if: Job 1 passed AND branch is main
        │
        ▼
Extract image tags (latest + sha-<short-hash>)
        │
        ▼
Set up QEMU (for multi-platform builds)
        │
        ▼
Set up Docker Buildx (advanced builder with caching)
        │
        ▼
docker login (using DOCKERHUB_TOKEN secret)
        │
        ▼
docker build + push (linux/amd64 and linux/arm64)
   - Uses GitHub Actions cache to speed up layer builds
   - Pushes tags: latest AND sha-<short-commit-hash>
```

**Why two tags?**
- `latest` — always points to the newest build (convenient)
- `sha-a1b2c3d` — pinned, immutable tag (safe for rollbacks — always know exactly what version is running)

### Job 3 — ☸️ Deploy

**Purpose:** Apply the updated Kubernetes manifests so the cluster runs the new image.

```
Runs only if: Job 2 passed AND branch is main
        │
        ▼
Write kubeconfig from secret (base64 decoded)
        │
        ▼
Patch k8s/deployment.yaml:
   image: → yourname/cicd-pipeline-demo:sha-a1b2c3d
        │
        ▼
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
        │
        ▼
kubectl rollout status (waits up to 120s)
        │
        ▼
kubectl get pods / kubectl get services (prints summary)
```

### End-to-end pipeline time

| Stage | Typical duration |
|---|---|
| Test | ~30–60 seconds |
| Build & Push | ~60–120 seconds (faster with cache) |
| Deploy | ~30–60 seconds |
| **Total** | **~2–4 minutes** |

---

## ☸️ Kubernetes Deployment

### Apply manifests manually

```bash
# Apply the Deployment
kubectl apply -f k8s/deployment.yaml

# Apply the Service (and HPA)
kubectl apply -f k8s/service.yaml
```

### Check pod status

```bash
kubectl get pods
```

Expected output:

```
NAME                                  READY   STATUS    RESTARTS   AGE
cicd-pipeline-demo-6d7f8b9c4d-x2kvp  1/1     Running   0          45s
cicd-pipeline-demo-6d7f8b9c4d-p9jzl  1/1     Running   0          45s
```

`1/1` means the container is running and the readiness probe is passing.

### Inspect a pod in detail

```bash
kubectl describe pod <pod-name>
```

### Check the Service

```bash
kubectl get services
```

Expected output:

```
NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
cicd-pipeline-demo-service   LoadBalancer   10.108.54.123   <pending>     80:31234/TCP   1m
```

> On Minikube, `EXTERNAL-IP` shows `<pending>`. Use `minikube tunnel` (see Testing section).

### Watch a rolling update in real time

```bash
kubectl rollout status deployment/cicd-pipeline-demo --watch
```

### View application logs

```bash
# Logs from all pods matching the label
kubectl logs -l app=cicd-pipeline-demo --tail=50 --follow
```

### Scale manually

```bash
# Scale up to 4 replicas
kubectl scale deployment cicd-pipeline-demo --replicas=4

# Scale back down
kubectl scale deployment cicd-pipeline-demo --replicas=2
```

### Roll back a deployment

```bash
# Roll back to the previous revision
kubectl rollout undo deployment/cicd-pipeline-demo

# Roll back to a specific revision
kubectl rollout history deployment/cicd-pipeline-demo
kubectl rollout undo deployment/cicd-pipeline-demo --to-revision=2
```

### Delete all resources

```bash
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/service.yaml
```

---

## 🧪 Testing the Application

### Option A — Minikube tunnel (recommended for local)

```bash
# In one terminal: create a tunnel so LoadBalancer gets an external IP
minikube tunnel

# In another terminal: get the external IP
kubectl get services cicd-pipeline-demo-service
# EXTERNAL-IP should now show 127.0.0.1
```

Then open `http://127.0.0.1` in your browser or:

```bash
curl http://127.0.0.1/
curl http://127.0.0.1/health
curl http://127.0.0.1/info
```

### Option B — kubectl port-forward (quickest for testing)

```bash
kubectl port-forward service/cicd-pipeline-demo-service 8080:80
```

Then:

```bash
curl http://localhost:8080/
curl http://localhost:8080/health
```

### Option C — Minikube service URL

```bash
minikube service cicd-pipeline-demo-service --url
```

This prints a URL you can open directly in a browser.

### Expected API responses

**GET /**
```json
{
  "message": "🚀 CI/CD Pipeline App — Running Successfully!",
  "version": "1.0.0",
  "hostname": "cicd-pipeline-demo-6d7f8b9c4d-x2kvp",
  "environment": "production",
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**GET /health**
```json
{
  "status": "healthy",
  "uptime": 145.32,
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**GET /info**
```json
{
  "app": "cicd-pipeline-demo",
  "node_version": "v18.20.0",
  "platform": "linux",
  "arch": "x64",
  "memory": {
    "total_mb": 7976,
    "free_mb": 4201
  }
}
```

---

## 📸 Screenshots

> Add screenshots of your running pipeline below. Replace the placeholders with actual images.

### CI/CD Pipeline — All Jobs Passing

```
[ Screenshot: GitHub Actions workflow page showing all three jobs
  (Test ✅, Build & Push ✅, Deploy ✅) with green checkmarks ]
```

### Docker Hub — Image Tags

```
[ Screenshot: Docker Hub repository page showing
  'latest' and 'sha-xxxxxxx' tags with push timestamps ]
```

### Kubernetes — Running Pods

```
[ Screenshot: Terminal output of `kubectl get pods`
  showing 2/2 pods in Running state ]
```

### Live Application

```
[ Screenshot: Browser or curl output showing the JSON response
  from http://<EXTERNAL-IP>/ ]
```

---

## 🔧 Troubleshooting

### Docker build fails with "tests failed"

The multi-stage Dockerfile runs tests during the build. Fix failing tests in `app/tests/app.test.js` first.

```bash
cd app && npm test    # Run tests locally before building
```

### kubectl: connection refused

Your kubeconfig is not pointing to the correct cluster.

```bash
kubectl config current-context    # See which context is active
minikube status                   # Make sure Minikube is running
minikube start                    # Start it if stopped
```

### GitHub Actions — Docker push fails

Check that `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets are set correctly in GitHub Settings → Secrets.

```bash
# Verify credentials locally
docker login -u YOUR_USERNAME
```

### Pods stuck in `ImagePullBackOff`

Kubernetes can't pull the image. Causes:
1. Wrong image name — check `k8s/deployment.yaml`
2. Private image — add an `imagePullSecret`
3. Docker Hub rate limit — authenticated pulls have higher limits

```bash
kubectl describe pod <pod-name>    # Inspect Events section for exact error
```

### Service EXTERNAL-IP stuck at `<pending>` on Minikube

Run `minikube tunnel` in a separate terminal — this is required for LoadBalancer services locally.

---

## 🔮 Future Improvements

| Improvement | Description |
|---|---|
| **Helm Charts** | Package Kubernetes manifests into a Helm chart for easier, configurable deployments |
| **Ingress Controller** | Replace LoadBalancer with NGINX Ingress + TLS termination for production-grade routing |
| **Environment Promotion** | Add `staging` and `production` environments with manual approval gates in GitHub Actions |
| **Secret Management** | Integrate HashiCorp Vault or AWS Secrets Manager instead of GitHub Secrets |
| **Observability** | Add Prometheus + Grafana for metrics, Loki for log aggregation |
| **SAST / Security Scanning** | Add Trivy image scanning and CodeQL static analysis jobs to the pipeline |
| **Multi-environment** | Separate `values.yaml` for dev/staging/prod, deployed to different namespaces |
| **Service Mesh** | Add Istio or Linkerd for mTLS, traffic splitting, and canary deployments |
| **Database** | Add PostgreSQL via StatefulSet + Secrets, demonstrating persistent storage in k8s |
| **ArgoCD / GitOps** | Replace the kubectl deploy step with ArgoCD for true GitOps continuous delivery |

---

## 📄 License

This project is licensed under the **MIT License** — feel free to fork, modify, and use it in your portfolio.

---

# Author

**Aniruddha Adhikrao Jadhav**

- GitHub: [@aniruddhajadhav7](https://github.com/aniruddhajadhav7)
- LinkedIn: [@aniruddhajadhav7](https://linkedin.com/in/aniruddhajadhav7)
- Docker Hub: [@aniruddhaaj7](https://hub.docker.com/u/aniruddhaaj7)
 

---

<div align="center">

⭐ **If this project helped you, please give it a star!** ⭐

*Built to demonstrate production DevOps practices — Docker · GitHub Actions · Kubernetes*

</div>
