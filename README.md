# Baremetal Module

Terraform module for provisioning baremetal servers on Airtel Cloud.

## Features

- Allocates an Airtel Cloud baremetal server and waits for it to reach `Ready` with power `On`
- Resolves `network_name` / `subnet_name` (and any `additional_subnet_names`) to their backend IDs
- Supports extra storage volumes and an initial backup schedule at allocation time
- Supports toggling the backup policy in place after creation via `policy_enabled`
- Exposes IP addresses and the backend port id (for use as a load balancer pool member)

## Usage

### Basic Example

```hcl
module "baremetal" {
  source = "Airtel-Cloud-Platform/baremetal/airtelcloud"

  name     = "bm01"
  flavor   = "bm.large"
  os_image = "CentOS_Stream9_May2026"

  network_name = "vpc-name"
  subnet_name  = "subnet-name"

  availability_zone = "N1"

  public_key = "ssh-rsa AAAA..."
}
```

### Complete Example

```hcl
module "baremetal" {
  source = "Airtel-Cloud-Platform/baremetal/airtelcloud"

  name       = "production-bm01"
  flavor     = "bm.xlarge"
  os_image   = "CentOS_Stream9_May2026"

  network_name             = "vpc-name"
  subnet_name              = "subnet-name"
  additional_subnet_names  = ["subnet-name-2"]

  availability_zone = "N1"

  is_reserved = true
  system_id   = "system-id"

  keypair_id = "keypair-uuid"
  public_key = "ssh-rsa AAAA..."

  storage = [
    {
      name        = "data-disk-1"
      size        = "500"
      path        = "/data"
      type        = "BlockStorage"
      file_system = "xfs"
    }
  ]

  backup_config = {
    schedule_type       = "weekly_full"
    start_time          = "21:00"
    incr_days           = [1, 2, 3, 4, 5]
    full_days           = [0]
    full_retention      = 4
    full_retention_unit = "MONTHS"
    backup_selections   = ["/data"]
  }
  policy_enabled = true

  tags = ["production", "baremetal"]

  delete_disks = true
  secure_erase = false
}
```

## Creating Multiple Baremetal Servers

Use Terraform `for_each` to create multiple servers.

```hcl
locals {
  servers = {
    bm01 = {}
    bm02 = {}
    bm03 = {}
  }
}

module "baremetal" {
  for_each = local.servers

  source = "Airtel-Cloud-Platform/baremetal/airtelcloud"

  name     = each.key
  flavor   = "bm.large"
  os_image = "CentOS_Stream9_May2026"

  network_name = var.network_name
  subnet_name  = var.subnet_name

  availability_zone = "N1"

  public_key = var.public_key
}
```

## Notes

### `network_name` is effectively required

The provider's schema marks `network_name` as `Optional`, but the resource's
create logic (`resolveBaremetalNetwork`) errors out if it is empty, since it's
needed to resolve `subnet_name` to a backend subnet id. This module makes
`network_name` a required input to surface that at `terraform plan` instead of
at `apply`.

### Almost every attribute forces replacement

Unlike the VM resource, most attributes on `airtelcloud_baremetal` --
including `name`, `flavor`, `os_image`, `cloud_init`, `subnet_name`,
`availability_zone`, `network_name`, `additional_subnet_names`, `system_id`,
`keypair`, `keypair_id`, `public_key`, `storage`, and `backup_config` -- carry
`RequiresReplace`. Changing any of these on an existing module call destroys
and recreates the server. Only `tags`, `policy_enabled`, `delete_disks`, and
`secure_erase` can be changed in place.

### No configurable `timeouts`

This resource does not expose a `timeouts` block in its schema. The
30-minute provisioning wait (polling for `state = Ready` and `power = On`)
is hardcoded in the provider and is not configurable from this module.

### `backend_port_id`

`backend_port_id` is sourced from `networkInfo.portId` on the server detail
endpoint. It can come back as `0`/unset if the backend hasn't populated it
yet -- check this output before using it as a load balancer pool member's
`backend_port_id`.

### Destroy behavior

`delete_disks` and `secure_erase` are sent as query parameters on release
and only take effect on `terraform destroy` (or when Terraform replaces the
resource). Both default to `false`, matching the provider's defaults.

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| name | Baremetal server name. Forces replacement. | string | Yes | - |
| flavor | Flavor profile to allocate. Forces replacement. | string | Yes | - |
| os_image | OS image name to install. Forces replacement. | string | Yes | - |
| cloud_init | Cloud-init script for first boot. Forces replacement. | string | No | null |
| network_name | VPC name or UUID. Forces replacement. | string | Yes | - |
| subnet_name | Primary subnet display name. Forces replacement. | string | Yes | - |
| additional_subnet_names | Extra subnet display names. Forces replacement. | list(string) | No | null |
| availability_zone | Availability zone (for example N1, S2). Forces replacement. | string | Yes | - |
| is_reserved | Allocate from reserved capacity. | bool | No | false |
| system_id | Optional system id used for reservation/release. Forces replacement. | string | No | null |
| keypair | SSH keypair name. Forces replacement. | string | No | null |
| keypair_id | SSH keypair UUID. Forces replacement. | string | No | null |
| public_key | SSH public key. Forces replacement. | string | No | null |
| storage | Extra disks. Forces replacement. | list(object) | No | null |
| backup_config | Initial backup schedule. Forces replacement. | object | No | null |
| policy_enabled | Mutable backup policy toggle. Updates in place. | bool | No | null |
| tags | Resource tags. | list(string) | No | null |
| delete_disks | Delete disks on destroy. | bool | No | false |
| secure_erase | Secure erase on destroy. | bool | No | false |

### `storage` object shape

| Name | Type | Required |
|------|------|----------|
| name | string | Yes |
| size | string | Yes |
| path | string | No |
| type | string | No |
| file_system | string | No |
| force_format | bool | No (default false) |

### `backup_config` object shape

| Name | Type | Required |
|------|------|----------|
| schedule_type | string | No |
| start_time | string | No |
| incr_days | list(number) | No |
| full_days | list(number) | No |
| full_retention | number | No |
| full_retention_unit | string | No |
| backup_selections | list(string) | No |

## Outputs

| Name | Description |
|------|-------------|
| id | Terraform resource id (the server name) |
| uuid | Baremetal server UUID |
| name | Baremetal server name |
| state | Current server state |
| power | Current power state |
| hostname | Resolved hostname |
| ip_addresses | Assigned IP addresses |
| backend_port_id | Backend port id, for LB pool member use |

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.5 |
| Airtel Cloud Provider | >= 1.1.3 |
