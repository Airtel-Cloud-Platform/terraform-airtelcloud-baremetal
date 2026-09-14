#########################################
# Basic Configuration
#########################################

variable "name" {
  description = "Baremetal server name. Forces replacement if changed."
  type        = string

  validation {
    condition     = length(trim(var.name, " ")) > 0
    error_message = "name cannot be empty."
  }
}

variable "flavor" {
  description = "Flavor profile to allocate. Forces replacement if changed."
  type        = string

  validation {
    condition     = length(trim(var.flavor, " ")) > 0
    error_message = "flavor cannot be empty."
  }
}

variable "os_image" {
  description = "OS image name to install. Forces replacement if changed."
  type        = string

  validation {
    condition     = length(trim(var.os_image, " ")) > 0
    error_message = "os_image cannot be empty."
  }
}

variable "cloud_init" {
  description = "Cloud-init script for first boot. Forces replacement if changed. When public_key is also set, the provider appends its own runcmd block that creates a cloud-user with that key, in addition to this script."
  type        = string
  default     = null
}

#########################################
# Networking
#########################################

variable "network_name" {
  description = "VPC name or UUID. Required to resolve subnet_name even though the provider schema marks this attribute Optional -- the resource's create logic fails without it. Forces replacement if changed."
  type        = string

  validation {
    condition     = length(trim(var.network_name, " ")) > 0
    error_message = "network_name cannot be empty."
  }
}

variable "subnet_name" {
  description = "Primary subnet display name, resolved against network_name. Forces replacement if changed."
  type        = string

  validation {
    condition     = length(trim(var.subnet_name, " ")) > 0
    error_message = "subnet_name cannot be empty."
  }
}

variable "additional_subnet_names" {
  description = "Extra subnet display names attached in addition to subnet_name. Forces replacement if changed."
  type        = list(string)
  default     = null

  validation {
    condition = (
      var.additional_subnet_names == null ||
      alltrue([for s in var.additional_subnet_names : length(trim(s, " ")) > 0])
    )
    error_message = "additional_subnet_names must not contain empty values."
  }
}

#########################################
# Placement
#########################################

variable "availability_zone" {
  description = "Availability zone used by baremetal APIs (for example N1, N2, S1, S2). Forces replacement if changed."
  type        = string

  validation {
    condition     = length(trim(var.availability_zone, " ")) > 0
    error_message = "availability_zone cannot be empty."
  }
}

#########################################
# Capacity Reservation
#########################################

variable "is_reserved" {
  description = "Whether to allocate from reserved capacity."
  type        = bool
  default     = false
}

variable "system_id" {
  description = "Optional system id used by the backend for reservation/release. Forces replacement if changed."
  type        = string
  default     = null
}

#########################################
# Authentication
#########################################

variable "keypair" {
  description = "SSH keypair name to inject via allocate metadata. Required as of the provider's latest commit -- previously Optional. Forces replacement if changed."
  type        = string

  validation {
    condition     = length(trim(var.keypair, " ")) > 0
    error_message = "keypair cannot be empty."
  }
}

variable "keypair_id" {
  description = "Optional keypair UUID, sent as keypairId in the baremetal allocate API. Forces replacement if changed."
  type        = string
  default     = null
}

variable "public_key" {
  description = "Optional SSH public key, sent as publicKey in the baremetal allocate API. When set without cloud_init, the provider injects a runcmd block that creates a cloud-user account with this key. Forces replacement if changed."
  type        = string
  default     = null
}

#########################################
# Storage
#########################################

variable "storage" {
  description = "Optional extra disks sent as allocate storage. Forces replacement if changed."
  type = list(object({
    name         = string
    size         = string
    path         = optional(string)
    type         = optional(string)
    file_system  = optional(string)
    force_format = optional(bool, false)
  }))
  default = null

  validation {
    condition = (
      var.storage == null ||
      alltrue([for s in var.storage : length(trim(s.name, " ")) > 0 && length(trim(s.size, " ")) > 0])
    )
    error_message = "Each storage entry requires a non-empty name and size."
  }
}

#########################################
# Backup
#########################################

variable "backup_config" {
  description = "Optional backup schedule sent as allocate backupConfig. Forces replacement if changed. Note: this only sets the initial schedule at allocation time -- use policy_enabled to toggle the backup policy on an existing server."
  type = object({
    schedule_type       = optional(string)
    start_time          = optional(string)
    incr_days           = optional(list(number))
    full_days           = optional(list(number))
    full_retention      = optional(number)
    full_retention_unit = optional(string)
    backup_selections   = optional(list(string))
  })
  default = null
}

variable "policy_enabled" {
  description = "Mutable backup policy toggle. Changing this after creation updates the server in place via PUT /server/{name} rather than replacing it."
  type        = bool
  default     = null
}

#########################################
# Tags
#########################################

variable "tags" {
  description = "Optional list of tags."
  type        = list(string)
  default     = null
}

#########################################
# Destroy Behavior
#########################################

variable "delete_disks" {
  description = "Whether to delete disks on resource destroy."
  type        = bool
  default     = false
}

variable "secure_erase" {
  description = "Whether to perform secure erase on resource destroy."
  type        = bool
  default     = false
}
