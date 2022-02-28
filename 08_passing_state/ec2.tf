resource "aws_instance" "app_instance" {
  depends_on                  = [aws_security_group.instance]
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance.id]
  subnet_id                   = data.aws_subnet.db_subnet.id
  user_data                   = <<EOF
    #!/bin/bash
    db_address="${aws_db_instance.postgresdb.address}"
    db_port="${aws_db_instance.postgresdb.port}"
    echo "Hello, World. DB is at $db_address:$db_port" >> index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "instance" {
  name   = "terraform-example-instance-${random_integer.int.result}"
  vpc_id = data.aws_vpc.default_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
