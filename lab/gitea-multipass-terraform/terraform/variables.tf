variable "ubuntu_image" {
  description = "Ubuntu image tag recognised by Multipass (e.g. '24.04', 'lts')"
  type        = string
  default     = "24.04"
}

variable "worker_count" {
  description = "Number of worker nodes to create"
  type        = number
  default     = 3
}

variable "manager_cpus" {
  description = "vCPUs allocated to the manager node"
  type        = number
  default     = 1
}

variable "manager_memory" {
  description = "RAM allocated to the manager node"
  type        = string
  default     = "1G"
}

variable "manager_disk" {
  description = "Disk size for the manager node"
  type        = string
  default     = "5G"
}

variable "worker_cpus" {
  description = "vCPUs allocated to each worker node"
  type        = number
  default     = 1
}

variable "worker_memory" {
  description = "RAM allocated to each worker node"
  type        = string
  default     = "1G"
}

variable "worker_disk" {
  description = "Disk size for each worker node"
  type        = string
  default     = "5G"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key used by Ansible"
  type        = string
  default     = "./terraform/id_ed25519"
}
