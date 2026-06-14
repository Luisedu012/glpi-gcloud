variable "project_id" {
  description = "ID do projeto Google Cloud onde a infraestrutura será criada."
  type        = string
}

variable "region" {
  description = "Região Google Cloud para recursos regionais."
  type        = string
  default     = "southamerica-east1"
}

variable "zone" {
  description = "Zona Google Cloud para a VM Compute Engine."
  type        = string
  default     = "southamerica-east1-a"
}

variable "app_name" {
  description = "Nome base da aplicação."
  type        = string
  default     = "glpi"
}

variable "environment" {
  description = "Ambiente da implantação."
  type        = string
  default     = "prod"
}

variable "subnet_cidr" {
  description = "Faixa CIDR da subnet dedicada do GLPI."
  type        = string
  default     = "10.10.0.0/24"
}

variable "admin_ip_cidr" {
  description = "IP público administrativo autorizado para SSH, em formato CIDR /32."
  type        = string

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/32$", var.admin_ip_cidr))
    error_message = "Informe o IP administrativo no formato x.x.x.x/32."
  }
}

variable "vm_service_account_email" {
  description = "E-mail da service account runtime da VM do GLPI."
  type        = string
}

variable "machine_type" {
  description = "Tipo da VM Compute Engine."
  type        = string
  default     = "e2-medium"
}

variable "boot_disk_size_gb" {
  description = "Tamanho do disco de boot da VM em GB."
  type        = number
  default     = 30
}

variable "data_disk_size_gb" {
  description = "Tamanho do disco persistente de dados em GB."
  type        = number
  default     = 64
}

variable "ssh_username" {
  description = "Usuário Linux que será usado para acesso SSH inicial."
  type        = string
  default     = "glpiadmin"
}

variable "ssh_public_key_path" {
  description = "Caminho local da chave pública SSH."
  type        = string
  default     = "~/.ssh/glpi-gcp.pub"
}