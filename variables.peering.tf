variable "name" {
  type        = string
  nullable    = false
  description = "Peering connection name, containing 1 to 64 characters."

  validation {
    condition     = length(trimspace(var.name)) > 0 && length(var.name) <= 64
    error_message = "name must contain 1 to 64 characters and must not be blank."
  }
}

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "Requester VPC ID, managed through the default provider. Changing it replaces the connection."

  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "peer_vpc_id" {
  type        = string
  nullable    = false
  description = "Accepter VPC ID. Both VPCs must be in the same region. Changing it replaces the connection."

  validation {
    condition     = length(trimspace(var.peer_vpc_id)) > 0 && var.peer_vpc_id != var.vpc_id
    error_message = "peer_vpc_id must be non-empty and different from vpc_id."
  }
}

variable "peer_tenant_id" {
  type        = string
  default     = null
  description = "Optional accepter project ID for cross-project peering. This is a project ID, not a project name or account/domain ID. Omit for same-project peering."

  validation {
    condition     = var.peer_tenant_id == null ? true : length(trimspace(var.peer_tenant_id)) > 0
    error_message = "peer_tenant_id must be null or a non-empty project ID."
  }
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Optional connection creation/deletion timeouts, for example { create = \"10m\", delete = \"10m\" }. These apply to the requester connection only."
}

variable "peering_connection_accepter" {
  type = object({
    accept = optional(bool, false)
  })
  default     = null
  description = <<DESCRIPTION
Optional peer-side accepter for cross-project peering. Set { accept = true } and
map opentelekomcloud.peer to a provider authenticated for the accepter project.
The connection ID is derived from the connection created by this module.
Omit this object for same-project connections, which do not need acceptance.
The default accept = false is retained for compatibility and does not approve a request.
DESCRIPTION
}

variable "vpc_route" {
  type = object({
    type = optional(string, "peering")
    local = optional(object({
      destination = string
    }))
    peer = optional(object({
      destination = string
    }))
  })
  default     = null
  description = <<DESCRIPTION
Optional routes, at most one per VPC. local.destination is the remote CIDR
reachable from the requester VPC; peer.destination is the return destination
reachable from the accepter VPC. Route type defaults to peering. Omit either side
to manage that route elsewhere. This uses opentelekomcloud_vpc_route_v2 and does
not create or associate custom route tables.

Example:
```hcl
vpc_route = {
  local = { destination = "172.16.0.0/16" }
  peer  = { destination = "10.10.0.0/16" }
}
```
DESCRIPTION

  validation {
    condition     = var.vpc_route == null ? true : var.vpc_route.type == "peering"
    error_message = "vpc_route.type must be peering."
  }

  validation {
    condition = var.vpc_route == null ? true : alltrue([
      for side in [var.vpc_route.local, var.vpc_route.peer] : side == null ? true : (
        can(cidrhost(side.destination, 0))
      )
    ])
    error_message = "Route destinations must be valid CIDR blocks; use /32 for a single IPv4 address or /128 for a single IPv6 address."
  }
}
