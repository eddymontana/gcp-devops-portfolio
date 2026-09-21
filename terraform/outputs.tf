output "artifact_registry_url" {
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
  description = "The URL route for your Artifact Registry Docker repository"
}

output "gke_cluster_name" {
  value       = google_container_cluster.gke.name
  description = "The name of your deployed GKE cluster"
}

output "region" {
  value       = var.region
  description = "GCP Region"
}