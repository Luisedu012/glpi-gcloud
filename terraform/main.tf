locals {
  name_prefix = "${var.app_name}-${var.environment}"

  labels = {
    app         = var.app_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_compute_network" "glpi_vpc" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  description = "VPC dedicada para o GLPI ${var.environment}."
}

resource "google_compute_subnetwork" "glpi_subnet" {
  name          = "${local.name_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.glpi_vpc.id

  private_ip_google_access = true

  description = "Subnet dedicada para a VM do GLPI."
}

resource "google_compute_address" "glpi_static_ip" {
  name         = "${local.name_prefix}-ip"
  region       = var.region
  address_type = "EXTERNAL"

  description = "IP publico estatico para acesso ao GLPI via DNS."
}

resource "google_compute_firewall" "allow_http" {
  name      = "${local.name_prefix}-allow-http"
  network   = google_compute_network.glpi_vpc.id
  direction = "INGRESS"
  priority  = 1000

  description = "Permite HTTP publico para ACME/Let's Encrypt e redirect para HTTPS."

  source_ranges = ["0.0.0.0/0"]

  target_service_accounts = [
    var.vm_service_account_email
  ]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow_https" {
  name      = "${local.name_prefix}-allow-https"
  network   = google_compute_network.glpi_vpc.id
  direction = "INGRESS"
  priority  = 1000

  description = "Permite HTTPS publico para acesso ao GLPI via Traefik."

  source_ranges = ["0.0.0.0/0"]

  target_service_accounts = [
    var.vm_service_account_email
  ]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "allow_ssh_admin" {
  name      = "${local.name_prefix}-allow-ssh-admin"
  network   = google_compute_network.glpi_vpc.id
  direction = "INGRESS"
  priority  = 1000

  description = "Permite SSH somente a partir do IP administrativo."

  source_ranges = [
    var.admin_ip_cidr
  ]

  target_service_accounts = [
    var.vm_service_account_email
  ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_disk" "glpi_data_disk" {
  name = "${local.name_prefix}-data-disk"
  type = "pd-balanced"
  zone = var.zone
  size = var.data_disk_size_gb

  labels = local.labels
}

resource "google_compute_instance" "glpi_vm" {
  name         = "${local.name_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  labels = local.labels

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = var.boot_disk_size_gb
      type  = "pd-balanced"
    }
  }

  attached_disk {
    source      = google_compute_disk.glpi_data_disk.id
    device_name = "${local.name_prefix}-data"
    mode        = "READ_WRITE"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.glpi_subnet.id

    access_config {
      nat_ip = google_compute_address.glpi_static_ip.address
    }
  }

  service_account {
    email = var.vm_service_account_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(pathexpand(var.ssh_public_key_path))}"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  deletion_protection = false

  tags = [
    "${local.name_prefix}-vm"
  ]

  depends_on = [
    google_compute_firewall.allow_http,
    google_compute_firewall.allow_https,
    google_compute_firewall.allow_ssh_admin
  ]
}