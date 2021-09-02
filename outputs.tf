output "haproxy_public_ip" {
    value = google_compute_instance.haproxy.network_interface.0.access_config.0.nat_ip
}

output "redmine0_public_ip" {
    value = google_compute_instance.redmine0.network_interface.0.access_config.0.nat_ip
}

output "redmine1_public_ip" {
    value = google_compute_instance.redmine1.network_interface.0.access_config.0.nat_ip
}

#output "postgres__public_ip" {
#    value = google_compute_instance.postgres.network_interface.0.access_config.0.nat_ip
#}