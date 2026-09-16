# Baremetal Module

Terraform module for provisioning and managing baremetal servers on Airtel Cloud.

## Features

* Provisions an Airtel Cloud baremetal server and waits for it to reach Ready state with power On
* Supports flavor and OS image selection.
* Supports primary and additional subnet configuration.
* Resolves VPC and subnet names to backend IDs through the Airtel Cloud provider.
* Supports optional additional block storage.
* Supports backup schedule configuration.
* Supports cloud-init configuration for first-boot initialization.
* Supports SSH keypair configuration.
* Supports allocation from reserved capacity.
* Supports backup policy enable/disable.
* Supports configurable disk deletion and secure erase during destroy.
* Exposes server state, power state, hostname, IP addresses, and backend port information.

## Usage

### Basic Example

```hcl
module "baremetal" {
  source = "Airtel-Cloud-Platform/baremetal/airtelcloud"

  name     = "bm01"
  flavor   = "metal-c56-m1024"
  os_image = "ubuntu22_Aug2026"

  network_name = "example-vpc"
  subnet_name  = "example-subnet"

  availability_zone = "S1"

  keypair = "example-keypair"
}
```

### Complete Example

```hcl
module "baremetal" {
  source = "Airtel-Cloud-Platform/baremetal/airtelcloud"

  name     = "production-bm01"
  flavor   = "metal-c56-m1024"
  os_image = "ubuntu22_Aug2026"

  network_name = "example-vpc"
  subnet_name  = "example-subnet"

  additional_subnet_names = [
    "example-subnet-2",
    "example-subnet-3"
  ]

  availability_zone = "S1"

  keypair     = "example-keypair"
  is_reserved = false


  tags = [
    "production",
    "baremetal"
  ]

  cloud_init = <<-EOF
    #cloud-config

    package_update: true

    packages:
      - nginx

    runcmd:
      - systemctl enable nginx
      - systemctl start nginx
  EOF

  storage = [
    {
      name         = "application-data"
      size         = "100"
      path         = "/data"
      type         = "BlockStorage"
      file_system  = "xfs"
      force_format = true
    }
  ]

  backup_config = {
    schedule_type       = "weekly_full"
    start_time          = "21:00"
    incr_days           = []
    full_days            = [7]
    full_retention      = 1
    full_retention_unit = "MONTHS"
    backup_selections   = ["/data"]
  }

  policy_enabled = true

  delete_disks = true
  secure_erase = false
}
```

## Creating Multiple Baremetal Servers

Use Terraform `for_each` to provision multiple baremetal servers using the same module.

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
  flavor   = "metal-c56-m1024"
  os_image = "ubuntu22_Aug2026"

  network_name = "example-vpc"
  subnet_name  = "example-subnet"

  availability_zone = "S1"

  keypair = "example-keypair"
}
```

## Network Configuration

A baremetal server can have one primary subnet and additional subnets.

### Primary Subnet

The primary subnet is specified using `subnet_name`:

```hcl
subnet_name = "example-subnet"
```

The provider resolves the subnet display name to its backend UUID before sending the allocation request.

### Additional Subnets

Additional subnets can be configured using `additional_subnet_names`:

```hcl
additional_subnet_names = [
  "example-subnet-2",
  "example-subnet-3"
]
```

The primary subnet specified by `subnet_name` is attached first, followed by the additional subnets.

### VPC

The `network_name` argument specifies the VPC to which the baremetal server is connected.

It can contain either a VPC name or UUID:

```hcl
network_name = "example-vpc"
```

When a VPC name is provided, the provider resolves it to the corresponding VPC UUID before allocation.

The VPC is required when resolving `subnet_name`.

## Availability Zone

The `availability_zone` argument specifies the availability zone in which the baremetal server is allocated.

Supported availability zones documented by the provider include:

* `N1`
* `N2`
* `S1`
* `S2`

Example:

```hcl
availability_zone = "S1"
```

## SSH Keypair

The `keypair` argument specifies the SSH keypair name to inject into the baremetal server.

Example:

```hcl
keypair = "example-keypair"
```

## Reserved Capacity

The `is_reserved` argument determines whether the baremetal server should be allocated from reserved capacity.

Example:

```hcl
is_reserved = true
```

The default value is:

```hcl
is_reserved = false
```


## Cloud-Init

The `cloud_init` argument allows you to automatically configure the baremetal server during its first boot.

For example, the following configuration installs and starts Nginx:

```hcl
cloud_init = <<-EOF
  #cloud-config

  package_update: true

  packages:
    - nginx

  runcmd:
    - systemctl enable nginx
    - systemctl start nginx
EOF
```

Cloud-init can be used to automate initial server configuration, including:

* Package installation
* User creation
* Service configuration
* Configuration file creation
* Startup commands

A shell script can also be provided:

```hcl
cloud_init = <<-EOF
  #!/bin/bash

  apt-get update
  apt-get install -y nginx

  systemctl enable nginx
  systemctl start nginx
EOF
```

> **Note:** Cloud-init is intended for first-boot initialization of the baremetal server.

## Storage Configuration

Additional disks can be configured using the `storage` argument.

Example:

```hcl
storage = [
  {
    name         = "application-data"
    size         = "100"
    path         = "/data"
    type         = "BlockStorage"
    file_system  = "xfs"
    force_format = true
  }
]
```

Each storage object supports the following attributes:

| Name         | Type   | Required |
| ------------ | ------ | -------- |
| name         | string | Yes      |
| size         | string | Yes      |
| path         | string | No       |
| type         | string | No       |
| file_system  | string | No       |
| force_format | bool   | No       |

### Storage Attributes

* `name` - Name of the disk.
* `size` - Disk size.
* `path` - Mount path for the disk.
* `type` - Storage type, for example `BlockStorage`.
* `file_system` - File system to use for the disk, for example `xfs`.
* `force_format` - Determines whether the disk should be formatted.

Example mount paths include:

```text
/data
/test
/backup
```

## Backup Configuration

Backups can be configured using the `backup_config` argument.

Example:

```hcl
backup_config = {
  schedule_type       = "weekly_full"
  start_time          = "21:00"
  incr_days           = []
  full_days           = [7]
  full_retention      = 1
  full_retention_unit = "MONTHS"
  backup_selections   = ["/data"]
}
```

The `backup_selections` field specifies the paths that should be included in the backup.

For example:

```hcl
backup_selections = [
  "/data",
  "/backup"
]
```

### Backup Configuration Object

| Name                | Type         | Required |
| ------------------- | ------------ | -------- |
| schedule_type       | string       | No       |
| start_time          | string       | No       |
| incr_days           | list(number) | No       |
| full_days           | list(number) | No       |
| full_retention      | number       | No       |
| full_retention_unit | string       | No       |
| backup_selections   | list(string) | No       |

### Backup Policy

The `policy_enabled` argument enables or disables the backup policy.

```hcl
policy_enabled = true
```

This is a mutable setting and can be updated after the baremetal server has been created.

When specified during creation, the value is also included in the backup configuration.

## Tags

The `tags` argument specifies tags used during server allocation.

Example:

```hcl
tags = [
  "production",
  "baremetal"
]
```

Tags represent placement/allocation tags used by the Airtel Cloud baremetal service.

They are not intended to be used as generic Terraform labels.

## Destroy Behavior

When the module is destroyed, the baremetal server is released.

Two arguments control the behavior of attached disks during server destruction.

### Delete Disks

Set `delete_disks` to `true` to delete attached disks when the baremetal server is destroyed.

```hcl
delete_disks = true
```

The default is:

```hcl
delete_disks = false
```

### Secure Erase

Set `secure_erase` to `true` to request secure erase during server destruction.

```hcl
secure_erase = true
```

The default is:

```hcl
secure_erase = false
```

Example:

```hcl
module "baremetal" {
  source = "Airtel-Cloud-Platform/baremetal/airtelcloud"

  name     = "bm01"
  flavor   = "metal-c56-m1024"
  os_image = "ubuntu22_Aug2026"

  network_name = "example-vpc"
  subnet_name  = "example-subnet"

  availability_zone = "S1"

  keypair = "example-keypair"

  delete_disks = true
  secure_erase = false
}
```

Both `delete_disks` and `secure_erase` apply when the server is destroyed or released.

## Inputs

| Name                    | Description                                                     | Type         | Required | Default |
| ----------------------- | --------------------------------------------------------------- | ------------ | -------- | ------- |
| name                    | Name of the baremetal server.                                   | string       | Yes      | -       |
| flavor                  | Flavor profile used to allocate the baremetal server.           | string       | Yes      | -       |
| os_image                | OS image name used to install the operating system.             | string       | Yes      | -       |
| subnet_name             | Display name of the primary subnet to attach.                   | string       | Yes      | -       |
| availability_zone       | Availability zone in which the server is allocated.             | string       | Yes      | -       |
| network_name            | VPC name or UUID.                                               | string       | Yes      | -       |
| keypair                 | SSH keypair name to inject into the server.                     | string       | Yes      | -       |
| additional_subnet_names | Additional subnet display names to attach.                      | list(string) | No       | null    |
| storage                 | Additional disks to attach to the server.                       | list(object) | No       | null    |
| backup_config           | Backup schedule configuration.                                  | object       | No       | null    |
| cloud_init              | Cloud-init configuration for first boot.                        | string       | No       | null    |
| is_reserved             | Allocate the server from reserved capacity.                     | bool         | No       | false   |
| system_id               | Optional system identifier used during reservation and release. | string       | No       | null    |
| tags                    | Tags used during server allocation.                             | list(string) | No       | null    |
| policy_enabled          | Enable or disable the backup policy.                            | bool         | No       | null    |
| delete_disks            | Delete attached disks when the server is destroyed.             | bool         | No       | false   |
| secure_erase            | Request secure erase when the server is destroyed.              | bool         | No       | false   |

## Storage Object

The `storage` input accepts a list of objects.

| Name         | Type   | Required |
| ------------ | ------ | -------- |
| name         | string | Yes      |
| size         | string | Yes      |
| path         | string | No       |
| type         | string | No       |
| file_system  | string | No       |
| force_format | bool   | No       |

Example:

```hcl
storage = [
  {
    name         = "application-data"
    size         = "100"
    path         = "/data"
    type         = "BlockStorage"
    file_system  = "xfs"
    force_format = true
  }
]
```

## Backup Configuration Object

The `backup_config` input accepts an object with the following attributes:

| Name                | Type         | Required |
| ------------------- | ------------ | -------- |
| schedule_type       | string       | No       |
| start_time          | string       | No       |
| incr_days           | list(number) | No       |
| full_days           | list(number) | No       |
| full_retention      | number       | No       |
| full_retention_unit | string       | No       |
| backup_selections   | list(string) | No       |

Example:

```hcl
backup_config = {
  schedule_type       = "weekly_full"
  start_time          = "21:00"
  incr_days           = []
  full_days           = [7]
  full_retention      = 1
  full_retention_unit = "MONTHS"
  backup_selections   = ["/data"]
}
```

## Outputs

| Name              | Description                                                           |
| ----------------- | --------------------------------------------------------------------- |
| id                | Terraform resource ID. This corresponds to the baremetal server name. |
| uuid              | Unique UUID of the baremetal server.                                  |
| name              | Baremetal server name.                                                |
| state             | Current state of the baremetal server.                                |
| power             | Current power state of the baremetal server.                          |
| hostname          | Hostname assigned to the baremetal server.                            |
| availability_zone | Availability zone in which the server is allocated.                   |
| ip_addresses      | IP addresses assigned to the baremetal server.                        |
| backend_port_id   | Backend network port identifier returned by the server detail API.    |

## Import

An existing baremetal server can be imported using its server name.

```shell
terraform import airtelcloud_baremetal.app <baremetal-name>
```

After importing the resource, run:

```shell
terraform plan
```

to verify that the Terraform configuration matches the existing baremetal server.

## Important Notes

* `name`, `flavor`, `os_image`, `subnet_name`, `availability_zone`, `network_name`, and `keypair` are required inputs.
* `network_name` can be a VPC name or UUID.
* `subnet_name` refers to the primary subnet display name and is resolved to a backend subnet UUID by the provider.
* `additional_subnet_names` can be used to attach additional subnets.
* `availability_zone` must be a valid availability zone supported by the Airtel Cloud baremetal service.
* `cloud_init` is intended for first-boot server initialization.
* `storage` can be used to configure additional disks.
* `backup_config` can be used to configure the backup schedule.
* `policy_enabled` controls the backup policy and can be updated after server creation.
* `is_reserved` controls whether the server is allocated from reserved capacity.
* `delete_disks` controls whether attached disks are deleted during server destruction.
* `secure_erase` controls whether secure erase is requested during server destruction.
* `system_id` can be supplied when required by the backend for reservation and release operations.
* `backend_port_id` is returned by the server detail API and can be used when integrating the baremetal server with other Airtel Cloud resources.

## Requirements

| Name                  | Version  |
| --------------------- | -------- |
| Terraform             | >= 1.5   |
| Airtel Cloud Provider | >= 1.2.4 |
