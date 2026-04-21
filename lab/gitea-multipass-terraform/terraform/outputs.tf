output "manager_ip" {
  description = "IP address of the manager node"
  value       = multipass_instance.manager.ipv4
}

output "worker_ips" {
  description = "IP addresses of the worker nodes"
  value       = [for w in multipass_instance.worker : w.ipv4]
}

output "next_steps" {
  description = "Commands to run after apply"
  value = {
    install_docker = "ansible-playbook -i ansible/hosts.ini ansible/install_docker.yml"
    list_vms       = "multipass list"
    destroy_vms    = "tofu -chdir=terraform destroy"
  }
}
