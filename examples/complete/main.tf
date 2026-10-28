module "baremetal" {
  source = "../.."

  name     = "production-bm01"
  flavor   = "metal-c56-m1024"
  os_image = "ubuntu22_Aug2026"

  network_name            = "example-vpc"
  subnet_name             = "example-subnet"
  additional_subnet_names = ["example-subnet-2"]

  availability_zone = "S1"

  is_reserved = false
  keypair     = "example-keypair"

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
    full_days           = [7]
    full_retention      = 1
    full_retention_unit = "MONTHS"
    backup_selections   = ["/data"]
  }
  policy_enabled = true

  tags = ["production", "baremetal"]

  delete_disks = true
  secure_erase = false
}
