# Домашнее задание к занятию "`Обновление приложений`" - `Барышников Никита`


## Цель задания

Выбрать и настроить стратегию обновления приложения.

### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор
<details>
	<summary></summary>
      <br>

1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
2. Ресурсы, выделенные для приложения, ограничены, и нет возможности их увеличить.
3. Запас по ресурсам в менее загруженный момент времени составляет 20%.
4. Обновление мажорное, новые версии приложения не умеют работать со старыми.
5. Вам нужно объяснить свой выбор стратегии обновления приложения.

</details>

#### Решение:

Так как запас ресурсов, выделенных для приложений, ограничен и в менее загруженный момент времени составляет 20%, то, скорее всего, в кластере нет возможности одновременно запустить несколько реплик новых и старых версий приложений, поэтому считаю, что в данном случае будет оптимальнее всего использовать стратегию обновления **Rolling update** (постепенное обновление).  
**Rolling update** - это стандартная стратегия развёртывания в Kubernetes. Она постепенно, один за другим заменяет поды со старой версией приложения на поды с новой версией без простоя кластера.  
Для обновления в манифест необходимо будет добавить:
```yaml
strategy:
type: RollingUpdate
rollingUpdate:
maxSurge: 20%
maxUnavailable: 20%
```

Параметр `maxSurge: 20%` позволит дополнительно запустить 20% реплик с новой версией приложения помимо уже имеющихся.  
Параметр `maxUnavailable: 20%` позволит уничтожить 20% реплик со старой версией приложения в процессе обновления, чтобы освободить ресурсы для реплик с новой версией приложения.

Также необходимо отметить, что обновления лучше всего проводить в менее загруженный момент времени.

---

### Задание 2. Обновить приложение
<details>
	<summary></summary>
      <br>

1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Количество реплик — 5.
2. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
4. Откатиться после неудачного обновления.

</details>

#### Решение:

Создадим пространство имен `updating-applications` для ДЗ.

1. Создадим deployment приложения с контейнерами nginx и multitool. Версию nginx возьмем 1.19. Количество реплик — 5.

Файл deployment-nginx-multitool-v1.19.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-nginx-multitool
  namespace: updating-applications
spec:
  replicas: 5
  selector:
    matchLabels:
      app: deployment
  template:
    metadata:
      labels:
        app: deployment
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
      - name: multitool
        image: wbitt/network-multitool
        env:
          - name: HTTP_PORT
            value: "8080"
```

С помощью команды `kubectl apply -f deployment-nginx-multitool-v1.19.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pods -o wide -w -n updating-applications` выведем все поды в пространстве `updating-applications` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -o wide -w -n updating-applications
NAME                                         READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
deployment-nginx-multitool-c49b7cf74-5cxp5   2/2     Running   0          3m14s   10.1.106.167   kuber   <none>           <none>
deployment-nginx-multitool-c49b7cf74-kwrgz   2/2     Running   0          3m14s   10.1.106.168   kuber   <none>           <none>
deployment-nginx-multitool-c49b7cf74-ntkmk   2/2     Running   0          3m14s   10.1.106.169   kuber   <none>           <none>
deployment-nginx-multitool-c49b7cf74-vj52n   2/2     Running   0          3m14s   10.1.106.170   kuber   <none>           <none>
deployment-nginx-multitool-c49b7cf74-zq4nr   2/2     Running   0          3m14s   10.1.106.171   kuber   <none>           <none>
```

2. Обновим версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.

Применем манифест с обновленной версией nginx.
Файл deployment-nginx-multitool-v1.20.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-nginx-multitool
  namespace: updating-applications
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 5
      maxUnavailable: 3
  selector:
    matchLabels:
      app: deployment
  template:
    metadata:
      labels:
        app: deployment
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
      - name: multitool
        image: wbitt/network-multitool
        env:
          - name: HTTP_PORT
            value: "8080"
```

Для обновления приложения выберем стратегию **Rolling update**. Значение параметра `maxSurge:` выберем равным 5 для сокращения времени обновления, а значение параметра `maxSurge:` укажем равное 3, чтобы пока поднимаются контейнеры с новой версией приложения хотя бы 2 старых оставались в рабочем состоянии.

С помощью команды `kubectl apply -f deployment-nginx-multitool-v1.20.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pods -o wide -w -n updating-applications` выведем все поды в пространстве `updating-applications` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -o wide -w -n updating-applications
NAME                                          READY   STATUS              RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
deployment-nginx-multitool-55f9d5ff78-5g2vw   0/2     ContainerCreating   0          4s    <none>         kuber   <none>           <none>
deployment-nginx-multitool-55f9d5ff78-dx4rr   0/2     ContainerCreating   0          4s    <none>         kuber   <none>           <none>
deployment-nginx-multitool-55f9d5ff78-kx42s   0/2     ContainerCreating   0          4s    <none>         kuber   <none>           <none>
deployment-nginx-multitool-55f9d5ff78-nv6bf   0/2     ContainerCreating   0          4s    <none>         kuber   <none>           <none>
deployment-nginx-multitool-55f9d5ff78-z7n54   0/2     ContainerCreating   0          4s    <none>         kuber   <none>           <none>
deployment-nginx-multitool-c49b7cf74-vj52n    2/2     Running             0          17m   10.1.106.170   kuber   <none>           <none>
deployment-nginx-multitool-c49b7cf74-zq4nr    2/2     Running             0          17m   10.1.106.171   kuber   <none>           <none>

deployment-nginx-multitool-55f9d5ff78-5g2vw   2/2     Running   0          24s   10.1.106.174   kuber   <none>           <none>
deployment-nginx-multitool-55f9d5ff78-dx4rr   2/2     Running   0          24s   10.1.106.172   kuber   <none>           <none>
deployment-nginx-multitool-55f9d5ff78-kx42s   2/2     Running   0          24s   10.1.106.173   kuber   <none>           <none>
deployment-nginx-multitool-55f9d5ff78-nv6bf   2/2     Running   0          24s   10.1.106.175   kuber   <none>           <none>
deployment-nginx-multitool-55f9d5ff78-z7n54   2/2     Running   0          24s   10.1.106.176   kuber   <none>           <none>
```

3. Попытаемся обновить nginx до версии 1.28, приложение должно оставаться доступным.
Применем манифест с обновленной версией nginx.
Файл deployment-nginx-multitool-v1.28.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-nginx-multitool
  namespace: updating-applications
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 5
      maxUnavailable: 3
  selector:
    matchLabels:
      app: deployment
  template:
    metadata:
      labels:
        app: deployment
    spec:
      containers:
      - name: nginx
        image: nginx:1.28
      - name: multitool
        image: wbitt/network-multitool
        env:
          - name: HTTP_PORT
            value: "8080"
```

С помощью команды `kubectl apply -f deployment-nginx-multitool-v1.28.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pods -o wide -w -n updating-applications` выведем все поды в пространстве `updating-applications` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -o wide -w -n updating-applications
NAME                                          READY   STATUS              RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
deployment-nginx-multitool-55f9d5ff78-kx42s   2/2     Running             0          8m34s   10.1.106.173   kuber   <none>           <none>
deployment-nginx-multitool-55f9d5ff78-nv6bf   2/2     Running             0          8m34s   10.1.106.175   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-869db   0/2     ContainerCreating   0          7s      <none>         kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-pqxvh   1/2     ImagePullBackOff    0          7s      10.1.106.178   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-pwggl   1/2     ImagePullBackOff    0          8s      10.1.106.177   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-qb74t   1/2     ImagePullBackOff    0          8s      10.1.106.181   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-wkjlc   1/2     ImagePullBackOff    0          8s      10.1.106.180   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-869db   1/2     ErrImagePull        0          9s      10.1.106.179   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-869db   1/2     ImagePullBackOff    0          10s     10.1.106.179   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-pqxvh   1/2     ErrImagePull        0          31s     10.1.106.178   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-wkjlc   1/2     ErrImagePull        0          35s     10.1.106.180   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-qb74t   1/2     ErrImagePull        0          36s     10.1.106.181   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-pwggl   1/2     ErrImagePull        0          38s     10.1.106.177   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-869db   1/2     ErrImagePull        0          40s     10.1.106.179   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-pqxvh   1/2     ImagePullBackOff    0          44s     10.1.106.178   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-qb74t   1/2     ImagePullBackOff    0          47s     10.1.106.181   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-wkjlc   1/2     ImagePullBackOff    0          49s     10.1.106.180   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-pwggl   1/2     ImagePullBackOff    0          53s     10.1.106.177   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-869db   1/2     ImagePullBackOff    0          55s     10.1.106.179   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-pqxvh   1/2     ErrImagePull        0          59s     10.1.106.178   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-qb74t   1/2     ErrImagePull        0          62s     10.1.106.181   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-wkjlc   1/2     ErrImagePull        0          64s     10.1.106.180   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-pwggl   1/2     ErrImagePull        0          70s     10.1.106.177   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-869db   1/2     ErrImagePull        0          71s     10.1.106.179   kuber   <none>           <none>
deployment-nginx-multitool-75d759d9bb-pqxvh   1/2     ImagePullBackOff    0          71s     10.1.106.178   kuber   <none>           <none>
```

Из вывода команды `kubectl get pods -o wide -w -n updating-applications` видно, что 2 старых пода остаются в работе, в то время как новые запуститься не могут из-за не существования образа nginx:1.28.

Проверим историю обновлений.
```bash
baryshnikov@kuber:~$ kubectl rollout history deployment -n updating-applications
deployment.apps/deployment-nginx-multitool
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>
```

4. Откатимся после неудачного обновления с помощью команды `kubectl rollout undo deployment -n updating-applications`
```bash
baryshnikov@kuber:~$ kubectl rollout undo deployment -n updating-applications
deployment.apps/deployment-nginx-multitool rolled back
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ kubectl rollout history deployment -n updating-applications
deployment.apps/deployment-nginx-multitool
REVISION  CHANGE-CAUSE
1         <none>
3         <none>
4         <none>
```

---