variable "location" {
    type = string
    description = "location resources are deployed to"
    default = "ukwest"
}

variable "resource_group_name" {
    type = string
    default = "rjf-rg-hub-bas-pd-ukwest-01"
  
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}

variable "virtual_network" {
  description = "hub vnet details"
  type = map(string)
}

variable "private_dns_zones" {
  description = "A map of private DNS zones to create"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "private_dns_resolver_name" {
  description = "The name of the private DNS resolver"
  type        = string
}

variable "subnet_ids" {
  type = map(string)
}

variable "dns_forwarding_ruleset_name" {
  description = "The name of the DNS forwarding ruleset"
  type        = string
}

# variable "forwarding_rules" {
#   description = "A map of forwarding rules to create"
#   type = map(object({
#     domain_name         = string
#     target_dns_servers  = list(object({
#       ip_address = string
#       port       = number
#     }))
#   }))
#   default = {}
# }
