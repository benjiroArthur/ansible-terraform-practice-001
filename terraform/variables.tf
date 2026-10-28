variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# Keys become Ansible group names; values are how many nodes to build in each.
# Adding a role or changing a count here is the only edit needed to resize the fleet.
variable "node_counts" {
  type        = map(number)
  description = "Instances to create per role."
  default = {
    app = 2
    db  = 2
  }
}

variable "node_prefix" {
  type        = string
  description = "Prefix for the Name tag of each node."
  default     = "managed_nodes"
}

variable "public_key_path" {
  type        = string
  description = "Path to the public key registered with EC2 for SSH access."
  default     = "~/.ssh/ansible-practise.pub"
}

variable "ansible_user" {
  type        = string
  description = "Default login user on the AMI; written into the generated inventory."
  default     = "ubuntu"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Private half of var.public_key_path, as Ansible should reference it."
  default     = "~/.ssh/ansible-practise"
}

variable "ssh_ingress_cidr" {
  type        = string
  description = "CIDR permitted to reach ports 22 and 80. Leave null to auto-detect this machine's public IP as a /32 on every apply."
  default     = null

  validation {
    condition     = var.ssh_ingress_cidr != "0.0.0.0/0"
    error_message = "Refusing to open SSH to the entire internet."
  }
}