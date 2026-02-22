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

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}