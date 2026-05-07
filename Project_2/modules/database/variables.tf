variable "db_subnets" {
  description = "Subnet ID for Database"
  type        = string
}

variable "resource_group_name" { }
variable "location" { }
variable "project" { }

variable "private_dns_zone" {
  description = "Private DNS zone ID for database"
  type = string
}

variable "dbadmin_login" {
  
}

variable "dbadmin_password" {
  sensitive = true
}

variable "dbstorage_mb" {
  
}

variable "dbstorage_tier" {
  
}

variable "DBsku_name" {
  
}
