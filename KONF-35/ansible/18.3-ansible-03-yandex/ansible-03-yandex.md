# Домашнее задание к занятию "`Использование Ansible`" - `Барышников Никита`


## Основная часть.
<details>
	<summary></summary>
      <br>

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает LightHouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику LightHouse, установить Nginx или любой другой веб-сервер, настроить его конфиг для открытия LightHouse, запустить веб-сервер.
4. Подготовьте свой inventory-файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

</details>

### Решение:

1. Допишим playbook: сделаем ещё один play, который устанавливает и настраивает LightHouse.  
2. При создании tasks воспользуемся модулями: `template`, `yum`, `git`.  
3. C помощью Tasks скачаем статику LightHouse, установим Nginx, настроить его конфиг для открытия LightHouse и запустии веб-сервер.  
4. Подготовим inventory-файл `prod.yml`.

Файл prod.yml.
```yml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_name: "root"
      ansible_host: 158.160.126.205
      ansible_private_key_file: /home/baryshnikov/.ssh/id_rsa

vector:
  hosts:
    vector-01:
      ansible_name: "root"
      ansible_host: 158.160.125.111
      ansible_private_key_file: /home/baryshnikov/.ssh/id_rsa

lighthouse:
  hosts:
    lighthouse-01:
      ansible_name: "root"
      ansible_host: 158.160.123.145
      ansible_private_key_file: /home/baryshnikov/.ssh/id_rsa
```

5. Запустим `ansible-lint site.yml` и исправим ошибки.

Скриншот 1 - Выполнение `ansible-lint site.yml`.
![Скриншот-1](/KONF-35/ansible/18.3-ansible-03-yandex/img/18.3.5_Запуск_ansible-lint_site.yml.png)

6. Попробуем запустить playbook на этом окружении с флагом `--check`.

Для запуска playbook с флагом `--check` выпоним команду:  
```bash
ansible-playbook -i inventory/prod.yml site.yml --check --ask-pass
```

Скриншот 2 - Попытка запуска playbook на этом окружении с флагом `--check`.
![Скриншот-2](/KONF-35/ansible/18.3-ansible-03-yandex/img/18.3.6_Запуск_playbook_на_окружении_с_флагом_--check.png)

Выполнение playbook завершилось с ошибкой, так как флаг `--check` не вносит никаких изменений и, следовательно, файлы дистрибутива не скачались, поэтому дальнейшие операции по выполнению установки выполнить не удалось.

7. Запустим playbook на `prod.yml` окружении с флагом `--diff`.

Для запуска playbook с флагом `--diff` выпоним команду:  
```bash
ansible-playbook -i inventory/prod.yml site.yml --diff --ask-pass
```

В результате получим следующее:  
```bash
baryshnikov@debian:~/08-ansible-03-yandex/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff --ask-pass
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

TASK [Vector | Template config] **********************************************************************************************
ok: [vector-01]

TASK [Vector | Create systed unit] *******************************************************************************************
ok: [vector-01]

TASK [Vector | Start Service] ************************************************************************************************
changed: [vector-01]

PLAY [Install Nginx] *********************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [lighthouse-01]

TASK [Nginx | Install epel-release] ******************************************************************************************
changed: [lighthouse-01]

TASK [Nginx | Install Nginx] *************************************************************************************************
changed: [lighthouse-01]

TASK [Nginx | Create general config] *****************************************************************************************
--- before: /etc/nginx/nginx.conf
+++ after: /home/baryshnikov/.ansible/tmp/ansible-local-1211008399x8f/tmppz0eb4se/nginx.conf.j2
@@ -1,84 +1,28 @@
-# For more information on configuration, see:
-#   * Official English Documentation: http://nginx.org/en/docs/
-#   * Official Russian Documentation: http://nginx.org/ru/docs/
+user root;
+worker_processes 1;
 
-user nginx;
-worker_processes auto;
-error_log /var/log/nginx/error.log;
-pid /run/nginx.pid;
-
-# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
-include /usr/share/nginx/modules/*.conf;
+error_log /var/log/nginx/error.log warn;
+pid /var/run/nginx.pid;
 
 events {
-    worker_connections 1024;
+  worker_connections 1024;
 }
 
 http {
-    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
-                      '$status $body_bytes_sent "$http_referer" '
-                      '"$http_user_agent" "$http_x_forwarded_for"';
+  include   /etc/nginx/mime.types;
+  default_type  application/octet-stream;
+  
+  log_format main '$remote_addr - $remote_user [$time_local] "$request" '
+                  '$status $body_bytes_sent "$http_refer" '
+                  '"$http_user_agent" "http_x_forwarded_for"';
+  access_log  /var/log/nginx/access.log main;
 
-    access_log  /var/log/nginx/access.log  main;
-
-    sendfile            on;
-    tcp_nopush          on;
-    tcp_nodelay         on;
-    keepalive_timeout   65;
-    types_hash_max_size 4096;
-
-    include             /etc/nginx/mime.types;
-    default_type        application/octet-stream;
-
-    # Load modular configuration files from the /etc/nginx/conf.d directory.
-    # See http://nginx.org/en/docs/ngx_core_module.html#include
-    # for more information.
-    include /etc/nginx/conf.d/*.conf;
-
-    server {
-        listen       80;
-        listen       [::]:80;
-        server_name  _;
-        root         /usr/share/nginx/html;
-
-        # Load configuration files for the default server block.
-        include /etc/nginx/default.d/*.conf;
-
-        error_page 404 /404.html;
-        location = /404.html {
-        }
-
-        error_page 500 502 503 504 /50x.html;
-        location = /50x.html {
-        }
-    }
-
-# Settings for a TLS enabled server.
-#
-#    server {
-#        listen       443 ssl http2;
-#        listen       [::]:443 ssl http2;
-#        server_name  _;
-#        root         /usr/share/nginx/html;
-#
-#        ssl_certificate "/etc/pki/nginx/server.crt";
-#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
-#        ssl_session_cache shared:SSL:1m;
-#        ssl_session_timeout  10m;
-#        ssl_ciphers HIGH:!aNULL:!MD5;
-#        ssl_prefer_server_ciphers on;
-#
-#        # Load configuration files for the default server block.
-#        include /etc/nginx/default.d/*.conf;
-#
-#        error_page 404 /404.html;
-#            location = /40x.html {
-#        }
-#
-#        error_page 500 502 503 504 /50x.html;
-#            location = /50x.html {
-#        }
-#    }
-
-}
-
+  sendfile  on;
+  #tcp_nopush on;
+  
+  keepalive_timeout 65;
+  
+  gzip  on;
+  
+  include /etc/nginx/conf.d/*.conf;
+}
\ No newline at end of file

changed: [lighthouse-01]

RUNNING HANDLER [Start-nginx] ************************************************************************************************
changed: [lighthouse-01]

RUNNING HANDLER [Restart-nginx] **********************************************************************************************
changed: [lighthouse-01]

PLAY [Install Lighthouse] ****************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [lighthouse-01]

TASK [Lighthouse | Install dependencies] *************************************************************************************
changed: [lighthouse-01]

TASK [Lighthouse | Clone from git] *******************************************************************************************
>> Newly checked out d701335c25cd1bb9b5155711190bad8ab852c2ce
changed: [lighthouse-01]

TASK [Lighthouse | Create lighthouse config] *********************************************************************************
--- before
+++ after: /home/baryshnikov/.ansible/tmp/ansible-local-1211008399x8f/tmpczx80xmk/lighthouse.conf.j2
@@ -0,0 +1,11 @@
+server {
+    listen    80;
+    server_name localhost;
+
+    access_log /var/log/nginx/lighthouse_access.log  main;
+
+    location / {
+        root    /home/admin/lighthouse;
+        index  index.html;
+    }
+}
\ No newline at end of file

changed: [lighthouse-01]

RUNNING HANDLER [Restart-nginx] **********************************************************************************************
changed: [lighthouse-01]

PLAY RECAP *******************************************************************************************************************
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
lighthouse-01              : ok=11   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=6    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

8. Повторно запустим playbook с флагом `--diff` и убедимся, что playbook идемпотентен:

```bash
baryshnikov@debian:~/08-ansible-03-yandex/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff --ask-pass
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

TASK [Vector | Template config] **********************************************************************************************
ok: [vector-01]

TASK [Vector | Create systed unit] *******************************************************************************************
ok: [vector-01]

TASK [Vector | Start Service] ************************************************************************************************
changed: [vector-01]

PLAY [Install Nginx] *********************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [lighthouse-01]

TASK [Nginx | Install epel-release] ******************************************************************************************
ok: [lighthouse-01]

TASK [Nginx | Install Nginx] *************************************************************************************************
ok: [lighthouse-01]

TASK [Nginx | Create general config] *****************************************************************************************
ok: [lighthouse-01]

PLAY [Install Lighthouse] ****************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [lighthouse-01]

TASK [Lighthouse | Install dependencies] *************************************************************************************
ok: [lighthouse-01]

TASK [Lighthouse | Clone from git] *******************************************************************************************
ok: [lighthouse-01]

TASK [Lighthouse | Create lighthouse config] *********************************************************************************
ok: [lighthouse-01]

PLAY RECAP *******************************************************************************************************************
clickhouse-01              : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
lighthouse-01              : ok=8    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vector-01                  : ok=6    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

9. [README.md](./config/playbook/README.md)-файл по playbook.