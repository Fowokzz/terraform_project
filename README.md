# 

1. Use Terraform to create three EC2 instances and put them behind an Elastic Load Balancer

2. Export the public IP addresses of the instances to a file called host-inventory.

3. Use AWS Route53 to set up a domain name and an A record for a subdomain that points to the ELB IP address.

4. Use Ansible to automate the configuration of the servers, including: Installing Apache, setting the time zone to Africa/Lagos, and displaying a simple HTML page that can be used to identify the servers.

