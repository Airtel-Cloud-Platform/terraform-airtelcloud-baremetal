module "baremetal" {
  source = "../.."

  name     = "production-bm01"
  flavor   = "bm.xlarge"
  os_image = "CentOS_Stream9_May2026"

  network_name            = "vpc-name"
  subnet_name             = "subnet-name"
  additional_subnet_names = ["subnet-name-2"]

  availability_zone = "N1"

  is_reserved = true

  keypair = "keypair-uuid"

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
