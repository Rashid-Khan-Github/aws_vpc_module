# Forcing user to provide the value
variable "cidr_block" {
  
}

variable "enable_dns_hostnames" {
  default = true
}
variable "enable_dns_support" {
  default = true
}

# even optional, but good practice to give tags always
variable "common_tags" {
  default = {}
}

variable "vpc_tags" {
  default = {}
}

variable "project_name" {
  
}

variable "igw_tags" {
  default = {}
}

variable "nat_gw_tags" {
  default = {}
}

variable "public_subnet_cidr" {
  type = list
  validation {
    condition = length(var.public_subnet_cidr) == 2
    error_message = "SizeError : Subnets CIDR size must be 2..!"
  }
}

variable "private_subnet_cidr" {
  type = list
  validation {
    condition = length(var.private_subnet_cidr) == 2
    error_message = "SizeError : Subnets CIDR size must be 2..!"
  }
}

variable "database_subnet_cidr" {
  type = list
  validation {
    condition = length(var.database_subnet_cidr) == 2
    error_message = "SizeError : Subnets CIDR size must be 2..!"
  }
}