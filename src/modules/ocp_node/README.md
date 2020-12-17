# ocp node module

This Terraform module creates a libvirt guest representing a ocp node.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| libvirt | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cpu | Virtual machine reserved CPU | `number` | `4` | no |
| disk\_size | Disk size in gigabytes | `number` | `120` | no |
| extra\_disks | Exra disks attached to node | `list(string)` | `[]` | no |
| fqdn | FQDN for the node | `string` | n/a | yes |
| id | Internal id for the node | `string` | n/a | yes |
| ignition | Ignition file with node configuration | `string` | n/a | yes |
| libvirt\_pool | Libvirt pool to create the volume | `string` | `"default"` | no |
| memory | Virtual machine reserved CPU | `number` | `16384` | no |
| network | Network configuration | <pre>object({<br>    name = string,<br>    ip   = string,<br>    mac  = string<br>  })</pre> | n/a | yes |
| os\_image | Path to the OS base image in qcow2 format | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| libvirt\_domain\_uuid | Libvirt domain UUID |

## Example

Set up a `main.tf` with:

```hcl
provider "libvirt" {
  uri = "qemu:///system"
}

module "ocp_node" {

  source = "./modules/ocp_node"

  id           = "ocp-node"
  fqdn         = "ocp-node.example.io"
  ignition     = "/var/lib/libvirt/images/node.ign"
  cpu          = 4
  memory       = 8192
  libvirt_pool = "ocp"
  os_image     = "src/storage/images/rhcos-4.6.8-x86_64-qemu.x86_64.qcow2"
  disk_size    = 120
  network      = {
    name = "ocp"
    ip   = "10.128.0.10"
    mac  = "CE:F0:00:00:00:10"
  }

}

```

Then run:

```console
$ terraform init
$ terraform plan
```
