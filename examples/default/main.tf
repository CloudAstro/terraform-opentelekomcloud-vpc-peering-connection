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
}
