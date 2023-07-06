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

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
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
  source = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
}

# volumes to attach to the "workers" domains as main disk
resource "libvirt_volume" "worker" {
  name           = "worker_${count.index}.qcow2"
  base_volume_id = libvirt_volume.debian.id
  count          = var.workers_count
}

resource "libvirt_domain" "workers" {
    name = "worker_${count.index}"
    autostart = true
    cloudinit = libvirt_cloudinit_disk.commoninit.id
    memory = "512"
    vcpu = 1
    console {
      type        = "pty"
      target_port = "0"
      target_type = "serial"
      source_path = "/dev/pts/4"
    }
    disk {
        volume_id = element(libvirt_volume.worker[*].id, count.index)   
    }
    network_interface {
        network_id     = libvirt_network.k8s_network.id
        hostname       = "main"
        wait_for_lease = true
    }

    count = var.workers_count
}
