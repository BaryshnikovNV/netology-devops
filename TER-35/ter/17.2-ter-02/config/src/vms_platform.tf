###yandex_compute_image vars for db

variable "vm_db_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "ubuntu image"
}

###yandex_compute_instance vars for db

variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "instance name"
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "platform ID"
}
/*
variable "vm_db_cores" {
  type        = string
  default     = "2"
  description = "vCPU numbers"
}

variable "vm_db_memory" {
  type        = string
  default     = "2"
  description = "VM memory, Gb"
}

variable "vm_db_core_fraction" {
  type        = string
  default     = "20"
  description = "core fraction"
}
*/