provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "build_key" {
  key_name   = "miniageos-build-key"
  public_key = file("~/.ssh/id_rsa.pub") # your local SSH public key path
}

resource "aws_security_group" "build_sg" {
  name        = "miniageos-build-sg"
  description = "Allow SSH inbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_HERE/32"]  # restrict SSH to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "build_instance" {
  ami           = "ami-0c2b8ca1dad447f8a"  # Amazon Linux 2 (update to your region's preferred build AMI)
  instance_type = "c5.4xlarge" # go for 32gb ram
  key_name      = aws_key_pair.build_key.key_name
  security_groups = [aws_security_group.build_sg.name]

  root_block_device {
    volume_size           = 350   # 350GB SSD
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "miniageos-build"
  }
}
