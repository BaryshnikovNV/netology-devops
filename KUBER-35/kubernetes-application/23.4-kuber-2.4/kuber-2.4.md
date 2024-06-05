# Домашнее задание к занятию "`Управление доступом`" - `Барышников Никита`


## Цель задания

В тестовой среде Kubernetes нужно предоставить ограниченный доступ пользователю.

### Задание 1. Создайте конфигурацию для подключения пользователя
<details>
	<summary></summary>
      <br>

1. Создайте и подпишите SSL-сертификат для подключения к кластеру.
2. Настройте конфигурационный файл kubectl для подключения.
3. Создайте роли и все необходимые настройки для пользователя.
4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).
5. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.

</details>

#### Решение:

Создадим пространство имен `access-control` для ДЗ.  
Создадим папку ~/certs и перейдем в ее с помощью команды `mkdir ~/certs && cd ~/certs`.

1. Создадим и подпишем SSL-сертификат для подключения к кластеру.

Первым делом создадим закрытый ключ для сертификата. Для этого воспользуемся командой **genrsa**:
```bash
openssl genrsa -out test.key 2048
```
Затем создадим запрос на подпись:
```bash
openssl req -new -key test.key -out test.csr -subj "/CN=test/O=ops"
```
Далее, сгенерируем сертификат сервера:
```bash
baryshnikov@kuber:~/certs$ openssl x509 -req -in test.csr -CA /var/snap/microk8s/current/certs/ca.crt -CAkey /var/snap/microk8s/current/certs/ca.key -CAcreateserial -out test.crt -days 500
Certificate request self-signature ok
subject=CN = test, O = ops
```

2. Настроим конфигурационный файл kubectl для подключения.

Добавим сведений о пользователе `test` в свой конфигурационный файл.
```bash
baryshnikov@kuber:~/certs$ kubectl config set-credentials test --client-certificate=test.crt --client-key=test.key
User "test" set.
```

Добавим сведений о контексте с именем `test-context` в файл конфигурации.
```bash
baryshnikov@kuber:~/certs$ kubectl config set-context test-context --cluster=microk8s-cluster --user=test
Context "test-context" created.
```

Далее, посмотрим файл конфигурации с добавленными сведениями:
```bash
baryshnikov@kuber:~/certs$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://10.129.0.28:16443
  name: microk8s-cluster
contexts:
- context:
    cluster: microk8s-cluster
    user: admin
  name: microk8s
- context:
    cluster: microk8s-cluster
    user: test
  name: test-context
current-context: microk8s
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
- name: test
  user:
    client-certificate: /home/baryshnikov/certs/test.crt
    client-key: /home/baryshnikov/certs/test.key
```

3. Создадим роли и все необходимые настройки для пользователя.

Включим RBAC в MicroK8S.

```bash
baryshnikov@kuber:~/certs$ microk8s enable rbac
Infer repository core for addon rbac
Enabling RBAC
Reconfiguring apiserver
Restarting apiserver
RBAC is enabled
baryshnikov@kuber:~/certs$
baryshnikov@kuber:~/certs$
baryshnikov@kuber:~/certs$ microk8s status
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dashboard            # (core) The Kubernetes dashboard
    dns                  # (core) CoreDNS
    ha-cluster           # (core) Configure high availability on the current node
    helm                 # (core) Helm - the package manager for Kubernetes
    helm3                # (core) Helm 3 - the package manager for Kubernetes
    ingress              # (core) Ingress controller for external access
    metrics-server       # (core) K8s Metrics Server for API access to service metrics
    rbac                 # (core) Role-Based Access Control for authorisation
  disabled:
    cert-manager         # (core) Cloud native certificate management
    cis-hardening        # (core) Apply CIS K8s hardening
    community            # (core) The community addons repository
    gpu                  # (core) Alias to nvidia add-on
    host-access          # (core) Allow Pods connecting to Host services smoothly
    hostpath-storage     # (core) Storage class; allocates storage from host directory
    kube-ovn             # (core) An advanced network fabric for Kubernetes
    mayastor             # (core) OpenEBS MayaStor
    metallb              # (core) Loadbalancer for your Kubernetes cluster
    minio                # (core) MinIO object storage
    nvidia               # (core) NVIDIA hardware (GPU and network) support
    observability        # (core) A lightweight observability stack for logs, traces and metrics
    prometheus           # (core) Prometheus operator for monitoring and logging
    registry             # (core) Private image registry exposed on localhost:32000
    rook-ceph            # (core) Distributed Ceph storage using Rook
    storage              # (core) Alias to hostpath-storage add-on, deprecated
```

Создадим Role.

Файл role.yml
```bash
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: access-control
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "watch", "list"]
```

Создадим RoleBinding.

Файл role-binding.yml
```bash
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader
  namespace: access-control
subjects:
- kind: User
  name: test
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

С помощью команд `kubectl apply -f role.yml` и `kubectl apply -f role-binding.yml` отправим манифесты в кластер.

C помощью команды `kubectl get role -n access-control` выведем все роли в пространстве `access-control` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get role -n access-control
NAME         CREATED AT
pod-reader   2024-06-05T14:59:51Z
```

C помощью команды `kubectl get rolebinding -n access-control` выведем все привязки субъектов к ролям в пространстве `access-control` с подробностями.
```bash
baryshnikov@kuber:~$ kubectl get rolebinding -n access-control
NAME         ROLE              AGE
pod-reader   Role/pod-reader   27s
```

4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).

Посмотрим на роль `pod-reader`:
```bash
baryshnikov@kuber:~$ kubectl get role pod-reader -n access-control -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"rbac.authorization.k8s.io/v1","kind":"Role","metadata":{"annotations":{},"name":"pod-reader","namespace":"access-control"},"rules":[{"apiGroups":[""],"resources":["pods","pods/log"],"verbs":["get","watch","list"]}]}
  creationTimestamp: "2024-06-05T14:59:51Z"
  name: pod-reader
  namespace: access-control
  resourceVersion: "287548"
  uid: 643c8fa6-2b28-4683-b0ce-dfedb7cc1486
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - pods/log
  verbs:
  - get
  - watch
  - list
```

---