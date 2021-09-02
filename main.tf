terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
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
  name = "redmine-network"
}


resource "google_compute_firewall" "vpc_icmp" {
  name    = "icmp-allow"
  network = google_compute_network.redmine_network.name

  allow {
    protocol = "icmp"
  }

  target_tags   = ["icmp-allow"]
    
}


resource "google_compute_firewall" "vpc_http" {
  name    = "http-allow"
  network = google_compute_network.redmine_network.name
    
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["http-allow"]
      
}


resource "google_compute_firewall" "vpc_https" {
  name    = "https-allow"
  network = google_compute_network.redmine_network.name

  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags   = ["https-allow"]
      
}

resource "google_compute_firewall" "vpc_ssh" {
  name    = "ssh-allow"
  network = google_compute_network.redmine_network.name

  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["ssh-allow"]
      
}


resource "google_compute_instance" "haproxy" {
  name         = "haproxy"
  machine_type = var.instance
  tags         = ["ssh-allow","http-allow","https-allow","icmp-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size = 20
    }
  }

  network_interface {
    network = google_compute_network.redmine_network.name
    access_config {
    }
  }

  metadata_startup_script = file("./first_run_haproxy.sh")
  
  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
    
  }
  
}


resource "google_compute_instance" "redmine0" {
  name         = "redmine0"
  machine_type = var.instance
  tags         = ["ssh-allow","icmp-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size = 20
    }
  }

  network_interface {
    network = google_compute_network.redmine_network.name
    access_config {
    }
  }

  metadata_startup_script = file("./first_run_redmine0.sh")
  
  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
    
  }
  
}

resource "google_compute_instance" "redmine1" {
  name         = "redmine1"
  machine_type = var.instance
  tags         = ["ssh-allow","icmp-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size = 20
    }
  }

  network_interface {
    network = google_compute_network.redmine_network.name
    access_config {
    }
  }

  metadata_startup_script = file("./first_run_redmine1.sh")
  
  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
    
  }
  
}


resource "google_compute_instance" "postgres" {
  name         = "postgres"
  machine_type = var.instance
  tags         = ["ssh-allow","icmp-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size = 20
    }
  }

  network_interface {
    network = google_compute_network.redmine_network.name
    access_config {
    }
  }

  metadata_startup_script = file("./first_run_postgres.sh")
  
  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
    
  }
  
}