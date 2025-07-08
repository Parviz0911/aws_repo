variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app1_instance_type" {
  description = "Instance type for app1"
  type        = string
  default     = "t3.micro"
}

variable "app2_instance_type" {
  description = "Instance type for app2"
  type        = string
  default     = "t3.micro"
}
