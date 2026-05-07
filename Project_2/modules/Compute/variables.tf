// variables for VMSS
variable "vm_username" {
  
}

variable "vmss_name" {
  
}

variable "resource_group_name" {
  
}

variable "location" {
  
}

variable "sku" {
  
}

variable "instances" {
  
}

variable "publisher" {
  
}

variable "os_version" {
  
}

variable "offer" {
  
}

variable "image_sku" {
  
}

variable "vm_nic_name" {
  
}

variable "vm_ifconfig_subnet_id" {
  
}

variable "os_disk_size" {
  
}

variable "storage_account_type" {
  
}

variable "appgw_backend_pool_id" {
  description = "Application Gateway backend address pool ID (set for web tier)"
  type        = string
  default     = null
}

variable "lb_backend_pool_id" {
  description = "Load Balancer backend address pool ID (set for app tier)"
  type        = string
  default     = null
}

variable "autoscale_min" {
  description = "Minimum number of VMSS instances"
  type        = number
  default     = 1
}

variable "autoscale_max" {
  description = "Maximum number of VMSS instances"
  type        = number
  default     = 3
}

variable "autoscale_cpu_scale_out_threshold" {
  description = "CPU percentage threshold to trigger scale out"
  type        = number
  default     = 90
}

variable "autoscale_cpu_scale_in_threshold" {
  description = "CPU percentage threshold to trigger scale in"
  type        = number
  default     = 25
}

