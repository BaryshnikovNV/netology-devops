# Домашнее задание к занятию "`Работа с Playbook`" - `Барышников Никита`


## Основная часть.
<details>
	<summary></summary>
      <br>

1. Подготовьте свой inventory-файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install). не забудьте сделать handler на перезапуск vector в случае изменения конфигурации!
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги. Пример качественной документации ansible playbook по [ссылке](https://github.com/opensearch-project/ansible-playbook). Так же приложите скриншоты выполнения заданий №5-8
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

</details>

### Решение:

1. Подготовим свой inventory-файл `prod.yml`.

Файл prod.yml.
```yml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_name: "root"
      ansible_host: 158.160.113.138
      ansible_private_key_file: /home/baryshnikov/.ssh/id_rsa

vector:
  hosts:
    vector-01:
      ansible_name: "root"
      ansible_host: 158.160.113.138
      ansible_private_key_file: /home/baryshnikov/.ssh/id_rsa
```

2. Допишем playbook: сделаем еще один play, который устанавливает и настраивает [vector](https://vector.dev). Также сделаем handler для перезапуска vector в случае изменения конфигурации.  
3. При создании tasks воспользуемся модулями: `get_url`, `template`, `yum`.  
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.  
5. Запустим `ansible-lint site.yml`.

Скриншот 1 - Выполнение `ansible-lint site.yml`.
![Скриншот-1](/KONF-35/ansible/18.2-ansible-02-playbook/img/18.2.5.1_Запуск_ansible-lint_site.yml.png)

Исправим ошибки из скриншота 1 и заново выполним `ansible-lint site.yml`:

Скриншот 2 - Повторное выполнение `ansible-lint site.yml` после исправления ошибок.
![Скриншот-2](/KONF-35/ansible/18.2-ansible-02-playbook/img/18.2.5.2_Повторный_запуск_ansible-lint_site.yml.png)

6. Попробуем запустить playbook на этом окружении с флагом `--check`.

Для запуска playbook с флагом `--check` выпоним команду:
```bash
ansible-playbook -i inventory/prod.yml site.yml --check --ask-pass
```

Скриншот 3 - Попытка запуска playbook на этом окружении с флагом `--check`.
![Скриншот-3](/KONF-35/ansible/18.2-ansible-02-playbook/img/18.2.5.6_Запуск_playbook_окружении_с_флагом_--check.png)

Выполнение playbook завершилось с ошибкой, так как флаг `--check` не вносит никаких изменений и, следовательно, файлы дистрибутива не скачались, поэтому дальнейшие операции по выполнению установки выполнить не удалось.

7. Запустим playbook на `prod.yml` окружении с флагом `--diff`.

Для запуска playbook с флагом `--diff` выпоним команду:
```bash
ansible-playbook -i inventory/prod.yml site.yml --diff --ask-pass
```

В результате получим следующее:  
```bash
baryshnikov@debian:~/08-ansible-02-playbook/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff --ask-pass
SSH password: 

PLAY [Install Clickhouse] ****************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
changed: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] *******************************************************************************************
changed: [clickhouse-01]

TASK [Flush handlers] ********************************************************************************************************

RUNNING HANDLER [Start clickhouse service] ***********************************************************************************
changed: [clickhouse-01]

TASK [Delay 20 sec] **********************************************************************************************************
Pausing for 20 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [clickhouse-01]

TASK [Create database] *******************************************************************************************************
changed: [clickhouse-01]

PLAY [Install Vector] ********************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [vector-01]

TASK [Get Vector distrib] ****************************************************************************************************
changed: [vector-01]

TASK [Install Vector packages] ***********************************************************************************************
changed: [vector-01]

TASK [Deploy config Vector] **************************************************************************************************
--- before: /etc/vector/vector.yaml
+++ after: /home/baryshnikov/.ansible/tmp/ansible-local-25850kl3dpsoi/tmpuauiz8x2/vector.toml.yml
@@ -44,4 +44,4 @@
 # in your browser at http://localhost:8686
 # api:
 #   enabled: true
-#   address: "127.0.0.1:8686"
+#   address: "127.0.0.1:8686"
\ No newline at end of file

changed: [vector-01]

RUNNING HANDLER [Start Vector service] ***************************************************************************************
changed: [vector-01]

PLAY RECAP *******************************************************************************************************************
clickhouse-01              : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Убедимся, что изменения на системе произведены:

Скриншот 4 - Проверка изменений в системе.
![Скриншот-4](/KONF-35/ansible/18.2-ansible-02-playbook/img/18.2.7.1_Проверка_изменений_в_системе.png)

8. Повторно запустим playbook с флагом `--diff` и убедимся, что playbook идемпотентен:

```bash
baryshnikov@debian:~/08-ansible-02-playbook/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff --ask-pass
SSH password: 

PLAY [Install Clickhouse] ****************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Install clickhouse packages] *******************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers] ********************************************************************************************************

TASK [Delay 20 sec] **********************************************************************************************************
Pausing for 20 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [clickhouse-01]

TASK [Create database] *******************************************************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] ********************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [vector-01]

TASK [Get Vector distrib] ****************************************************************************************************
ok: [vector-01]

TASK [Install Vector packages] ***********************************************************************************************
ok: [vector-01]

TASK [Deploy config Vector] **************************************************************************************************
ok: [vector-01]

PLAY RECAP *******************************************************************************************************************
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

9. [README.md](./config/playbook/README.md)-файл по playbook.

---