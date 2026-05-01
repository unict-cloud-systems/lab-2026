terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "1.4.3"
    }
  }

  # State lives on the host runner — persists across pipeline runs
  backend "local" {
    path = "~/k8s-terraform.tfstate"
  }
}

provider "multipass" {}

# ── Render cloud-init with the local SSH public key ───────────────────────────

resource "local_file" "cloud_init" {
  filename = "${path.module}/cloud-init.rendered.yml"
  content = templatefile("${path.module}/cloud-init.tpl", {
    ssh_public_key = trimspace(file("${path.module}/id_ed25519.pub"))
  })
}

# ── Control-plane node(s) ─────────────────────────────────────────────────────

resource "multipass_instance" "control_plane" {
  count = var.control_plane_count

  name           = "control-plane-${count.index + 1}"
  image          = var.ubuntu_image
  cpus           = var.control_plane_cpus
  memory         = var.control_plane_memory
  disk           = var.control_plane_disk
  cloudinit_file = local_file.cloud_init.filename
  depends_on     = [local_file.cloud_init]
}

# ── Worker nodes ──────────────────────────────────────────────────────────────

resource "multipass_instance" "worker" {
  count = var.worker_count

  name           = "worker-${count.index + 1}"
  image          = var.ubuntu_image
  cpus           = var.worker_cpus
  memory         = var.worker_memory
  disk           = var.worker_disk
  cloudinit_file = local_file.cloud_init.filename
  depends_on     = [local_file.cloud_init]
}

# ── Generate Ansible inventory ─────────────────────────────────────────────────
# Written to ~ (home dir) so it persists between pipeline jobs on the same host

resource "local_file" "inventory" {
  filename = pathexpand("~/k8s-hosts.ini")

  content = templatefile("${path.module}/inventory.tpl", {
    control_plane_ips = [for cp in multipass_instance.control_plane : cp.ipv4]
    worker_ips        = [for w in multipass_instance.worker : w.ipv4]
    ssh_private_key   = var.ssh_private_key_path
  })
}
