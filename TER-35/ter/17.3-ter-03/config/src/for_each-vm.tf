locals {
    ssh-keys = file("~/.ssh/id_ed25519.pub")
}


### VM "main" and "replica"

resource "yandex_compute_instance" "for_each" {
  depends_on = [ yandex_compute_instance.web ]
  for_each = {for i in var.each_vm : i.vm_name => i}
  name = each.value.vm_name

  platform_id = each.value.platform_id
  resources {
    cores = each.value.cpu
    memory = each.value.ram
  }


  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = each.value.disk
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
  
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${local.ssh-keys}"
  }

}