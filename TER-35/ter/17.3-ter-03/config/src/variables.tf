###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}


/*
###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZyC+NWgo5azELYdgWKti/+oPqHVlYl2wGwe6NIDqT1 baryshnikov@debian"
  description = "ssh-keygen -t ed25519"
}*/


###yandex_compute_image vars for web

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "ubuntu image"
}

###yandex_compute_instance vars for web

variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
  description = "instance name"
}

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "platform ID"
}


###vm_resources var

variable "vms_resources" {
  description = "Resources for all vms"
  type        = map(map(number))
  default     = {
    vm_web_resources = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
  }
}


###var for vms main and replica

variable "each_vm" {
    type = list(object({
      vm_name     = string
      cpu         = number
      ram         = number
      disk        = number
      platform_id = string
    }))
  default = [ {
    vm_name = "main"
    cpu = 2
    ram = 2
    disk = 10
    platform_id = "standard-v1"
  },
  {
    vm_name = "replica"
    cpu = 2
    ram = 2
    disk = 10
    platform_id = "standard-v1"
  } ]
}


###var for disk

variable "storage_disk" {
  type = list(object({
    for_storage = object({
      name       = string
      type       = string
      size       = number
      count      = number
    })
  }))

  default = [ {
    for_storage = {
      name =  "disk"
      type =  "network-hdd"
      size =  1
      count = 3
    }
  } ]
}


###var for vm storage

variable "yandex_compute_instance_storage" {
  type = object({
    storage_resources = object({
      cores         = number
      memory        = number
      core_fraction = number
      name          = string
      zone          = string
    })
  })

  default = {
    storage_resources = {
      cores         = 2
      memory        = 2
      core_fraction = 5
      name          = "storage"
      zone          = "ru-central1-a"
    }
  }
}

variable "boot_disk_storage" {
  type = object({
    size = number
    type = string
  })
  default = {
    size = 5
    type = "network-hdd"
  }
}