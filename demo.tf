provider "aws" {
    region = "us-east-2"
}


#resource "provider_resourcename" "name" 
  
resource "aws_instance" "myinstance" {
    ami = "ami-09558250a3419e7d0"
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.SG.id ]
    user_data = "${file("userdata.sh")}"
    tags = {
      "Name" = "My demo"
      "Env"  =  "Production"
    }
}


 
resource "aws_security_group" "SG" {
  name = "prod-sg"
 
  dynamic "ingress" {
    for_each = ["22" , "80" , "443"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol  = "tcp"
      cidr_blocks  = ["0.0.0.0/0"]
    }
  }


   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
 }
}

resource "aws_vpc" "myVPC" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "ProdVPC"
    }
}


resource "aws_internet_gateway" "myIG" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "ProdIG"
  }
}


resource "aws_subnet" "mysubnet" {
    vpc_id = aws_vpc.myVPC.id
    cidr_block = "10.0.1.0/24"
    
    tags = {
      Name = "ProdSubnet"
    }
}


resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.myVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIG.id
  }

  tags = {
    Name = "ProdRT"
  }
}
