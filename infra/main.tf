terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "k8s_network" {
    name = "k8s_network"
    mode = "nat"
    domain = "k8s.local"
    addresses = ["10.17.3.0/24", "2001:db8:ca2:2::1/64"]
    dns {
        enabled = true
        local_only = true
    }
    dhcp {
        enabled = true
    }
}

resource "libvirt_volume" "debian" {
  name   = "debian"
  source = "https://cloud.debian.org/images/cloud/bullseye/20210814-734/debian-11-nocloud-amd64-20210814-734.qcow2"
}

# volumes to attach to the "workers" domains as main disk
resource "libvirt_volume" "worker" {
  name           = "worker_${count.index}.qcow2"
  base_volume_id = libvirt_volume.debian.id
  count          = var.workers_count
}

resource "libvirt_domain" "workers" {
    name = "worker_${count.index}"
    memory = "512"
    vcpu = 1
    network_interface {
        network_id     = libvirt_network.k8s_network.id
        hostname       = "main"
        wait_for_lease = true
    }
    disk {
        volume_id = element(libvirt_volume.worker[*].id, count.index)   
    }
    count = var.workers_count
}
