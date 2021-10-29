provider "google" {
  project = "still-protocol-328412"
}

terraform {
  backend "gcs" {
    bucket = "tf-chapter4-backend"
    prefix = "config"
  }
}
