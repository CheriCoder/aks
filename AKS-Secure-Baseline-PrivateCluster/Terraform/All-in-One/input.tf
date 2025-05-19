variable "location" {
  type    = string
  default = "eastus"
}

variable "rgHubName" {
  type    = string
  default = "AksTerra-AVM-Hub-RG"
}

variable "rgLzName" {
  type    = string
  default = "AksTerra-AVM-LZ-RG"
}

variable "nsgHubDefaultName" {
  type    = string
  default = "nsg-default"
}

variable "nsgLzDefaultName" {
  type    = string
  default = "nsg-default"
}

variable "nsgVMName" {
  type    = string
  default = "nsg-vm"
}
variable "hubVNETaddPrefixes" {
  type    = string
  default = "10.0.0.0/16"
}

variable "snetHubDefaultAddr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "snetFirewallAddr" {
  type    = string
  default = "10.0.1.0/26"
}

variable "snetBastionAddr" {
  type    = string
  default = "10.0.2.0/27"
}

variable "snetVMAddr" {
  type    = string
  default = "10.0.3.0/27"
}

variable "routeAddr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "vnetHubName" {
  type    = string
  default = "vnet-hub"
}

variable "vnetLzName" {
  type    = string
  default = "vnet-lz"
}

variable "availabilityZones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "environment" {
  type = string
  default = "dev"  
}

variable "rtHubName" {
  type    = string
  default = "rt-hub-table"
}

variable "rtLzName" {
  type    = string
  default = "rt-hub-table"
}

variable "nsgAppGWName" {
  type    = string
  default = "nsg-appgw"
}

variable "spokeVNETaddPrefixes" {
  type    = string
  default = "10.1.0.0/16"
}

variable "snetSpokeDefaultAddr" {
  type    = string
  default = "10.1.0.0/24"
}

variable "snetAksAddr" {
  type    = string
  default = "10.1.1.0/26"
}

variable "snetAppGWAddr" {
  type    = string
  default = "10.1.2.0/27"
}

variable "acrName" {
  type    = string
  default = "acrlzti5y24convadev"
}

variable "akvName" {
  type    = string
  default = "akvlzti5y24convadev"
}

variable "adminGroupObjectIds" {
  type    = string
  default = "0fc03333-7063-4575-af44-443784e95b09"
}