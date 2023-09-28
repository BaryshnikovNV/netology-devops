# Домашнее задание к занятию "`PostgreSQL`" - `Барышников Никита`


### Задание 1. 

Используя Docker, поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.  
Подключитесь к БД PostgreSQL, используя `psql`.  
Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.  
**Найдите и приведите** управляющие команды для:
- вывода списка БД,
- подключения к БД,
- вывода списка таблиц,
- вывода описания содержимого таблиц,
- выхода из psql.  

Решение:

Для запуска PostgreSQL используем Docker. В качестве docker-compose файла используем [docker-compose.yml](./config/docker-compose.yml).

Запускаем контейнер в фоновом режиме:  
```bash
docker compose up -d
```

Запускаем процесс bash в нутри запущенного контейнера `pg_container`:  
```bash
docker exec -it pg_container bash
```

Запускаем утилиту psql:  
```bash
psql postgres
```

Воспользуемся командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

Скриншот 1 - Вывод подсказки по имеющимся в psql управляющим командам.
![Скриншот-1](https://github.com/BaryshnikovNV/netology-devops/blob/db-04-postgresql/BD-DEV-9/db/15.4-db-04-postgresql/img/15.4.1_Вывод_подсказки_по_имеющимся_в_psql_управляющим_командам.png)

C помощью подсказки определим управляющие команды:

- вывод списка БД                        (\l[+]   [PATTERN]      list databases);
- подключение к БД                       ( \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo} connect to new database (currently "postgres"));
- вывод списка таблиц                    (\dt[S+] [PATTERN]      list tables);
- вывода описания содержимого таблиц     (\d[S+]  NAME           describe table, view, sequence, or index);
- выхода из psql                         (\q                     quit psql).

---

### Задание 2.

Используя `psql`, создайте БД `test_database`.  
Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-04-postgresql/test_data).  
Восстановите бэкап БД в `test_database`.  
Перейдите в управляющую консоль `psql` внутри контейнера.  
Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.  
Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах.  
**Приведите в ответе** команду, которую вы использовали для вычисления, и полученный результат.

Решение:

Скопируем файл дампа в запущенный контейнер:
```bash
docker cp test_dump.sql pg_container:/var/tmp/test_dump.sql
```

Создаем базу данных test_database:
```sql
CREATE DATABASE test_database;
```

И восстановим бэкап БД в `test_database`:
```bash
psql -U root -d test_database < /var/tmp/test_dump.sql
```

Скриншот 2 - Восстановление бэкапа.
![Скриншот-2](https://github.com/BaryshnikovNV/netology-devops/blob/db-04-postgresql/BD-DEV-9/db/15.4-db-04-postgresql/img/15.4.2.1_Восстановление_бэкапа.png)

Подключимся к восстановленной БД:
```bash
psql -U root -d test_database
```

Посмотрим список существующих таблиц:
```bash
\dt
```

Проведем операцию ANALYZE для сбора статистики по таблице:
```sql
ANALYZE verbose orders;
```

Найдем столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах:
```sql
SELECT attname, avg_width FROM pg_stats WHERE tablename='orders';
```

Скриншот 3 - Нахождение столбца таблицы orders с наибольшим средним значением размера элементов в байтах.
![Скриншот-3](https://github.com/BaryshnikovNV/netology-devops/blob/db-04-postgresql/BD-DEV-9/db/15.4-db-04-postgresql/img/15.4.2.2_Нахождение_столбца_таблицы_orders.png)

Таким столбцом является title.

---

### Задание 3.

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров ипоиск по ней занимает долгое время. Вам как успешному выпускнику курсов DevOps в Нетологии предложилипровести разбиение таблицы на 2: шардировать на orders_1 - price>499 и orders_2 - price<=499.  
Предложите SQL-транзакцию для проведения этой операции.  
Можно ли было изначально исключить ручное разбиение при проектировании таблицы orders?

Решение:



---

### Задание 4.

Используя утилиту `pg_dump`, создайте бекап БД `test_database`.  
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

Решение:



---