# Домашнее задание к занятию "`Оркестрация кластером Docker контейнеров на примере Docker Swarm`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

Дайте письменые ответы на вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm-кластере: replication и global?
- Какой алгоритм выбора лидера используется в Docker Swarm-кластере?
- Что такое Overlay Network?

</details>

### Решение:

- В чём отличие режимов работы сервисов в Docker Swarm-кластере: replication и global?

Для реплицированного сервиса указывается сколько идентичных задач нужно запустить. Например, развернуть сервис HTTP с тремя репликами, каждая из которых обслуживает один и тот же контент.

Глобальный сервис — это сервис, который запускает одну задачу на каждой ноде. Предварительно заданного количества задач нет. Каждый раз, когда добавляется нода в swarm, оркестратор создает задачу, а планировщик назначает задачу новой ноде.


- Какой алгоритм выбора лидера используется в Docker Swarm-кластере?

Один из ключевых компонентов Docker Swarm — это Raft, алгоритм консенсуса, который обеспечивает надежность и устойчивость к авариям в кластере Docker.  
Raft — это алгоритм консенсуса, который позволяет узлам кластера приходить к согласию относительно состояния системы в случае сбоев и изменяющихся условий среды. Docker Swarm использует этот алгоритм для выбора лидера кластера, который координирует работу других узлов и принимает решения от имени всего кластера.

Raft использует следующие основные понятия:  
1. Лидер — узел, который выбирается консенсусом как текущий координатор кластера. Он отвечает за принятие решений и репликацию этих решений на другие узлы.
2. Подчиненные — узлы, которые следуют решениям лидера.
3. Распределенный журнал — реплицированный и упорядоченный журнал событий, который хранится на всех узлах кластера.
4. Лог-согласование — процесс, при котором узлы соглашаются об одном и том же состоянии системы.


- Что такое Overlay Network?

**Overlay network** или наложенная сеть или оверлей — виртуальная сеть туннелей, работающая поверх физической.

---

## Задание 2.
<details>
	<summary></summary>
      <br>

Создайте ваш первый Docker Swarm-кластер в Яндекс Облаке.

Чтобы получить зачёт, предоставьте скриншот из терминала (консоли) с выводом команды:
```
docker node ls
```

</details>

### Решение:

Инициализируем Terraform c помощью команды ```terraform init```, проверим план с помощью команды ```terraform plan``` и используем его с помощью команды ```terraform apply```:

Скриншот 1 - Вывод команды ```terraform apply```.
![Скриншот-1](/VIRTD-35/virt/16.5-virt-05-docker-swarm/img/16.5.2.1_Вывод_команды_terraform_apply.png)

Зайдем на ноду node01 и проверим Docker Swarm-клсатер с помощью команды ```docker node ls```:

Скриншот 2 - Созданный Docker Swarm-кластер в Яндекс.Облаке на 6 нод.
![Скриншот-2](/VIRTD-35/virt/16.5-virt-05-docker-swarm/img/16.5.2.2_Созданный_Docker_Swarm-кластер_в_Яндекс.Облаке_на_6_нод.png)

---

## Задание 3.
<details>
	<summary></summary>
      <br>

Создайте ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Чтобы получить зачёт, предоставьте скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```

</details>

### Решение:

Проверим клсатер мониторинга, состоящий из стека микросервисов с помощью команды ```docker service ls```:

Скриншот 3 - Созданный кластер мониторинга, состоящий из стека микросервисов.
![Скриншот-3](/VIRTD-35/virt/16.5-virt-05-docker-swarm/img/16.5.3_Созданный_кластер_мониторинга,_состоящий_из_стека_микросервисов.png)

---

## Задание 4.
<details>
	<summary></summary>
      <br>

Выполните на лидере Docker Swarm-кластера команду, указанную ниже, и дайте письменное описание её функционала — что она делает и зачем нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```

</details>

### Решение:

Выполним на лидере Docker Swarm-кластера команду ```docker swarm update --autolock=true```:

Скриншот 4 - Скриншот выполнения команды на лидере Docker Swarm кластера.
![Скриншот-4](/VIRTD-35/virt/16.5-virt-05-docker-swarm/img/16.5.4_Скриншот_выполнения_команды_на_лидере_Docker_Swarm_кластера.png)

Команда ```docker swarm update --autolock=true``` создаёт ключ для шифрования/дешифрования логов Raft.  
Блокировка нужна для защиты ключа шифрования. При перезапуске Docker в память каждого управляющего узла загружается как ключ TLS, используемый для шифрования связи между узлами swarm, так и ключ, используемый для шифрования и расшифровки журналов Raft на диске. Docker может защитить общий ключ TLS и ключ используемый для шифрования журналов Raft, предоставив управление им и ручной разблокировкой узлов пользователю. Данная функция называется *автоблокировка*.

---