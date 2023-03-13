provider "google" {
  project = "fastapi-deployment-380510"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_instance" "vm_instance" {
  name         = "fast-api"
  machine_type = "e2-standard-2"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }

  metadata_startup_script = <<EOF
#!/bin/bash
apt-get update
apt-get install -y python3-pip git
git clone https://github.com/efi-cloudex/fastapi-tutorial.git
cd fastapi-tutorial
curl -sSL https://install.python-poetry.org | python3 -
sudo /root/.local/bin/poetry install
sudo /root/.local/bin/poetry run uvicorn main:app
EOF
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.self_link
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "fastapi" {
  name    = "fastapi-firewall"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }
  source_ranges = ["0.0.0.0/0"]
}