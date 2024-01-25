# Домашнее задание к занятию "`Работа с roles`" - `Барышников Никита`


## Основная часть.
<details>
	<summary></summary>
      <br>

1. Создайте в старой версии playbook файл `requirements.yml` и заполните его содержимым:

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.13"
       name: clickhouse 
   ```

2. При помощи `ansible-galaxy` скачайте себе эту роль.
3. Создайте новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.
4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. 
5. Перенести нужные шаблоны конфигов в `templates`.
6. Опишите в `README.md` обе роли и их параметры. Пример качественной документации ansible role [по ссылке](https://github.com/cloudalchemy/ansible-prometheus).
7. Повторите шаги 3–6 для LightHouse. Помните, что одна роль должна настраивать один продукт.
8. Выложите все roles в репозитории. Проставьте теги, используя семантическую нумерацию. Добавьте roles в `requirements.yml` в playbook.
9. Переработайте playbook на использование roles. Не забудьте про зависимости LightHouse и возможности совмещения `roles` с `tasks`.
10. Выложите playbook в репозиторий.
11. В ответе дайте ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

</details>

### Решение:

1. Создадим в старой версии playbook файл `requirements.yml` и заполним его содержимым:

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.13"
       name: clickhouse 
   ```

2. При помощи команды `ansible-galaxy role install -r requirements.yml -p roles` скачаем себе эту роль.

```bash
baryshnikov@debian:~/08-ansible-04-role/playbook$ ansible-galaxy role install -r requirements.yml -p roles
Starting galaxy role install process
- extracting clickhouse to /home/baryshnikov/08-ansible-04-role/playbook/roles/clickhouse
- clickhouse (1.13) was installed successfully
```

3. Создадим новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.

```bash
baryshnikov@debian:~/08-ansible-04-role/playbook/roles$ ansible-galaxy role init vector-role
- Role vector-role was created successfully
```

4. На основе tasks из старого playbook заполним новую role. Разнесем переменные между `vars` и `default`.  
5. Перенесем нужные шаблоны конфигов в `templates`.  
6. Опишем в `README.md` обе роли и их параметры.  
7. Повторим шаги 3–6 для LightHouse.  
8. Выложим все roles в репозитории [LightHouse-role](https://github.com/BaryshnikovNV/lighthouse-role) и [Vector-role](https://github.com/BaryshnikovNV/vector-role).  
Добавим roles в `requirements.yml` в playbook.  
```yml
---
  - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
    scm: git
    version: "1.13"
    name: clickhouse

  - src: git@github.com:BaryshnikovNV/vector-role.git
    scm: git
    version: "v1.0.0"
    name: vector

  - src: git@github.com:BaryshnikovNV/lighthouse-role.git
    scm: git
    version: "v1.0.0"
    name: lighthouse
```

9. Переработаем playbook на использование roles.  
10. Получившийся [playbook](./config/playbook).
