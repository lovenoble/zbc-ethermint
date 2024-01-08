variable "region" {
  type = string
  default = "eu-west-2"
}

variable "az" {
  type = string
  default = "eu-west-2a"
}

variable "ami" {
  type = string
  # Ubuntu Jammy Jellyfish	22.04 LTS at region eu-west-2
  # https://cloud-images.ubuntu.com/locator/ec2/
  default = "ami-0a93c302c38b5ec8e"
}

variable "validator_count" {
  description = "Worker nodes to be spawned to run validator nodes on"
  type = number
  default = 5
}

variable "full_node_count" {
  description = "Full node count"
  type = number
  default = 3
}

variable "worker_type" {
  type = string
  # compute optimized for fhe operations
  default = "c5n.4xlarge"
}

variable "worker_disk_size_gb" {
  type = number
  default = 30
}

variable "cidr_vpc" {
  type = string
  default = "10.0.0.0/16"
}

variable "cidr_subnet" {
  type = string
  default = "10.0.0.0/24"
}

variable "ssh_public_key" {
  type = string
  description = "SSH public key to be put in machines"
}
