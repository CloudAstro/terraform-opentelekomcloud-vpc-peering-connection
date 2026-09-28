output "vpc_peering_connection" {
  depends_on  = [opentelekomcloud_vpc_peering_connection_accepter_v2.vpc_peering_connection_accepter]
  value       = opentelekomcloud_vpc_peering_connection_v2.vpc_peering_connection
  description = <<DESCRIPTION
All the argument attributes are also exported as result attributes:
* `id` - The VPC peering connection ID.
* `status` - The VPC peering connection status. The value can be `PENDING_ACCEPTANCE`, `REJECTED`, `EXPIRED`, `DELETED`, or `ACTIVE`.

Example output:
```
output "name" {
  value = module.peering.vpc_peering_connection.name
}
```
DESCRIPTION
}

output "vpc_peering_connection_v2" {
  depends_on  = [opentelekomcloud_vpc_peering_connection_accepter_v2.vpc_peering_connection_accepter]
  value       = opentelekomcloud_vpc_peering_connection_v2.vpc_peering_connection
  description = "Deprecated compatibility alias for consumers of the former peering module. Use `vpc_peering_connection` for new configurations."
}
