
# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "4.51.0"
#     }
#   }
# }

# provider "aws" {
#   region = "us-east-1"
#   # access_key = var.AWS_ACCESS_KEY_ID
#   # secret_key = var.AWS_SECRET_ACCESS_KEY
# }

# #awsvpc
# resource "aws_vpc" "mini-project" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   tags = {
#     Name = "project" 
#   }  
# }

# #awsIG
# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.mini-project.id
# }

# #awsSubnet
# resource "aws_subnet" "subnets" {
#   for_each   = var.subnet_blocks

#   vpc_id     = aws_vpc.mini-project.id
#   cidr_block = each.value["cidr"]
#   availability_zone = each.value["az"]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = each.key
#   }
# }

# #awsRouteTable
# resource "aws_route_table" "project-rt" {
#   vpc_id = aws_vpc.mini-project.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   # route {
#   #   ipv6_cidr_block        = "::/0"
#   #   egress_only_gateway_id = aws_egress_only_internet_gateway.gw.id
#   # }

#   tags = {
#     Name = "project"
#   }
# }


# #awsRouteTableAssociation
# resource "aws_route_table_association" "a" {
#   for_each   = aws_subnet.subnets
#   subnet_id = each.value.id
  
#   route_table_id = aws_route_table.project-rt.id
# }



# #awsSecurityGroup
# resource "aws_security_group" "project-load-balancer-sg" {
#   name        = "project-load-balancer-sg"
#   description = "Load balancer security group"
#   vpc_id      = aws_vpc.mini-project.id

#   ingress {
#     description      = "HTTPS"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "HTTP"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "SSH"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "load-balancer-sg"
#   }
# }


# #keyPair
# resource "tls_private_key" "mini-project-key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }
# resource "aws_key_pair" "generated-key" {
#   key_name = var.key_pair_name
#   public_key = tls_private_key.mini-project-key.public_key_openssh
# }
# resource "local_file" "ssh" {
#   content = tls_private_key.mini-project-key.private_key_pem
#   filename = "${var.key_pair_name}.pem"
#   file_permission = 0400
# }


# #awsInstance
# resource "aws_instance" "instances" {
#     for_each = aws_subnet.subnets

#     ami      = "ami-00874d747dde814fa"
#     instance_type = "t2.micro"
#     key_name  =  var.key_pair_name
#     subnet_id = each.value.id
#     security_groups = [aws_security_group.project-load-balancer-sg.id]
    
#     provisioner "local-exec" {
#       command = "echo '${self.public_ip}' >> ./host-inventory"
#     }
#  }


# #awsAppLoadBalancer
# resource "aws_lb" "project-load-balancer" {
#   name               = "project-load-balancer"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.project-load-balancer-sg.id]
#   subnets            = [for subnet in aws_subnet.subnets : subnet.id]

#   enable_deletion_protection = false
# }


# #awsTargetGroup
# resource "aws_lb_target_group" "project-target-group" {
#   name        = "project-target-group"
#   target_type = "instance"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.mini-project.id

#   health_check {
#     path = "/"
#     protocol = "HTTP"
#     matcher = "200-299"
#     interval = 15
#     timeout = 3
#     healthy_threshold = 3
#     unhealthy_threshold = 3
#   }
# }

# #awsListener
# resource "aws_lb_listener" "project-listener" {
#   load_balancer_arn = aws_lb.project-load-balancer.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.project-target-group.arn
#   }
# }

# #awsListenerRule
# resource "aws_lb_listener_rule" "project-listener-rule" {
#   listener_arn = aws_lb_listener.project-listener.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.project-target-group.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/"]
#     }
#   }
# }

# #aws Attach target group to the load balancer
# resource "aws_lb_target_group_attachment" "project-target-group-attachment" {
#   target_group_arn = aws_lb_target_group.project-target-group.arn
#   for_each   = aws_instance.instances
#   target_id = each.value.id
#   port             = 80
# }

# #run ansible playbook
# resource "null_resource" "ansible-playbook" {
#   for_each = var.instance_blocks
  
#   provisioner "remote-exec" {
#     inline = ["echo 'connect to ssh'"]

#   connection {
#     type = "ssh"
#     user = "ubuntu"
#     private_key = file("~/Downloads/Terraform_Project1/Project1/mini-project-key.pem")
#     host = aws_instance.instances[each.key].public_ip
#   }
# } 
#   provisioner "local-exec"{
#     command = "ansible-playbook -i ${aws_instance.instances[each.key].public_ip}, --private-key ${var.private_key_path} setup.yml"
#   }
#   depends_on = [
#     aws_instance.instances
#   ]
# }