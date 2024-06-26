# Домашнее задание к занятию "`Платформа мониторинга Sentry`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

Так как Self-Hosted Sentry довольно требовательная к ресурсам система, мы будем использовать Free Сloud account.

Free Cloud account имеет ограничения:

- 5 000 errors;
- 10 000 transactions;
- 1 GB attachments.

Для подключения Free Cloud account:

- зайдите на sentry.io;
- нажмите «Try for free»;
- используйте авторизацию через ваш GitHub-аккаунт;
- далее следуйте инструкциям.

В качестве решения задания пришлите скриншот меню Projects.

</details>

### Решение:

Зайдем на sentry.io и авторизуемся используя GitHub-аккаунт.

Скриншот 1 - Меню Projects.
![Скриншот-1](./img/20.4.1_Меню_Projects.png)

---

## Задание 2.
<details>
	<summary></summary>
      <br>

1. Создайте python-проект и нажмите `Generate sample event` для генерации тестового события.
2. Изучите информацию, представленную в событии.
3. Перейдите в список событий проекта, выберите созданное вами и нажмите `Resolved`.
4. В качестве решения задание предоставьте скриншот `Stack trace` из этого события и список событий проекта после нажатия `Resolved`.

</details>

### Решение:

1. Создадим python-проект и нажмем `Generate sample event` для генерации тестового события.

Скриншот 2 - Создание python проекта.
![Скриншот-2](./img/20.4.2.1_Создание_python_проекта.png)

2. Изучим информацию, представленную в событии.

Скриншот 3 - Информация представленная в событии.
![Скриншот-3](./img/20.4.2.2_Информация_представленная_в_событии.png)

3. Перейдем в список событий проекта, выберем созданное и нажмем `Resolved`.

Скриншот 4 - Выполнение Resolved.
![Скриншот-4](./img/20.4.2.3_Выполнение_Resolved.png)

4. В качестве решения задания представим скриншот `Stack trace` из этого события и список событий проекта после нажатия `Resolved`.

Скриншот 5 - Stack trace.
![Скриншот-5](./img/20.4.2.4_Stack_trace.png)

Скриншот 6 - Список событий проекта после нажатия `Resolved`.
![Скриншот-6](./img/20.4.2.5_Список_событий_проекта_после_нажатия_Resolved.png)

---

## Задание 3.
<details>
	<summary></summary>
      <br>

1. Перейдите в создание правил алёртинга.
2. Выберите проект и создайте дефолтное правило алёртинга без настройки полей.
3. Снова сгенерируйте событие `Generate sample event`.
Если всё было выполнено правильно — через некоторое время вам на почту, привязанную к GitHub-аккаунту, придёт оповещение о произошедшем событии.
4. Если сообщение не пришло — проверьте настройки аккаунта Sentry (например, привязанную почту), что у вас не было 
`sample issue` до того, как вы его сгенерировали, и то, что правило алёртинга выставлено по дефолту (во всех полях all).
Также проверьте проект, в котором вы создаёте событие — возможно алёрт привязан к другому.
5. В качестве решения задания пришлите скриншот тела сообщения из оповещения на почте.
6. Дополнительно поэкспериментируйте с правилами алёртинга. Выбирайте разные условия отправки и создавайте sample events.

</details>

### Решение:

1. Перейдем в создание правил алёртинга.

Скриншот 7 - Создание правил алертинга.
![Скриншот-7](./img/20.4.3.1_Создание_правил_алертинга.png)

2. Выберем проект `python-project` и создадим дефолтное правило алёртинга.

Скриншот 8 - Настройка алерта.
![Скриншот-8](./img/20.4.3.2_Настройка_алерта.png)

3. Снова сгенерируем событие `Generate sample event`.

Скриншот 9 - Тело сообщения из оповещения на почте.
![Скриншот-9](./img/20.4.3.3_Тело_сообщения_из_оповещения_на_почте.png)

---