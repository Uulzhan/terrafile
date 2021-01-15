provider "aws" {
    region = "us-east-2"
}
#resource "provider_resourcename" "name" }
# 1. Create vpc
resource "aws_vpc" "tf_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "tf_vpc"
  }
}
# 2. Create Internet Gateway
resource "aws_internet_gateway" "tf_ig" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf_ig"
  }
}
# 3. Create Custom Route Table
resource "aws_route_table" "tf_routetable" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_ig.id
  }
  route {
    ipv6_cidr_block    = "::/0"
    gateway_id         = aws_internet_gateway.tf_ig.id
  }
  tags = {
    Name = "tf_routetable"
  }
}
# 4. Create a Subnet
resource "aws_subnet" "tf_subnet" {
  vpc_id                    = aws_vpc.tf_vpc.id
  cidr_block                = "10.0.1.0/24"  
  availability_zone         = "us-east-2a"
  tags = {
    Name = "tf_subnet"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "terraform_rtable" {
  subnet_id      = aws_subnet.tf_subnet.id
  route_table_id = aws_route_table.tf_routetable.id
}
# 6. Create Security Group to allow port 22,80,443,8080
resource "aws_security_group" "terraform_SG" {
  name        = "allow_web_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.tf_vpc.id
  
  dynamic ingress {
    for_each = ["80", "22", "443", "8080"]
    content { 
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }  
}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_web"
  }
}
# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "terraform_webserver" {
  subnet_id       = aws_subnet.tf_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.terraform_SG.id]
}
# 8. Assign an Elastic IP to the newtork interface craeted in step 7
resource "aws_eip" "one" {
  vpc                        = true
  network_interface          = aws_network_interface.terraform_webserver.id
  associate_with_private_ip  = "10.0.1.50"
  depends_on                 = [aws_internet_gateway.tf_ig]
}

#9. Create Linux Server and install jenkins using userdata

  resource "aws_instance" "terraform_instance" {
  ami                  = "ami-0a0ad6b70e61be944"
  instance_type        = "t2.micro"
  availability_zone    = "us-east-2a"
  key_name             = "ansiblekey"
  network_interface {
    device_index          = 0
    network_interface_id  = aws_network_interface.terraform_webserver.id
  }
  user_data = file("userdata.sh")
  tags = {
    Name = "terraform_userdata"
  } 
}
