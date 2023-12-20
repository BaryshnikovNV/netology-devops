# Домашнее задание к занятию "`Управляющие конструкции в коде Terraform`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

1. Изучите проект.
2. Заполните файл personal.auto.tfvars.
3. Инициализируйте проект, выполните код. Он выполнится, даже если доступа к preview нет.

Примечание. Если у вас не активирован preview-доступ к функционалу «Группы безопасности» в Yandex Cloud, запросите доступ у поддержки облачного провайдера. Обычно его выдают в течение 24-х часов.

Приложите скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud или скриншот отказа в предоставлении доступа к preview-версии.

</details>

### Решение:

Заполним файл personal.auto.tfvars.

Скриншот 1 - Скриншот входящих правил «Группы безопасности» с именем example_dynamic в ЛК Yandex Cloud.
![Скриншот-1](/TER-35/ter/17.3-ter-03/img/17.3.1_Скриншот_входящих_правил_Группы_безопасности_в_ЛК_Yandex_Cloud.png)

---

## Задание 2.
<details>
	<summary></summary>
      <br>

1. Создайте файл count-vm.tf. Опишите в нём создание двух **одинаковых** ВМ  web-1 и web-2 (не web-0 и web-1) с минимальными параметрами, используя мета-аргумент **count loop**. Назначьте ВМ созданную в первом задании группу безопасности.(как это сделать узнайте в документации провайдера yandex/compute_instance )
2. Создайте файл for_each-vm.tf. Опишите в нём создание двух ВМ для баз данных с именами "main" и "replica" **разных** по cpu/ram/disk , используя мета-аргумент **for_each loop**. Используйте для обеих ВМ одну общую переменную типа:
```
variable "each_vm" {
  type = list(object({  vm_name=string, cpu=number, ram=number, disk=number }))
}
```  
При желании внесите в переменную все возможные параметры.
4. ВМ из пункта 2.1 должны создаваться после создания ВМ из пункта 2.2.
5. Используйте функцию file в local-переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata, взятому из ДЗ 2.
6. Инициализируйте проект, выполните код.

</details>

### Решение:

1. Создадим файл count-vm.tf. Опишем в нём создание двух одинаковых ВМ web-1 и web-2 с минимальными параметрами, используя мета-аргумент count loop:

```HCL
resource "yandex_compute_instance" "web" {
  count = 2
  name = "web-${count.index+1}"
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vms_resources.vm_web_resources.cores
    memory        = var.vms_resources.vm_web_resources.memory
    core_fraction = var.vms_resources.vm_web_resources.core_fraction
  }
```

Назначим ВМ группу безопасности:

```HCL
network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
```

2. Создадим файл for_each-vm.tf. Опишим в нём создание двух ВМ для баз данных с именами "main" и "replica" **разных** по cpu/ram/disk, используя мета-аргумент **for_each loop**. 

```HCL
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
```

4. Настроим создание ВМ из пункта 2.2 после создания ВМ из пункта 2.1:

```HCL
  depends_on = [ yandex_compute_instance.web ]
```

5. Используем функцию file в local-переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata, взятому из ДЗ 2:

```HCL
locals {
    ssh-keys = file("~/.ssh/id_ed25519.pub")
}

metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${local.ssh-keys}"
  }
```

Инициализируем и выполним код.

Скриншот 2 - Выполнение кода проекта.
![Скриншот-2](/TER-35/ter/17.3-ter-03/img/17.3.2_Выполнение_кода_проекта.png)

---

## Задание 3.
<details>
	<summary></summary>
      <br>

1. Создайте 3 одинаковых виртуальных диска размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле **disk_vm.tf** .
2. Создайте в том же файле **одиночную**(использовать count или for_each запрещено из-за задания №4) ВМ c именем "storage"  . Используйте блок **dynamic secondary_disk{..}** и мета-аргумент for_each для подключения созданных вами дополнительных дисков.

</details>

### Решение:

1. Создадим 3 одинаковых виртуальных диска размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле **disk_vm.tf**.

```HCL
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

resource "yandex_compute_disk" "disks" {
    name  = "${var.storage_disk[0].for_storage.name}-${count.index+1}"
    type  = var.storage_disk[0].for_storage.type
    size  = var.storage_disk[0].for_storage.size
    count = var.storage_disk[0].for_storage.count
}
``` 

2. Создадим в том же файле одиночную ВМ c именем "storage". Используем блок dynamic secondary_disk{..} и мета-аргумент for_each для подключения созданных дополнительных дисков.

```HCL
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
```

---

## Задание 4.
<details>
	<summary></summary>
      <br>

1. В файле ansible.tf создайте inventory-файл для ansible.
Используйте функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла из лекции.
Готовый код возьмите из демонстрации к лекции [**demonstration2**](https://github.com/netology-code/ter-homeworks/tree/main/03/demonstration2).
Передайте в него в качестве переменных группы виртуальных машин из задания 2.1, 2.2 и 3.2, т. е. 5 ВМ.
2. Инвентарь должен содержать 3 группы и быть динамическим, т. е. обработать как группу из 2-х ВМ, так и 999 ВМ.
3. Добавьте в инвентарь переменную  [**fqdn**](https://cloud.yandex.ru/docs/compute/concepts/network#hostname).
``` 
[webservers]
web-1 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
web-2 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[databases]
main ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
replica ansible_host<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[storage]
storage ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
```
Пример fqdn: ```web1.ru-central1.internal```(в случае указания имени ВМ); ```fhm8k1oojmm5lie8i22a.auto.internal```(в случае автоматической генерации имени ВМ зона изменяется). ужную вам переменную найдите в документации провайдера или terraform console.
4. Выполните код. Приложите скриншот получившегося файла. 

Для общего зачёта создайте в вашем GitHub-репозитории новую ветку terraform-03. Закоммитьте в эту ветку свой финальный код проекта, пришлите ссылку на коммит.   
**Удалите все созданные ресурсы**.

</details>

### Решение:

1. Создадим файл ansible.tf. Напишем код используя функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла опираясь на пример из демонстрации к лекции.

Файл ansible.tf:  
```HCL
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tftpl",
  {webservers = yandex_compute_instance.web
  databases = yandex_compute_instance.for_each
  storage = [yandex_compute_instance.storage]})
  filename = "${abspath(path.module)}/hosts.cfg"
}
```

2. Создадим inventory-файл, содержащий 3 группы.

Файл hosts.tftpl:  
```HCL
[webservers]

%{~ for i in webservers ~}

${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]}
%{~ endfor ~}


[databases]

%{~ for i in databases ~}

${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]}
%{~ endfor ~}


[storage]

%{~ for i in storage ~}

${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]}
%{~ endfor ~}
```

3. Скриншот файла hosts.cfg

Скриншот 3 - Скриншот файла hosts.cfg.
![Скриншот-3](/TER-35/ter/17.3-ter-03/img/17.3.4_Скриншот_файла_hosts.cfg.png)
```

---