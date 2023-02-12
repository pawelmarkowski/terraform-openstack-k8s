# terraform-openstack-k8s

how to use module?

add source in module:

```bash
module "k8s" {
  source = "git@github.com:pawelmarkowski/terraform-openstack-k8s.git"
  master_nodes = {
    prefix          = "master-node"
    quantity        = var.master_nodes_qty
    flavor_id       = data.openstack_compute_flavor_v2.master_node_flavor.id
    image_id        = data.openstack_images_image_v2.ubuntu.id
    api_access_cidr = var.api_access_cidr
    default_dns_ttl = 180
    network         = resource.openstack_networking_network_v2.master_nodes_net
    subnet          = resource.openstack_networking_subnet_v2.master_nodes_sub
  }

  worker_nodes = {
    prefix    = "worker-node"
    quantity  = var.worker_nodes_qty
    flavor_id = data.openstack_compute_flavor_v2.worker_node_flavor.id
    image_id  = data.openstack_images_image_v2.ubuntu.id
    network   = resource.openstack_networking_network_v2.worker_nodes_net
    subnet    = resource.openstack_networking_subnet_v2.worker_nodes_sub
  }
  fip_pool_name = var.fip_pool_name
  dns_zone = resource.openstack_dns_zone_v2.dns_zone
  key_pair = var.key_pair
}
```
