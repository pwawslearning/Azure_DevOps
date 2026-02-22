resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh.private_key_openssh
  filename = "${path.root}/ssh_key/ssh_key.pem"

  provisioner "local-exec" {
    command = "chmod 400 ${path.root}/ssh_key/ssh_key.pem"
  }
}

resource "local_file" "kubeconfig" {
  filename   = "./kubeconfig"
  content    = azurerm_kubernetes_cluster.ask_cluster.kube_config_raw
  depends_on = [azurerm_kubernetes_cluster.ask_cluster]
}