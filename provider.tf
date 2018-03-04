# Choos the provider, here its AWS

provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "javahome-tfstate"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}
