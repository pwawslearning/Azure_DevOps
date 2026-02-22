resource "azurerm_resource_group" "rg" {
  name     = "${var.proj}-${var.env}-rg"
  location = var.location
}

data "azurerm_kubernetes_service_versions" "version" {
  location        = var.location
  include_preview = false
}

resource "azurerm_kubernetes_cluster" "ask_cluster" {
  name                = "${var.proj}-${var.env}0011"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.proj}-${var.env}0011"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.version.latest_version
  node_resource_group = "${var.proj}-${var.env}-node_rg"

  default_node_pool {
    name            = "nodepool"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
    os_sku          = "Ubuntu"
  }
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = tls_private_key.ssh.public_key_openssh
    }
  }
}
