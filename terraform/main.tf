# Public parameter published by AWS; always resolves to the current
# Ubuntu image for the provider's region.
data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

data "aws_vpc" "default" {
  default = true
}

# This machine's public IP, refreshed on every plan/apply. Home and mobile ISPs
# rotate addresses, which silently breaks SSH ingress; looking it up here keeps
# the security group in step without editing a hardcoded CIDR each time.
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

# Registers the public half of the local keypair with EC2. The private key
# never leaves this machine and never enters Terraform state.
resource "aws_key_pair" "deployer" {
  key_name   = "ansible-practise"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "managed_node" {
  name        = "ansible-practise-managed-node"
  description = "SSH from the control machine; unrestricted egress"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.managed_node.id
  description       = "SSH from the Ansible control machine"
  cidr_ipv4         = local.ssh_ingress_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.managed_node.id
  description       = "HTTP from the Ansible control machine"
  cidr_ipv4         = local.ssh_ingress_cidr
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Needed for dnf, and for anything Ansible installs on the node.
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.managed_node.id
  description       = "All outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "managed_node" {
  for_each               = local.node_definitions
  ami                    = data.aws_ssm_parameter.ubuntu.value
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.managed_node.id]

  tags = {
    Name = each.key
    Role = each.value.role
  }
}
