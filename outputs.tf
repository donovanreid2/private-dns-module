output "resource_group_name" {
  value = azurerm_resource_group.privdns_rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.privdns_rg.location
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.hub_vnet.id
}

output "private_dns_zone_names" {
  value = [for zone in azurerm_private_dns_zone.pvt_zone : zone.name]
}

output "private_dns_zone_virtual_network_link_names" {
  value = [for link in azurerm_private_dns_zone_virtual_network_link.pvt_link : link.name]
}

output "private_dns_resolver_id" {
  value = azurerm_private_dns_resolver.pdr.id
}

output "private_dns_resolver_inbound_endpoint_id" {
  value = azurerm_private_dns_resolver_inbound_endpoint.ie.id
}

output "private_dns_resolver_outbound_endpoint_id" {
  value = azurerm_private_dns_resolver_outbound_endpoint.oe.id
}

output "dns_forwarding_ruleset_id" {
  value = azurerm_private_dns_resolver_dns_forwarding_ruleset.frs.id
}

output "private_dns_resolver_virtual_network_link_name" {
  value = azurerm_private_dns_resolver_virtual_network_link.vnetlink.name
}
