###creating 3 virtual disks

resource "yandex_compute_disk" "disks" {
    name  = "${var.storage_disk[0].for_storage.name}-${count.index+1}"
    type  = var.storage_disk[0].for_storage.type
    size  = var.storage_disk[0].for_storage.size
    count = var.storage_disk[0].for_storage.count
}



###creating VM storage

resource "yandex_compute_instance" "storage" {
  name = var.yandex_compute_instance_storage.storage_resources.name
  zone = var.yandex_compute_instance_storage.storage_resources.zone

  resources {
    cores  = var.yandex_compute_instance_storage.storage_resources.cores
    memory = var.yandex_compute_instance_storage.storage_resources.memory
    core_fraction = var.yandex_compute_instance_storage.storage_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = var.boot_disk_storage.type
      size     = var.boot_disk_storage.size
    }
  }
      metadata = {
        serial-port-enable = "1"
        ssh-keys           = "ubuntu:${local.ssh-keys}"
    }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.example.id
    ]
  }
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.disks.*.id
    content {
      disk_id = secondary_disk.value
  }
  }
}