# Домашнее задание к занятию "`SQL`" - `Барышников Никита`


### Задание 1. 

Используя Docker, поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.  
Приведите получившуюся команду или docker-compose-манифест.

Решение:

Для запуска PostgreSQ используем Docker. В качестве docker-compose файла используем [docker-compose.yml](./config/docker-compose.yml).

Запускаем контейнер в фоновом режиме:  
```bash
docker compose up -d
```

Запускаем процесс bash в нутри запущенного контейнера pg_container:  
```bash
docker exec -it pg_container bash
```

---

### Задание 2.

В БД из задачи 1:
- создайте пользователя test-admin-user и БД test_db;
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже);
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db;
- создайте пользователя test-simple-user;
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE этих таблиц БД test_db.

Таблица orders:
- id (serial primary key);
- наименование (string);
- цена (integer).

Таблица clients:
- id (serial primary key);
- фамилия (string);
- страна проживания (string, index);
- заказ (foreign key orders).

Приведите:
- итоговый список БД после выполнения пунктов выше;
- описание таблиц (describe);
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db;
- список пользователей с правами над таблицами test_db.

Решение:

Создаем базу данных test_db под пользователем root:  
```sql
createdb test_db -U root
```

Выполняем подключение к бд test_db:  
```sql
psql -d test_db -U root
```

Создаем пользователя test-admin-user:  
```sql
CREATE USER test_admin_user;
```

В БД создаем таблицу orders:  
```sql
CREATE TABLE orders
(
   id SERIAL PRIMARY KEY,
   наименование TEXT,
   цена INTEGER
);
```
и таблицу clients:  
```sql
CREATE TABLE clients
(
    id SERIAL PRIMARY KEY,
    фамилия TEXT,
    "страна проживания" TEXT,
    заказ INTEGER,
    FOREIGN KEY (заказ) REFERENCES orders(id)
);
```

Создадим индекс, ускоряющий выборку данных, с именем country_index для поля "страна проживания" таблицы clients:  
```sql
CREATE INDEX country_index ON clients ("страна проживания");
```

Предоставим привилегии на все операции пользователю test-admin-user на таблицу orders БД test_db:  
```sql
GRANT ALL ON TABLE orders TO test_admin_user;
```
и на таблицу clients:  
```sql
GRANT ALL ON TABLE clients TO test_admin_user;
```

Создадим пользователя test-simple-user:  
```sql
CREATE USER test_simple_user;
```

Предоставим пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE таблицы clients БД test_db:  
```sql
GRANT SELECT,INSERT,UPDATE,DELETE ON TABLE clients TO test_simple_user;
```
и таблицы orders:  
```sql
GRANT SELECT,INSERT,UPDATE,DELETE ON TABLE orders TO test_simple_user;
```

Скриншот-1 - Итоговый список БД после выполнения пунктов выше.
![Скриншот-1](https://github.com/BaryshnikovNV/netology-devops/blob/db-02-sql/BD-DEV-9/db/15.2-db-02-sql/img/15.2.2.1_Итоговый_список_БД.png)

Скриншот-2 - Описание таблиц (describe).
![Скриншот-2](https://github.com/BaryshnikovNV/netology-devops/blob/db-02-sql/BD-DEV-9/db/15.2-db-02-sql/img/15.2.2.2_Описание_таблиц_(describe).png)

SQL-запрос для выдачи списка пользователей с правами над таблицами test_db:  
```sql
SELECT grantee, table_catalog, table_name, privilege_type FROM information_schema.table_privileges WHERE table_name IN ('orders','clients');
```

Скриншот-3 - Список пользователей с правами над таблицами test_db.
![Скриншот-3](https://github.com/BaryshnikovNV/netology-devops/blob/db-02-sql/BD-DEV-9/db/15.2-db-02-sql/img/15.2.2.3_Cписок_пользователей_с_правами_над_таблицами_test_db.png)

---

### Задание 3.

Используя SQL-синтаксис, наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL-синтаксис:
- вычислите количество записей для каждой таблицы.

Приведите в ответе:
- запросы,
- результаты их выполнения.

Решение:

Наполним таблицы текстовыми данными, указанными в задании выше.

Для таблицы orders:
```sql
INSERT INTO orders VALUES (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);
```

Для таблицы clients:
```sql
INSERT INTO clients VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Ронни Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');
```

Для вычисления количества записей в таблицк orders используем запрос:
```sql
SELECT COUNT (*) FROM orders;
```
для clients:
```sql
SELECT COUNT (*) FROM clients;
```

Скриншот-4 - Скриншот результата выполнения SQL-запросов для вычисления количества записей в таблицах orders и clients.
![Скриншот-4](https://github.com/BaryshnikovNV/netology-devops/blob/db-02-sql/BD-DEV-9/db/15.2-db-02-sql/img/15.2.3_Результат_выполнения_SQL-запросов_для_вычисления_количества_записей_в_таблицах.png)

---

### Задание 4.

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.  
Используя foreign keys, свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения этих операций.  
Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод этого запроса.  
Подсказка: используйте директиву `UPDATE`.

Решение:



---

### Задание 5.

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).  
Приведите получившийся результат и объясните, что значат полученные значения.

Решение:



---

### Задание 6.

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. задачу 1).  
Остановите контейнер с PostgreSQL, но не удаляйте volumes.  
Поднимите новый пустой контейнер с PostgreSQL.  
Восстановите БД test_db в новом контейнере.  
Приведите список операций, который вы применяли для бэкапа данных и восстановления.

Решение:



---