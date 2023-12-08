# Домашнее задание к занятию "`Основы Terraform. Yandex Cloud`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

В качестве ответа всегда полностью прикладывайте ваш terraform-код в git.  Убедитесь что ваша версия **Terraform** =1.5.Х (версия 1.6.Х может вызывать проблемы с Яндекс провайдером) 

1. Изучите проект. В файле variables.tf объявлены переменные для Yandex provider.
2. Переименуйте файл personal.auto.tfvars_example в personal.auto.tfvars. Заполните переменные: идентификаторы облака, токен доступа. Благодаря .gitignore этот файл не попадёт в публичный репозиторий.\
   **Необязательное задание\*:** попробуйте самостоятельно разобраться с документацией и использовать авторизацию terraform provider с помощью [service_account_key_file](https://terraform-provider.yandexcloud.net).\
   Настройка провайдера при этом будет выглядеть следующим образом:
```
provider "yandex" {
  service_account_key_file = file("~/.authorized_key.json")
  folder_id                = var.folder_id
  cloud_id                 = var.cloud_id
}
```
4. Сгенерируйте новый или используйте свой текущий ssh-ключ. Запишите его открытую(public) часть в переменную **vms_ssh_public_root_key**.
5. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте, в чём заключается их суть.
6. Подключитесь к консоли ВМ через ssh и выполните команду ``` curl ifconfig.me```.
Примечание: К OS ubuntu "out of a box, те из коробки" необходимо подключаться под пользователем ubuntu: ```"ssh ubuntu@vm_ip_address"```. Предварительно убедитесь, что ваш ключ добавлен в ssh-агент: ```eval $(ssh-agent) && ssh-add``` Вы познакомитесь с тем как при создании ВМ создать своего пользователя в блоке metadata в следующей лекции.;
8. Ответьте, как в процессе обучения могут пригодиться параметры ```preemptible = true``` и ```core_fraction=5``` в параметрах ВМ.

В качестве решения приложите:

- скриншот ЛК Yandex Cloud с созданной ВМ, где видно внешний ip-адрес;
- скриншот консоли, curl должен отобразить тот же внешний ip-адрес;
- ответы на вопросы.

</details>

### Решение:

5. При выполнении команды ```terraform apply``` на экране появилась ошибка:

```
╷
│ Error: Error while requesting API to create instance: server-request-id = fca69a17-51e3-4f2f-b39f-89fd41cd5469 server-trace-id = 8d45a0229503bad6:8cc9edae7d5dd220:8d45a0229503bad6:1 client-request-id = f2861886-a98a-40c8-b02b-3fc536e8ccad client-trace-id = 849e896e-ddbd-490b-9c35-fe4e7318739e rpc error: code = FailedPrecondition desc = Platform "standart-v4" not found
│ 
│   with yandex_compute_instance.platform,
│   on main.tf line 15, in resource "yandex_compute_instance" "platform":
│   15: resource "yandex_compute_instance" "platform" {
│ 
╵
```

Скриншот 1 - Ошибка при выполнении ```terraform apply```.
![Скриншот-1](/TER-35/ter/17.2-ter-02/img/17.2.1.5.1_Ошибка_при_выполнении_terraform_apply.png)

При просмотре блока resource **"yandex_compute_instance" "platform"** начинающегося со сторки 15, были выявлены следующие ошибки:
- в строке 17, где задается платформа, есть ошибка в названии платформы, а также в ее версии. Платформа должна называться *standard*, a не *standart* (https://docs.comcloud.xyz/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance) и версией она может быть не больше v3 (https://cloud.yandex.ru/docs/compute/concepts/vm-platforms);
- в строке 19 указано 1 ядро, хотя минимально может быть только 2 ядра (https://cloud.yandex.ru/docs/compute/concepts/performance-levels).

Таким образом, исправленный код блока ресурса должен выглядить следующем образом:

```hcl
resource "yandex_compute_instance" "platform" {
  name        = "netology-develop-platform-web"
  platform_id = "standard-v1"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
```

После исправления вышеуказанных ошибок ВМ успешно создается.  

Скриншот 2 - Создание ВМ после исправления ошибок.
![Скриншот-2](/TER-35/ter/17.2-ter-02/img/17.2.1.5.2_Создание_ВМ_после_исправления_ошибок.png)

Скриншот 3 - ЛК Yandex Cloud с созданной ВМ, где видно внешний ip-адрес.
![Скриншот-3](/TER-35/ter/17.2-ter-02/img/17.2.1.5.3_ЛК_Yandex_Cloud_с_созданной_ВМ,_где_видно_внешний_ip-адрес.png)

6. Подключение к консоли ВМ через ssh и выполнение команды ```curl ifconfig.me```.  

Скриншот 4 - Подключение по SSH.
![Скриншот-4](/TER-35/ter/17.2-ter-02/img/17.2.1.6_Подключение_по_SSH.png)

7. Параметр ```preemptible = true``` позволяет создать прерываемую ВМ.

Прерываемые виртуальные машины — это виртуальные машины, которые могут быть принудительно остановлены в любой момент. Это может произойти в двух случаях:  
- Если с момента запуска виртуальной машины прошло 24 часа.  
- Если возникнет нехватка ресурсов для запуска обычной виртуальной машины в той же зоне доступности. Вероятность такого события низкая, но может меняться изо дня в день.

Прерываемые виртуальные машины доступны по более низкой цене в сравнении с обычными, однако не обеспечивают отказоустойчивости.

Параметр ```core_fraction``` указывает базовую производительность ядра в процентах. Данный параметр позволяет сэкономить на ВМ.

---

## Задание 2.
<details>
	<summary></summary>
      <br>

1. Изучите файлы проекта.
2. Замените все хардкод-**значения** для ресурсов **yandex_compute_image** и **yandex_compute_instance** на **отдельные** переменные. К названиям переменных ВМ добавьте в начало префикс **vm_web_** .  Пример: **vm_web_name**.
2. Объявите нужные переменные в файле variables.tf, обязательно указывайте тип переменной. Заполните их **default** прежними значениями из main.tf. 
3. Проверьте terraform plan. Изменений быть не должно.

</details>

### Решение:

1. Изучим файлы проекта.  
2. Заменим все хардкод-**значения** для ресурсов **yandex_compute_image** и **yandex_compute_instance** на **отдельные** переменные. К названиям переменных ВМ добавим в начало префикс **vm_web_** :  
```HCL
data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}
resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id
  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }
```  
3. Объявим нужные переменные в файле variables.tf, с указанием типа переменной. Заполним их **default** прежними значениями из main.tf:  
```HCL
###yandex_compute_image vars

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "ubuntu image"
}

###yandex_compute_instance vars

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

variable "vm_web_cores" {
  type        = string
  default     = "2"
  description = "vCPU numbers"
}

variable "vm_web_memory" {
  type        = string
  default     = "1"
  description = "VM memory, Gb"
}

variable "vm_web_core_fraction" {
  type        = string
  default     = "5"
  description = "core fraction"
}
```

4. Проверим terraform plan. Изменений нет.  

Скриншот 5 - Выпонение terraform plan.
![Скриншот-5](/TER-35/ter/17.2-ter-02/img/17.2.2_Выпонение_terraform_plan.png)

---

## Задание 3.
<details>
	<summary></summary>
      <br>

1. Создайте в корне проекта файл 'vms_platform.tf' . Перенесите в него все переменные первой ВМ.
2. Скопируйте блок ресурса и создайте с его помощью вторую ВМ в файле main.tf: **"netology-develop-platform-db"** ,  ```cores  = 2, memory = 2, core_fraction = 20```. Объявите её переменные с префиксом **vm_db_** в том же файле ('vms_platform.tf').
3. Примените изменения.

</details>

### Решение:

1. Создадим в корне проекта файл 'vms_platform.tf'. Перенесем в него все переменные первой ВМ.  
2. Скопируем блок ресурса и создадим с его помощью вторую ВМ в файле main.tf: **"netology-develop-platform-db"** , ```cores  = 2, memory = 2, core_fraction = 20```. Объявим её переменные с префиксом **vm_db_** в том же файле ('vms_platform.tf').

Содержимое файла 'vms_platform.tf':  
```HCL
###yandex_compute_image vars for db

variable "vm_db_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "ubuntu image"
}

###yandex_compute_instance vars for db

variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "instance name"
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "platform ID"
}

variable "vm_db_cores" {
  type        = string
  default     = "2"
  description = "vCPU numbers"
}

variable "vm_db_memory" {
  type        = string
  default     = "2"
  description = "VM memory, Gb"
}

variable "vm_db_core_fraction" {
  type        = string
  default     = "20"
  description = "core fraction"
}
```

Добавление второй ВМ в файл main.tf:    
```HCL
###VM №2

data "yandex_compute_image" "ubuntu_2" {
  family = var.vm_db_family
}
resource "yandex_compute_instance" "platform_2" {
  name        = var.vm_db_name
  platform_id = var.vm_db_platform_id
  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
  }

}
```

3. Применим изменения в конфигурацию выполнив terraform apply.

Скриншот 6 - Применение изменений в конфигурацию.
![Скриншот-6](/TER-35/ter/17.2-ter-02/img/17.2.3.1_Применение_изменений_в_конфигурацию_выполненив_terraform_apply.png)

Скриншот 7 - ЛК Yandex Cloud с созданной второй ВМ.
![Скриншот-7](/TER-35/ter/17.2-ter-02/img/17.2.3.2_ЛК_Yandex_Cloud_с_созданной_второй_ВМ.png)

---