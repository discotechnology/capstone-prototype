locals {
  cloud_image_name_k8s    = "noble-server-cloudimg-amd64-k8s.qcow2"
  cloud_image_name_client = "noble-server-cloudimg-amd64-client.qcow2"
}

resource "proxmox_download_file" "ubuntu_cloud_image_k8s" {
  content_type = "import"
  datastore_id = var.image_datastore
  node_name    = var.proxmox_node_k8s
  url          = var.ubuntu_cloud_image_url
  file_name    = local.cloud_image_name_k8s
  overwrite    = false
}

resource "proxmox_download_file" "ubuntu_cloud_image_client" {
  content_type = "import"
  datastore_id = var.image_datastore
  node_name    = var.proxmox_node_client
  url          = var.ubuntu_cloud_image_url
  file_name    = local.cloud_image_name_client
  overwrite    = false
}

resource "proxmox_virtual_environment_vm" "k8s_control_plane" {
  name            = "flying-nimbus-k8s-control"
  vm_id           = var.control_plane_vm_id
  node_name       = var.proxmox_node_k8s
  started         = true
  on_boot         = true
  stop_on_destroy = true

  agent {
    enabled = false
  }

  cpu {
    type    = "host"
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.vm_datastore
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image_k8s.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 32
  }

  network_device {
    bridge = var.proxmox_bridge
    model  = "virtio"
  }

  initialization {
    datastore_id = var.cloud_init_datastore

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = "${var.control_plane_ip}/${var.network_prefix_length}"
        gateway = var.gateway_ip
      }
    }

    user_account {
      username = var.vm_username
      keys     = [trimspace(var.ssh_public_key)]
    }
  }
}

resource "proxmox_virtual_environment_vm" "k8s_worker" {
  name            = "flying-nimbus-k8s-worker"
  vm_id           = var.worker_vm_id
  node_name       = var.proxmox_node_k8s
  started         = true
  on_boot         = true
  stop_on_destroy = true

  agent {
    enabled = false
  }

  cpu {
    type    = "host"
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = var.vm_datastore
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image_k8s.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 32
  }

  network_device {
    bridge = var.proxmox_bridge
    model  = "virtio"
  }

  initialization {
    datastore_id = var.cloud_init_datastore

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = "${var.worker_ip}/${var.network_prefix_length}"
        gateway = var.gateway_ip
      }
    }

    user_account {
      username = var.vm_username
      keys     = [trimspace(var.ssh_public_key)]
    }
  }
}

resource "proxmox_virtual_environment_vm" "client" {
  name            = "flying-nimbus-client"
  vm_id           = var.client_vm_id
  node_name       = var.proxmox_node_client
  started         = true
  on_boot         = true
  stop_on_destroy = true

  agent {
    enabled = false
  }

  cpu {
    type    = "host"
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = var.vm_datastore
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image_client.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = var.proxmox_bridge
    model  = "virtio"
  }

  initialization {
    datastore_id = var.cloud_init_datastore

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = "${var.client_ip}/${var.network_prefix_length}"
        gateway = var.gateway_ip
      }
    }

    user_account {
      username = var.vm_username
      keys     = [trimspace(var.ssh_public_key)]
    }
  }
}
