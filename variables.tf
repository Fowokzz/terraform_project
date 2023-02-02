# variable "subnet_blocks" {
#     description = "cidr, availability zone and name tag for each subnet"
#     type = map(object({
#         cidr = string
#         az = string
#     }))
# }


# variable "instance_blocks" {
#     description = "subnet, availability zone and name for each instance"
#     type = map(object({
#         subnet_id = string
#         az = string
#     }))
# }

variable "subnet_cidr" {
  type = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
}

variable "instance_count" {
  type = number
  default = 3
}


variable "key_pair_name" {
    description = "SSH key pair name"
    type = string
}

variable "public_key" {
    description = "tls public key"
    type = string
}

# variable "private_key_path" {
#     description = "path for downloaded private key"
#     type = string
# }

locals {
  private_key_path = "./mini-project-key.pem"
}

variable "domain_names" {
    type = map(string)
    description = "domain name and subdomain "
}

variable "token" {
  description = "name.com API token"
  type = string
}

variable "username" {
  description = "name.com username"
  type = string
}

