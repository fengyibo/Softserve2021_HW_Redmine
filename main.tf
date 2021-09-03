terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("gcp.json")

  project = var.project
  region  = var.region
  zone    = "${var.region}-a"
}


resource "google_compute_network" "redmine_network" {
  name                    = "redmine-network"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "redmine_subnetwork" {
  name                     = "redmine-subnetwork"
  ip_cidr_range            = var.network_cidr
  network                  = google_compute_network.redmine_network.self_link
  region                   = var.region
  private_ip_google_access = true
}


resource "google_compute_firewall" "vpc_icmp" {
  name    = "icmp-allow"
  network = google_compute_network.redmine_network.name
  allow {
    protocol = "icmp"
  }
  target_tags = ["icmp-allow"]
}

resource "google_compute_firewall" "vpc_http" {
  name    = "http-allow"
  network = google_compute_network.redmine_network.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http-allow"]
}

resource "google_compute_firewall" "vpc_ssh" {
  name    = "ssh-allow"
  network = google_compute_network.redmine_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh-allow"]
}

resource "google_compute_firewall" "vpc_hastat" {
  name    = "hastat-allow"
  network = google_compute_network.redmine_network.name
  allow {
    protocol = "tcp"
    ports    = ["8888"]
  }
  target_tags = ["hastat-allow"]
}

resource "google_compute_firewall" "vpc_internal" {
  name    = "internal-allow"
  network = google_compute_network.redmine_network.name
  source_ranges = [google_compute_subnetwork.redmine_subnetwork.ip_cidr_range]
  allow {
    protocol = "tcp"
  }
  target_tags = ["internal-allow"]
}


resource "google_compute_instance" "haproxy" {
  name         = "haproxy"
  machine_type = var.instance
  depends_on   = [google_compute_instance.redmine0, google_compute_instance.redmine1]
  tags = ["ssh-allow", "http-allow", "icmp-allow", "hastat-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.redmine_subnetwork.name
    network_ip = var.haproxy_ip
    access_config {
    }
  }

  metadata_startup_script = templatefile("first_run_haproxy.sh.tpl", {
    REDMINE0_IP = var.redmine0_ip,
    REDMINE1_IP = var.redmine1_ip,
    CFG_FILE = var.haproxy_cfg
  })

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
    myvar    = "myvalue"

  }

}


resource "google_compute_instance" "redmine0" {
  name         = "redmine0"
  machine_type = var.instance
  depends_on   = [google_compute_instance.postgres]
  tags         = ["ssh-allow", "icmp-allow", "internal-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.redmine_subnetwork.name
    network_ip = var.redmine0_ip
    access_config {
    }
  }

  metadata_startup_script = templatefile("first_run_redmine0.sh.tpl", {
    DB_NAME = var.db_name,
    DB_USER = var.db_user,
    DB_PASSWORD = var.db_password,
    REDMINE_KEY = var.redmine_secret_key,
    POSTGRES_IP = var.postgres_ip
  })

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"

  }

}

resource "google_compute_instance" "redmine1" {
  name         = "redmine1"
  machine_type = var.instance
  depends_on   = [google_compute_instance.redmine0]
  tags         = ["ssh-allow", "icmp-allow", "internal-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.redmine_subnetwork.name
    network_ip = var.redmine1_ip
    access_config {
    }
  }

  metadata_startup_script = templatefile("first_run_redmine1.sh.tpl", {
    DB_NAME = var.db_name,
    DB_USER = var.db_user,
    DB_PASSWORD = var.db_password,
    REDMINE_KEY = var.redmine_secret_key,
    POSTGRES_IP = var.postgres_ip
  })

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"

  }

}


resource "google_compute_instance" "postgres" {
  name         = "postgres"
  machine_type = var.instance
  depends_on   = [google_compute_subnetwork.redmine_subnetwork]
  tags         = ["ssh-allow", "icmp-allow", "internal-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.redmine_subnetwork.name
    network_ip = var.postgres_ip
    access_config {
    }
  }

  metadata_startup_script = templatefile("first_run_postgres.sh.tpl", {
    DB_NAME = var.db_name,
    DB_USER = var.db_user,
    DB_PASSWORD = var.db_password
  })

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"

  }
}
