variable "DEBUG" {
  description = "Enable debug mode"
  type        = bool
  default     = false
}

# Libvirt configuration
variable "libvirt" {
  description = "Libvirt configuration"
  type = object({
    pool      = string,
    pool_path = string
  })
}

variable "network" {
  description = "Network configuration"
  type = object({
    name    = string,
    subnet  = string,
    gateway = string
  })
}

# DNS configuration
variable "dns" {
  description = "DNS configuration"
  type = object({
    domain = string,
    server = string
  })
}

# Helper node specification
variable "helper_node" {
  description = "Configuration for helper node virtual machine"
  type = object({
    base_img         = string,
    vcpu             = number,
    memory           = number,
    ha_proxy_version = string
  })
}

# Openshift masters specification
variable "ocp_master" {
  description = "Configuration for Openshift master virtual machine"
  type = object({
    base_img = string,
    vcpu     = number,
    memory   = number
  })
}

# Openshift inventory
variable "ocp_inventory" {
  description = "List of Openshift cluster nodes"
  type        = map(object({
    ip_address  = string,
    mac_address = string
  }))
}