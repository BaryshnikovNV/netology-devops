# Домашнее задание к занятию "`Вычислительные мощности. Балансировщики нагрузки`" - `Барышников Никита`


### Задание 1. Yandex Cloud
<details>
	<summary></summary>
      <br>

**Что нужно сделать**

1. Создать бакет Object Storage и разместить в нём файл с картинкой:

 - Создать бакет в Object Storage с произвольным именем (например, _имя_студента_дата_).
 - Положить в бакет файл с картинкой.
 - Сделать файл доступным из интернета.
 
2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и веб-страницей, содержащей ссылку на картинку из бакета:

 - Создать Instance Group с тремя ВМ и шаблоном LAMP. Для LAMP рекомендуется использовать `image_id = fd827b91d99psvq5fjit`.
 - Для создания стартовой веб-страницы рекомендуется использовать раздел `user_data` в [meta_data](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata).
 - Разместить в стартовой веб-странице шаблонной ВМ ссылку на картинку из бакета.
 - Настроить проверку состояния ВМ.
 
3. Подключить группу к сетевому балансировщику:

 - Создать сетевой балансировщик.
 - Проверить работоспособность, удалив одну или несколько ВМ.
4. (дополнительно)* Создать Application Load Balancer с использованием Instance group и проверкой состояния.

Полезные документы:

- [Compute instance group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance_group).
- [Network Load Balancer](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer).
- [Группа ВМ с сетевым балансировщиком](https://cloud.yandex.ru/docs/compute/operations/instance-groups/create-with-balancer).

</details>

#### Решение:

1. Создать бакет Object Storage и разместить в нём файл с картинкой:

- Создадим бакет в Object Storage.

Файл bucket.tf
```hcl
# Cервисный аккаунт для backet
resource "yandex_iam_service_account" "service" {
  folder_id = var.folder_id
  name      = "bucket-sa"
}

# Роль сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "bucket-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.service.id}"
  depends_on = [yandex_iam_service_account.service]
}

# Статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.service.id
  description        = "static access key for object storage"
}

# Создадим бакет с использованием ключа
resource "yandex_storage_bucket" "baryshnikov-nv" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = local.bucket_name
  acl    = "public-read" # открыте публичного доступа для просмотра
}

# Локальная переменная отвечающая за текущую дату в названии бакета
locals {
    current_timestamp = timestamp()
    formatted_date = formatdate("DD-MM-YYYY", local.current_timestamp)
    bucket_name = "baryshnikov-nv-${local.formatted_date}"
}
```

- Положим в бакет файл с картинкой.

Файл object.tf
```hcl
# Создание объекта в существующей папке с изображением кошки
resource "yandex_storage_object" "cute-cat-picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = local.bucket_name
  key    = "cute-cat-picture.jpg"
  source = "./cute-cat-picture.jpg"
  acl = "public-read"
  depends_on = [yandex_storage_bucket.baryshnikov-nv]
}
```

- Сделаем файл доступным из интернета.

С помощью настройки аргумената acl откроем доступ к файлу для чтения.

Далее, выполним `terraform apply` и проверим создание бакета:
```bash
baryshnikov@debian:~$ yc storage bucket list
+---------------------------+----------------------+----------+-----------------------+---------------------+
|           NAME            |      FOLDER ID       | MAX SIZE | DEFAULT STORAGE CLASS |     CREATED AT      |
+---------------------------+----------------------+----------+-----------------------+---------------------+
| baryshnikov-nv-11-07-2024 | b1ghnkadavleanbnn9ut |        0 | STANDARD              | 2024-07-11 14:39:39 |
+---------------------------+----------------------+----------+-----------------------+---------------------+

baryshnikov@debian:~$ 
baryshnikov@debian:~$ 
baryshnikov@debian:~$ yc storage bucket stats --name baryshnikov-nv-11-07-2024
name: baryshnikov-nv-11-07-2024
default_storage_class: STANDARD
anonymous_access_flags:
  read: true
  list: true
  config_read: true
created_at: "2024-07-11T14:39:39.169356Z"
updated_at: "2024-07-11T14:39:39.169356Z"
```

2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и веб-страницей, содержащей ссылку на картинку из бакета:

Создадим сеть и public подсеть фиксированного размера:
```hcl
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
```

- Создадим [Instance Group с тремя ВМ и шаблоном LAMP](./config/group_vm.tf).

- Создадим стартовую веб-страницу используя раздел `user_data` в [meta_data](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata) и разместим в стартовой веб-странице шаблонной ВМ ссылку на картинку из бакета.
```hcl
#Создание стартовой веб-страницы
    user-data  = <<EOF
#!/bin/bash
cd /var/www/html
echo '<html><img src="http://${yandex_storage_bucket.baryshnikov-nv.bucket_domain_name}/cute-cat-picture.jpg"/></html>' > index.html
EOF
```

- Настроим проверку состояния ВМ (проверка состояния выполняется каждые 30 секунд и считается успешной, если подключение к порту 80 виртуальной машины происходит успешно в течении 10 секунд).
```hcl
# Проверка состояния ВМ
  health_check {
    interval = 30
    timeout  = 10
    tcp_options {
      port = 80
    }
  }
```

3. Подключить группу к сетевому балансировщику:

- Создадим сетевой балансировщик.

Файл network_load_balancer.tf
```hcl
resource "yandex_lb_network_load_balancer" "network-load-balancer" {
  name = "balancer"
  deletion_protection = "false"
  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_compute_instance_group.group-vms.load_balancer[0].target_group_id
    
    healthcheck {
      name = "http"
      interval = 2
      timeout = 1
      unhealthy_threshold = 2
      healthy_threshold = 5
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
```

Балансировщик нагрузки будет проверять доступность порта 80 и путь "/" при обращении к целевой группе виртуальных машин. Проверка будет выполняться с интервалом 2 секунды, с таймаутом 1 секунда. Пороговые значения для определения состояния сервера будут следующими: 2 неудачные проверки для перевода сервера LAMP в недоступное состояние и 5 успешных проверок для возврата в доступное состояние.

Выполним `terraform apply` и проверим создание балансировщика:
```bash
baryshnikov@debian:~$ yc load-balancer network-load-balancer list
+----------------------+----------+-------------+----------+----------------+------------------------+--------+
|          ID          |   NAME   |  REGION ID  |   TYPE   | LISTENER COUNT | ATTACHED TARGET GROUPS | STATUS |
+----------------------+----------+-------------+----------+----------------+------------------------+--------+
| enpb73h3b1t7bh5uchdm | balancer | ru-central1 | EXTERNAL |              1 | enpp8svjver9utgmtebc   | ACTIVE |
+----------------------+----------+-------------+----------+----------------+------------------------+--------+

```

Выведем список созданных ВМ:
```bash
baryshnikov@debian:~$ yc compute instance list
+----------------------+---------------------------+---------------+---------+----------------+-------------+
|          ID          |           NAME            |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+---------------------------+---------------+---------+----------------+-------------+
| fhm7tiflktk2mjiqo3mt | cl1u7lfduqo7e41qnjbo-ozob | ru-central1-a | RUNNING | 158.160.35.130 | 10.0.1.30   |
| fhmlsriijhhmm6lka3vb | cl1u7lfduqo7e41qnjbo-yzem | ru-central1-a | RUNNING | 158.160.44.202 | 10.0.1.34   |
| fhmmc5op0q0nsjveh1ll | cl1u7lfduqo7e41qnjbo-ycaj | ru-central1-a | RUNNING | 51.250.73.219  | 10.0.1.18   |
+----------------------+---------------------------+---------------+---------+----------------+-------------+

```

Отобразим состояние целевых ресурсов в прикрепленной целевой группе:
```bash
baryshnikov@debian:~$ yc load-balancer network-load-balancer target-states --id enpb73h3b1t7bh5uchdm --target-group-id enpp8svjver9utgmtebc
+----------------------+-----------+---------+
|      SUBNET ID       |  ADDRESS  | STATUS  |
+----------------------+-----------+---------+
| e9bk7ks8hgckcielqvbt | 10.0.1.18 | HEALTHY |
| e9bk7ks8hgckcielqvbt | 10.0.1.30 | HEALTHY |
| e9bk7ks8hgckcielqvbt | 10.0.1.34 | HEALTHY |
+----------------------+-----------+---------+

```

Определим ip-адрес балансировщика:
```bash
baryshnikov@debian:~$ yc load-balancer network-load-balancer get balancer
id: enpb73h3b1t7bh5uchdm
folder_id: b1ghnkadavleanbnn9ut
created_at: "2024-07-11T17:32:48Z"
name: balancer
region_id: ru-central1
status: ACTIVE
type: EXTERNAL
listeners:
  - name: my-listener
    address: 158.160.142.219
    port: "80"
    protocol: TCP
    target_port: "80"
    ip_version: IPV4
attached_target_groups:
  - target_group_id: enpp8svjver9utgmtebc
    health_checks:
      - name: http
        interval: 2s
        timeout: 1s
        unhealthy_threshold: "2"
        healthy_threshold: "5"
        http_options:
          port: "80"
          path: /
```

Проверим доступность картинки:
```bash
baryshnikov@debian:~$ curl 158.160.142.219
<html><img src="http://baryshnikov-nv-11-07-2024.storage.yandexcloud.net/cute-cat-picture.jpg"/></html>
```

Таким образом можно сделать вывод, что балансировщик работает и картинка доступна из внешней сети.

- Проверим работоспособность, удалив несколько ВМ.
```bash
baryshnikov@debian:~$ yc load-balancer network-load-balancer list
+----------------------+----------+-------------+----------+----------------+------------------------+--------+
|          ID          |   NAME   |  REGION ID  |   TYPE   | LISTENER COUNT | ATTACHED TARGET GROUPS | STATUS |
+----------------------+----------+-------------+----------+----------------+------------------------+--------+
| enpb73h3b1t7bh5uchdm | balancer | ru-central1 | EXTERNAL |              1 | enpp8svjver9utgmtebc   | ACTIVE |
+----------------------+----------+-------------+----------+----------------+------------------------+--------+

baryshnikov@debian:~$ 
baryshnikov@debian:~$ 
baryshnikov@debian:~$ yc compute instance list
+----------------------+---------------------------+---------------+----------+---------------+-------------+
|          ID          |           NAME            |    ZONE ID    |  STATUS  |  EXTERNAL IP  | INTERNAL IP |
+----------------------+---------------------------+---------------+----------+---------------+-------------+
| fhm7tiflktk2mjiqo3mt | cl1u7lfduqo7e41qnjbo-ozob | ru-central1-a | DELETING |               |             |
| fhmlsriijhhmm6lka3vb | cl1u7lfduqo7e41qnjbo-yzem | ru-central1-a | DELETING |               |             |
| fhmmc5op0q0nsjveh1ll | cl1u7lfduqo7e41qnjbo-ycaj | ru-central1-a | RUNNING  | 51.250.73.219 | 10.0.1.18   |
+----------------------+---------------------------+---------------+----------+---------------+-------------+

baryshnikov@debian:~$ 
baryshnikov@debian:~$ 
baryshnikov@debian:~$ yc load-balancer network-load-balancer target-states --id enpb73h3b1t7bh5uchdm --target-group-id enpp8svjver9utgmtebc
+----------------------+-----------+---------+
|      SUBNET ID       |  ADDRESS  | STATUS  |
+----------------------+-----------+---------+
| e9bk7ks8hgckcielqvbt | 10.0.1.18 | HEALTHY |
+----------------------+-----------+---------+

baryshnikov@debian:~$ 
baryshnikov@debian:~$ 
baryshnikov@debian:~$ curl 158.160.142.219
<html><img src="http://baryshnikov-nv-11-07-2024.storage.yandexcloud.net/cute-cat-picture.jpg"/></html>
```

Не смотря на удаление нескольких вм, балансировщик все равно работает и картинка доступна из внешней сети.

---