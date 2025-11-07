variable "MY_IP" {
  description = "Your public IP address for SSH access"
  type        = string
  # Default value will be set by the local data source below
  # Remove the default here and use the local data block below
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "c6a.4xlarge" # Big for building

  root_block_device {
    volume_size = 400 # 400GB storage
    volume_type = "gp3" # fast SSD type
    delete_on_termination = true # it will be saved somewhere else before tearing down
  }

  tags = {
    Name = "build-mini"
  }
}

resource "aws_security_group" "build_mini_sg" {
  name        = "miniageos-sg"
  description = "Allow SSH inbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${MY_IP}/32"]  # restrict SSH to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}