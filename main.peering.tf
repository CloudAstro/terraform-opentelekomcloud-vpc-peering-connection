resource "opentelekomcloud_vpc_peering_connection_v2" "vpc_peering_connection" {
  name           = var.name
  peer_tenant_id = var.peer_tenant_id
  peer_vpc_id    = var.peer_vpc_id
  vpc_id         = var.vpc_id

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }
}

resource "opentelekomcloud_vpc_peering_connection_accepter_v2" "vpc_peering_connection_accepter" {
  for_each = var.peering_connection_accepter != null ? { "this" = var.peering_connection_accepter } : {}

  provider                  = opentelekomcloud.peer
  vpc_peering_connection_id = opentelekomcloud_vpc_peering_connection_v2.vpc_peering_connection.id
  accept                    = each.value.accept
}

resource "opentelekomcloud_vpc_route_v2" "vpc_route_local_vpc" {
  for_each = try(var.vpc_route.local, null) != null ? { "this" = var.vpc_route } : {}

  type        = each.value.type
  nexthop     = opentelekomcloud_vpc_peering_connection_v2.vpc_peering_connection.id
  destination = each.value.local.destination
  vpc_id      = var.vpc_id

  depends_on = [opentelekomcloud_vpc_peering_connection_accepter_v2.vpc_peering_connection_accepter]
}

resource "opentelekomcloud_vpc_route_v2" "vpc_route_peer_vpc" {
  for_each = try(var.vpc_route.peer, null) != null ? { "this" = var.vpc_route } : {}

  provider    = opentelekomcloud.peer
  type        = each.value.type
  nexthop     = opentelekomcloud_vpc_peering_connection_v2.vpc_peering_connection.id
  destination = each.value.peer.destination
  vpc_id      = var.peer_vpc_id

  depends_on = [opentelekomcloud_vpc_peering_connection_accepter_v2.vpc_peering_connection_accepter]
}
