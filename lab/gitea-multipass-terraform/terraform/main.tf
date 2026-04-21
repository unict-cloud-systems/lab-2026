terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "1.4.3"
    }
  }
}

provider "multipass" {}

# ── Render cloud-init with the SSH public key injected by the pipeline ────────

resource "local_file" "cloud_init" {
  filename = pathexpand("~/cloud-init.rendered.yml")
  content  = templatefile("${path.module}/cloud-init.tpl", {
    ssh_public_key = trimspace(file("${path.module}/id_ed25519.pub"))
  })
}

# ── Manager node ──────────────────────────────────────────────────────────────

resource "multipass_instance" "manager" {
  name           = "manager"
  image          = var.ubuntu_image
  cpus           = var.manager_cpus
  memory         = var.manager_memory
  disk           = var.manager_disk
  cloudinit_file = abspath(local_file.cloud_init.filename)
  depends_on     = [local_file.cloud_init]
}

# ── Worker nodes ──────────────────────────────────────────────────────────────

resource "multipass_instance" "worker" {
  count = var.worker_count

  name           = "worker${count.index + 1}"
  image          = var.ubuntu_image
  cpus           = var.worker_cpus
  memory         = var.worker_memory
  disk           = var.worker_disk
  cloudinit_file = abspath(local_file.cloud_init.filename)
  depends_on     = [local_file.cloud_init]
}

# ── Generate Ansible inventory automatically ──────────────────────────────────

resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/hosts.ini"

  content = templatefile("${path.module}/inventory.tpl", {
    manager_ip      = multipass_instance.manager.ipv4
    worker_ips      = [for w in multipass_instance.worker : w.ipv4]
    ssh_private_key = var.ssh_private_key_path
  })
}
