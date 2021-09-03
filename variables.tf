variable "region" {
    type = string
    default = "europe-west3"
}

variable "project" {
    type = string
    default = "redmine-324809"
}

variable "instance" {
    type = string
    default = "e2-small"
}

variable "user" {
    type = string
    default = "taras"
}

variable "publickeypath" {
    type = string
    default = "~/.ssh/id_rsa.pub"
}

variable "db_name" {
    type = string
    default = "redmine"
}

variable "db_user" {
    type = string
    default = "redmine_user"
}

variable "db_password" {
    type = string
    default = "redmine_password"
}

variable "redmine_secret_key" {
    type = string
    default = "redmine_key"
}

variable "network_cidr" {
    type = string
    default = "10.127.0.0/24"
}

variable "haproxy_ip" {
    type = string
    default = "10.127.0.100"
}

variable "redmine0_ip" {
    type = string
    default = "10.127.0.110"
}

variable "redmine1_ip" {
    type = string
    default = "10.127.0.120"
}

variable "postgres_ip" {
    type = string
    default = "10.127.0.130"
}

variable "haproxy_cfg" {
    type = string
    default = "/etc/haproxy/haproxy.cfg"
}
