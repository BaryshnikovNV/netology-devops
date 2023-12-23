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
erraform state rm module.vpc_dev
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