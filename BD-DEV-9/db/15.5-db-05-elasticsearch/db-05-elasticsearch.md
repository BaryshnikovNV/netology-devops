# Домашнее задание к занятию "`Elasticsearch`" - `Барышников Никита`


### Задание 1. 

В этом задании вы потренируетесь в:

- установке Elasticsearch,
- первоначальном конфигурировании Elasticsearch,
- запуске Elasticsearch в Docker.

Используя Docker-образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для Elasticsearch,
- соберите Docker-образ и сделайте `push` в ваш docker.io-репозиторий,
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины.

Требования к `elasticsearch.yml`:

- данные `path` должны сохраняться в `/var/lib`,
- имя ноды должно быть `netology_test`.

В ответе приведите:

- текст Dockerfile-манифеста,
- ссылку на образ в репозитории dockerhub,
- ответ `Elasticsearch` на запрос пути `/` в json-виде.

Подсказки:

- возможно, вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum,
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml,
- при некоторых проблемах вам поможет Docker-директива ulimit,
- Elasticsearch в логах обычно описывает проблему и пути её решения.

Далее мы будем работать с этим экземпляром Elasticsearch.  

Решение:

Для запуска Elasticsearch используем Docker. В качестве dockerfile воспользуемся [dockerfile](./config/dockerfile).

Ссылка на образ `elasticsearch` в репозитории [dockerhub](https://hub.docker.com/layers/baryshnikovnv/elasticsearch/7.17.14_add_configs/images/sha256-c8704fb047fb4cf81b9f1b993603bfbf26501896471f5e0f090e5582d0edc0e3?context=explore).

Создадим контейнер `elasticsearch`:
```bash
docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 elasticsearch:7.17.14
```

Ответ `elasticsearch` на запрос:
```bash
curl localhost:9200
```
Скриншот 1 - Ответ elasticsearch на запрос.
![Скриншот-1](/BD-DEV-9/db/15.5-db-05-elasticsearch/img/15.5.1_Ответ_elasticsearch_на_запрос.png)

---

### Задание 2.

В этом задании вы научитесь:

- создавать и удалять индексы,
- изучать состояние кластера,
- обосновывать причину деградации доступности данных.

Ознакомьтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `Elasticsearch` 3 индекса в соответствии с таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API, и **приведите в ответе** на задание.

Получите состояние кластера `Elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находятся в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера Elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

Решение:

Создадим три индекса в соответствии с заданием:
```bash
curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
```

```bash
curl -X PUT localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2,  "number_of_replicas": 1 }}'
```

```bash
curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4,  "number_of_replicas": 2 }}'
```

Получим список индексов и их статусов, используя API:
```bash
curl -X GET 'http://localhost:9200/_cat/indices?v'
```

Скриншот 2 - Список индексов и их статусов, используя API.
![Скриншот-2](/BD-DEV-9/db/15.5-db-05-elasticsearch/img/15.5.2.1_Список_индексов_и_их_статусов,_используя_API.png)

Получим состояние кластера Elasticsearch, используя API:
```bash
curl -XGET localhost:9200/_cluster/health/?pretty=true
```

Скриншот 3 - Получение состояния кластера Elasticsearch, используя API.
![Скриншот-3](/BD-DEV-9/db/15.5-db-05-elasticsearch/img/15.5.2.2_Получение_состояния_кластера_Elasticsearch,_используя_API.png)

Статус "yellow" указывает на то, что фрагменты реплик не смогли быть распределены по другим узлам. А не могут они быть распределены по другим узлам, потому что в кластере у нас всего лишь одна нода.

Удалим все индексы:

```bash
curl -X DELETE 'http://localhost:9200/ind-1?pretty';
curl -X DELETE 'http://localhost:9200/ind-2?pretty';
curl -X DELETE 'http://localhost:9200/ind-3?pretty'
```

Убедимся, что индексы удалены:
```bash
curl -X GET 'http://localhost:9200/_cat/indices?v'
```

Скриншот 4 - Удаление всех индексов.
![Скриншот-4](/BD-DEV-9/db/15.5-db-05-elasticsearch/img/15.5.2.3_Удаление_всех_индексов.png)

---

### Задание 3.

В этом задании вы научитесь:

- создавать бэкапы данных,
- восстанавливать индексы из бэкапов.

Создайте директорию `{путь до корневой директории с Elasticsearch в образе}/snapshots`.

Используя API, [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
эту директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `Elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `Elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:

- возможно, вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `Elasticsearch`.

Решение:

Используя API зарегистрируем директорию `/elasticsearch-7.17.14/snapshots` как `snapshot repository` с именем 'netology_backup':
```bash
curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/elasticsearch-7.17.14/snapshots"
  }
}'
```

Запрос API для созданного репозитория:
```bash
curl -X GET "localhost:9200/_snapshot/netology_backup?pretty"
```

Скриншот 5 - Запрос API и результат вызова API для создания репозитория.
![Скриншот-5](/BD-DEV-9/db/15.5-db-05-elasticsearch/img/15.5.3.1_Запрос_API_и_результат_вызова_API_для_создания_репозитория.png)

Создадим индекс `test` с 0 реплик и 1 шардом:
```bash
curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'{ "settings": { "index": { "number_of_shards": 1, "number_of_replicas": 0 } } }'
```

Посмотрим список индексов:
```bash
curl 'localhost:9200/_cat/indices?v'
```

Скриншот 6 - Список индексов.
![Скриншот-6](/BD-DEV-9/db/15.5-db-05-elasticsearch/img/15.5.3.2_Список_индексов.png)

Создадим `snapshot` состояния кластера `elasticsearch`:
```bash
curl -X PUT "localhost:9200/_snapshot/netology_backup/my_snapshot?pretty"
```

Зайдем внутрь контейнера и выведем список файлов в директории со `snapshot`ами:
```bash
ll -a /elasticsearch-7.17.14/snapshots
```

Скриншот 7 - Список файлов в директории со `snapshot`ами.
![Скриншот-7](/BD-DEV-9/db/15.5-db-05-elasticsearch/img/15.5.3.3_Список_файлов_в_директории_со_snapshotами.png)

Удалим индекс `test`:
```bash
curl -X DELETE "localhost:9200/test?pretty"
```

Создадим индекс `test-2`:
```bash
curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'{ "settings": { "index": { "number_of_shards": 1, "number_of_replicas": 0 } } }'
```

Посмотрим список индексов:
```bash
curl 'localhost:9200/_cat/indices?v'
```

Скриншот 8 - Список индексов.
![Скриншот-8](/BD-DEV-9/db/15.5-db-05-elasticsearch/img/15.5.3.4_Список_индексов.png)

Восстановим состояние кластера `elasticsearch` из `snapshot`, созданного ранее:
```bash
curl -X POST "localhost:9200/_snapshot/netology_backup/my_snapshot/_restore?pretty" -H 'Content-Type: application/json' -d'{"include_global_state":true}'
```

Посмотрим итоговый список индексов:
```bash
curl 'localhost:9200/_cat/indices?v'
```

Скриншот 9 - Итоговый список индексов.
![Скриншот-9](/BD-DEV-9/db/15.5-db-05-elasticsearch/img/15.5.3.5_Итоговый_список_индексов.png)

---