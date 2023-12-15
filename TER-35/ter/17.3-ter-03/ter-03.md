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