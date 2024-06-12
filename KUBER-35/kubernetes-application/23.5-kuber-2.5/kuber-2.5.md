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