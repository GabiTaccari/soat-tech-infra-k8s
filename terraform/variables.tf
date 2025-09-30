variable "image" {
  description = "Container image da aplicação"
  type        = string
  default     = "ghcr.io/gabitaccari/soat-tech-fase3:dev"
}

variable "kubeconfig" {
  description = "Conteúdo do kubeconfig (YAML) para acessar o cluster"
  type        = string
  sensitive   = true
}
