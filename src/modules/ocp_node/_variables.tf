# Virtual machine variables
variable "id" {
  description = "Internal id for the node"
  type        = string
}

variable "fqdn" {
  description = "FQDN for the node"
  type        = string
}

variable "cpu" {
  description = "Virtual machine reserved CPU"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Virtual machine reserved CPU"
  type        = number
  default     = 16384
}

variable "extra_disks" {
  description = "Exra disks attached to node"
  type        = list(string)
  default     = []
}

variable "ignition" {
  description = "Ignition file with node configuration"
  type        = string
}

# Storage variables
variable "libvirt_pool" {
  description = "Libvirt pool to create the volume"
  type        = string
  default     = "default"
}

variable "os_image" {
  description = "Path to the OS base image in qcow2 format"
  type        = string
}

variable "disk_size" {
  description = "Disk size in gigabytes"
  type        = number
  default     = 120
}

# Network variables
variable "network" {
  description = "Network configuration"
  type = object({
    name = string,
    ip   = string,
    mac  = string
  })
}
