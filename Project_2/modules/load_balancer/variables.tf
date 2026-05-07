variable "lb_subnet" {
  type = string
}

variable "location" {
  
}

variable "resource_group_name" {
  
}

variable "environment" {
  
}

variable "project" {
  
}

variable "backend_port" {
  type = string
}

variable "backend_protocol" {
  type = string
}

variable "probe_request_path" {
  type = string
}

variable "probe_interval" {
  type = number
}

variable "application_port" {
  type = number
}

variable "application_protocol" {
  type = string
}