data "aws_ami" "latest_img" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "mini-project-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated-key" {
  key_name = var.key_pair_name
  public_key = tls_private_key.mini-project-key.public_key_openssh
}
resource "local_file" "ssh" {
  content = tls_private_key.mini-project-key.private_key_pem
  filename = "${var.key_pair_name}.pem"
  file_permission = 0400
}


resource "aws_instance" "instances" {
    count = var.instance_count

    ami      = data.aws_ami.latest_img.id
    instance_type = "t2.micro"
    key_name  =  var.key_pair_name
    subnet_id = aws_subnet.subnets[count.index].id
    security_groups = [aws_security_group.project-load-balancer-sg.id]
    
    provisioner "local-exec" {
      command = "echo '${self.public_ip}' >> ./host-inventory"
    }
 }


 resource "null_resource" "ansible-playbook" {
   count = var.instance_count
  
  provisioner "remote-exec" {
    inline = ["echo 'connect to ssh'"]

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file(local.private_key_path)
    host = aws_instance.instances[count.index].public_ip
  }
} 
  provisioner "local-exec"{
    command = "ansible-playbook -i ${aws_instance.instances[count.index].public_ip}, --private-key ${local.private_key_path} setup.yml"
  }
  depends_on = [
     aws_instance.instances
   ]
}