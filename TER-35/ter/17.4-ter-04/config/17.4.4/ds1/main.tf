terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~>0.104.0"
    }
    template = {
      source = "hashicorp/template"
      version = "~>2.2.0"
    }
  }
  required_version = ">=0.13"


  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "tfstate-new"
    region   = "ru-central1"
    key      = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true

        dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gc5lv1oap0ommnp9nu/etnfskduul53l4opdt72"
        dynamodb_table    = "tfstate-develop"
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

module "vpc_prod" {
  source = "./vpc"
  env_name = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-c", cidr = "10.0.3.0/24" }
  ]
}

module "vpc_dev" {
  source         = "./vpc"
  env_name       = "develop"
  subnets = [
    {zone        ="ru-central1-a", 
    cidr         = "10.0.1.0/24"}
  ]
}

module "test-vm" {
  source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=95c286e"
  env_name        = "develop"
  network_id      = module.vpc_dev.network_id
  subnet_zones    = ["ru-central1-a"]
  subnet_ids      = [ module.vpc_dev.subnet_id ]
  instance_name   = "web"
  instance_count  = 1
  image_family    = "ubuntu-2004-lts"
  public_ip       = true
  
  metadata = {
      user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
      serial-port-enable = 1
  }
}

#Пример передачи cloud-config в ВМ для демонстрации №3
data "template_file" "cloudinit" {
 template = file("./cloud-init.yml")
 vars = {
   ssh-authorized-keys = file(var.ssh-authorized-keys[0])
  }
}