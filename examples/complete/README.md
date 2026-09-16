# Complete Example

A fully-configured `airtelcloud_baremetal` server: reserved capacity,
extra storage, an initial backup schedule, tags, and destroy-time disk
cleanup.

## Usage

```bash
cd examples/complete
terraform init
terraform plan
```

This example uses a relative `source = "../.."`, pointing at the module
root two directories up. Replace `network_name`, `subnet_name`,
`availability_zone`, `flavor`, `os_image`, `system_id`, and `keypair_id`
with values valid for your account before applying.

Note that almost every attribute in this module forces replacement --
see the module's own README for the full list -- so changing most of
these values after the first `apply` destroys and recreates the server.
