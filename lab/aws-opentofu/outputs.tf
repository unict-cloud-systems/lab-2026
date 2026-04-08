output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.manager.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i labsuser.pem ubuntu@${aws_instance.manager.public_ip}"
}

output "aws_cli_describe" {
  description = "AWS CLI command to describe running instances"
  value       = "aws ec2 describe-instances --filters Name=tag:Name,Values=lab-cloud-systems-2026 --query 'Reservations[*].Instances[*].{ID:InstanceId,State:State.Name,IP:PublicIpAddress}' --output table"
}
