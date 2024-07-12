#Создание VPC
resource "yandex_vpc_network" "vpc0" {
  name = var.vpc_name
}

#Публичная подсеть

#Создадим в VPC subnet c названием public
resource "yandex_vpc_subnet" "public" {
  name           = var.public_subnet
  zone           = var.default_zone
  network_id     = yandex_vpc_network.vpc0.id
  v4_cidr_blocks = var.default_cidr
}