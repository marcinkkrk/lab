variable "vpcs" {
  description = "A list of VPCs."
  default     = ["main", "database"]
}

output "new_vpcs" {
  value = [for vpc in var.vpcs : title(vpc)]
}

// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

variable "my_vpcs" {
  default = {
    main     = "main_vpc"
    detabase = "database_vpc"
  }
}

output "my_vpcs" {
  value = [for name, desc in var.my_vpcs : "${name} is the ${desc}"]
}
