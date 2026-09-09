output "id" {
  description = "Terraform resource id (the baremetal server name)."
  value       = airtelcloud_baremetal.this.id
}

output "uuid" {
  description = "Baremetal server UUID."
  value       = airtelcloud_baremetal.this.uuid
}

output "name" {
  description = "Baremetal server name."
  value       = airtelcloud_baremetal.this.name
}

output "state" {
  description = "Current server state (for example Ready)."
  value       = airtelcloud_baremetal.this.state
}

output "power" {
  description = "Current power state."
  value       = airtelcloud_baremetal.this.power
}

output "hostname" {
  description = "Resolved hostname from the API."
  value       = airtelcloud_baremetal.this.hostname
}

output "ip_addresses" {
  description = "Assigned IP addresses."
  value       = airtelcloud_baremetal.this.ip_addresses
}

output "backend_port_id" {
  description = "Backend port id (networkInfo.portId), usable as a load balancer pool member's backend_port_id."
  value       = airtelcloud_baremetal.this.backend_port_id
}
