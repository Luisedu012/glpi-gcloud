output "vpc_name" {
  description = "Nome da VPC criada."
  value       = google_compute_network.glpi_vpc.name
}

output "subnet_name" {
  description = "Nome da subnet criada."
  value       = google_compute_subnetwork.glpi_subnet.name
}

output "static_ip" {
  description = "IP publico estatico do GLPI."
  value       = google_compute_address.glpi_static_ip.address
}

output "vm_name" {
  description = "Nome da VM do GLPI."
  value       = google_compute_instance.glpi_vm.name
}

output "vm_zone" {
  description = "Zona da VM."
  value       = google_compute_instance.glpi_vm.zone
}

output "ssh_command" {
  description = "Comando SSH para acessar a VM."
  value       = "ssh -i ~/.ssh/glpi-gcp ${var.ssh_username}@${google_compute_address.glpi_static_ip.address}"
}

output "dns_instruction" {
  description = "Instrucao para criacao de DNS na Hostinger."
  value       = "Criar registro A: glpi.empresa.com.br -> ${google_compute_address.glpi_static_ip.address}"
}