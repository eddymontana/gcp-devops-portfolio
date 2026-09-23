variable "project_id" {
  description = "The GCP Project ID where resources will be deployed"
  type        = string
}

variable "region" {
  description = "The default GCP region for deployment"
  type        = string
  default     = "us-central1"
}

variable "app_name" {
  description = "The base name for the application resources"
  type        = string
  default     = "portfolio-app"
}