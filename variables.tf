variable "amount_of_vms" {
    default = 1
}

variable "image" {
    default = "ubuntu-20-04-x64"
}

variable "name" {
    default = "wireguard"
}

variable "region" {
    default = "fra1"
}

variable "size" {
    default = "s-1vcpu-1gb"
}

variable "do_token" {
    sensitive = true
}

variable "pvt_key" {}

variable "ssh_key_fingerprint" {}

variable "use_local_ansible" {
    default = true
}

variable "user" {
    default = "root"
}

variable "type" {
    default = "ssh"
}

variable "timeout" {
    default = "3m"
}