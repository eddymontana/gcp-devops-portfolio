# 🚀 GCP DevOps Portfolio: Production-Grade FastAPI on Cloud Run

[![CI/CD Pipeline](https://github.com/darklordyng/gcp-devops-portfolio/actions/workflows/deploy.yml/badge.svg)](https://github.com/darklordyng/gcp-devops-portfolio/actions/workflows/deploy.yml)
[![Cloud Run Service](https://img.shields.io/badge/Cloud%20Run-Live-blue?logo=googlecloud)](https://portfolio-app-service-yxsvcxt2tq-uc.a.run.app)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)](https://www.terraform.io/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green?logo=fastapi)](https://fastapi.tiangolo.com/)

A production-ready, cloud-native DevOps portfolio project demonstrating automated Infrastructure as Code (IaC), zero-secret CI/CD pipelines, and serverless containerization on Google Cloud Platform (GCP).

## 🌐 Live Demos
* **API Endpoint:** [https://portfolio-app-service-yxsvcxt2tq-uc.a.run.app](https://portfolio-app-service-yxsvcxt2tq-uc.a.run.app)
* **Interactive Docs (Swagger UI):** [https://portfolio-app-service-yxsvcxt2tq-uc.a.run.app/docs](https://portfolio-app-service-yxsvcxt2tq-uc.a.run.app/docs)
* **Health Check:** [https://portfolio-app-service-yxsvcxt2tq-uc.a.run.app/health](https://portfolio-app-service-yxsvcxt2tq-uc.a.run.app/health)

---

## 🏗️ Architecture & Tech Stack

* **Cloud Provider:** Google Cloud Platform (`us-central1`)
* **Compute:** Google Cloud Run (v2 Serverless Container)
* **Artifact Storage:** Google Artifact Registry (DOCKER format)
* **Infrastructure as Code:** Terraform (State management, API enablement, IAM bindings)
* **CI/CD Automation:** GitHub Actions with Workload Identity Federation (OIDC)
* **Application Framework:** FastAPI (Python) running on port `8080` with custom startup/liveness probes.

---

## 🔒 Security & Best Practices
1. **Zero Long-Lived Credentials:** Uses Google Cloud Workload Identity Federation for keyless GitHub Actions authentication.
2. **Least Privilege IAM:** Dedicated service accounts (`portfolio-cloudrun-sa`) bound strictly to necessary runtime permissions.
3. **Cost Optimization:** Configured with `min_instance_count = 0` to scale down to zero when idle, fitting securely within GCP "Always Free" tier boundaries.
4. **Resiliency:** Implements explicit health probes (`/health`) and container port mappings to prevent cold-start failures.

---

## 🛠️ Local Development & Deployment

### Prerequisites
* Google Cloud SDK (`gcloud`) installed
* Terraform (`>= 1.5.0`)
* Docker

### 1. Terraform Infrastructure Provisioning
```bash
cd terraform
export GOOGLE_OAUTH_ACCESS_TOKEN="$(gcloud auth print-access-token)"
terraform init
terraform apply

### 2. Local App Execution
```bash
cd app
pip install -r requirements.txt
uvicorn main:app --reload --port 8080
