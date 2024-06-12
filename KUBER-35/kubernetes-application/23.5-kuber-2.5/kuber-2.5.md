# Домашнее задание к занятию "`Helm`" - `Барышников Никита`


## Цель задания

В тестовой среде Kubernetes необходимо установить и обновить приложения с помощью Helm.

### Задание 1. Подготовить Helm-чарт для приложения
<details>
	<summary></summary>
      <br>

1. Необходимо упаковать приложение в чарт для деплоя в разные окружения. 
2. Каждый компонент приложения деплоится отдельным deployment’ом или statefulset’ом.
3. В переменных чарта измените образ приложения для изменения версии.

</details>

#### Решение:

С помощью команды `helm create nginx` создадим Helm-чарт nginx.  
Удалим из чарта все лишнее и отредактируем файлы Chart.yaml, values.yaml, deployment.yaml и service.yaml.

Файл Chart.yaml
```yaml
apiVersion: v2
name: nginx
description: A Helm chart for Kubernetes

type: application

version: 0.1.0

appVersion: "1.27.0"
```

Файл values.yaml
```yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent

  tag: ""

service:
  type: ClusterIP
  port: 80
```

Файл deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: deployment
  template:
    metadata:
      labels:
        app: deployment
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: {{ .Values.service.port }}
              protocol: TCP
```

Файл service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
spec:
  ports:
    - name: nginx
      port: {{ .Values.service.port }}
      protocol: TCP
  selector:
    app: deployment
```

---

### Задание 2. Запустить две версии в разных неймспейсах
<details>
	<summary></summary>
      <br>

1. Подготовив чарт, необходимо его проверить. Запуститe несколько копий приложения.
2. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2.
3. Продемонстрируйте результат.

</details>

#### Решение:

Создадим пространство имен `app1` и `app2`.
```bash
baryshnikov@kuber:~$ kubectl create namespace app1
namespace/app1 created
baryshnikov@kuber:~$ kubectl create namespace app2
namespace/app2 created
```

Запустим одну версию приложения в пространстве app1.
```bash
baryshnikov@kuber:~$ helm upgrade --install --atomic nginx nginx/ --namespace app1
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/baryshnikov/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/baryshnikov/.kube/config
Release "nginx" does not exist. Installing it now.
NAME: nginx
LAST DEPLOYED: Wed Jun 12 07:30:36 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Запустим вторую версию приложения в том же пространстве app1.
```bash
baryshnikov@kuber:~$ helm upgrade --install --atomic nginx2 nginx/ --namespace app1 --set image.tag=1.26.0
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/baryshnikov/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/baryshnikov/.kube/config
Release "nginx2" does not exist. Installing it now.
NAME: nginx2
LAST DEPLOYED: Wed Jun 12 07:31:12 2024
NAMESPACE: app1
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Запустим третью версию приложения в пространстве app2.
```bash
baryshnikov@kuber:~$ helm upgrade --install --atomic nginx3 nginx/ --namespace app2 --set image.tag=1.25.0
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/baryshnikov/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/baryshnikov/.kube/config
Release "nginx3" does not exist. Installing it now.
NAME: nginx3
LAST DEPLOYED: Wed Jun 12 07:31:46 2024
NAMESPACE: app2
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Посмотрим релизы установленные в пространстве app1.
```bash
baryshnikov@kuber:~$ helm -n app1 list --all
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/baryshnikov/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/baryshnikov/.kube/config
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
nginx   app1            1               2024-06-12 07:30:36.091141454 +0000 UTC deployed        nginx-0.1.0     1.27.0
nginx2  app1            1               2024-06-12 07:31:12.585832541 +0000 UTC deployed        nginx-0.1.0     1.27.0
```

Посмотрим релизы установленные в пространстве app2.
```bash
baryshnikov@kuber:~$ helm -n app2 list --all
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/baryshnikov/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/baryshnikov/.kube/config
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
nginx3  app2            1               2024-06-12 07:31:46.989696668 +0000 UTC deployed        nginx-0.1.0     1.27.0
```

Выведем все deployment и service в пространстве app1 и app2.
```bash
baryshnikov@kuber:~$ kubectl get deployment -n app1
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
nginx    1/1     1            1           3m46s
nginx2   1/1     1            1           3m10s
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ kubectl get deployment -n app2
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
nginx3   1/1     1            1           2m42s
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ kubectl get svc -n app1
NAME     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
nginx    ClusterIP   10.152.183.220   <none>        80/TCP    4m8s
nginx2   ClusterIP   10.152.183.156   <none>        80/TCP    3m32s
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ kubectl get svc -n app2
NAME     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
nginx3   ClusterIP   10.152.183.244   <none>        80/TCP    3m2s
```

---