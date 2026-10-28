# Writes the Ansible inventory from live instance attributes, so the IPs can
# never drift from what Terraform actually built.
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644" // Make sure Ansible can read it

  content = templatefile("${path.module}/templates/inventory.ini.tftpl", {
    groups               = local.inventory_groups
    ansible_user         = var.ansible_user
    ssh_private_key_file = var.ssh_private_key_path
  })
}
