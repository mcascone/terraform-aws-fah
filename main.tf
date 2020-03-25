provider "aws" {
  region = "us-east-2"
  shared_credentials_file = "~/.aws/credentials"
  # profile = "terraform"
}

# resource "aws_key_pair" "aws1" {
#   key_name = "aws1"
#   public_key = "ssh-rsa MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1yxIneCk2Cvfdw1IwDcRiujPA8wrbKNe1AAi8fkyhRb4YZ96KbrAfGIe7fwab4IrOO3dvdlgxlcBxiqhMLzqzP0aY5aF9oKd3LU8e62t9h0Qx/rqPfxaYVax7+sfry6x29lZyCuuo/smeYdltZ+xD0MLmX+9+NS0Wfu1+kJO4dylDS3meCIZeorryE8lEMyPQrz8R7UvnhLuWVno8tIMyFm8mH0k+6YyvlUUfaurudEtAMAI1k4Q6R7JLkxAEf4fQGjj5YiGAZgBEMMDgLSMcI4NuiFfrCK3cAPFdkNoXyXc1iSKQgx0ibaSu8xu6Daq4N5DnSTMrRiFi7mFPiDRpXFH0ieWhvxX43ktMk7W1aHXuoeW6uyJu67FAiBXOseb6LwuB+2zmZ1V/X6kAXYZA9kE0H8paXa1IyppGb2uuX5C4kaYW93pPJdtYMTXcXgsMuhDiOMP3RWKT1dEp6cnslAzvWoxA6VtDNzHmE+NBemuYrCfORHFFHITONqj32RNDhJSxHyEPR6m1jrpBqemFkRrqGXua95xBlHJi7EYUtllUewAb26lsGyuCKpg+DcBlRFPltiYGnFoG7rjgemkKWylYCTJSihHGu76aE6hC2xxJnJ8cBUVJ2IQv9Fpq1Ocg0yIo6g93lRvxjk4KMBFYCT4YN3Est4VSYJxlFwssgECAwEAAQ=="
# }


# resource "aws_instance" "fah" {
#   ami = "ami-07f3715a1f6dbb6d9"
#   instance_type = "t2.micro"
#   # key_name = "aws1"
#   tags {
#     Name = "fah1"
#   }
# }

resource "aws_security_group" "instance" {
  name = "terraform-example-secgp-instance"
  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_instance" "fah-ubuntu" {
#   ami = "${var.ubuntu_ami}"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = ["${aws_security_group.instance.id}"]

#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               nohup busybox httpd -f -p ${var.server_port} &
#               EOF

#   tags {
#     Name = "fah-ubuntu"
#   }
# }

resource "aws_launch_configuration" "example" {
  image_id        = "${var.ubuntu_ami}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  min_size = 2
  max_size = 10
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

