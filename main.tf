terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
      configuration_aliases = [
        azurerm.connectivity
      ]
    }
  }
}


resource "azurerm_resource_group" "privdns_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.resource_tags
}

data "azurerm_virtual_network" "hub_vnet" {
  name                = var.virtual_network.name
  resource_group_name = var.virtual_network.resource_group_name
}

resource "azurerm_private_dns_zone" "pvt_zone" {
  for_each            = var.private_dns_zones
  name                = each.value.name
  resource_group_name = azurerm_resource_group.privdns_rg.name
  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "pvt_link" {
  for_each               = var.private_dns_zones
  name                   = "${each.value.name}-vnet-link"
  resource_group_name    = azurerm_resource_group.privdns_rg.name
  private_dns_zone_name  = azurerm_private_dns_zone.pvt_zone[each.key].name
  virtual_network_id     = data.azurerm_virtual_network.hub_vnet.id
  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_resolver" "pdr" {
  name                = var.private_dns_resolver_name
  resource_group_name = azurerm_resource_group.privdns_rg.name
  location            = azurerm_resource_group.privdns_rg.location
  virtual_network_id  = data.azurerm_virtual_network.hub_vnet.id
  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "ie" {
  name                    = "${var.private_dns_resolver_name}-inbound-endpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.pdr.id
  location                = azurerm_resource_group.privdns_rg.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = var.subnet_ids.inboundsubnet_id
  }
  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "oe" {
  name                    = "${var.private_dns_resolver_name}-outbound-endpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.pdr.id
  location                = azurerm_resource_group.privdns_rg.location
  subnet_id               = var.subnet_ids.outboundsubnet_id
  lifecycle {
    ignore_changes = [ tags ]
  }
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "frs" {
  name                                       = var.dns_forwarding_ruleset_name
  resource_group_name                        = azurerm_resource_group.privdns_rg.name
  location                                   = azurerm_resource_group.privdns_rg.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.oe.id]
  lifecycle {
    ignore_changes = [ tags ]
  }
}

# resource "azurerm_private_dns_resolver_forwarding_rule" "fr" {
#   for_each                  = var.forwarding_rules
#   name                      = "${var.dns_forwarding_ruleset_name}-${each.key}-rule"
#   dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.frs.id
#   domain_name               = each.value.domain_name
#   enabled                   = true

#   dynamic "target_dns_servers" {
#     for_each = each.value.target_dns_servers
#     content {
#       ip_address = target_dns_servers.value.ip_address
#       port       = target_dns_servers.value.port
#     }
#   }
# }

resource "azurerm_private_dns_resolver_virtual_network_link" "vnetlink" {
  name                      = "${var.private_dns_resolver_name}-vnet-link"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.frs.id
  virtual_network_id        = data.azurerm_virtual_network.hub_vnet.id
}
