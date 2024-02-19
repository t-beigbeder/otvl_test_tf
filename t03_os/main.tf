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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDi9hMeHKwGxPD+XMyeGoXp6dPNv3i667uEJbjZ4GNfGM4IsF3UAp/xxCO4i+Ga08y9+RriGZYG/Nce1lsUaDVr3KzvMBmS2rXq+5WSoZsPgvJwRDnl0CvdhSMhNg9UjMAKwn/gmmRr1F400ddeH+FZZ+1aAzLTmzVWscfkmkNyiCfxG1TaKuzJUgxuXMQhAyI6lMPNvPglIGcaaVGxtAHTVNtvPRtmAYtzgUoqmwNIFCeXkWa1s2Ti7hyRICuis5v5w5ZSoMYNN+7uN2GdcnPAUbwpRsqnBXkM7bDv6xDClNVKHPhYGfDi64qG/oSCCswWyvJWNBfNyB1slLxuNPmfd4kJIv9A9eYHDNbXRSGPJwkllx6Dn2n5An5ASaP5TaDNzo7g+LTIX+jqhUS3wpNy2JMX5QnCZvam4nrpW/CLbfiit/VQEZyzMQkWWjHDDipaShQo3QotI0TCQduV+NAyJOdTat7lhZS4TTvYMyyB20DqXUy3SkpXO7e/DPsBzVRlibOf/THT4PzwSBJ+qqWbIqRIGw43WQphPCuIjDImcHKevaEsJ/AKRMeSAFYTzQEjsWqHoXldDNl5z9YhYHf0Tb55XannI23n3XUk0V0u4a7mSVRBPIfF9IS+FN1rIGBCySmOWT2bLbNEjboSVnRCbOZN9vd6yF1R/bS9FSZf/Q=="
}

data "openstack_networking_network_v2" "ext_net" {
  name = "Ext-Net"
}

resource "openstack_networking_network_v2" "otvl_net" {
  name           = "otvl-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "otvl_sn" {
  network_id = openstack_networking_network_v2.otvl_net.id
  name = "otvl-sn"
  cidr       = "172.23.0.0/28"
}

resource "openstack_compute_instance_v2" "t02_bastion" {
  name        = "t02_bastion"
  provider    = openstack.ovh
  image_name  = "Debian 12"
  flavor_name = "d2-2"
  key_pair    = openstack_compute_keypair_v2.test_keypair.name
  network {
    uuid = data.openstack_networking_network_v2.ext_net.id
  }
  network {
    uuid = openstack_networking_network_v2.otvl_net.id
    fixed_ip_v4 = "172.23.0.4"
  }
}

resource "openstack_compute_instance_v2" "t02_k3s_1" {
  name        = "t02_k3s_1"
  provider    = openstack.ovh
  image_name  = "Debian 12"
  flavor_name = "d2-2"
  key_pair    = openstack_compute_keypair_v2.test_keypair.name
  network {
    uuid = data.openstack_networking_network_v2.ext_net.id
  }
  network {
    uuid = openstack_networking_network_v2.otvl_net.id
    fixed_ip_v4 = "172.23.0.5"
  }
}
