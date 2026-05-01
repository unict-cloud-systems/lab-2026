output "control_plane_ips" {
  description = "IP addresses of the control-plane node(s)"
  value       = join(" ", [for cp in multipass_instance.control_plane : cp.ipv4])
}

output "worker_ips" {
  description = "IP addresses of the worker nodes"
  value       = [for w in multipass_instance.worker : w.ipv4]
}

output "next_steps" {
  description = "Ansible commands to run after apply"
  value = {
    prerequisites   = "ansible-playbook -i terraform/hosts.ini ansible/00-prerequisites.yml"
    control_plane   = "ansible-playbook -i terraform/hosts.ini ansible/01-control-plane.yml"
    workers         = "ansible-playbook -i terraform/hosts.ini ansible/02-workers.yml"
    destroy_vms     = "tofu destroy"
  }
}
