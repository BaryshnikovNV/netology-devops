# Домашнее задание к занятию "`Применение принципов IaaC в работе с виртуальными машинами`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

- Опишите основные преимущества применения на практике IaaC-паттернов.
- Какой из принципов IaaC является основополагающим?

</details>

### Решение:



---

## Задание 2.
<details>
	<summary></summary>
      <br>

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный — push или pull?

</details>

### Решение:



---

## Задание 3.
<details>
	<summary></summary>
      <br>

Установите на личный компьютер:

- VirtualBox ([ссылка для установки](https://www.virtualbox.org/)),
- Vagrant ([ссылка для установки](https://github.com/netology-code/devops-materials)),
- Terraform ([ссылка для установки](https://github.com/netology-code/devops-materials/blob/master/README.md)),
- Ansible.

*Приложите вывод команд установленных версий каждой из программ, оформленный в Markdown.*

</details>

### Решение:



---

## Задание 4.
<details>
	<summary></summary>
      <br>

Воспроизведите практическую часть лекции самостоятельно.

- Создайте виртуальную машину.
- Зайдите внутрь ВМ, убедитесь, что Docker установлен с помощью команды
```
docker ps,
```
Vagrantfile из лекции и код ansible находятся в [папке](https://github.com/netology-code/virt-homeworks/tree/virt-11/05-virt-02-iaac/src).

Примечание. Если Vagrant выдаёт ошибку:
```
URL: ["https://vagrantcloud.com/bento/ubuntu-20.04"]     
Error: The requested URL returned error: 404:
```

выполните следующие действия:

1. Скачайте с [сайта](https://app.vagrantup.com/bento/boxes/ubuntu-20.04) файл-образ "bento/ubuntu-20.04".
2. Добавьте его в список образов Vagrant: "vagrant box add bento/ubuntu-20.04 <путь к файлу>".

*Приложите скриншоты в качестве решения на эту задачу.*

</details>

### Решение:



---