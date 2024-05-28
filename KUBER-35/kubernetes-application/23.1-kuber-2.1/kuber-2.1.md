# Домашнее задание к занятию "`Хранение в K8s. Часть 1`" - `Барышников Никита`


## Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

### Задание 1. Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.
<details>
	<summary></summary>
      <br>

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

</details>

#### Решение:

Создадим пространство имен `storage-in-k8s-part-1` для ДЗ.

Создадим Deployment приложения, состоящего из контейнеров busybox и multitool.

Файл deployment-busybox-multitool.yml.
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-busybox-multitool
  namespace: storage-in-k8s-part-1
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
      volumes:
        - name: data
          emptyDir: {}
      containers:
        - name: busybox
          image: busybox:1.36.1
          command: ['sh', '-c', 'while true; do date >> /opt/date.log; sleep 5; done']
          volumeMounts:
            - name: data
              mountPath: "/opt"
        - name: multitool
          image: wbitt/network-multitool
          volumeMounts:
            - name: data
              mountPath: "/test"
```

С помощью команды `kubectl apply -f deployment-busybox-multitool.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pods -n storage-in-k8s-part-1` выведем все поды в пространстве `storage-in-k8s-part-1` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -n storage-in-k8s-part-1
NAME                                            READY   STATUS    RESTARTS   AGE
deployment-busybox-multitool-648f499dd4-h8vxj   2/2     Running   0          5s
```

Проверим возможность multitool читать файл, который периодоически обновляется:
```bash
baryshnikov@kuber:~$ kubectl exec -n storage-in-k8s-part-1 -it deployment-busybox-multitool-648f499dd4-h8vxj -c multitool -- sh
/ # cat /test/date.log
Tue May 28 15:10:53 UTC 2024
Tue May 28 15:10:58 UTC 2024
Tue May 28 15:11:03 UTC 2024
Tue May 28 15:11:08 UTC 2024
Tue May 28 15:11:13 UTC 2024
Tue May 28 15:11:18 UTC 2024
Tue May 28 15:11:23 UTC 2024
Tue May 28 15:11:28 UTC 2024
/ # exit
```

---