# Домашнее задание к занятию "`MySQL`" - `Барышников Никита`


### Задание 1. 

Используя Docker, поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.  
Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-03-mysql/test_data) и восстановитесь из него.  
Перейдите в управляющую консоль `mysql` внутри контейнера.  
Используя команду `\h`, получите список управляющих команд.  
Найдите команду для выдачи статуса БД и **приведите в ответе** из её вывода версию сервера БД.  
Подключитесь к восстановленной БД и получите список таблиц из этой БД.  
**Приведите в ответе** количество записей с `price` > 300.  

Решение:

Для запуска MySql используем Docker. В качестве docker-compose файла используем [docker-compose.yml](./config/docker-compose.yml).

Запускаем контейнер в фоновом режиме:  
```bash
docker compose up -d
```

Скриншот 1 - Запуск docker-compose.
![Скриншот-1](https://github.com/BaryshnikovNV/netology-devops/blob/db-03-mysql/BD-DEV-9/db/15.3-db-03-mysql/img/15.3.1.1_Запуск_dockerfile.png)

Скопируем файл дампа в запущенный контейнер:
```bash
docker cp test_dump.sql mysql_container:/var/tmp/test_dump.sql
```

Запускаем процесс bash в нутри запущенного контейнера mysql_container:  
```bash
docker exec -it mysql_container bash
```

И восстановим базу:
```bash
mysql -u root -p MYSQL_DB < /var/tmp/test_dump.sql
```

Выполняем подключение к серверу:  
```bash
mysql -u root -p
```

Используя команду `\h`, получим список управляющих команд:

Скриншот 2 - Получение списка управляющих команд.
![Скриншот-2](https://github.com/BaryshnikovNV/netology-devops/blob/db-03-mysql/BD-DEV-9/db/15.3-db-03-mysql/img/15.3.1.2_Получение_списка_управляющих_команд.png)

Для выдачи статуса БД и версии сервера БД воспользуемся командой `\s`:

Скриншот 3 - Выдача статуса БД и версии сервера БД.
![Скриншот-3](https://github.com/BaryshnikovNV/netology-devops/blob/db-03-mysql/BD-DEV-9/db/15.3-db-03-mysql/img/15.3.1.3_Выдача_статуса_БД_и_версии_сервера_БД.png)

Выбираем базу данных MYSQL_DB:
```sql
USE MYSQL_DB;
```

Для вывода список таблиц БД воспользуемся командой:
```sql
SHOW TABLES;
```

Приведем количество записей с `price` > 300 с помощью команды:
```sql
SELECT COUNT(*) FROM orders WHERE price > 300;
```

Скриншот 4 - Вывод списка таблиц БД и количество записей с price 300.
![Скриншот-4](https://github.com/BaryshnikovNV/netology-devops/blob/db-03-mysql/BD-DEV-9/db/15.3-db-03-mysql/img/15.3.1.4_Вывод_списка_таблиц_БД_и_количество_записей_с_price_300.png)

---

### Задание 2.

Создайте пользователя test в БД c паролем test-pass, используя:

- плагин авторизации mysql_native_password
- срок истечения пароля — 180 дней
- количество попыток авторизации — 3
- максимальное количество запросов в час — 100
- аттрибуты пользователя:
  - Фамилия "Pretty"    
  - Имя "James".
  
Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.  
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES, получите данные по пользователю `test` и **приведите в ответе к задаче**.

Решение:

Создание пользователя `test` в БД c паролем test-pass, используя вышеуказанные параметры:

```sql
CREATE USER 'test'@'localhost' 
    IDENTIFIED WITH mysql_native_password BY 'test-pass'
    WITH MAX_CONNECTIONS_PER_HOUR 100
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2
    ATTRIBUTE '{"first_name":"James", "last_name":"Pretty"}';
```

Предоставление привелегий пользователю 'test' на операции SELECT базы 'test_db':
```sql
GRANT SELECT ON lodyanyy_db.* to 'test'@'localhost';
```

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получим данные по пользователю 'test':
```sql
SELECT * from INFORMATION_SCHEMA.USER_ATTRIBUTES where USER = 'test';
```

Скриншот 5 - Получение данных по пользователю test.
![Скриншот-5](https://github.com/BaryshnikovNV/netology-devops/blob/db-03-mysql/BD-DEV-9/db/15.3-db-03-mysql/img/15.3.2.1_Получение_данных_по_пользователю_test.png)

---

### Задание 3.

Установите профилирование `SET profiling = 1`. Изучите вывод профилирования команд `SHOW PROFILES;`.  
Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.  
Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:  
- на `MyISAM`,
- на `InnoDB`.

Решение:



---

### Задание 4.

Изучите файл `my.cnf` в директории /etc/mysql.
Измените его согласно ТЗ (движок InnoDB):

- скорость IO важнее сохранности данных;
- нужна компрессия таблиц для экономии места на диске;
- размер буффера с незакомиченными транзакциями 1 Мб;
- буффер кеширования 30% от ОЗУ;
- размер файла логов операций 100 Мб.

Приведите в ответе изменённый файл `my.cnf`.

Решение:

Изучите файл `my.cnf` в директории /etc/mysql.
Измените его согласно ТЗ (движок InnoDB):

- скорость IO важнее сохранности данных;
- нужна компрессия таблиц для экономии места на диске;
- размер буффера с незакомиченными транзакциями 1 Мб;
- буффер кеширования 30% от ОЗУ;
- размер файла логов операций 100 Мб.

Приведите в ответе изменённый файл `my.cnf`.

---