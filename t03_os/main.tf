provider "openstack" {
  alias       = "ovh"
}

terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.42.0"
    }
  }
}

resource "openstack_compute_keypair_v2" "test_keypair" {
  provider   = openstack.ovh
  name       = "t02_ssh"
  public_key = file("~/.ssh/id_rsa_4k.pub")
}

resource "openstack_networking_network_v2" "network_1" {
  name           = "tf_test_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  network_id = openstack_networking_network_v2.network_1.id
  name = "tf_test_network_sn"
  cidr       = "192.168.199.0/24"
}

#data "openstack_networking_network_v2" "ext_network" {
#  name = "Ext-Net"
#}
#
#data "openstack_networking_subnet_ids_v2" "ext_subnets" {
#  network_id = data.openstack_networking_network_v2.ext_network.id
#}
#
#resource "openstack_networking_floatingip_v2" "t02_floatip" {
#  pool       = data.openstack_networking_network_v2.ext_network.name
#  subnet_ids = data.openstack_networking_subnet_ids_v2.ext_subnets.ids
#}

data "openstack_networking_floatingip_v2" "t02_floatip" {
  address = "152.228.213.231"
}

resource "openstack_compute_instance_v2" "t02_instance" {
  name        = "t02_instance"
  provider    = openstack.ovh
  image_name  = "Debian 12"
  flavor_name = "d2-2"
  key_pair    = openstack_compute_keypair_v2.test_keypair.name
  network {
    name      = "tf_test_network"
  }
}

resource "openstack_compute_floatingip_associate_v2" "t02_instance_float_ip" {
  floating_ip = data.openstack_networking_floatingip_v2.t02_floatip.address
  instance_id = openstack_compute_instance_v2.t02_instance.id
  fixed_ip    = openstack_compute_instance_v2.t02_instance.network.0.fixed_ip_v4
}
