variable "project_id" {
  type        = string
  default     = "vocal-byte-509214-b1"
  description = "The target GCP Project ID"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "The target GCP region for all infrastructure resources"
}