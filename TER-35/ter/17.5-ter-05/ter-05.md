# Домашнее задание к занятию "`Использование Terraform в команде`" - `Барышников Никита`


## Задание 1.
<details>
	<summary></summary>
      <br>

1. Возьмите код:
- из [ДЗ к лекции 4](https://github.com/netology-code/ter-homeworks/tree/main/04/src),
- из [демо к лекции 4](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1).
2. Проверьте код с помощью tflint и checkov. Вам не нужно инициализировать этот проект.
3. Перечислите, какие **типы** ошибок обнаружены в проекте (без дублей).

</details>

### Решение:

Из [ДЗ к лекции 4](https://github.com/netology-code/ter-homeworks/tree/main/04/src) возьмем код.

Проверим код с помощью tflint. После ввода команды

```bash
docker run --rm -v $(pwd):/data -t ghcr.io/terraform-linters/tflint
```

Получаем результат:

Скриншот 1 - Проверка кода с помощью tflint для дз из лекции 4.
![Скриншот-1](/TER-35/ter/17.5-ter-05/img/17.5.1.1_Проверка_кода_с_помощью_tflint.png)

Исходя из скриншота 1 видно, что:

- *Missing version constraint for provider "yandex" in `required_providers` (terraform_required_providers)* - отсутствует ограничение версии yandex-провайдера;
- *[Fixable] variable "vms_ssh_root_key" is declared but not used (terraform_unused_declarations)* - переменная ```vms_ssh_root_key``` объявлена, но не используется;
- *[Fixable] variable "vm_web_name" is declared but not used (terraform_unused_declarations)* - переменная ```vm_web_name``` объявлена, но не используется;
- *[Fixable] variable "vm_db_name" is declared but not used (terraform_unused_declarations)* - переменная ```vm_db_name``` объявлена, но не используется.

Аналогичную операцию проделаем с [демо к лекции 4](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1).

Проверка кода с помощью tflint для демо к лекции 4:  
```
baryshnikov@debian:~/demonstration1$ sudo docker run --rm -v $(pwd):/data -t ghcr.io/terraform-linters/tflint
[sudo] пароль для baryshnikov: 
6 issue(s) found:

Warning: Missing version constraint for provider "yandex" in `required_providers` (terraform_required_providers)

  on main.tf line 3:
   3:     yandex = {
   4:       source = "yandex-cloud/yandex"
   5:     }

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_required_providers.md

Warning: Module source "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main" uses a default branch as ref (main) (terraform_module_pinned_source)

  on main.tf line 33:
  33:   source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_module_pinned_source.md

Warning: Missing version constraint for provider "template" in `required_providers` (terraform_required_providers)

  on main.tf line 51:
  51: data "template_file" "cloudinit" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_required_providers.md

Warning: [Fixable] variable "default_cidr" is declared but not used (terraform_unused_declarations)

  on variables.tf line 22:
  22: variable "default_cidr" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_unused_declarations.md

Warning: [Fixable] variable "vpc_name" is declared but not used (terraform_unused_declarations)

  on variables.tf line 28:
  28: variable "vpc_name" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_unused_declarations.md

Warning: [Fixable] variable "public_key" is declared but not used (terraform_unused_declarations)

  on variables.tf line 34:
  34: variable "public_key" {

Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.5.0/docs/rules/terraform_unused_declarations.md
```

Из ходя из результата вывода команды видно:

- *Module source "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main" uses a default branch as ref (main) (terraform_module_pinned_source)* - удаленному модулю не обязательно указывать ветвь main, так как она и так используется по умолчанию;
- *Missing version constraint for provider "template" in `required_providers` (terraform_required_providers)* - не указана версия template-провайдера;
- *[Fixable] variable "default_cidr" is declared but not used (terraform_unused_declarations)* - переменная ```default_cidr``` объявлена, но не используется;
- *[Fixable] variable "vpc_name" is declared but not used (terraform_unused_declarations)* - переменная ```vpc_name``` объявлена, но не используется;
- *[Fixable] variable "public_key" is declared but not used (terraform_unused_declarations)* - переменная ```public_key``` объявлена, но не используется.


Проверим код [демо к лекции 4](https://github.com/netology-code/ter-homeworks/tree/main/04/demonstration1) с помощью checkov:  
```
baryshnikov@debian:~/demonstration1$ sudo docker run --rm --tty --volume $(pwd):/tf --workdir /tf bridgecrew/checkov --download-external-modules true --directory /tf

       _               _              
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V / 
  \___|_| |_|\___|\___|_|\_\___/ \_/  
                                      
By Prisma Cloud | version: 3.1.44 

terraform scan results:

Passed checks: 2, Failed checks: 5, Skipped checks: 0

Check: CKV_YC_4: "Ensure compute instance does not have serial console enabled."
	PASSED for resource: module.test-vm.yandex_compute_instance.vm[0]
	File: /.external_modules/github.com/udjin10/yandex_compute_instance/main/main.tf:24-73
	Calling File: /main.tf:32-48
Check: CKV_YC_4: "Ensure compute instance does not have serial console enabled."
	PASSED for resource: module.test-vm.yandex_compute_instance.vm[1]
	File: /.external_modules/github.com/udjin10/yandex_compute_instance/main/main.tf:24-73
	Calling File: /main.tf:32-48
Check: CKV_YC_2: "Ensure compute instance does not have public IP."
	FAILED for resource: module.test-vm.yandex_compute_instance.vm[0]
	File: /.external_modules/github.com/udjin10/yandex_compute_instance/main/main.tf:24-73
	Calling File: /main.tf:32-48

		Code lines for this resource are too many. Please use IDE of your choice to review the file.
Check: CKV_YC_11: "Ensure security group is assigned to network interface."
	FAILED for resource: module.test-vm.yandex_compute_instance.vm[0]
	File: /.external_modules/github.com/udjin10/yandex_compute_instance/main/main.tf:24-73
	Calling File: /main.tf:32-48

		Code lines for this resource are too many. Please use IDE of your choice to review the file.
Check: CKV_YC_2: "Ensure compute instance does not have public IP."
	FAILED for resource: module.test-vm.yandex_compute_instance.vm[1]
	File: /.external_modules/github.com/udjin10/yandex_compute_instance/main/main.tf:24-73
	Calling File: /main.tf:32-48

		Code lines for this resource are too many. Please use IDE of your choice to review the file.
Check: CKV_YC_11: "Ensure security group is assigned to network interface."
	FAILED for resource: module.test-vm.yandex_compute_instance.vm[1]
	File: /.external_modules/github.com/udjin10/yandex_compute_instance/main/main.tf:24-73
	Calling File: /main.tf:32-48

		Code lines for this resource are too many. Please use IDE of your choice to review the file.
Check: CKV_TF_1: "Ensure Terraform module sources use a commit hash"
	FAILED for resource: test-vm
	File: /main.tf:32-48
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/supply-chain-policies/terraform-policies/ensure-terraform-module-sources-use-git-url-with-commit-hash-revision

		32 | module "test-vm" {
		33 |   source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
		34 |   env_name        = "develop"
		35 |   network_id      = yandex_vpc_network.develop.id
		36 |   subnet_zones    = ["ru-central1-a"]
		37 |   subnet_ids      = [ yandex_vpc_subnet.develop.id ]
		38 |   instance_name   = "web"
		39 |   instance_count  = 2
		40 |   image_family    = "ubuntu-2004-lts"
		41 |   public_ip       = true
		42 |   
		43 |   metadata = {
		44 |       user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
		45 |       serial-port-enable = 1
		46 |   }
		47 | 
		48 | }
```

Из ходя из результата вывода команды:

- *"Ensure compute instance does not have serial console enabled."* - нужно убедиться, что серийная консоль выключена;
- *"Ensure compute instance does not have public IP."* - нужно убедиться, что вм не имеет публичного адреса;
- *"Ensure security group is assigned to network interface"* - нужно убедиться, что сетевому интерфейсу назначена группа безопасности;
- *"Ensure Terraform module sources use a commit hash"* - нужно убедиться, что используемый терраформ модуль использует хэш-коммит.

---