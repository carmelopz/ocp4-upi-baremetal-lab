# Enable debug mode
variable "DEBUG" {
  description = "Enable debug mode"
  type        = bool
  default     = false
}

# Pull secret for Red Hat registry
variable "OCP_PULL_SECRET" {
  description = "Openshift pull secret"
  type        = string
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
    ha_proxy_version = string,
    registry_version = string
  })
}

# Openshift cluster information
variable "ocp_cluster" {
  description = "Openshift cluster information"
  type        = object({
    name        = string,
    environment = string,
    dns_domain  = string,
    pods_cidr   = string,
    pods_range  = number,
    svcs_cidr   = string,
    num_masters = number
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

# Openshift bootstrap specification
variable "ocp_bootstrap" {
  description = "Configuration for Openshift bootstrap virtual machine"
  type = object({
    base_img = string,
    vcpu     = number,
    memory   = number
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