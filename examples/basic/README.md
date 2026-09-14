# Basic Example

Minimal `airtelcloud_baremetal` server: required fields plus a public key
for SSH access. No storage, backup, or tags configured.

## Usage

```bash
cd examples/basic
terraform init
terraform plan
```

This example uses a relative `source = "../.."`, pointing at the module
root two directories up. Replace `network_name`, `subnet_name`,
`availability_zone`, `flavor`, and `os_image` with values valid for your
account before applying -- the provider does not validate these
client-side, so a bad value fails partway through the 30-minute
provisioning wait rather than at `plan` time.
