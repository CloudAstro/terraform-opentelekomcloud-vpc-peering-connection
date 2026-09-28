<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
# OpenTelekomCloud VPC Peering Connection Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE)

This module connects two OTC VPCs in the same region. It supports an optional
peer-side accepter and one optional route in each direction.

# Features

- **Peering Management**: Creates a connection between requester and accepter VPCs.
- **Cross-Project Acceptance**: Optional accepter uses an explicitly mapped peer provider.
- **Reciprocal Routes**: Routes use the peering connection as next hop and wait for the managed accepter.
- **Input Validation**: Checks names, distinct VPC IDs, route type and destinations.
- **Timeout Control**: Supports requester connection create/delete timeouts.

# Setup Requirements

Configure the provider through supported environment variables, such as
`OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_DOMAIN_NAME`, `OS_PROJECT_NAME`
and `OS_REGION`. Both examples use the configured project and region, create
their own VPCs and have no required personal inputs or hard-coded project IDs.

Every caller must map `opentelekomcloud.peer`, even when acceptance and routes
are omitted. For same-project peering, map both provider names to the same
provider, as the examples show. Cross-project peering requires a separate
provider configured for the peer project and its project ID in `peer_tenant_id`.

# Example Usage

The [default example](examples/default/main.tf) creates two non-overlapping VPCs
and a peering connection. The [full example](examples/full/main.tf) also creates
reciprocal routes and sets connection timeouts. Neither needs explicit acceptance
because both VPCs belong to the same project:

```hcl
module "vpc_local" {
  source  = "CloudAstro/vpc/opentelekomcloud"
  version = "1.1.1"

  name = "peering-local-example"
  cidr = "10.10.0.0/16"
}

module "vpc_peer" {
  source  = "CloudAstro/vpc/opentelekomcloud"
  version = "1.1.1"

  name = "peering-peer-example"
  cidr = "172.16.0.0/16"
}

module "peering" {
  source = "../.."

  # Both VPCs belong to the same project in this generic example.
  providers = {
    opentelekomcloud      = opentelekomcloud
    opentelekomcloud.peer = opentelekomcloud
  }

  name        = "peering-example"
  vpc_id      = module.vpc_local.vpc_v1.id
  peer_vpc_id = module.vpc_peer.vpc_v1.id

  # Same-project peering does not need an explicit accepter.
  # Each destination is the CIDR of the VPC on the other side.
  vpc_route = {
    local = { destination = module.vpc_peer.vpc_v1.cidr }
    peer  = { destination = module.vpc_local.vpc_v1.cidr }
  }

  timeouts = {
    create = "10m"
    delete = "10m"
  }
}
```
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.0 |
| <a name="requirement_opentelekomcloud"></a> [opentelekomcloud](#requirement\_opentelekomcloud) | >= 1.36.35 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_opentelekomcloud"></a> [opentelekomcloud](#provider\_opentelekomcloud) | >= 1.36.35 |
| <a name="provider_opentelekomcloud.peer"></a> [opentelekomcloud.peer](#provider\_opentelekomcloud.peer) | >= 1.36.35 |

## Resources

| Name | Type |
|------|------|
| [opentelekomcloud_vpc_peering_connection_accepter_v2.vpc_peering_connection_accepter](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_peering_connection_accepter_v2) | resource |
| [opentelekomcloud_vpc_peering_connection_v2.vpc_peering_connection](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_peering_connection_v2) | resource |
| [opentelekomcloud_vpc_route_v2.vpc_route_local_vpc](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_route_v2) | resource |
| [opentelekomcloud_vpc_route_v2.vpc_route_peer_vpc](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_route_v2) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Peering connection name, containing 1 to 64 characters. | `string` | n/a | yes |
| <a name="input_peer_vpc_id"></a> [peer\_vpc\_id](#input\_peer\_vpc\_id) | Accepter VPC ID. Both VPCs must be in the same region. Changing it replaces the connection. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Requester VPC ID, managed through the default provider. Changing it replaces the connection. | `string` | n/a | yes |
| <a name="input_peer_tenant_id"></a> [peer\_tenant\_id](#input\_peer\_tenant\_id) | Optional accepter project ID for cross-project peering. This is a project ID, not a project name or account/domain ID. Omit for same-project peering. | `string` | `null` | no |
| <a name="input_peering_connection_accepter"></a> [peering\_connection\_accepter](#input\_peering\_connection\_accepter) | Optional peer-side accepter for cross-project peering. Set { accept = true } and<br/>map opentelekomcloud.peer to a provider authenticated for the accepter project.<br/>The connection ID is derived from the connection created by this module.<br/>Omit this object for same-project connections, which do not need acceptance.<br/>The default accept = false is retained for compatibility and does not approve a request. | <pre>object({<br/>    accept = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional connection creation/deletion timeouts, for example { create = "10m", delete = "10m" }. These apply to the requester connection only. | <pre>object({<br/>    create = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_vpc_route"></a> [vpc\_route](#input\_vpc\_route) | Optional routes, at most one per VPC. local.destination is the remote CIDR<br/>reachable from the requester VPC; peer.destination is the return destination<br/>reachable from the accepter VPC. Route type defaults to peering. Omit either side<br/>to manage that route elsewhere. This uses opentelekomcloud\_vpc\_route\_v2 and does<br/>not create or associate custom route tables.<br/><br/>Example:<pre>hcl<br/>vpc_route = {<br/>  local = { destination = "172.16.0.0/16" }<br/>  peer  = { destination = "10.10.0.0/16" }<br/>}</pre> | <pre>object({<br/>    type = optional(string, "peering")<br/>    local = optional(object({<br/>      destination = string<br/>    }))<br/>    peer = optional(object({<br/>      destination = string<br/>    }))<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_peering_connection"></a> [vpc\_peering\_connection](#output\_vpc\_peering\_connection) | All the argument attributes are also exported as result attributes:<br/>* `id` - The VPC peering connection ID.<br/>* `status` - The VPC peering connection status. The value can be `PENDING_ACCEPTANCE`, `REJECTED`, `EXPIRED`, `DELETED`, or `ACTIVE`.<br/><br/>Example output:<pre>output "name" {<br/>  value = module.peering.vpc_peering_connection.name<br/>}</pre> |
| <a name="output_vpc_peering_connection_v2"></a> [vpc\_peering\_connection\_v2](#output\_vpc\_peering\_connection\_v2) | Deprecated compatibility alias for consumers of the former peering module. Use `vpc_peering_connection` for new configurations. |

## Modules

No modules.

## 🌐 Additional Information

- The intended public module address is `CloudAstro/vpc-peering-connection/opentelekomcloud`, published from `terraform-opentelekomcloud-vpc-peering-connection`.
- Use `module.peering.vpc_peering_connection.id` for the connection ID. `vpc_peering_connection_v2` remains a compatibility output alias.
- The full example demonstrates all same-project operations. It does not create subnets, workloads or security rules, and does not test traffic.

## Cross-Project Peering

Configure two root provider instances in the same region: the requester provider
and an alias authenticated for the accepter project. In the module call:

```hcl
providers = {
  opentelekomcloud      = opentelekomcloud
  opentelekomcloud.peer = opentelekomcloud.peer
}
```

Set `peer_tenant_id` to the accepter project ID and
`peering_connection_accepter = { accept = true }` to manage acceptance. Peer-side
routes use that same peer provider. If the peer administrator manages acceptance
externally, leave the accepter unset and ensure acceptance is complete before
creating routes. The module cannot wait for acceptance that it does not manage.

## 📚 Resources

- [Terraform VPC Peering Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_peering_connection_v2)
- [Terraform VPC Route Resource](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/vpc_route_v2)
- [OpenTelekomCloud VPC Peering API](https://docs.otc.t-systems.com/virtual-private-cloud/api-ref/apis/vpc_peering_connection/index.html)
- [Contributing](CONTRIBUTING.md)

## ⚠️ Notes

- Both VPCs must be in the same region and use compatible, non-overlapping address ranges. Security groups and network ACLs must allow the required traffic.
- Leave `peering_connection_accepter` unset for same-project connections. Setting `accept = false` does not approve a cross-project request, even though an accepter resource exists.
- Routes wait for a configured accepter, and output dependencies also include it. The requester resource's reported `status` may reflect its preceding refresh; the output is not a live connectivity check.
- Do not manage the same route through this module and another route resource. This module exposes one route per side; manage additional routes separately. It does not select custom route tables or configure subnet associations.
- Removed `peer_tenant_name`, which was unused; select the peer project through its provider configuration instead. The unused `peering_connection_accepter.vpc_peering_connection_id` field was also removed because this module always accepts its own connection.
- Current resource addresses remain unchanged. Migration blocks for older resource names are omitted for the initial standalone publication. Consumers using those older names must plan an explicit state migration before upgrading.
- `timeouts` applies only to requester connection operations. Accepter and route resources retain their provider timeouts.
- Generate this README with `terraform-docs .`; edit `_header.md`, `_footer.md` and Terraform descriptions. The shared GitHub workflows assume a standalone repository root. Release Please reads the configured initial version `1.0.0`.
- This preparation does not publish a release or apply cloud infrastructure.

## 🧾 License

[Apache License 2.0](LICENSE), as declared in the existing module documentation.
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->