variable "vpc_cidr" {
  type        = "string"
  default     = "173.19.0.0/16"
  description = "CIDR valu for VPC"
}

variable "ec2_ami" {
  default = "ami-f2d3638a"
}

# Gets all the AZs based on current region
data "aws_availability_zones" "azs" {}

# Declare CIDR blocks for all subnets
variable "subets_cidr" {
  default = ["173.19.1.0/24", "173.19.2.0/24", "173.19.3.0/24", "173.19.5.0/24"]
}
