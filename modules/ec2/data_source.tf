data "aws_ami" "example" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.4.20240528.0-kernel-6.1-x86_64"] #amzn2-ami-hvm-2.0.20211001.1-x86_64-*"]
  }
}
