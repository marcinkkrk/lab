// BETTER SOLUTION, now we cen remove "10.0.32.0/19" and everything will be fine

variable "subnet_cidr_blocks2" {
  description = "value"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example" {
  for_each = toset(var.subnet_cidr_blocks2)
  vpc_id   = aws_vpc.main.id

  cidr_block        = each.value
  availability_zone = "eu-west-1"
}

output "aws_subnets" {
  value = aws_subnet.example
}

output "all_ids" {
  value = values(aws_subnet.example)[*].id
}

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

variable "custom_ports" {
  description = "Custom ports to open on the security group."
  type        = map(any)

  default = {
    80   = ["0.0.0.0/0"]
    8081 = ["10.0.0.0/16"]
  }
}

resource "aws_security_group" "web" {
  name   = "allow-web-access"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.custom_ports

    content {
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value
    }
  }
}

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

locals {
  web_servers = {
    nginx-0 = {
      instance_type     = "t2.micro"
      availability_zone = "eu-west-1a"
    }
    nginx-1 = {
      instance_type     = "t2.micro"
      availability_zone = "eu-west-1b"
    }
  }
}

resource "aws_instance" "web" {
  for_each = local.web_servers

  ami               = "ami-01f23391a59163da9"
  instance_type     = each.value.instance_type
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.key
  }
}
