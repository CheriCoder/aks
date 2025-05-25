variable "prefix" {
  description = "The prefix for all resources"
  type        = string
}

variable "environment" {
  description = "The environment (dev, test, prod, etc.)"
  type        = string
}

variable "location" {
  description = "The Azure location where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "allowed_ips" {
  description = "List of allowed IP addresses for the Key Vault"
  type        = list(string)
  default     = []
}

variable "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  type        = string
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for the Key Vault"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet where the private endpoint will be created"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}