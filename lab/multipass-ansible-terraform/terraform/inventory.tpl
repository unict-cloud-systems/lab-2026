[managers]
manager ansible_host=${manager_ip} ansible_user=ubuntu

[workers]
%{ for i, ip in worker_ips ~}
worker${i + 1} ansible_host=${ip} ansible_user=ubuntu
%{ endfor ~}

[swarm:children]
managers
workers

[all:vars]
ansible_ssh_private_key_file=${ssh_private_key}
ansible_ssh_common_args=-o StrictHostKeyChecking=no
