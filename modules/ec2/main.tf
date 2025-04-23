resource "aws_instance" "ubuntu" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "${var.env}-ec2"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.env}-ec2-sg"
  description = "Allow SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
