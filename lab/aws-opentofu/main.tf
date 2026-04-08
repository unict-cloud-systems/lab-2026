# Look up the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-*"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "lab-ssh-sg"
  description = "Allow SSH inbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "manager" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type   # "t2.micro" (Free Tier)
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "lab-cloud-systems-2026"
  }
}