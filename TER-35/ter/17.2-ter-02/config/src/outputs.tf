output "VMs" {
  value = {
    instance_web = yandex_compute_instance.platform.name
    external_ip_web = yandex_compute_instance.platform.network_interface.0.nat_ip_address
    instance_db = yandex_compute_instance.platform_2.name
    external_ip_db = yandex_compute_instance.platform_2.network_interface.0.nat_ip_address
  }
}