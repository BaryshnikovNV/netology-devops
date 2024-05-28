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

### Задание 2. Создать DaemonSet приложения, которое может прочитать логи ноды.
<details>
	<summary></summary>
      <br>

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

</details>

#### Решение:

Создадим DaemonSet приложения, состоящего из multitool.

Файл daemonset-multitool.yml.
```yml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: daemonset-multitool
  namespace: storage-in-k8s-part-1
spec:
  selector:
    matchLabels:
      app: daemonset
  template:
    metadata:
      labels:
        app: daemonset
    spec:
      volumes:
        - name: host
          hostPath:
            path: /var/log
      containers:
        - name: multitool
          image: wbitt/network-multitool
          volumeMounts:
            - name: host
              mountPath: "/var/log/cluster"
```

С помощью команды `kubectl apply -f daemonset-multitool.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pods -n storage-in-k8s-part-1` выведем все поды в пространстве `storage-in-k8s-part-1` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get pods -n storage-in-k8s-part-1
NAME                                            READY   STATUS    RESTARTS   AGE
daemonset-multitool-mpbng                       1/1     Running   0          10s
deployment-busybox-multitool-648f499dd4-h8vxj   2/2     Running   0          66m
```

Проверим возможность чтения файла `syslog` изнутри пода:
```bash
baryshnikov@kuber:~$ kubectl exec -n storage-in-k8s-part-1 -it daemonset-multitool-mpbng -- sh
/ # tail /var/log/cluster/syslog
May 28 16:17:03 kuber microk8s.daemon-containerd[819]: time="2024-05-28T16:17:03.395538259Z" level=info msg="ImageUpdate event &ImageUpdate{Name:docker.io/wbitt/network-multitool:latest,Labels:map[string]string{io.cri-containerd.image: managed,},XXX_unrecognized:[],}"
May 28 16:17:03 kuber microk8s.daemon-containerd[819]: time="2024-05-28T16:17:03.399616395Z" level=info msg="ImageUpdate event &ImageUpdate{Name:docker.io/wbitt/network-multitool@sha256:d1137e87af76ee15cd0b3d4c7e2fcd111ffbd510ccd0af076fc98dddfc50a735,Labels:map[string]string{io.cri-containerd.image: managed,},XXX_unrecognized:[],}"
May 28 16:17:03 kuber microk8s.daemon-containerd[819]: time="2024-05-28T16:17:03.400475461Z" level=info msg="PullImage \"wbitt/network-multitool:latest\" returns image reference \"sha256:713337546be623588ed8ffd6d5e15dd3ccde8e4555ac5c97e5715d03580d2824\""
May 28 16:17:03 kuber microk8s.daemon-containerd[819]: time="2024-05-28T16:17:03.402265224Z" level=info msg="CreateContainer within sandbox \"3c7fa468c8f4565351fc38897be26fdbf73b2ebaadb5bad72c979f230aeac203\" for container &ContainerMetadata{Name:multitool,Attempt:0,}"
May 28 16:17:03 kuber microk8s.daemon-containerd[819]: time="2024-05-28T16:17:03.437617448Z" level=info msg="CreateContainer within sandbox \"3c7fa468c8f4565351fc38897be26fdbf73b2ebaadb5bad72c979f230aeac203\" for &ContainerMetadata{Name:multitool,Attempt:0,} returns container id \"6eb6689dd09067d0c87a2ce1986ce37fc20a97672270ca4ff70089371bb0aab1\""
May 28 16:17:03 kuber microk8s.daemon-containerd[819]: time="2024-05-28T16:17:03.438128681Z" level=info msg="StartContainer for \"6eb6689dd09067d0c87a2ce1986ce37fc20a97672270ca4ff70089371bb0aab1\""
May 28 16:17:03 kuber systemd-networkd[774]: calif984e3522a5: Gained IPv6LL
May 28 16:17:03 kuber microk8s.daemon-containerd[819]: time="2024-05-28T16:17:03.498553016Z" level=info msg="StartContainer for \"6eb6689dd09067d0c87a2ce1986ce37fc20a97672270ca4ff70089371bb0aab1\" returns successfully"
May 28 16:17:04 kuber microk8s.daemon-kubelite[4941]: I0528 16:17:04.319660    4941 pod_startup_latency_tracker.go:102] "Observed pod startup duration" pod="storage-in-k8s-part-1/daemonset-multitool-mpbng" podStartSLOduration=2.219564291 podStartE2EDuration="3.319625651s" podCreationTimestamp="2024-05-28 16:17:01 +0000 UTC" firstStartedPulling="2024-05-28 16:17:02.300730804 +0000 UTC m=+5731.069650881" lastFinishedPulling="2024-05-28 16:17:03.400792145 +0000 UTC m=+5732.169712241" observedRunningTime="2024-05-28 16:17:04.318727403 +0000 UTC m=+5733.087647511" watchObservedRunningTime="2024-05-28 16:17:04.319625651 +0000 UTC m=+5733.088545752"
May 28 16:17:20 kuber systemd[1]: run-containerd-runc-k8s.io-48389d21b9f946bff658664e5e8389d32b9017a2b2be79bef7bfcd581901ef91-runc.3yVMvo.mount: Deactivated successfully.
/ #
```

---