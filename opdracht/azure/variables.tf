variable "subscription_id" {
  default = "c064671c-8f74-4fec-b088-b53c568245eb"
}

variable "location" {
  default = "West Europe"
}

variable "admin_password" {
  default = "Welkom01!"
}

variable "resource_group_name" {
  description = "Existing Resource Group name"
  default     = "S1225975"
}

variable "vnet_name" {
  description = "Virtual network name"
  default     = "Ubuntu01-VNET"
}

variable "vnet_address_space" {
  description = "Address space for VNET"
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "Subnet name"
  default     = "Ubuntu01-Subnet"
}

variable "subnet_address_prefix" {
  description = "Subnet address prefix"
  default     = "10.0.1.0/24"
}

variable "vm_count" {
  description = "Number of VMs to deploy"
  type        = number
  default     = 2
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  default     = "UbuntuOpdr6"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "iacuser"
}

variable "ssh_key_name" {
  description = "Name of SSH key resource in Azure"
  type        = string
  default     = "Win11WSL-Azure"
}

variable "ssh_public_key" {
  description = "Path to your SSH public key file"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCemER4vOJBuocl26U+CaPW/tJzYZYubhVN13cuNK+7BOc6qbrhDOERUFSPLIOW25AbdcpwRaYTm6WzZfigbZeV3QEDbaMilR368DDit8QaI8ngm8fp+oEzyl9uy5UDYCSrpJxhF5l66QQ1UxNeIfVyPZirTs6JRK6mlUEJxx0iGq/b8LMEi6vMXN/f3XNI8/2bgz34PWoz/oq+FxQuSQcP8Qp5wyd3EWPpOmrY97N63eG9gFyk7EoBPTeUe/qbTcELMXAlBOc6Se4MCQu8i24Iq2GmdH2/BdORc3C8HAj9Avn3MSjbVEW0505nZBblkqYEM39p1TmM1q2o10ynOk/xCoh6ZjCXH2Lotlna3L1Bvje4FkJQAsbPvI8o6GqpKZUdA5FY9QhmvJ3OiNADP115D1TdNDhBplUFuULX5CoFZPTSgj54N50Nz4GSKAHneRVxcXz/KNcjpMgpwCLhLUOkRKHcL0OG6MM/zyzHe5P6KpFLhaZFqmzd8YL4I7KPT2bxcU+QbQaxxPlGK50gOXq4pCHACMFcQ2halPMeQfzFAN3cTle23OQYhIQZEPXnc+tG02Anwh00GjMXnvzjAwbpQpXH+dnEgKIjma4qvkstmG6yk2VLqqX4BJndE6/AWnkS6Ux5YU1aG5Zy+3uX+t95NDHC3WeHcPIoe4AIuvVbwQ== student@DESKTOP-1NUD89T"
}