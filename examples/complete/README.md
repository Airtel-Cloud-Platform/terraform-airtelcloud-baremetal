# Complete Example

Fully configured `airtelcloud_baremetal`: extra subnets, storage, backup schedule, tags, and destroy-time disk flags.

## Usage

```bash
cd examples/complete
terraform init
terraform plan
```

This example uses `source = "../.."`. Replace `network_name`, `subnet_name`, `availability_zone`, `flavor`, `os_image`, and `keypair` with values valid for your account before applying.

`name`, `flavor`, `os_image`, `network_name`, `subnet_name`, `availability_zone`, `keypair`, `cloud_init`, `storage`, `additional_subnet_names`, and `system_id` force replacement. `backup_config`, `policy_enabled`, `tags`, `is_reserved`, `delete_disks`, and `secure_erase` do not.
