# Домашнее задание к занятию "`Продвинутые методы работы с Terraform`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

1. Возьмите из [демонстрации к лекции готовый код](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1) для создания ВМ с помощью remote-модуля.
2. Создайте одну ВМ, используя этот модуль. В файле cloud-init.yml необходимо использовать переменную для ssh-ключа вместо хардкода. Передайте ssh-ключ в функцию template_file в блоке vars ={} .
Воспользуйтесь [**примером**](https://grantorchard.com/dynamic-cloudinit-content-with-terraform-file-templates/). Обратите внимание, что ssh-authorized-keys принимает в себя список, а не строку.
3. Добавьте в файл cloud-init.yml установку nginx.
4. Предоставьте скриншот подключения к консоли и вывод команды ```sudo nginx -t```.

</details>

### Решение:

1. Возьмем из [демонстрации к лекции готовый код](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1) для создания ВМ с помощью remote-модуля.

2. Создадим одну ВМ, используя этот модуль (установим параметр ```instance_count  = 1``` в модуле ```test-vm```).

В файл ```variables.tf``` добавим переменную ключа:  
```hcl
variable "ssh-authorized-keys" {
  description = "The path to the public ssh key file"
  type    = list(string)
  default = ["/home/baryshnikov/.ssh/id_ed25519.pub"]
}
```

Передадим cloud-config в ВМ:
```hcl
data "template_file" "cloudinit" {
 template = file("./cloud-init.yml")
 vars = {
   ssh-authorized-keys = file(var.ssh-authorized-keys[0])
  }
}
```

3. Добавим в файл cloud-init.yml установку nginx.

4. Подключимся через ssh к ВМ:

Скриншот 1 - Подключение к консоли и вывод команды ```sudo nginx -t```.
![Скриншот-1](/TER-35/ter/17.4-ter-04/img/17.4.1_Подключение_к_консоли.png)

---