variable "env_name" {
  type        = string
  description = "Имя облачной сети"
}

variable "zone" {
  type        = string
  description = "Зона доступности"
}

variable "v4_cidr_blocks" {
  type        = string
  description = "cidr блок"
}