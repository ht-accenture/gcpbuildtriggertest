resource "google_project_service" "this" {
    for_each           = toset(var.services-list)
    
    disable_on_destroy = false
    project            = var.project-id
    
    service            = each.value
}

resource "google_cloudbuild_trigger" "build-trigger" {
  trigger_template {
    branch_name = "master"
    repo_name   = "https://github.com/ht-accenture/gcpbuildtriggertest"
  }

  build {
    step {
      name = "gcr.io/cloud-builders/gsutil"
      args = ["mb", "gs://test-bucket-hopefully-created-with-tf"]
      timeout = "120s"
    }
    step {
      name = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "gcloud"
      args = ["pubsub", "topics", "create", "bucket-metadata-topic"]
  }  
}
