provider "google" {
  # OSS, so use this
  #credentials = "${file("/some/path/to/your/auth.json")}"
  #credentials = "${var.serviceAccount}"
  # change this name to your project
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_container_cluster" "k8s" {
  name     = var.cluster_name
  location = var.zone

  initial_node_count = var.node_count

  # this is going to be your project
  project = var.project

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "sandbox"
    }

    machine_type = var.machine_type
    tags         = var.tags
  }

  master_auth {
    username = var.masterAuthUser
    password = var.masterAuthPass
  }
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = google_container_cluster.k8s.master_auth[0].client_certificate
}

output "client_key" {
  value = google_container_cluster.k8s.master_auth[0].client_key
}

output "cluster_ca_certificate" {
  value = google_container_cluster.k8s.master_auth[0].cluster_ca_certificate
}

