# Protocol	Direction	Port Range	Purpose	Used By

# ALL NODES

resource "openstack_compute_secgroup_v2" "k8s_master_nodes" {
  name        = "k8s_allow_ssh_icmp"
  description = "k8s_allow_ssh_icmp"

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = var.master_nodes["subnet"].cidr
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = var.worker_nodes["subnet"].cidr
  }
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }
}


# MASTER NODES
resource "openstack_compute_secgroup_v2" "k8s_master_nodes" {
  name        = "k8s_master_nodes"
  description = "k8s_master_nodes"

  rule {
    from_port   = 2379
    to_port     = 2380
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }
  rule {
    from_port   = 6443
    to_port     = 6443
    ip_protocol = "tcp"
    cidr        = var.master_nodes["api_access_cidr"]
  }
  rule {
    from_port   = 6443
    to_port     = 6443
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }

  rule {
    from_port   = 6443
    to_port     = 6443
    ip_protocol = "tcp"
    cidr        = var.worker_nodes["subnet"].cidr
  }
  rule {
    from_port   = 10250
    to_port     = 10250
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }
  rule {
    from_port   = 10257
    to_port     = 10257
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }
  rule {
    from_port   = 10259
    to_port     = 10259
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }
}
resource "openstack_compute_secgroup_v2" "k8s_worker_nodes" {
  name        = "k8s_worker_nodes"
  description = "k8s_worker_nodes"
  rule {
    from_port   = 10250
    to_port     = 10250
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }
  rule {
    from_port   = 10250
    to_port     = 10250
    ip_protocol = "tcp"
    cidr        = var.worker_nodes["subnet"].cidr
  }
  rule {
    from_port   = 30000
    to_port     = 32767
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }
  rule {
    from_port   = 30000
    to_port     = 32767
    ip_protocol = "tcp"
    cidr        = var.worker_nodes["subnet"].cidr
  }
}

resource "openstack_compute_secgroup_v2" "k8s_cillium_master_nodes" {
  name        = "k8s_cillium_master_nodes"
  description = "https://docs.cilium.io/en/v1.9/operations/system_requirements/"

  rule {
    from_port   = 2379
    to_port     = 2380
    ip_protocol = "tcp"
    cidr        = var.worker_nodes["subnet"].cidr
  }
  rule {
    from_port   = 4240
    to_port     = 4240
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }
  rule {
    from_port   = 4240
    to_port     = 4240
    ip_protocol = "tcp"
    cidr        = var.worker_nodes["subnet"].cidr
  }
  rule {
    from_port   = 8472
    to_port     = 8472
    ip_protocol = "udp"
    cidr        = var.worker_nodes["subnet"].cidr
  }
  rule {
    from_port   = 8472
    to_port     = 8472
    ip_protocol = "udp"
    cidr        = var.master_nodes["subnet"].cidr
  }
}

resource "openstack_compute_secgroup_v2" "k8s_cillium_worker_nodes" {
  name        = "k8s_cillium_worker_nodes"
  description = "https://docs.cilium.io/en/v1.9/operations/system_requirements/"
  rule {
    from_port   = 4240
    to_port     = 4240
    ip_protocol = "tcp"
    cidr        = var.master_nodes["subnet"].cidr
  }
  rule {
    from_port   = 4240
    to_port     = 4240
    ip_protocol = "tcp"
    cidr        = var.worker_nodes["subnet"].cidr
  }
  rule {
    from_port   = 8472
    to_port     = 8472
    ip_protocol = "udp"
    cidr        = var.worker_nodes["subnet"].cidr
  }
  rule {
    from_port   = 8472
    to_port     = 8472
    ip_protocol = "udp"
    cidr        = var.master_nodes["subnet"].cidr
  }
}
