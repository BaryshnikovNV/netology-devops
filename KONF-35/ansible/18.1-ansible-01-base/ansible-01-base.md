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