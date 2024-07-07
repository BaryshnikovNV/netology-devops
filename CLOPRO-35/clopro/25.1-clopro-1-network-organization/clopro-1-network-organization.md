# Домашнее задание к занятию "`Организация сети`" - `Барышников Никита`


### Задание 1. Yandex Cloud
<details>
	<summary></summary>
      <br>

**Что нужно сделать**

1. Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 192.168.10.0/24.
 - Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1.
 - Создать в этой публичной подсети виртуалку с публичным IP, подключиться к ней и убедиться, что есть доступ к интернету.
3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 192.168.20.0/24.
 - Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.
 - Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее, и убедиться, что есть доступ к интернету.

Resource Terraform для Yandex Cloud:

- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet).
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table).
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance).

</details>

#### Решение:

1. Создадим пустую VPC с именем `vpc0`.
```hcl
resource "yandex_vpc_network" "vpc0" {
  name = var.vpc_name
}
```

2. Публичная подсеть

- Создадим в VPC subnet c названием public, сетью 192.168.10.0/24.
```hcl
resource "yandex_vpc_subnet" "public" {
  name           = var.public_subnet
  zone           = var.default_zone
  network_id     = yandex_vpc_network.dvl.id
  v4_cidr_blocks = var.public_cidr
}
```

- Создадим в этой подсети [NAT-инстанс](./config/nat-instance.tf), присвоив ему адрес 192.168.10.254. В качестве image_id используем fd80mrhj8fl2oe87o4e1.

- Создадим в этой публичной подсети [виртуалку с публичным IP](./config/public.tf).

1. Приватная подсеть.

- Создадим в VPC subnet с названием private, сетью 192.168.20.0/24.
```hcl
resource "yandex_vpc_subnet" "private" {
  name           = var.private_subnet
  zone           = var.default_zone
  network_id     = yandex_vpc_network.dvl.id
  v4_cidr_blocks = var.private_cidr
  route_table_id = yandex_vpc_route_table.private-route.id
}
```

- Создадим route table. Добавим статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.
```hcl
resource "yandex_vpc_route_table" "private-route" {
  name       = "private-route"
  network_id = yandex_vpc_network.dvl.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}
```

- Создадим в этой приватной подсети [виртуалку с внутренним IP](./config/private.tf).

Выполним команду `terraform apply`
<details>
        <summary></summary>
      <br>

```bash
baryshnikov@debian:~/clopro-1$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.nat will be created
  + resource "yandex_compute_instance" "nat" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "nat"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "serial-port-enable" = "1"
          + "ssh-keys"           = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1DQbMVBaaHPzULxhvTzw3zFG/jp0K1u3nBfdLFHdUreJgax7bE5xFDZVSZFPB1W3pPt4gDobrSrXE/PDWikGz9NCQe3VFqfWGDKqr81cBNWJtc7CUJ0pcPOFweDImaekiKCmIdLeNK6k2/5Zgn2/2t1uXLWX8YbnSQBr/sCAR3nGqDodZ1cXuGnZUJpEXFiN1JXWofP2vb+FyKsyJ3HxJkHyJ1thRab7jxF5yRIlv49MRZHzCKohdOM4Y/S32pmP3NvTajlW14CQHxEA11otbfUDMWDuHrgB1hsZbUjBXloDIT76r3LICzg/69Y6k7fxh8bc05I7fV5TA3ilZdsd6D1pe5c3pk0lzxzGlUdsB/9YU1iNlJludM7uumnyzRmRwiIbpMibr7RvoBxY0Dcdh1dEqD0aUreCaIQB8mtnO+gkw5qU+bSiY8GUt+ZDqr/8OF8vV+ty/UYcbNaNmegS7QK+maIcajXEkyz8iAiC42d6OpcTCTHrcJO4ewfk6gSc= baryshnikov@debian
            EOT
        }
      + name                      = "nat"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80mrhj8fl2oe87o4e1"
              + name        = (known after apply)
              + size        = 10
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = "192.168.10.254"
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
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.private will be created
  + resource "yandex_compute_instance" "private" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "private"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "serial-port-enable" = "1"
          + "ssh-keys"           = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1DQbMVBaaHPzULxhvTzw3zFG/jp0K1u3nBfdLFHdUreJgax7bE5xFDZVSZFPB1W3pPt4gDobrSrXE/PDWikGz9NCQe3VFqfWGDKqr81cBNWJtc7CUJ0pcPOFweDImaekiKCmIdLeNK6k2/5Zgn2/2t1uXLWX8YbnSQBr/sCAR3nGqDodZ1cXuGnZUJpEXFiN1JXWofP2vb+FyKsyJ3HxJkHyJ1thRab7jxF5yRIlv49MRZHzCKohdOM4Y/S32pmP3NvTajlW14CQHxEA11otbfUDMWDuHrgB1hsZbUjBXloDIT76r3LICzg/69Y6k7fxh8bc05I7fV5TA3ilZdsd6D1pe5c3pk0lzxzGlUdsB/9YU1iNlJludM7uumnyzRmRwiIbpMibr7RvoBxY0Dcdh1dEqD0aUreCaIQB8mtnO+gkw5qU+bSiY8GUt+ZDqr/8OF8vV+ty/UYcbNaNmegS7QK+maIcajXEkyz8iAiC42d6OpcTCTHrcJO4ewfk6gSc= baryshnikov@debian
            EOT
        }
      + name                      = "private"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8pbf0hl06ks8s3scqk"
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
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.public will be created
  + resource "yandex_compute_instance" "public" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "public"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "serial-port-enable" = "1"
          + "ssh-keys"           = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1DQbMVBaaHPzULxhvTzw3zFG/jp0K1u3nBfdLFHdUreJgax7bE5xFDZVSZFPB1W3pPt4gDobrSrXE/PDWikGz9NCQe3VFqfWGDKqr81cBNWJtc7CUJ0pcPOFweDImaekiKCmIdLeNK6k2/5Zgn2/2t1uXLWX8YbnSQBr/sCAR3nGqDodZ1cXuGnZUJpEXFiN1JXWofP2vb+FyKsyJ3HxJkHyJ1thRab7jxF5yRIlv49MRZHzCKohdOM4Y/S32pmP3NvTajlW14CQHxEA11otbfUDMWDuHrgB1hsZbUjBXloDIT76r3LICzg/69Y6k7fxh8bc05I7fV5TA3ilZdsd6D1pe5c3pk0lzxzGlUdsB/9YU1iNlJludM7uumnyzRmRwiIbpMibr7RvoBxY0Dcdh1dEqD0aUreCaIQB8mtnO+gkw5qU+bSiY8GUt+ZDqr/8OF8vV+ty/UYcbNaNmegS7QK+maIcajXEkyz8iAiC42d6OpcTCTHrcJO4ewfk6gSc= baryshnikov@debian
            EOT
        }
      + name                      = "public"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8pbf0hl06ks8s3scqk"
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
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.vpc0 will be created
  + resource "yandex_vpc_network" "vpc0" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "vpc0"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_route_table.private-route will be created
  + resource "yandex_vpc_route_table" "private-route" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + labels     = (known after apply)
      + name       = "private-route"
      + network_id = (known after apply)

      + static_route {
          + destination_prefix = "0.0.0.0/0"
          + next_hop_address   = "192.168.10.254"
        }
    }

  # yandex_vpc_subnet.private will be created
  + resource "yandex_vpc_subnet" "private" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "private"
      + network_id     = (known after apply)
      + route_table_id = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.20.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.public will be created
  + resource "yandex_vpc_subnet" "public" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "public"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.vpc0: Creating...
yandex_vpc_network.vpc0: Creation complete after 3s [id=enp7b9r2v1ppejn716c3]
yandex_vpc_subnet.public: Creating...
yandex_vpc_route_table.private-route: Creating...
yandex_vpc_subnet.public: Creation complete after 1s [id=e9bkdj3b0cilqmv657fp]
yandex_compute_instance.nat: Creating...
yandex_compute_instance.public: Creating...
yandex_vpc_route_table.private-route: Creation complete after 1s [id=enpp68saep9tlgsphnav]
yandex_vpc_subnet.private: Creating...
yandex_vpc_subnet.private: Creation complete after 1s [id=e9blf6bjqnkebguk7aea]
yandex_compute_instance.private: Creating...
yandex_compute_instance.public: Still creating... [10s elapsed]
yandex_compute_instance.nat: Still creating... [10s elapsed]
yandex_compute_instance.private: Still creating... [10s elapsed]
yandex_compute_instance.public: Still creating... [20s elapsed]
yandex_compute_instance.nat: Still creating... [20s elapsed]
yandex_compute_instance.private: Still creating... [20s elapsed]
yandex_compute_instance.public: Still creating... [30s elapsed]
yandex_compute_instance.nat: Still creating... [30s elapsed]
yandex_compute_instance.private: Still creating... [30s elapsed]
yandex_compute_instance.public: Creation complete after 32s [id=fhmkp0h4fpgcdpope8dc]
yandex_compute_instance.nat: Still creating... [40s elapsed]
yandex_compute_instance.private: Creation complete after 39s [id=fhmlb8sa4gv5ghqhsmgr]
yandex_compute_instance.nat: Still creating... [50s elapsed]
yandex_compute_instance.nat: Still creating... [1m0s elapsed]
yandex_compute_instance.nat: Creation complete after 1m6s [id=fhm2muj78cdteg7mql7r]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

</details>

Посмотрим созданные ресурсы с помощью CLI
```bash
baryshnikov@debian:~/clopro-1$ yc vpc network list
+----------------------+------+
|          ID          | NAME |
+----------------------+------+
| enp7b9r2v1ppejn716c3 | vpc0 |
+----------------------+------+

baryshnikov@debian:~/clopro-1$ yc vpc subnet list
+----------------------+---------+----------------------+----------------------+---------------+-------------------+
|          ID          |  NAME   |      NETWORK ID      |    ROUTE TABLE ID    |     ZONE      |       RANGE       |
+----------------------+---------+----------------------+----------------------+---------------+-------------------+
| e9bkdj3b0cilqmv657fp | public  | enp7b9r2v1ppejn716c3 |                      | ru-central1-a | [192.168.10.0/24] |
| e9blf6bjqnkebguk7aea | private | enp7b9r2v1ppejn716c3 | enpp68saep9tlgsphnav | ru-central1-a | [192.168.20.0/24] |
+----------------------+---------+----------------------+----------------------+---------------+-------------------+


baryshnikov@debian:~/clopro-1$ yc compute instance list
+----------------------+---------+---------------+---------+----------------+----------------+
|          ID          |  NAME   |    ZONE ID    | STATUS  |  EXTERNAL IP   |  INTERNAL IP   |
+----------------------+---------+---------------+---------+----------------+----------------+
| fhm2muj78cdteg7mql7r | nat     | ru-central1-a | RUNNING | 158.160.99.144 | 192.168.10.254 |
| fhmkp0h4fpgcdpope8dc | public  | ru-central1-a | RUNNING | 158.160.124.16 | 192.168.10.5   |
| fhmlb8sa4gv5ghqhsmgr | private | ru-central1-a | RUNNING |                | 192.168.20.18  |
+----------------------+---------+---------------+---------+----------------+----------------+

```

Подключимся к ВМ с публичным IP-адресом из публичной виртуальной сети и убедимся, что у нее есть доступ к интернету.
```bash
baryshnikov@debian:~/clopro-1$ ssh ubuntu@158.160.124.16
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-105-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sun Jul  7 07:05:38 AM UTC 2024

  System load:  0.0               Processes:             132
  Usage of /:   41.1% of 9.76GB   Users logged in:       0
  Memory usage: 10%               IPv4 address for eth0: 192.168.10.5
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@public:~$ 
ubuntu@public:~$ 
ubuntu@public:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=58 time=21.8 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=58 time=21.1 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=58 time=21.2 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=58 time=21.1 ms
^C
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 21.108/21.305/21.788/0.280 ms
```

Так как у ВМ из приватной виртуальной сети нет публичного IP-адреса, то для подключения к ней закинем в ВМ из публичной виртуальной сети приватный ssh-ключ. Далее подключимся из ВМ из публичной виртуальной сети к ВМ из внутренней по SSH и проверим, что эта ВМ имеет доступ в интернет.
```bash
ubuntu@public:~/.ssh$ ssh ubuntu@192.168.20.18
Enter passphrase for key '/home/ubuntu/.ssh/id_rsa': 
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-105-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sun Jul  7 07:17:12 AM UTC 2024

  System load:  0.0               Processes:             130
  Usage of /:   45.8% of 9.76GB   Users logged in:       0
  Memory usage: 10%               IPv4 address for eth0: 192.168.20.18
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@private:~$ 
ubuntu@private:~$ 
ubuntu@private:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=54 time=41.6 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=54 time=40.8 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=54 time=40.5 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=54 time=42.2 ms
^C
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 40.456/41.268/42.234/0.697 ms
```

---