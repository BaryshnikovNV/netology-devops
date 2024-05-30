# Домашнее задание к занятию "`Хранение в K8s. Часть 2`" - `Барышников Никита`


## Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

### Задание 1. Создать Deployment приложения, использующего локальный PV, созданный вручную.
<details>
	<summary></summary>
      <br>

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

</details>

#### Решение:

Создадим пространство имен `storage-in-k8s-part-2` для ДЗ.

1. Создадим Deployment приложения, состоящего из контейнеров busybox и multitool.

Файл deployment-busybox-multitool.yml.
```yml
apiVersion: apps/v1
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-busybox-multitool
  namespace: storage-in-k8s-part-2
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
        - name: busybox
          image: dockerhub.timeweb.cloud/busybox
          command: ['sh', '-c', 'while true; do date >> /static/date.log; sleep 5; done']
          volumeMounts:
            - name: my-volume
              mountPath: /static
        - name: multitool
          image: dockerhub.timeweb.cloud/wbitt/network-multitool
          volumeMounts:
            - name: my-volume
              mountPath: /static
      volumes:
        - name: my-volume
          persistentVolumeClaim:
            claimName: task-pv-claim
```

2. Создаим PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.

Файл pv.yml.
```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
spec:
  storageClassName: manual
  capacity:
    storage: 10Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/test"
```

С помощью команды `kubectl apply -f pv.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pv` выведем все созданные PV.
```bash
baryshnikov@kuber:~$ kubectl get pv
NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
task-pv-volume   10Mi       RWO            Retain           Available           manual         <unset>
```

Файл pvc.yml.
```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
  namespace: storage-in-k8s-part-2
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
```

С помощью команды `kubectl apply -f pvc.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pvc -n storage-in-k8s-part-2` выведем все созданные PVC в пространстве `storage-in-k8s-part-2`.  
```bash
baryshnikov@kuber:~$ kubectl get pvc -n storage-in-k8s-part-2
NAME            STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
task-pv-claim   Bound    task-pv-volume   10Mi       RWO            manual         <unset>                 19s
```

3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории.

С помощью команды `kubectl apply -f deployment-busybox-multitool.yml` отправим манифест в кластер.  
C помощью команды `kubectl get pods -n storage-in-k8s-part-2` выведем все поды в пространстве `storage-in-k8s-part-2` с подробностями.  
```bash
baryshnikov@kuber:~$ kubectl get pods -n storage-in-k8s-part-2
NAME                                            READY   STATUS    RESTARTS   AGE
deployment-busybox-multitool-68b4977786-ctwxz   2/2     Running   0          13s
```

Проверим возможность multitool читать файл, который периодоически обновляется:  
```bash
baryshnikov@kuber:~$ kubectl exec -n storage-in-k8s-part-2 -it deployment-busybox-multitool-68b4977786-ctwxz -c multitool -- sh
/ # cat /static/date.log
Thu May 30 16:30:17 UTC 2024
Thu May 30 16:30:22 UTC 2024
Thu May 30 16:30:27 UTC 2024
Thu May 30 16:30:32 UTC 2024
Thu May 30 16:30:37 UTC 2024
Thu May 30 16:30:42 UTC 2024
Thu May 30 16:30:47 UTC 2024
Thu May 30 16:30:52 UTC 2024
Thu May 30 16:30:57 UTC 2024
Thu May 30 16:31:02 UTC 2024
/ # exit
```

4. Удалим Deployment и PVC.  
```bash
baryshnikov@kuber:~$ kubectl delete -n storage-in-k8s-part-2 deployment deployment-busybox-multitool
deployment.apps "deployment-busybox-multitool" deleted
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ kubectl delete -n storage-in-k8s-part-2 pvc task-pv-claim
persistentvolumeclaim "task-pv-claim" deleted
```

Посмотрим, что после этого произошло с PV.  
```bash
baryshnikov@kuber:~$ kubectl get pv
NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
task-pv-volume   10Mi       RWO            Retain           Released   storage-in-k8s-part-2/task-pv-claim   manual         <unset>
```

После удаления PVC, PV не удалился, а перешел в состояние `Released`. Т.е., PV считается `освобожденным` и не привязанным к PVC.

5. Проверим, что файл сохранился на локальном диске ноды.  
```bash
baryshnikov@kuber:~$ ls /test
date.log
```

Удалим PV.  
```bash
baryshnikov@kuber:~$ kubectl delete -n storage-in-k8s-part-2 pv task-pv-volume
Warning: deleting cluster-scoped resources, not scoped to the provided namespace
persistentvolume "task-pv-volume" deleted
baryshnikov@kuber:~$
baryshnikov@kuber:~$
baryshnikov@kuber:~$ kubectl get pv
No resources found
```

Проверим что произошло с файлом после удаления PV.  
```bash
baryshnikov@kuber:~$ ls /test
date.log
```

После удаления PV файл ls `/test/date.log` сохранился, так как по умолчанию после удаления PV ресурсы из внешних
провайдеров автоматически не удаляются. Если бы в манифесте PV вид политики ReclaimPolicy был указан либо Delete, либо Recycle, то файл бы удалился.

---