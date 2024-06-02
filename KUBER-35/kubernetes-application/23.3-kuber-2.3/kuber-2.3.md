# Домашнее задание к занятию "`Конфигурация приложений`" - `Барышников Никита`


## Цель задания

В тестовой среде Kubernetes необходимо создать конфигурацию и продемонстрировать работу приложения.

### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу
<details>
	<summary></summary>
      <br>

1. Создать Deployment приложения, состоящего из контейнеров nginx и multitool.
2. Решить возникшую проблему с помощью ConfigMap.
3. Продемонстрировать, что pod стартовал и оба конейнера работают.
4. Сделать простую веб-страницу и подключить её к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

</details>

#### Решение:

Создадим пространство имен `application-configuration` для ДЗ.

1. Создадим Deployment приложения, состоящего из контейнеров nginx и multitool.

Файл deployment-nginx-multitool.yml.
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-nginx-multitool
  namespace: application-configuration
spec:
  replicas: 1
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
        image: dockerhub.timeweb.cloud/nginx:1.26
      - name: multitool
        image: dockerhub.timeweb.cloud/wbitt/network-multitool
```

С помощью команды `kubectl apply -f deployment-nginx-multitool.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pods -n application-configuration` выведем все поды в пространстве `application-configuration` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -n application-configuration
NAME                                          READY   STATUS             RESTARTS      AGE
deployment-nginx-multitool-7b6976f548-qmfn5   1/2     CrashLoopBackOff   2 (26s ago)   54s
```

Один из конетейнеров не зупаскается, так как контейнеры nginx и multitool пытаются использовать один и тот же порт 80.

2. Решим возникшую проблему с помощью ConfigMap.

Для решения проблемы необходимо с помощью параметра `HTTP_PORT` изменить порт 80 на 8080 для контейнера multitool.

Укажим порт 8080 в ConfigMap.

Файл configmap.yml
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-nginx-multitool
  namespace: application-configuration
data:
  HTTP_PORT: "8080"
```

С помощью команды `kubectl apply -f configmap.yml` отправим манифест в кластер.  
C помощью команды `kubectl get configmaps -n application-configuration` выведем все configmap в пространстве `application-configuration` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get configmaps -n application-configuration
NAME                        DATA   AGE
configmap-nginx-multitool   1      13s
kube-root-ca.crt            1      20h
```

Также необходимо отредактировать deployment-nginx-multitool.yml

Файл deployment-nginx-multitool.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-nginx-multitool
  namespace: application-configuration
spec:
  replicas: 1
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
        image: dockerhub.timeweb.cloud/nginx:1.26
      - name: multitool
        image: dockerhub.timeweb.cloud/wbitt/network-multitool
        env:
        - name: HTTP_PORT
          valueFrom:
            configMapKeyRef:
              name: configmap-nginx-multitool
              key: HTTP_PORT
```

С помощью команды `kubectl apply -f deployment-nginx-multitool.yml` отправим манифест в кластер.

3. Проверим, что pod стартовал и оба конейнера работают.

C помощью команды `kubectl get pods -n application-configuration` выведем все поды в пространстве `application-configuration` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -n application-configuration
NAME                                          READY   STATUS    RESTARTS   AGE
deployment-nginx-multitool-7d88b4b97b-ljl4r   2/2     Running   0          12s
```

4. Сделаем простую веб-страницу и подключим её к Nginx с помощью ConfigMap.

Отредактируем файлы deployment-nginx-multitool.yml и configmap.yml.

Файл deployment-nginx-multitool.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-nginx-multitool
  namespace: application-configuration
spec:
  replicas: 1
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
        image: dockerhub.timeweb.cloud/nginx:1.26
        volumeMounts:
          - name: nginx-index-file
            mountPath: /usr/share/nginx/html/
      - name: multitool
        image: dockerhub.timeweb.cloud/wbitt/network-multitool
        env:
        - name: HTTP_PORT
          valueFrom:
            configMapKeyRef:
              name: configmap-nginx-multitool
              key: HTTP_PORT
      volumes:
        - name: nginx-index-file
          configMap:
            name: configmap-nginx-multitool
```

Файл configmap.yml
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-nginx-multitool
  namespace: application-configuration
data:
  HTTP_PORT: "8080"
  index.html: |
    <html>
    <h1>Welcome</h1>
    </br>
    <h1>This is a configMap Index file</h1>
    </html>
```

С помощью команд `kubectl apply -f configmap.yml` и `kubectl apply -f deployment-nginx-multitool.yml` отправим манифесты в кластер.

Создадим отдельный Service.

Файл service.yml.
```yml
apiVersion: v1
kind: Service
metadata:
  name: service-nginx-multitool
  namespace: application-configuration
spec:
  type: NodePort
  ports:
    - name: nginx
      port: 80
      protocol: TCP
      targetPort: 80
      nodePort: 30000
    - name: multitool
      port: 8080
      protocol: TCP
      targetPort: 8080
      nodePort: 30001
  selector:
    app: deployment
```

Подключим Service.

С помощью команды `kubectl apply -f service.yml` отправим манифест в кластер.  
C помощью команды `kubectl get svc -n application-configuration` выведем все сервисы в пространстве `application-configuration` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get svc -n application-configuration
NAME                      TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE
service-nginx-multitool   NodePort   10.152.183.233   <none>        80:30000/TCP,8080:30001/TCP   10s
```

Проверим вывод `curl`:
```bash
baryshnikov@kuber:~$ curl 158.160.86.63:30000
<html>
<h1>Welcome</h1>
</br>
<h1>This is a configMap Index file</h1>
</html>
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ curl 158.160.86.63:30001
WBITT Network MultiTool (with NGINX) - deployment-nginx-multitool-7777d66f96-49cx7 - 10.1.106.165 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
baryshnikov@kuber:~$
```

---

### Задание 2. Создать приложение с вашей веб-страницей, доступной по HTTPS
<details>
	<summary></summary>
      <br>

1. Создать Deployment приложения, состоящего из Nginx.
2. Создать собственную веб-страницу и подключить её как ConfigMap к приложению.
3. Выпустить самоподписной сертификат SSL. Создать Secret для использования сертификата.
4. Создать Ingress и необходимый Service, подключить к нему SSL в вид. Продемонстировать доступ к приложению по HTTPS. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

</details>

#### Решение:

1. Создадим Deployment приложения, состоящего из Nginx.

Файл deployment-nginx.yml.
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-nginx
  namespace: application-configuration
spec:
  replicas: 1
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
        image: dockerhub.timeweb.cloud/nginx:1.26
        volumeMounts:
          - name: nginx-index-file
            mountPath: /usr/share/nginx/html/
      volumes:
        - name: nginx-index-file
          configMap:
            name: configmap-nginx
```

2. Создадим собственную веб-страницу и подключим её как ConfigMap к приложению.

Файл configmap-nginx.yml
```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-nginx
  namespace: application-configuration
data:
  index.html: |
    <html>
    <h1>Welcome</h1>
    </br>
    <h1>This is a configMap Index file</h1>
    </html>
```

С помощью команд `kubectl apply -f configmap-nginx.yml` и `kubectl apply -f deployment-nginx.yml` отправим манифесты в кластер.

C помощью команды `kubectl get configmaps -n application-configuration` выведем все configmap в пространстве `application-configuration` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get configmap -n application-configuration
NAME                        DATA   AGE
configmap-nginx             1      95s
configmap-nginx-multitool   2      64m
kube-root-ca.crt            1      21h
```

C помощью команды `kubectl get pods -n application-configuration` выведем все поды в пространстве `application-configuration` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -n application-configuration
NAME                                          READY   STATUS    RESTARTS   AGE
deployment-nginx-57fd5fff5c-77b4t             1/1     Running   0          9m29s
deployment-nginx-multitool-7777d66f96-49cx7   2/2     Running   0          51m
```

3. Выпустим самоподписной сертификат SSL. 

Сгенерируем самоподписной сертификал с помощью команды ```openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout tls.key -out tls.crt -subj "/CN=my-example.com" -days 365```.  
Получим файлы ```tls.crt``` и ```tls.key```.

Создадим Secret для использования сертификата c помощью команды:
```bash
baryshnikov@kuber:~$ kubectl create secret tls tls-secret --key tls.key --cert tls.crt --namespace=application-configuration
secret/tls-secret created
```

Проверим, что Secret создан:
```bash
baryshnikov@kuber:~$ kubectl get secrets -n application-configuration
NAME         TYPE                DATA   AGE
tls-secret   kubernetes.io/tls   2      14s
```

4. Создадим Ingress.

Файл ingress.yml.
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: application-configuration
spec:
  rules:
  - host: my-example.com
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: service-nginx
              port:
                number: 80
  tls:
    - hosts:
      - my-example.com
      secretName: secret-tls
```

Создадим необходимый Service:

Файл service-nginx.yml.
```yml
apiVersion: v1
kind: Service
metadata:
  name: service-nginx
  namespace: application-configuration
spec:
  type: NodePort
  ports:
    - name: nginx
      port: 80
      protocol: TCP
      targetPort: 80
      nodePort: 31000
  selector:
    app: deployment
```

С помощью команд `kubectl apply -f service-nginx.yml` и `kubectl apply -f ingress.yml` отправим манифесты в кластер.  
C помощью команды `kubectl get svc -n application-configuration` выведем все сервисы в пространстве `application-configuration` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get svc -n application-configuration
NAME                      TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                       AGE
service-nginx             NodePort   10.152.183.147   <none>        80:31000/TCP                  12m
service-nginx-multitool   NodePort   10.152.183.233   <none>        80:30000/TCP,8080:30001/TCP   139m
```

С помощью команды `kubectl get ingress -n application-configuration` проверим состояние добавленного Ingress:
```bash
baryshnikov@kuber:~$ kubectl get ingress -n application-configuration
NAME      CLASS    HOSTS            ADDRESS     PORTS     AGE
ingress   public   my-example.com   127.0.0.1   80, 443   43s
```

Затем в файл hosts добавим строчку ```158.160.86.63 my-example.com```.

Далее, проверим доступ к приложению по HTTPS:
```bash
baryshnikov@kuber:~$ curl -k https://my-example.com
<html>
<h1>Welcome</h1>
</br>
<h1>This is a configMap Index file</h1>
</html>
baryshnikov@kuber:~$
```

---