# Домашнее задание к занятию "`Продвинутые методы работы с Terraform`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

1. Возьмите из [демонстрации к лекции готовый код](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1) для создания ВМ с помощью remote-модуля.
2. Создайте одну ВМ, используя этот модуль. В файле cloud-init.yml необходимо использовать переменную для ssh-ключа вместо хардкода. Передайте ssh-ключ в функцию template_file в блоке vars ={} .
Воспользуйтесь [**примером**](https://grantorchard.com/dynamic-cloudinit-content-with-terraform-file-templates/). Обратите внимание, что ssh-authorized-keys принимает в себя список, а не строку.
3. Добавьте в файл cloud-init.yml установку nginx.
4. Предоставьте скриншот подключения к консоли и вывод команды ```sudo nginx -t```.

</details>

### Решение:

1. Возьмем из [демонстрации к лекции готовый код](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1) для создания ВМ с помощью remote-модуля.

2. Создадим одну ВМ, используя этот модуль (установим параметр ```instance_count  = 1``` в модуле ```test-vm```).

В файл ```variables.tf``` добавим переменную ключа:  
```hcl
variable "ssh-authorized-keys" {
  description = "The path to the public ssh key file"
  type    = list(string)
  default = ["/home/baryshnikov/.ssh/id_ed25519.pub"]
}
```

Передадим cloud-config в ВМ:
```hcl
data "template_file" "cloudinit" {
 template = file("./cloud-init.yml")
 vars = {
   ssh-authorized-keys = file(var.ssh-authorized-keys[0])
  }
}
```

3. Добавим в файл cloud-init.yml установку nginx.

4. Подключимся через ssh к ВМ:

Скриншот 1 - Подключение к консоли и вывод команды ```sudo nginx -t```.
![Скриншот-1](/TER-35/ter/17.4-ter-04/img/17.4.1_Подключение_к_консоли.png)

---

## Задание 2.
<details>
	<summary></summary>
      <br>

1. Напишите локальный модуль vpc, который будет создавать 2 ресурса: **одну** сеть и **одну** подсеть в зоне, объявленной при вызове модуля, например: ```ru-central1-a```.
2. Вы должны передать в модуль переменные с названием сети, zone и v4_cidr_blocks.
3. Модуль должен возвращать в root module с помощью output информацию о yandex_vpc_subnet. Пришлите скриншот информации из terraform console о своем модуле. Пример: > module.vpc_dev  
4. Замените ресурсы yandex_vpc_network и yandex_vpc_subnet созданным модулем. Не забудьте передать необходимые параметры сети из модуля vpc в модуль с виртуальной машиной.
5. Откройте terraform console и предоставьте скриншот содержимого модуля. Пример: > module.vpc_dev.
6. Сгенерируйте документацию к модулю с помощью terraform-docs.    
 
Пример вызова

```
module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  zone = "ru-central1-a"
  cidr = "10.0.1.0/24"
}
```

</details>

### Решение:

1. Напишем локальный модуль vpc, который будет создавать 2 ресурса: **одну** сеть и **одну** подсеть в зоне, объявленной при вызове модуля.  
2. Воспользуемся в модуле переменными с названием сети, zone и v4_cidr_blocks.

```hcl
variable "env_name" {
  type        = string
  description = "Имя облачной сети"
}

variable "zone" {
  type        = string
  description = "Зона доступности"
}

variable "v4_cidr_blocks" {
  type        = string
  description = "cidr блок"
}
```

3. Скриншот информации из terraform console о модуле.

Скриншот 2 - Вывод команды module.vpc_dev.
![Скриншот-2](/TER-35/ter/17.4-ter-04/img/17.4.2_Вывод_команды_module.vpc_dev.png)

4. Заменим ресурсы yandex_vpc_network и yandex_vpc_subnet созданным модулем.

```hcl
module "test-vm" {
  source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
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
```

5. Сгенерируем документацию к модулю с помощью terraform-docs. Для этого воспользуемся следующей командой:  
```bash
sudo docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs > doc.md
```

---

## Задание 3.
<details>
	<summary></summary>
      <br>

1. Выведите список ресурсов в стейте.
2. Полностью удалите из стейта модуль vpc.
3. Полностью удалите из стейта модуль vm.
4. Импортируйте всё обратно. Проверьте terraform plan. Изменений быть не должно.
Приложите список выполненных команд и скриншоты процессы.

</details>

### Решение:

1. Выведем список ресурсов в стейте.  
```bash
terraform state list
```

2. Полностью удалим из стейта модуль vpc.  
```bash
terraform state rm module.vpc_dev
```

3. Полностью удалим из стейта модуль vm.  
```bash
terraform state rm module.test-vm
```

Скриншот 3 - Удаление ресурсов state.
![Скриншот-3](/TER-35/ter/17.4-ter-04/img/17.4.3.1_Удаление_ресурсов_state.png)

4. Импортируем всё обратно.

Модуль vpc (network):  
```bash
terraform import module.vpc_dev.yandex_vpc_network.vpc enpb8m637pv3qt7vp4rk
```

Скриншот 4 - Импорт module.vpc_dev.yandex_vpc_network.vpc.
![Скриншот-4](/TER-35/ter/17.4-ter-04/img/17.4.3.2_Импорт_module.vpc_dev.yandex_vpc_network.vpc.png)

Модуль vpc (subnet):  
```bash
terraform import module.vpc_dev.yandex_vpc_subnet.subnet e9bnvrthg73vjjqu44c6
```

Скриншот 5 - Импорт module.vpc_dev.yandex_vpc_subnet.
![Скриншот-5](/TER-35/ter/17.4-ter-04/img/17.4.3.3_Импорт_module.vpc_dev.yandex_vpc_subnet.png)

Модуль vm:  
```bash
terraform import module.test-vm.yandex_compute_instance.vm[0] fhm4am90sj85bt8lli1g
```

Скриншот 6 - Импорт module.test-vm.yandex_compute_instance.vm.
![Скриншот-6](/TER-35/ter/17.4-ter-04/img/17.4.3.4_Импорт_module.test-vm.yandex_compute_instance.vm.png)

---

## Задание 4*.
<details>
	<summary></summary>
      <br>

1. Измените модуль vpc так, чтобы он мог создать подсети во всех зонах доступности, переданных в переменной типа list(object) при вызове модуля.  
  
Пример вызова
```
module "vpc_prod" {
  source       = "./vpc"
  env_name     = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-c", cidr = "10.0.3.0/24" },
  ]
}

module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
}
```

Предоставьте код, план выполнения, результат из консоли YC.

</details>

### Решение:

1. Изменим модуль vpc так, чтобы он мог создать подсети во всех зонах доступности, переданных в переменной типа list(object) при вызове модуля.

План выполнения:

```
baryshnikov@debian:~/ds1$ terraform plan
module.test-vm.data.yandex_compute_image.my_image: Reading...
data.template_file.cloudinit: Reading...
data.template_file.cloudinit: Read complete after 0s [id=*********]
module.test-vm.data.yandex_compute_image.my_image: Read complete after 0s [id=*******]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # module.test-vm.yandex_compute_instance.vm[0] will be created
  + resource "yandex_compute_instance" "vm" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + description               = "TODO: description; {{terraform managed}}"
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "develop-web-0"
      + id                        = (known after apply)
      + labels                    = {
          + "env"     = "develop"
          + "project" = "undefined"
        }
      + metadata                  = {
          + "serial-port-enable" = "1"
          + "user-data"          = <<-EOT
                #cloud-config
                users:
                  - name: ubuntu
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL']
                    ssh_authorized_keys:
                      - ssh-ed25519 **********
                
                package_update: true
                package_upgrade: false
                packages:
                 - vim
                 - nginx
            EOT
        }
      + name                      = "develop-web-0"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd85an6q1o26nf37i2nl"
              + name        = (known after apply)
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # module.vpc_dev.yandex_vpc_network.vpc_net will be created
  + resource "yandex_vpc_network" "vpc_net" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "develop-network"
      + subnet_ids                = (known after apply)
    }

  # module.vpc_dev.yandex_vpc_subnet.vpc_subnet["ru-central1-a"] will be created
  + resource "yandex_vpc_subnet" "vpc_subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "develop-ru-central1-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.0.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # module.vpc_prod.yandex_vpc_network.vpc_net will be created
  + resource "yandex_vpc_network" "vpc_net" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "production-network"
      + subnet_ids                = (known after apply)
    }

  # module.vpc_prod.yandex_vpc_subnet.vpc_subnet["ru-central1-a"] will be created
  + resource "yandex_vpc_subnet" "vpc_subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "production-ru-central1-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.0.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # module.vpc_prod.yandex_vpc_subnet.vpc_subnet["ru-central1-b"] will be created
  + resource "yandex_vpc_subnet" "vpc_subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "production-ru-central1-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.0.2.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # module.vpc_prod.yandex_vpc_subnet.vpc_subnet["ru-central1-c"] will be created
  + resource "yandex_vpc_subnet" "vpc_subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "production-ru-central1-c"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.0.3.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-c"
    }

Plan: 7 to add, 0 to change, 0 to destroy.
╷
│ Warning: Version constraints inside provider configuration blocks are deprecated
│ 
│   on .terraform/modules/test-vm/providers.tf line 2, in provider "template":
│    2:   version = "2.2.0"
│ 
│ Terraform 0.13 and earlier allowed provider version constraints inside the provider configuration block, but that is now
│ deprecated and will be removed in a future version of Terraform. To silence this warning, move the provider version
│ constraint into the required_providers block.
```

Скриншот 7 - Созданные облачные сети.
![Скриншот-7](/TER-35/ter/17.4-ter-04/img/17.4.4.1_Облачные_сети.png)

Скриншот 8 - Созданные подсети.
![Скриншот-8](/TER-35/ter/17.4-ter-04/img/17.4.4.2_Подсети.png)

---