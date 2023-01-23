resource "openstack_compute_servergroup_v2" "master_nodes_sg" {
  name     = "${var.master_nodes["prefix"]}s-sg"
  policies = ["anti-affinity"]
}

resource "openstack_compute_servergroup_v2" "worker_nodes_sg" {
  name     = "${var.worker_nodes["prefix"]}s-sg"
  policies = ["anti-affinity"]
}

resource "openstack_compute_instance_v2" "master_nodes" {
  count     = var.master_nodes["quantity"]
  name      = "${var.master_nodes["prefix"]}-${count.index}"
  image_id  = var.master_nodes["image_id"]
  flavor_id = var.master_nodes["flavor_id"]
  key_pair  = var.key_pair
  security_groups = [
    openstack_compute_secgroup_v2.k8s_all_nodes.id,
    openstack_compute_secgroup_v2.k8s_master_nodes.id,
    openstack_compute_secgroup_v2.k8s_cillium_master_nodes.id
  ]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.master_nodes_sg.id
  }

  network {
    name = var.master_nodes["network"].name
  }
  depends_on = [openstack_compute_servergroup_v2.master_nodes_sg]
}

resource "openstack_compute_instance_v2" "worker_nodes" {
  count     = var.worker_nodes["quantity"]
  name      = "${var.worker_nodes["prefix"]}-${count.index}"
  image_id  = var.worker_nodes["image_id"]
  flavor_id = var.worker_nodes["flavor_id"]
  key_pair  = var.key_pair
  security_groups = [
    openstack_compute_secgroup_v2.k8s_all_nodes.id,
    openstack_compute_secgroup_v2.k8s_master_nodes.id,
    openstack_compute_secgroup_v2.k8s_cillium_master_nodes.id
  ]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.worker_nodes_sg.id
  }

  network {
    name = var.worker_nodes["network"].name
  }
  depends_on = [openstack_compute_servergroup_v2.worker_nodes_sg]
}

resource "openstack_lb_loadbalancer_v2" "master_nodes_lb" {
  name          = "${var.master_nodes["prefix"]}s-lb"
  vip_subnet_id = var.master_nodes["subnet"].id
}

resource "openstack_lb_listener_v2" "listener_tcp" {
  protocol        = "TCP"
  protocol_port   = "6443"
  loadbalancer_id = openstack_lb_loadbalancer_v2.master_nodes_lb.id

  # insert_headers = {
  #   X-Forwarded-For = "true"
  # }
}

resource "openstack_lb_pool_v2" "pool_proxy" {
  protocol    = "HTTPS"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.listener_tcp.id

  persistence {
    type = "SOURCE_IP"
  }
}

resource "openstack_lb_member_v2" "master_nodes_lb_https_members" {
  count         = var.master_nodes["quantity"]
  pool_id       = openstack_lb_pool_v2.pool_proxy.id
  address       = openstack_compute_instance_v2.master_nodes[count.index].network[0].fixed_ip_v4
  protocol_port = "6443"
}

resource "openstack_lb_monitor_v2" "monitor_https_lb" {
  pool_id          = openstack_lb_pool_v2.pool_proxy.id
  type             = "HTTPS"
  url_path         = "/healthz"
  expected_codes   = "200"
  delay            = 10
  timeout          = 5
  max_retries      = 2
  max_retries_down = 2
}

resource "openstack_networking_floatingip_v2" "master_nodes_lb_floating_ip" {
  pool    = var.pool_name
  port_id = openstack_lb_loadbalancer_v2.master_nodes_lb.vip_port_id
}

resource "openstack_dns_recordset_v2" "master_nodes_domain" {
  count   = length(var.dns_zone) == 0 ? 0 : 1
  zone_id = var.dns_zone.id
  name    = "api.${var.dns_zone.name}"
  ttl     = var.master_nodes["default_dns_ttl"]
  type    = "A"
  records = [openstack_networking_floatingip_v2.master_nodes_lb_floating_ip.address]
}
