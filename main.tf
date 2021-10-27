resource "google_project_service" "this" {
  for_each = toset(var.services-list)

  disable_on_destroy = false
  project            = var.project-id

  service = each.value
}

resource "google_cloudbuild_trigger" "build-trigger" {
  github {
    owner = "ht-accenture"
    name  = "gcpbuildtriggertest"

    push {
      branch = "master"
    }
  }

  build {
    step {
      name		= "marketplace.gcr.io/google/centos8:latest"
      args		= ["sudo", "apt-get", "update", "&&", "sudo", "apt-get", "install", "terraform"]
      timeout		= "300s"
    }
  }
  depends_on = [
    google_cloudfunctions_function.metadata-listener,
    google_pubsub_topic.pubsub,
    google_storage_bucket.observed-bucket
  ]
}

resource "google_storage_bucket" "observed-bucket" {
  name          = "chapter4-test-bucket-328412"
  location      = "EU"
  force_destroy = true
}

data "archive_file" "function-code" {
  type		= "zip"
  output_path	= "${path.module}/func.zip"
  source_file	= "${path.module}/src/main.py"
}

resource "google_storage_bucket_object" "src" {
  name		= "func.zip"
  bucket	= google_storage_bucket.observed-bucket.name
  source	= "${path.module}/func.zip"
  depends_on	= [data.archive_file.function-code]
}

resource "google_pubsub_topic" "pubsub" {
  name = "bucket-topic"
}

resource "google_cloudfunctions_function" "metadata-listener" {
  name    = "listener-function"
  runtime = "python38"
  region  = var.region
  depends_on = [
    google_storage_bucket.observed-bucket,
    google_storage_bucket_object.src
  ]

  entry_point           = "start"
  source_archive_bucket = google_storage_bucket.observed-bucket.name
  source_archive_object = google_storage_bucket_object.src.name
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.observed-bucket.name
  }
}

#resource "google_storage_bucket" "gcf-storage" {
#  name		= var.gcf-storage
#  location	= "EUROPE-WEST3"
#  force_destroy	= true
#}

#resource "google_storage_bucket" "artifacts-storage" {
#  name		= var.artifacts-storage
#  location	= "EU"
#  force_destroy	= true
#}
