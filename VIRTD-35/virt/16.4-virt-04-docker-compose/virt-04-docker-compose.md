# Домашнее задание к занятию "`Оркестрация группой Docker-контейнеров на примере Docker Compose`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

Создайте собственный образ любой операционной системы (например, debian-11) с помощью Packer версии 1.7.0 . Перед выполнением задания изучите ([инструкцию!!!](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/packer-quickstart)). В инструкции указана минимальная версия 1.5, но нужно использовать 1.7, так как там есть нужный нам функционал


Чтобы получить зачёт, вам нужно предоставить скриншот страницы с созданным образом из личного кабинета YandexCloud.

</details>

### Решение:

Скриншот 1 - Скриншот из терминала с созданным образом.
![Скриншот-1](/VIRTD-35/virt/16.4-virt-04-docker-compose/img/16.4.1.1_Скриншот_из_терминала_с_созданным_образом.png)

Скриншот 2 - Скриншот страницы с созданным образом из личного кабинета YandexCloud.
![Скриншот-2](/VIRTD-35/virt/16.4-virt-04-docker-compose/img/16.4.1.2_Скриншот_страницы_с_созданным_образом.png)

---

## Задание 2.
<details>
	<summary></summary>
      <br>

**2.1.** Создайте вашу первую виртуальную машину в YandexCloud с помощью web-интерфейса YandexCloud.        

**2.2.*** **(Необязательное задание)**      
Создайте вашу первую виртуальную машину в YandexCloud с помощью Terraform (вместо использования веб-интерфейса YandexCloud).
Используйте Terraform-код в директории ([src/terraform](https://github.com/netology-group/virt-homeworks/tree/virt-11/05-virt-04-docker-compose/src/terraform)).

Чтобы получить зачёт, вам нужно предоставить вывод команды terraform apply и страницы свойств, созданной ВМ из личного кабинета YandexCloud.

</details>

### Решение:

**2.1.** Создадим первую виртуальную машину в YandexCloud с помощью web-интерфейса YandexCloud.

Скриншот 3 - Создание первой виртуальной машины в YandexCloud с помощью web-интерфейса YandexCloud.
![Скриншот-3](/VIRTD-35/virt/16.4-virt-04-docker-compose/img/16.4.2.1_Создание_первой_виртуальную_машины_в_Yandex.png)

**2.2.** Создадим первую виртуальную машину в YandexCloud с помощью Terraform.

Скриншот 4 - Вывод команды terraform apply.
![Скриншот-4](/VIRTD-35/virt/16.4-virt-04-docker-compose/img/16.4.2.2.1_Вывод_команды_terraform_apply.png)

Скриншот 5 - Страница свойств созданной ВМ из личного кабинета Yandex Cloud.
![Скриншот-5](/VIRTD-35/virt/16.4-virt-04-docker-compose/img/16.4.2.2.2_Страница_свойств_созданной_ВМ_из_личного_кабинета_Yandex_Cloud.png)

---

## Задание 3.
<details>
	<summary></summary>
      <br>

С помощью Ansible и Docker Compose разверните на виртуальной машине из предыдущего задания систему мониторинга на основе Prometheus/Grafana.
Используйте Ansible-код в директории ([src/ansible](https://github.com/netology-group/virt-homeworks/tree/virt-11/05-virt-04-docker-compose/src/ansible)).

Чтобы получить зачёт, вам нужно предоставить вывод команды "docker ps" , все контейнеры, описанные в [docker-compose](https://github.com/netology-group/virt-homeworks/blob/virt-11/05-virt-04-docker-compose/src/ansible/stack/docker-compose.yaml),  должны быть в статусе "Up".

</details>

### Решение:

Скриншот 6 - Запуск playbook.
![Скриншот-6](/VIRTD-35/virt/16.4-virt-04-docker-compose/img/16.4.3.1_Запуск_playbook.png)

Скриншот 7 - Состояние всех контейнеров, описанных в docker-compose.
![Скриншот-7](/VIRTD-35/virt/16.4-virt-04-docker-compose/img/16.4.3.2_Состояние_всех_контейнеров,_описанных_в_docker-compose.png)

---

## Задание 4.
<details>
	<summary></summary>
      <br>

1. Откройте веб-браузер, зайдите на страницу http://<внешний_ip_адрес_вашей_ВМ>:3000.
2. Используйте для авторизации логин и пароль из [.env-file](https://github.com/netology-group/virt-homeworks/blob/virt-11/05-virt-04-docker-compose/src/ansible/stack/.env).
3. Изучите доступный интерфейс, найдите в интерфейсе автоматически созданные docker-compose-панели с графиками([dashboards](https://grafana.com/docs/grafana/latest/dashboards/use-dashboards/)).
4. Подождите 5-10 минут, чтобы система мониторинга успела накопить данные.

Чтобы получить зачёт, предоставьте: 

- скриншот работающего веб-интерфейса Grafana с текущими метриками.

</details>

### Решение:

Скриншот 8 - Работающий веб-интерфейс Grafana с текущими метриками.
![Скриншот-8](/VIRTD-35/virt/16.4-virt-04-docker-compose/img/16.4.4_Работающий_веб-интерфейс_Grafana_с_текущими_метриками.png)

---