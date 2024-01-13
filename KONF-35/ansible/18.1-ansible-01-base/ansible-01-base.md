# Домашнее задание к занятию "`Введение в Ansible`" - `Барышников Никита`


## Основная часть.
<details>
	<summary></summary>
      <br>

1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.
2. Найдите файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяйте его на `all default fact`.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились значения: для `deb` — `deb default fact`, для `el` — `el default fact`.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.
13. Предоставьте скриншоты результатов запуска команд.

</details>

### Решение:

1. Попробуем запустить playbook на окружении из `test.yml`, зафиксируем значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.

Команда для запуска playbook:
```bash
ansible-playbook -i inventory/test.yml site.yml
```

Скриншот 1 - Значение, которое имеет факт `some_fact` для localhost при выполнении playbook.
![Скриншот-1](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.1_Значение,_которое_имеет_факт_some_fact_для_localhost_при_выполнении_playbook.png)

Из скриншоты 1 видно, что значение `some_fact`=12.

2. Найдем файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяем его на `all default fact`.

Отредактируем файл `group_vars/all/examp.yml`.

Скриншот 2 - Изменение значения переменной some_fact.
![Скриншот-2](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.2_Изменение_значения_переменной_some_fact.png)

3. Воспользуемся подготовленным `docker` окружением.

Запустим контейенр ubuntu c помощью команды:
```bash
docker run -d --name ubuntu pycontribs/ubuntu:latest sleep infinity
```

Запустим контейенр centos7 c помощью команды:
```bash
docker run -d --name centos7 pycontribs/centos:7 sleep infinity
```

4. Проведем запуск playbook на окружении из `prod.yml`.

```bash
ansible-playbook -i inventory/prod.yml site.yml
```

Скриншот 3 - Проведение запуска playbook на окружении из prod.yml.
![Скриншот-3](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.4_Проведение_запуска_playbook_на_окружении_из_prod.yml.png)

Полученные значения `some_fact` для каждого из `managed host` на скриншоте 3.

5. Добавим факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились значения: для `deb` — `deb default fact`, для `el` — `el default fact`.

Редактируем файлы `group_vars/deb/examp.yml` и `group_vars/el/examp.yml`.

6. Повторим запуск playbook на окружении `prod.yml`. Убедимся, что выдаются корректные значения для всех хостов.

Скриншот 4 - Повторное проведение запуска playbook на окружении из prod.yml.
![Скриншот-4](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.6_Повторное_проведение_запуска_playbook_на_окружении_из_prod.yml.png)

7. При помощи `ansible-vault` зашифруем факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

```bash
ansible-vault encrypt group_vars/deb/examp.yml group_vars/el/examp.yml
```

Скриншот 5 - Шифрование фактов в `group_vars/deb` и `group_vars/el` с паролем `netology`.
![Скриншот-5](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.7_Шифрование_фактов_в_deb_и_el.png)

8. Запустим playbook на окружении `prod.yml`. При запуске `ansible` должен запросить пароль.

```bash
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-password
```

Скриншот 6 - Запуск playbook на окружении prod.yml после шифорвания фактов в `group_vars/deb` и `group_vars/el` с паролем `netology`.
![Скриншот-6](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.8_Запуск_playbook_на_окружении_prod.yml_после_шифорвания_фактов.png)

9. Посмотрим при помощи `ansible-doc -t connection -l` список доступных подключаемых модулей.

Скриншот 7 - Вывод списка доступных подключаемых модулей.
![Скриншот-7](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.9_Список_доступных_подключаемых_модулей.png)

Из скриншота 7 наиболее подходящим для работы на `control node` является модуль **ansible.builtin.ssh**.

10. В `prod.yml` добавим новую группу хостов с именем `local`, в ней разместим localhost с необходимым типом подключения.

Скриншот 8 - Добавление новой группы хостов с именем `local` в `prod.yml`.
![Скриншот-8](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.10_Добавление_новой_группы_хостов_с_именем_local_в_prod.yml.png)

11. Запустим playbook на окружении `prod.yml`. При запуске `ansible` запросил пароль. Из скриншота 9 убедимся, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

Скриншот 9 - Запуск playbook на окружении prod.yml после после добавления новой группы хостов с именем `local` в `prod.yml`.
![Скриншот-9](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.11_Запуск_playbook_на_окружении_prod.yml_после_добавления_новой_группы_хостов_с_именем_local.png)

12. Ссылка на открытый репозиторий с измененным [playbook](./config/mandatory_part/playbook).

---

## Необязательная часть.
<details>
	<summary></summary>
      <br>

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот вариант](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в ваш личный репозиторий.

</details>

### Решение:

1. Расшифруем все зашифрованные файлы с переменными с помощью команды `ansible-vault decrypt`:

```bash
ansible-vault decrypt group_vars/deb/examp.yml group_vars/el/examp.yml
```

Скриншот 10 - Расшифрование фактов в `group_vars/deb` и `group_vars/el` с паролем `netology`.
![Скриншот-10](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.12_Расшифрование_фактов_в_deb_и_el.png)

2. Зашифруем отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`.

```bash
ansible-vault encrypt_string
```

Скриншот 11 - Шифрование отдельного значения `PaSSw0rd` для переменной `some_fact` паролем `netology`.
![Скриншот-11](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.13_Шифрование_отдельного_значения_PaSSw0rd_для_переменной_some_fact.png)

Добавим полученное значение в `group_vars/all/exmp.yml`:

Скриншот 12 - Добавление полученного значения в `group_vars/all/exmp.yml`.
![Скриншот-12](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.14_Добавление_полученного_значения_в_exmp.yml.png)

3. Запустим playbook, убедимся, что для нужных хостов применился новый fact.

Скриншот 13 - Запуск playbook на окружении prod.yml после добавления нового fact.
![Скриншот-13](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.15_Запуск_playbook_на_окружении_prod.yml_после_добавления_нового_fact.png)

4. Добавим новую группу хостов `fedora`, придумаем для неё переменную. В качестве образа используем [этот вариант](https://hub.docker.com/r/pycontribs/fedora).

Скриншот 14 - Запуск playbook на окружении prod.yml после добавления новой группы хостов и новой переменной.
![Скриншот-14](/KONF-35/ansible/18.1-ansible-01-base/img/18.1.16_Запуск_playbook_на_окружении_prod.yml_после_добавления_новой_группы_хостов_и_новой_переменной.png)

5. Напишим скрипт на bash: автоматизируем поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.

Файл script.sh
```bash
#!/bin/bash

host_c=centos7
host_u=ubuntu
host_f=fedora

image_c=pycontribs/centos:7
image_u=pycontribs/ubuntu:latest
image_f=pycontribs/fedora:latest

docker run -d --name $host_c $image_c sleep infinity
docker run -d --name $host_u $image_u sleep infinity
docker run -d --name $host_f $image_f sleep infinity

ansible-playbook -i inventory/prod.yml site.yml --ask-vault-password

docker stop $host_c $host_u $host_f
docker rm $host_c $host_u $host_f
```

6. Ссылка на открытый репозиторий с измененным [playbook](./config/optional_part/playbook).

---