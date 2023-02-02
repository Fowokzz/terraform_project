# subnet_blocks = {
#     subnet_01 = {
#         cidr = "10.0.1.0/24"
#         az = "us-east-1a"
#     }
#     subnet_02 = {
#         cidr = "10.0.2.0/24"
#         az = "us-east-1b"
#     }
#     subnet_03 = {
#         cidr = "10.0.3.0/24"
#         az = "us-east-1c"
#     }
# }

# instance_blocks = {
#     instance_01 = {
#         subnet_id = "subnet_01"
#         az = "us-east-1a"
#         tags = {
#             Name = "Server01"
#         }     
#     }

#     instance_02 = {
#         subnet_id = "subnet_02"
#         az = "us-east-1b"
#         tags = {
#             Name = "Server02"
#         }
#     }

#     instance_03 = {
#         subnet_id = "subnet_03"
#         az = "us-east-1c"
#         tags = {
#             Name = "Server03"
#         }
#     }
# }






domain_names = {
  domain_name = "fowokeoluwole.live"
  subdomain_name = "terraform-test.fowokeoluwole.live"
}

 key_pair_name = "mini-project-key"
 public_key = "tls_private_key.mini-project-key.public_key_openssh}"
#  private_key_path = "~/Downloads/Terraform_Project1/Project1/mini-project-key.pem"