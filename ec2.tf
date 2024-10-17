resource "aws_instance" "web" {
  ami                    = "ami-08ec94f928cf25a9d"
  instance_type          = "t3.micro"
  #key_name               = "react-ec2-key"
  vpc_security_group_ids = [aws_security_group.security_group_react.id]
  subnet_id              = "subnet-0852ebafdcca26e65"

  tags = {
    Name = "react-app-ec2"
  }
}
