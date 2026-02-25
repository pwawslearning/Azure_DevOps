variable "location" {
  type    = string
  default = "Southeast Asia"
}

variable "subscription_id" {
  type = string
  default = ""
}

variable "proj" {
  type = string
  default = "aks"
}

variable "env" {
  type = string
}

variable "sku_name" {
  type = string
  default = "standard"
}