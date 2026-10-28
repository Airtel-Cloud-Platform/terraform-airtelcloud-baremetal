module "baremetal" {
  source = "../.."

  name     = "bm01"
  flavor   = "metal-c56-m1024"
  os_image = "ubuntu22_Aug2026"

  network_name = "example-vpc"
  subnet_name  = "example-subnet"

  availability_zone = "S1"
  keypair           = "example-keypair"
}
