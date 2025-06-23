provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for the subnets."
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]

}

resource "aws_subnet" "example" {
  count  = length(var.subnet_cidr_blocks)
  vpc_id = aws_vpc.main.id

  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = "eu-west-1a"

}

output "first_id" {
  value       = aws_subnet.example[0].id
  description = "The ID for the first subnet."
}

output "all_ids" {
  value       = aws_subnet.example[*].id
  description = "The ID's for all subnets."
}
