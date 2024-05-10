locals {
  azs = slice(data.aws_availability_zones.azs_info.names, 0, 2)
}