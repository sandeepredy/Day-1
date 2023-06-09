#setting-up provider

provider "aws" {
    region = "ap-south-1"  
}

# write the ec2 instance config 
resource "aws_instance" "ec2_public" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key_name
    security_groups = ["${aws_security_group.sandeep-ssh-security-group.id}"]
    subnet_id = aws_subnet.sandeep-public-subnet-1.id
    associate_public_ip_address = true
    lifecycle {
      create_before_destroy = true
    }
    tags ={
        Name = "sandeep-ec2-Public"
    }

  
}