data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]
  

  filter {
    name   = "custom-ami"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
