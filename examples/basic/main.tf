module "baremetal" {
  source = "Airtel-Cloud-Platform/baremetal/airtelcloud"

  name     = "bm01"
  flavor   = "bm.large"
  os_image = "CentOS_Stream9_May2026"

  network_name = "vpc-name"
  subnet_name  = "subnet-name"

  availability_zone = "N1"
  keypair           = "my-keypair"
}
