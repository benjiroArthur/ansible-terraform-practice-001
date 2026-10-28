output "managed_nodes" {
  value       = local.node_ips
  description = "Map of instance Name tag to public IP."
}