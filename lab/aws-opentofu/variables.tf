variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"  # Free Tier eligible
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH"
  type        = string
  default     = "vockey"
}