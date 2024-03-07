# Домашнее задание к занятию "`Teamcity`" - `Барышников Никита`


## Подготовка к выполнению
<details>
	<summary></summary>
      <br>

1. В Yandex Cloud создайте новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`.
2. Дождитесь запуска teamcity, выполните первоначальную настройку.
3. Создайте ещё один инстанс (2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишите к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`.
4. Авторизуйте агент.
5. Сделайте fork [репозитория](https://github.com/aragastmatb/example-teamcity).
6. Создайте VM (2CPU4RAM) и запустите [playbook](./infrastructure).

</details>

#### Решение:

1. В Yandex Cloud создадим новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`.  
2. Выполним первоначальную настройку.  
3. Создадим ещё один инстанс (2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишем к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`.  
4. Авторизуем агент.  
5. Сделаем fork [репозитория](https://github.com/aragastmatb/example-teamcity).  
6. Создадим VM (2CPU4RAM) и запустим [playbook](./infrastructure).

Скриншот 1 - Создание инстансов и ВМ.
![Скриншот-1](./img/19.5.1.1_Создание_инстансов_и_вм.png)

Скриншот 2 - Выполнение запуска playbook.
![Скриншот-2](./img/19.5.1.2_Запуск_playbook.png)

Скриншот 3 - Выполнение первоначальной настройки teamcity.
![Скриншот-3](./img/19.5.1.3_Выполнение_первоначальной_настройки_teamcity.png)

Скриншот 4 - Выполнение авторизации агента.
![Скриншот-4](./img/19.5.1.4_Выполнение_авторизации_агента.png)

---