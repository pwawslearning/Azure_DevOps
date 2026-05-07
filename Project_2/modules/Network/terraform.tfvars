# address_space = "10.0.0.0/24"

# subnets_name = {
#   pub_sub01 = {
#     address_prefix = "10.0.0.0/28"
#   }
#   pub_sub02 = {
#     address_prefix = "10.0.0.16/28"
#   }
#   pri_sub01 = {
#     address_prefix = "10.0.0.32/28"
#   }
#   pri_sub02 = {
#     address_prefix = "10.0.0.48/28"
#   }
#   pri_sub03 = {
#     address_prefix = "10.0.0.64/28"
#   }
#   pri_sub04 = {
#     address_prefix = "10.0.0.80/28"
#   }
#   pri_sub05 = {
#     address_prefix = " 10.0.0.96/28"
#   }
# }

# nsg_names = {
#   pub_sub01 = {
#     nsg_rules = [
#       {
#         name                       = "allow_ssh"
#         priority                   = 100
#         direction                  = "Inbound"
#         access                     = "Allow"
#         protocol                   = "Tcp"
#         source_port_range          = "*"
#         destination_port_range     = "22"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#       },
#       {
#         name                       = "allow_Tcp"
#         priority                   = 1000
#         direction                  = "Inbound"
#         access                     = "Allow"
#         protocol                   = "Tcp"
#         source_port_range          = "*"
#         destination_port_range     = "80"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#       },
#       {
#         name                       = "DenyAllow"
#         priority                   = 4095
#         direction                  = "Inbound"
#         access                     = "Deny"
#         protocol                   = "*"
#         source_port_range          = "*"
#         destination_port_range     = "*"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#       }
#     ]
#   }
#   pub_sub02 = {
#     nsg_rules = [
#       {
#         name                       = "allow_ssh"
#         priority                   = 100
#         direction                  = "Inbound"
#         access                     = "Allow"
#         protocol                   = "Tcp"
#         source_port_range          = "*"
#         destination_port_range     = "22"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#       },
#       {
#         name                       = "allow_Tcp"
#         priority                   = 1000
#         direction                  = "Inbound"
#         access                     = "Allow"
#         protocol                   = "Tcp"
#         source_port_range          = "*"
#         destination_port_range     = "80"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#       },
#       {
#         name                       = "DenyAllow"
#         priority                   = 4095
#         direction                  = "Inbound"
#         access                     = "Deny"
#         protocol                   = "*"
#         source_port_range          = "*"
#         destination_port_range     = "*"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#       }
#     ]
#   }
#   pri_sub01 = {
#     nsg_rules = [
#       {
#         name                       = "AllowAll"
#         priority                   = 1000
#         direction                  = "Inbound"
#         access                     = "Allow"
#         protocol                   = "*"
#         source_port_range          = "*"
#         destination_port_range     = "*"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#       }
#     ]
#   }
#   pri_sub02 = {
#     nsg_rules = [
#       {
#         name                       = "AllowAll"
#         priority                   = 1000
#         direction                  = "Inbound"
#         access                     = "Allow"
#         protocol                   = "*"
#         source_port_range          = "*"
#         destination_port_range     = "*"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#       }
#     ]
#   }
# }
