provider "aws" {
  region  = "eu-west-3"
  profile = "finstack"
}

terraform {
  required_version = "~> 0.12.0"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "gregbkr"
    workspaces {
      name = "cardano-node-testnet"
    }
  }
}

# VARS
variable "tag" {
  default = "cardano-node-testnet"
}
variable "az" {
  default = "eu-west-3a"
}
variable "env" {
  default = "dev"
}

# Fist get the default VPC and subnet IDs
data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# EC2
resource "aws_instance" "instance" {
  #ami           = "ami-" # Ubuntu 20.04 (eu-west-1)
  ami               = "ami-078db6d55a16afc82" # Ubuntu 20.04 (eu-west-3)
  instance_type     = "t2.medium"
  availability_zone = var.az
  key_name          = "finstack-eu-west-3"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "60"
    encrypted             = "true"
    delete_on_termination = "true"
  }
  vpc_security_group_ids = [aws_security_group.firewall.id]
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  user_data_base64 = base64encode(<<EOF
#cloud-config
repo_update: true
repo_upgrade: all

packages:
 - git
 - unzip
 - nmap
 - docker.io
 - docker-compose

runcmd:
  - fallocate -l 16G /swapfile
  - chmod 600 /swapfile
  - mkswap /swapfile
  - swapon /swapfile
  - echo /swapfile none swap sw 0 0 >> /etc/fstab
  - swapon -s
  - docker version
  - docker-compose version
  - sudo lsblk
  - mkdir -p /sdh/cardano
EOF
  )
  tags = {
    Name          = var.tag
    "Patch Group" = var.env
  }
}

# EBS disk
resource "aws_ebs_volume" "ebs" {
  availability_zone = var.az
  size              = 50
  encrypted         = true
  tags = {
    Name = "${var.tag}-data"
    env  = var.env
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.instance.id
}

# Elastic IP which will not change if instance get recreated
resource "aws_eip" "eip" {
  instance = aws_instance.instance.id
  vpc      = true
}

# Firewall
resource "aws_security_group" "firewall" {
  name        = var.tag
  description = "Security Group"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Policy to let session manager access our instance
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 instance role
resource "aws_iam_role" "role" {
  name               = "${var.tag}-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      },
      {
         "Effect":"Allow",
         "Principal":{
            "Service":"ssm.amazonaws.com"
         },
         "Action":"sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.tag}-profile"
  role = aws_iam_role.role.name
}

# OUTPUTS
# output "default_vpc_id" {
#   value = "${data.aws_vpc.default.id}"
# }
# output "default_subnet_ids" {
#   value = ["${data.aws_subnet_ids.default.ids}"]
# }
output "instance_ip" {
  value = [aws_instance.instance.public_ip]
}
output "elastic_ip" {
  value = [aws_eip.eip.public_ip]
}
