terraform {
  required_version = ">= 1.0"
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

# Automatically enable required Google Cloud APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

# Create a Custom VPC Network
resource "google_compute_network" "vpc" {
  name                    = "portfolio-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.apis]
}

# Create a Subnet for the GKE Cluster
resource "google_compute_subnetwork" "subnet" {
  name          = "portfolio-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
  depends_on    = [google_project_service.apis]
}

# Create an Artifact Registry Repository to store Docker Images
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "portfolio-app-repo"
  description   = "Docker repository for DevOps Portfolio"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis]
}

# Create the GKE Autopilot Cluster
resource "google_container_cluster" "gke" {
  name     = "portfolio-gke-cluster"
  location = var.region

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  enable_autopilot = true

  deletion_protection = false

  depends_on = [google_project_service.apis]
}