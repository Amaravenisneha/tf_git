provider "aws" {
    region = "ap-south-1"
    access_key = "AKIATISKIOURRP5QSYZ6"
    secret_key = "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"
}

resource "aws_vpc" "vpc1_me" {
    cidr_block  =   "10.0.0.0/24"

    tags    =   {
        Name = "vpc1_me"
    }
} 

resource "aws_subnet" "public" {

    vpc_id            = aws_vpc.vpc1_me.id
    cidr_block        = "10.0.0.0/25"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "public"
  }

}

resource "aws_subnet" "private" {

    vpc_id            = aws_vpc.vpc1_me.id
    cidr_block        = "10.0.0.128/25"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "private"
  }

}

resource "aws_internet_gateway" "vpc1_gw" {

    vpc_id = aws_vpc.vpc1_me.id

    tags = {
        Name = "vpc1_gw"
    }
}

resource "aws_route_table" "public_rt" {

    vpc_id = aws_vpc.vpc1_me.id

    route {

        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.vpc1_gw.id
    }

    route {

        ipv6_cidr_block = "::/0"
        gateway_id      = aws_internet_gateway.vpc1_gw.id
    }

    tags = {

        Name = "public_rt"
    }

}

resource "aws_route_table_association" "public_1_rt_a" {

    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public_rt.id

}

resource "aws_security_group" "web_sg" {

    name   = "HTTP and SSH"
    vpc_id = aws_vpc.vpc1_me.id

    ingress {

        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {

        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {

        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

}


resource "aws_instance" "web_instance" {

    ami           = "ami-079b5e5b3971bd10d"
    instance_type = "t2.micro"
    key_name      = "MyKeyPair"

    subnet_id                   = aws_subnet.public.id
    vpc_security_group_ids      = [aws_security_group.web_sg.id]
    associate_public_ip_address = true

    tags = {

        "Name" : "Sneha"
    }

}

resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo The server's IP address is ${self.public.id}"
  }

  provisioner "file" {
    source      = "conf/myapp.conf"
    destination = "/etc/myapp.conf"

  connection {
    type     = "ssh"
    user     = "root"
    password = "${var.root_password}"
    host     = "${var.host}"
  }
  
  }
  
}
