# Домашнее задание к занятию "`Как работает сеть в K8s`" - `Барышников Никита`


## Цель задания

Настроить сетевую политику доступа к подам.

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа
<details>
	<summary></summary>
      <br>

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.
4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
5. Продемонстрировать, что трафик разрешён и запрещён.

</details>

#### Решение:

Работу выполним на MicroK8S.  
Убедимся, что кластер имеет сетевой плагин Calico и он работает.
```bash
baryshnikov@kuber:~$ kubectl get po -A
NAMESPACE     NAME                                         READY   STATUS    RESTARTS        AGE
kube-system   calico-kube-controllers-77bd7c5b-5hbg7       1/1     Running   1 (6m31s ago)   12m
kube-system   calico-node-qpxzm                            1/1     Running   1 (6m31s ago)   12m
kube-system   coredns-864597b5fd-hbdst                     1/1     Running   1 (6m31s ago)   12m
kube-system   dashboard-metrics-scraper-5657497c4c-m9s8b   1/1     Running   1 (6m31s ago)   8m57s
kube-system   kubernetes-dashboard-54b48fbf9-f6rxp         1/1     Running   1 (6m31s ago)   8m57s
kube-system   metrics-server-848968bdcd-twljt              1/1     Running   1 (6m31s ago)   8m58s
```

Создадим пространство имен `app` для ДЗ.  
Создадим deployment'ы приложений [frontend](./config/deployment&service/deployment-frontend.yml), [backend](./config/deployment&service/deployment-backend.yml) и [cache](./config/deployment&service/deployment-cache.yml) и соответсвующие [сервисы](./config/deployment&service).

Отправим манифесты deployment'ов в кластер.
```bash
baryshnikov@kuber:~$ kubectl apply -f deployment-frontend.yml
deployment.apps/frontend created
baryshnikov@kuber:~$ kubectl apply -f deployment-backend.yml
deployment.apps/backend created
baryshnikov@kuber:~$ kubectl apply -f deployment-cache.yml
deployment.apps/cache created
```

Выведем все поды в пространстве `app` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -n app
NAME                        READY   STATUS    RESTARTS   AGE
backend-c9bbf6f68-r8t56     1/1     Running   0          44s
cache-bd6c58d5f-lr2gk       1/1     Running   0          35s
frontend-6d7978b6c6-wvnqt   1/1     Running   0          52s
```

Отправим манифесты service'ов в кластер.
```bash
baryshnikov@kuber:~$ kubectl apply -f service-frontend.yml
service/service-frontend created
baryshnikov@kuber:~$ kubectl apply -f service-backend.yml
service/service-backend created
baryshnikov@kuber:~$ kubectl apply -f service-cache.yml
service/service-cache created
```
Выведем все сервисы в пространстве `app` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get svc -n app
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service-backend    ClusterIP   10.152.183.188   <none>        80/TCP    28s
service-cache      ClusterIP   10.152.183.37    <none>        80/TCP    22s
service-frontend   ClusterIP   10.152.183.27    <none>        80/TCP    36s
```

Проверим доступность сервисов между собой
```bash
baryshnikov@kuber:~$ kubectl exec -n app backend-c9bbf6f68-r8t56 -- curl service-cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   138  100   138    0     0  72289      0 --:--:-- --:--:-- --:--:--  134k
WBITT Network MultiTool (with NGINX) - cache-bd6c58d5f-lr2gk - 10.1.106.144 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ kubectl exec -n app cache-bd6c58d5f-lr2gk -- curl service-frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   142  100   142    0     0   101k      0 --:--:-- --:--:-- --:--:--  138k
WBITT Network MultiTool (with NGINX) - frontend-6d7978b6c6-wvnqt - 10.1.106.142 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ kubectl exec -n app frontend-6d7978b6c6-wvnqt -- curl service-backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   140  100   140    0     0   134k      0 --:--:-- --:--:-- --:--:--  136k
WBITT Network MultiTool (with NGINX) - backend-c9bbf6f68-r8t56 - 10.1.106.143 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

Создадим сетевую политику запрещающий весь трафик между подами в кластере.

Файл deny.yml
```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ingress-deny-all
  namespace: app
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

Отправим манифест в кластер.
```bash
baryshnikov@kuber:~$ kubectl apply -f deny.yml
networkpolicy.networking.k8s.io/ingress-deny-all created
```

Просмотрим объекты сетевой политики в пространстве `app` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get networkpolicy -n app
NAME               POD-SELECTOR   AGE
ingress-deny-all   <none>         168m
```

Убедимся, что весь трафик запрещен
```bash
baryshnikov@kuber:~$ kubectl exec -n app backend-c9bbf6f68-r8t56 -- curl service-cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:01:00 --:--:--     0
```

Создалим политику, чтобы обеспечить доступ frontend -> backend:

Файл allow-front-to-back.yml
```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-front-to-back
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: back
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: front
  policyTypes:
  - Ingress
```

Отправим манифест в кластер.
```bash
baryshnikov@kuber:~$ kubectl apply -f allow-front-to-back.yml
networkpolicy.networking.k8s.io/allow-front-to-back created
```

Просмотрим объекты сетевой политики в пространстве `app` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get networkpolicy -n app
NAME                  POD-SELECTOR   AGE
allow-front-to-back   app=back       19s
ingress-deny-all      <none>         3h6m
```

Просмотрим описание сетевой политики в пространстве `app`:
```bash
baryshnikov@kuber:~$ kubectl describe networkpolicy allow-front-to-back -n app
Name:         allow-front-to-back
Namespace:    app
Created on:   2024-06-29 12:41:44 +0000 UTC
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     app=back
  Allowing ingress traffic:
    To Port: <any> (traffic allowed to all ports)
    From:
      PodSelector: app=front
  Not affecting egress traffic
  Policy Types: Ingress
```

Убедимся, что сетевой трафик из frontend в backend разрешен
```bash
baryshnikov@kuber:~$ kubectl exec -n app frontend-6d7978b6c6-wvnqt -- curl service-backend
WBITT Network MultiTool (with NGINX) - backend-c9bbf6f68-r8t56 - 10.1.106.145 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   140  100   140    0     0  95693      0 --:--:-- --:--:-- --:--:--  136k
```

Создалим политику, чтобы обеспечить доступ backend -> cache:

Файл allow-back-to-cache.yml
```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-back-to-cache
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: cache
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: back
  policyTypes:
  - Ingress
```

Отправим манифест в кластер.
```bash
baryshnikov@kuber:~$ kubectl apply -f allow-back-to-cache.yml
networkpolicy.networking.k8s.io/allow-back-to-cache created
```

Просмотрим объекты сетевой политики в пространстве `app` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get networkpolicy -n app
NAME                  POD-SELECTOR   AGE
allow-back-to-cache   app=cache      22s
allow-front-to-back   app=back       14m
ingress-deny-all      <none>         3h20m
```

Просмотрим описание сетевой политики в пространстве `app`:
```bash
baryshnikov@kuber:~$ kubectl describe networkpolicy allow-back-to-cache -n app
Name:         allow-back-to-cache
Namespace:    app
Created on:   2024-06-29 12:56:02 +0000 UTC
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     app=cache
  Allowing ingress traffic:
    To Port: <any> (traffic allowed to all ports)
    From:
      PodSelector: app=back
  Not affecting egress traffic
  Policy Types: Ingress
```

Убедимся, что сетевой трафик из backend в cache разрешен
```bash
baryshnikov@kuber:~$ kubectl exec -n app backend-c9bbf6f68-r8t56 -- curl service-cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   138  100   138    0     0    99k      0 --:--:-- --:--:-- --:--:--  134k
WBITT Network MultiTool (with NGINX) - cache-bd6c58d5f-lr2gk - 10.1.106.150 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

Убедимся, что сетевой трафик из cache в frontend запрещен
```bash
baryshnikov@kuber:~$ kubectl exec -n app cache-bd6c58d5f-lr2gk -- curl service-frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:10 --:--:--     0
```

Убедимся, что сетевой трафик из cache в backend запрещен
```bash
baryshnikov@kuber:~$ kubectl exec -n app cache-bd6c58d5f-lr2gk -- curl service-backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:14 --:--:--     0
```

Убедимся, что сетевой трафик из backend в frontend запрещен
```bash
baryshnikov@kuber:~$ kubectl exec -n app backend-c9bbf6f68-r8t56 -- curl service-frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:13 --:--:--     0
```

---