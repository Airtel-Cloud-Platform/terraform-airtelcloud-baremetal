# storage and backup_config are Terraform Plugin Framework *nested attributes*
# on airtelcloud_baremetal, not blocks -- they're assigned directly from the
# matching list(object(...)) / object(...) module variables rather than via
# `dynamic` block syntax.

resource "airtelcloud_baremetal" "this" {
  name              = var.name
  flavor            = var.flavor
  os_image          = var.os_image
  cloud_init        = var.cloud_init
  subnet_name       = var.subnet_name
  availability_zone = var.availability_zone
  network_name      = var.network_name

  additional_subnet_names = var.additional_subnet_names

  is_reserved = var.is_reserved
  system_id   = var.system_id

  keypair    = var.keypair
  keypair_id = var.keypair_id
  public_key = var.public_key

  storage       = var.storage
  backup_config = var.backup_config

  policy_enabled = var.policy_enabled

  tags = var.tags

  delete_disks = var.delete_disks
  secure_erase = var.secure_erase
}
