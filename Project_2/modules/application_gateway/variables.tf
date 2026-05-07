variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "apgw_sku" {
  type = string
}

variable "backend_port" {
  type = number
}

variable "capacity" {
  type = number
}

variable "frontend_port" {
  type = number
}

variable "cookie_based_affinity" {
  type = string
}

variable "backend_path" {
  type = string
}

variable "backend_protocol" {
  type = string
}

variable "listener_protocol" {
  type = string
}

variable "probe_protocol" {
  type = string
}

variable "rule_set_version" {
  type = string
}

variable "apgw_subnet_id" {
  description = "Subnet ID for Application Gateway"
  type        = string
}