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
