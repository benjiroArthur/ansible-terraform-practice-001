# Expands { app = 2, db = 2 } into a flat, stably-keyed map:
#   { app_001 = { role = "app" }, app_002 = ..., db_001 = ..., db_002 = ... }
# The inner comprehension builds one map per role; merge(...) folds them into one.
# The trailing "..." is the spread operator, turning the list of maps into
# separate arguments to merge().
locals {
  # An explicit var.ssh_ingress_cidr wins; otherwise fall back to the public IP
  # discovered by data.http.my_ip. chomp() strips the trailing newline that
  # checkip.amazonaws.com returns, which would otherwise corrupt the CIDR.
  ssh_ingress_cidr = coalesce(
    var.ssh_ingress_cidr,
    "${chomp(data.http.my_ip.response_body)}/32",
  )

  node_definitions = merge([
    for role, count in var.node_counts : {
      for i in range(count) : format("%s_%s_%03d", var.node_prefix, role, i + 1) => { role = role }
    }
  ]...)

  # Flat name -> public IP, for the root output.
  node_ips = { for name, i in aws_instance.managed_node : name => i.public_ip }

  # role -> { name -> public IP }, one entry per Ansible group.
  inventory_groups = {
    for role in keys(var.node_counts) : role => {
      for name, i in aws_instance.managed_node : name => i.public_ip
      # Only include nodes of this role in this group.
      if local.node_definitions[name].role == role
    }
  }
}
