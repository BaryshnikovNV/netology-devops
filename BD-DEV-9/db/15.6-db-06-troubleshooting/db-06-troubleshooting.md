# Домашнее задание к занятию "`Troubleshooting`" - `Барышников Никита`


### Задание 1. 

Перед выполнением задания ознакомьтесь с документацией по [администрированию MongoDB](https://docs.mongodb.com/manual/administration/).

Пользователь (разработчик) написал в канал поддержки, что у него уже 3 минуты происходит CRUD-операция в MongoDB и её нужно прервать.

Вы как инженер поддержки решили произвести эту операцию:

- напишите список операций, которые вы будете производить для остановки запроса пользователя;
- предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB.  

Решение:

Для остановки запроса пользователя можно воспользоваться командой `db.currentOp`, которая найдет кативные id запросы пользователя, выполняющиеся больше 3 минут:
```
db.currentOp(
   {
     "active" : true,
     "$ownOps": true,
     "secs_running" : { "$gt" : 180 }
   }
)
```
А для остановки этих запросов можно воспользоватья командой `db.killOp()`.

Решить проблему с долгими (зависающими) запросами в MongoDB можно за счет оптимизации, например, добавить индекс, настроить шардинг. Также, можно установить ограничение времения исполнения операций с помощью `maxTimeMS()`.

---

### Задание 2.

Перед выполнением задания познакомьтесь с документацией по [Redis latency troobleshooting](https://redis.io/topics/latency).

Вы запустили инстанс Redis для использования совместно с сервисом, который использует механизм TTL. Причём отношение количества записанных key-value-значений к количеству истёкших значений есть величина постоянная иувеличивается пропорционально количеству реплик сервиса.

При масштабировании сервиса до N реплик вы увидели, что:

- сначала происходит рост отношения записанных значений к истекшим,
- Redis блокирует операции записи.

Как вы думаете, в чём может быть проблема?

Решение:

Причина может быть в том, что если в базе данных есть много-много ключей, срок действия которых истекает в одну и ту же секунду, и они составляют не менее 25% от текущей совокупности ключей с установленным сроком действия, Redis может заблокировать, чтобы процент ключей, срок действия которых уже истек, был ниже 25%.

---

### Задание 3.

Вы подняли базу данных MySQL для использования в гис-системе. При росте количества записей в таблицах базыпользователи начали жаловаться на ошибки вида:
```python
InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
```
Как вы думаете, почему это начало происходить и как локализовать проблему?

Какие пути решения этой проблемы вы можете предложить?

Решение:

Существует три вероятные причины появления этого сообщения об ошибке:

- Нужно проверить состояние сети. Обычно данная ошибка указывает на проблему с сетевым подключением. Также, возможно, запрос является очень большим и можно попробовать увеличить `net_read_timeout` с 30 секунд по умолчанию до 60 секунд или дольше, достаточного для завершения передачи данных.
- Такая ошибка может возникнуть, когда клиент пытается установить первоначальное соединение с сервером. В этом случае можно попробовать увеличить `connect_timeout`.
- Проблема с BLOB values. В этом случае нужно увеличить `max_allowed_packet`.

---

### Задание 4.

Вы решили перевести гис-систему из задачи 3 на PostgreSQL, так как прочитали в документации, что эта СУБД работает с большим объёмом данных лучше, чем MySQL.

После запуска пользователи начали жаловаться, что СУБД время от времени становится недоступной. В dmesg вы видите, что:

`postmaster invoked oom-killer`

Как вы думаете, что происходит?

Как бы вы решили эту проблему?

Решение:

Когда у сервера или процесса заканчивается память, Linux предлагает 2 пути решения: обрушить всю систему или завершить процесс (приложение), который съедает память. Лучше, конечно, завершить процесс и спасти ОС от аварийного завершения. В двух словах, Out-Of-Memory Killer — это процесс, который завершает приложение, чтобы спасти ядро от сбоя. Он жертвует приложением, чтобы сохранить работу ОС.

Чтобы решить проблему можно попытаться установить для `vm.overcommit_memory` значение 2, что снизит вероятность завершение процесса PostgreSQL. Также, можно увеличить объем ОЗУ.

Также, в PostgreSQL можно настроить параметры, регулирующие использование ресурсов:

- `shared_buffers (integer)`. Задает объем памяти, который сервер базы данных использует для буферов общей памяти. Обычно значение по умолчанию составляет 128 мегабайт (128MB), но может быть меньше, если настройки ядра его не поддерживают (как определено в initdb). Это значение должно составлять не менее 128 килобайт. Однако для хорошей производительности обычно требуются значения, значительно превышающие минимальные. Если это значение указано без единиц измерения, оно принимается в виде блоков, то есть BLCKSZ байт, обычно 8 КБ. (Значения по умолчанию BLCKSZ изменяют минимальное значение.) Этот параметр может быть установлен только при запуске сервера.
- `temp_buffers (integer)`. Устанавливает максимальный объем памяти, используемый для временных буферов в каждом сеансе базы данных. Это локальные для сеанса буферы, используемые только для доступа к временным таблицам. Если это значение указано без единиц измерения, оно принимается в виде блоков, то есть BLCKSZ байт, обычно 8 КБ. Значение по умолчанию равно восьми мегабайтам (8MB). (Если BLCKSZ не равно 8 КБ, значение по умолчанию масштабируется пропорционально ему.) Этот параметр можно изменять в рамках отдельных сеансов, но только перед первым использованием временных таблиц в рамках сеанса; последующие попытки изменить значение не окажут влияния на этот сеанс.
- `work_mem (integer)`. Устанавливает базовый максимальный объем памяти, который будет использоваться операцией запроса (такой как сортировка или хэш-таблица) перед записью во временные файлы на диске. Если это значение указано без единиц измерения, оно принимается за килобайты. Значение по умолчанию равно четырем мегабайтам (4MB).
- `hash_mem_multiplier (floating point)`. Используется для вычисления максимального объема памяти, который могут использовать операции на основе хэша. Конечный предел определяется путем умножения work_mem на hash_mem_multiplier. Значение по умолчанию равно 2.0, что позволяет использовать операции на основе хэша в два раза больше обычного work_mem базового объема.
- `maintenance_work_mem (integer)`. Указывает максимальный объем памяти, который будет использоваться операциями обслуживания, такими как VACUUM, CREATE INDEX, и ALTER TABLE ADD FOREIGN KEY. Если это значение указано без единиц измерения, оно принимается в килобайтах. По умолчанию оно равно 64 мегабайтам (64MB). Поскольку одновременно в сеансе базы данных может выполняться только одна из этих операций, а при установке обычно не так много из них выполняется одновременно, безопасно устанавливать это значение значительно большим, чем work_mem. Увеличение настроек может повысить производительность при очистке и восстановлении дампов базы данных.
- `max_stack_depth (integer)`. Определяет максимальную безопасную глубину стека выполнения сервера. Идеальной настройкой для этого параметра является фактический предел размера стека, установленный ядром (как установлено ulimit -s или локальный эквивалент), за вычетом запаса прочности в мегабайт или около того. Запас прочности необходим, поскольку глубина стека проверяется не в каждой программе сервера, а только в ключевых потенциально рекурсивных программах. Если это значение указано без единиц измерения, оно принимается за килобайты. Значение по умолчанию равно двум мегабайтам (2MB), что относительно мало и вряд ли приведет к сбоям. Однако оно может быть слишком маленьким для выполнения сложных функций. Изменять этот параметр могут только суперпользователи и пользователи с соответствующими SET привилегиями.

---