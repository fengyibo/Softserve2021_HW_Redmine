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
  depends_on   = [google_compute_instance.redmine0, google_compute_instance.redmine1]
  tags         = ["ssh-allow","http-allow","icmp-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.redmine_subnetwork.name
    network_ip = var.haproxy_ip
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
  depends_on   = [google_sql_user.postgres_user]
  tags         = ["ssh-allow","icmp-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.redmine_subnetwork.name
    network_ip = var.redmine0_ip
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
  depends_on   = [google_sql_user.postgres_user]
  tags         = ["ssh-allow","icmp-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.redmine_subnetwork.name
    network_ip = var.redmine1_ip
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
  count        = 0
  machine_type = var.instance
  depends_on   = [google_compute_subnetwork.redmine_subnetwork]
  tags         = ["ssh-allow","icmp-allow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210825"
      size = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.redmine_subnetwork.name
    network_ip = var.postgres_ip
    access_config {
    }
  }

#  metadata_startup_script = file("./first_run_postgres.sh")
    metadata_startup_script = templatefile("first_run_postgres.sh.tpl", {redmine0=var.redmine0_ip, redmine1=var.redmine1_ip})

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
    
  }
  
}










resource "google_sql_database_instance" "postgres" {
  name = "postgres"
  database_version = "POSTGRES_9_6"
  region = var.region
  
  settings {
    tier = var.db_tier
        
    location_preference {
      zone = "${var.region}-a"
    }
   
    maintenance_window {
      day  = "7"  # sunday
      hour = "3" # 3am
    }
   
    backup_configuration {
      binary_log_enabled = true
      enabled = true
      start_time = "00:00"
    }
   
    ip_configuration {
      ipv4_enabled = "false"
      private_network = google_compute_network.redmine_network.id
      authorized_networks {
        value = var.network_cidr
      }
    }
  }
}

resource "google_sql_database" "postgres_db" {
  name = var.db_name
  project = var.project
  instance = google_sql_database_instance.postgres.name
  charset = "UTF8"
}

resource "google_sql_user" "postgres_user" {
  name = var.db_user
  project  = var.project
  instance = google_sql_database_instance.postgres.name
  host = "%"
  password = var.db_password
}












