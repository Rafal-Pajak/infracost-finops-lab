terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "finops-lab-prod-01"
  region  = "europe-west3"
  zone    = "europe-west3-a"
}

locals {
  common_labels = {
    environment = "prod"
    owner       = "platform-team"
    cost_center = "cc-4100"
  }
}

resource "google_compute_instance" "app_vm" {
  name         = "gce-app-prod-01"
  machine_type = "e2-standard-2"
  zone         = "europe-west3-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 50
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    enable-oslogin = "TRUE"
    block-project-ssh-keys = "TRUE"
  }

  labels = local.common_labels
}
