// Create application registration and getting client_id and Client_secret

data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name = "${var.proj}-${var.env}-sp"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "sp" {
  client_id                    = azuread_application.app.client_id
  app_role_assignment_required = true
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "psswd" {
  service_principal_id = azuread_service_principal.sp.id
}
