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
