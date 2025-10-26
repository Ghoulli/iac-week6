terraform {
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

locals {
  webserver_names = ["esxi-web-01", "esxi-web-02"]
}

#12
# Create the 2 web server VMs
resource "esxi_guest" "webservers" {
  count      = 2
  guest_name = local.webserver_names[count.index]
  disk_store = var.disk_store
  ovf_source = var.ovf_source
  memsize    = var.memory
  numvcpus   = var.vcpu
  power      = "on"

  network_interfaces {
    virtual_network = var.network_name
  }
  customization {
    cloudinit = filebase64("cloudinit.yaml")
  }
    
  provisioner "local-exec" {
    command = "echo ${self.ip_address} >> /vm_ips.txt"
  }
}

