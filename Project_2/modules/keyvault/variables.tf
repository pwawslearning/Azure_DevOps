variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vmss_identity_ids" {
  description = "Map of VMSS name to managed identity principal ID"
  type        = map(string)
  default     = {}
}