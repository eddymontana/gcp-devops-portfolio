terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ------------------------------------------------------------------------------
# 1. Enable Required Cloud Run & Artifact Registry APIs
# ------------------------------------------------------------------------------
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com"
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# ------------------------------------------------------------------------------
# 2. Artifact Registry (Stores the FastAPI Container Images)
# ------------------------------------------------------------------------------
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "portfolio-app-repo"
  description   = "Docker repository for DevOps Portfolio FastAPI app"
  format        = "DOCKER"

  depends_on = [google_project_service.apis]
}

# ------------------------------------------------------------------------------
# 3. Dedicated Service Account for Cloud Run Runtime
# ------------------------------------------------------------------------------
resource "google_service_account" "cloud_run_sa" {
  account_id   = "portfolio-cloudrun-sa"
  display_name = "Portfolio Cloud Run Service Account"

  depends_on = [google_project_service.apis]
}

# ------------------------------------------------------------------------------
# 4. Cloud Run Service (Initial Placeholder deployment; CI/CD updates image)
# ------------------------------------------------------------------------------
resource "google_cloud_run_v2_service" "app" {
  name     = "portfolio-app-service"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run_sa.email

    scaling {
      min_instance_count = 0  # Scales to $0 cost when idle
      max_instance_count = 5  # Prevents unexpected traffic spikes from costing money
    }

    containers {
      # Bootstrap image so Terraform can provision the resource before GitHub Actions builds your code
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      ports {
        container_port = 8000
      }

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }

      startup_probe {
        http_get {
          path = "/healthz"
          port = 8000
        }
        initial_delay_seconds = 0
        timeout_seconds       = 3
        period_seconds        = 5
        failure_threshold     = 3
      }

      liveness_probe {
        http_get {
          path = "/healthz"
          port = 8000
        }
        period_seconds = 10
      }
    }
  }

  lifecycle {
    # Ignore image changes made by GitHub Actions pipeline pushes
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version
    ]
  }

  depends_on = [
    google_project_service.apis,
    google_artifact_registry_repository.repo
  ]
}

# ------------------------------------------------------------------------------
# 5. Allow Public (Unauthenticated) Access to the Portfolio Service
# ------------------------------------------------------------------------------
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}