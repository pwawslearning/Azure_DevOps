## Generate public key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh.private_key_openssh
  filename = "${path.root}/ssh_key/${var.vmss_name}-ssh_key.pem"

  provisioner "local-exec" {
    command = "chmod 400 ${path.root}/ssh_key/${var.vmss_name}-ssh_key.pem"
  }
}

## Create User-assigned_identity ###
resource "azurerm_user_assigned_identity" "this" {
  location            = var.location
  name                = "${var.vmss_name}-identity" 
  resource_group_name = var.resource_group_name
}


### Create VMSS 

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  instances           = var.instances
  admin_username      = var.vm_username

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  disable_password_authentication = true
  admin_ssh_key {
    username   = var.vm_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.image_sku
    version   = var.os_version
  }

  os_disk {
    storage_account_type = var.storage_account_type
    caching              = "ReadWrite"
    disk_size_gb = var.os_disk_size
  }

  network_interface {
    name    = var.vm_nic_name
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.vm_ifconfig_subnet_id

       # Attach to Application Gateway if appgw_backend_pool_id is provided
      application_gateway_backend_address_pool_ids = var.appgw_backend_pool_id != null ? [var.appgw_backend_pool_id] : []

      # Attach to Load Balancer if lb_backend_pool_id is provided
      load_balancer_backend_address_pool_ids = var.lb_backend_pool_id != null ? [var.lb_backend_pool_id] : []
    }
  }
   lifecycle {
    ignore_changes = [ 
      admin_ssh_key
     ]
    prevent_destroy = false
    create_before_destroy = true
  }
}

# Autoscale settings — one per VMSS
resource "azurerm_monitor_autoscale_setting" "this" {
  name                = "${var.resource_group_name}-${var.vmss_name}-autoscaling"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "autocaling_profile"
   
    capacity {
      default = var.instances
      minimum = var.autoscale_min
      maximum = var.autoscale_max
    }

    # Scale OUT — CPU high
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.autoscale_cpu_scale_out_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Scale IN — CPU low
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.autoscale_cpu_scale_in_threshold
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }    
}