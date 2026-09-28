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
