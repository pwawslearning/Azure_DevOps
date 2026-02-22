variable "location" {
  type    = string
}

variable "proj" {
  type = string
  default = "aks"
}

variable "env" {
  type = string
  default = "dev"
}

variable "sku_name" {
  type = string
  default = "Standard"
}