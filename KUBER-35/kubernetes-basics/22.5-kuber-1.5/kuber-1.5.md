# Домашнее задание к занятию "`Сетевое взаимодействие в K8S. Часть 2`" - `Барышников Никита`


## Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к двум приложениям снаружи кластера по разным путям.

### Задание 1. Создать Deployment приложений backend и frontend
<details>
	<summary></summary>
      <br>

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

</details>

#### Решение:

Создадим пространство имен `networking-in-k8s-part2` для ДЗ.
```bash
baryshnikov@kuber:~$ kubectl create namespace networking-in-k8s-part2
namespace/networking-in-k8s-part2 created
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ kubectl get ns
NAME                      STATUS   AGE
default                   Active   21d
kube-node-lease           Active   21d
kube-public               Active   21d
kube-system               Active   21d
networking-in-k8s-part1   Active   21h
networking-in-k8s-part2   Active   32s
```

1. Создадим Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.

Файл deployment-frontend.yml.
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: networking-in-k8s-part2
spec:
  replicas: 3
  selector:
    matchLabels:
      app: front
  template:
    metadata:
      labels:
        app: front
    spec:
      containers:
      - name: nginx
        image: nginx:1.26
```

С помощью команды `kubectl apply -f deployment-frontend.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pods -n networking-in-k8s-part2` выведем все поды в пространстве `networking-in-k8s-part2` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -n networking-in-k8s-part2
NAME                        READY   STATUS    RESTARTS   AGE
frontend-65697b8cc5-m2w4h   1/1     Running   0          12s
frontend-65697b8cc5-n44fj   1/1     Running   0          12s
frontend-65697b8cc5-wjmq7   1/1     Running   0          12s
```

2. Создадим Deployment приложения _backend_ из образа multitool.

Файл deployment-backend.yml.
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: networking-in-k8s-part2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: back
  template:
    metadata:
      labels:
        app: back
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
```

С помощью команды `kubectl apply -f deployment-backend.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pods -n networking-in-k8s-part2` выведем все поды в пространстве `networking-in-k8s-part2` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -n networking-in-k8s-part2
NAME                        READY   STATUS    RESTARTS   AGE
backend-c9bbf6f68-zfh6x     1/1     Running   0          11s
frontend-65697b8cc5-m2w4h   1/1     Running   0          101s
frontend-65697b8cc5-n44fj   1/1     Running   0          101s
frontend-65697b8cc5-wjmq7   1/1     Running   0          101s
```

3. Добавим Service, который обеспечит доступ к обоим приложениям внутри кластера.

Файл service-frontend.yml.
```yml
apiVersion: v1
kind: Service
metadata:
  name: service-frontend
  namespace: networking-in-k8s-part2
spec:
  ports:
    - name: nginx
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: front
```

Файл service-backend.yml.
```yml
apiVersion: v1
kind: Service
metadata:
  name: service-backend
  namespace: networking-in-k8s-part2
spec:
  ports:
    - name: multitool
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: back
```

С помощью команд `kubectl apply -f service-frontend.yml` и `kubectl apply -f service-backend.yml` отправим манифесты в кластер.  
C помощью команды `kubectl get svc -n networking-in-k8s-part2` выведем все сервисы в пространстве `networking-in-k8s-part2` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get svc -n networking-in-k8s-part2
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service-backend    ClusterIP   10.152.183.186   <none>        80/TCP    8m17s
service-frontend   ClusterIP   10.152.183.232   <none>        80/TCP    8m50s
```

4. Продемонстрировать, что приложения видят друг друга с помощью Service.

Проверим доступ к backend с помощью команды `kubectl exec -n networking-in-k8s-part2 frontend-65697b8cc5-m2w4h -- curl service-backend`.

Доступ к backend:
```bash
baryshnikov@kuber:~$ kubectl exec -n networking-in-k8s-part2 frontend-65697b8cc5-m2w4h -- curl service-backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0WBITT Network MultiTool (with NGINX) - backend-c9bbf6f68-zfh6x - 10.1.106.181 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
100   140  100   140    0     0   133k      0 --:--:-- --:--:-- --:--:--  136k
```

Проверим доступ к frontend с помощью команды `kubectl exec -n networking-in-k8s-part2 backend-c9bbf6f68-zfh6x -- curl service-frontend`.

Доступ к frontend:
```bash
baryshnikov@kuber:~$ kubectl exec -n networking-in-k8s-part2 backend-c9bbf6f68-zfh6x -- curl service-frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   654k      0 --:--:-- --:--:-- --:--:--  600k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

---