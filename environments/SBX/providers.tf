provider "aws" {
  region = "us-east-1"
}

terraform {
backend "s3" {
  bucket  = "ziyotek-terraform-state-rady-host-1"
  key     = "ec2-examle/devops/terraform.tfstate"
  region  = "us-east-1"
  encrypt = true
  dynamodb_table = "terraform-lock"
}
}