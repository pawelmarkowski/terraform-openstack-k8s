variable "master_nodes" {
  type = object({
    prefix          = string
    quantity        = number
    flavor_id       = string
    image_id        = string
    api_access_cidr = string
    default_dns_ttl = number
    network         = any
    subnet          = any
  })
}

variable "worker_nodes" {
  type = object({
    prefix    = string
    quantity  = number
    flavor_id = string
    image_id  = string
    network   = any
    subnet    = any
  })
}

variable "key_pair" {
  type = string
}

variable "fip_pool_name" {
  type = string
}

variable "dns_zone" {
  # openstack_dns_zone_v2
}

variable "trusted_public_cidr" {
  type    = string
  default = ""
}

variable "jumphost_flavor_id" {
  type    = string
  default = ""
}
