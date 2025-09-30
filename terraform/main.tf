terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
  }
}

# Usa o kubeconfig padrão (~/.kube/config) — será criado no workflow
provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}

#############################
# DEPLOYMENT
#############################

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = "soat-tech-deployment"
    namespace = "default"
    labels = {
      app = "soat-tech"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "soat-tech"
      }
    }

    template {
      metadata {
        labels = {
          app = "soat-tech"
        }
      }

      spec {
        # Secret para puxar imagem privada do GHCR
        image_pull_secrets {
          name = "ghcr-secret"
        }

        container {
          name  = "soat-tech"
          image = var.image # ex: ghcr.io/gabitaccari/soat-tech-fase3:dev

          port {
            container_port = 3000
          }

          env {
            name  = "DATABASE_URL"
            value = "postgresql://soat:soat123@postgres-service:5432/pedidos?schema=public"
          }

          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = "app-secrets"
                key  = "JWT_SECRET"
              }
            }
          }

          env {
            name = "JWT_AUD"
            value_from {
              secret_key_ref {
                name = "app-secrets"
                key  = "JWT_AUD"
              }
            }
          }
        }
      }
    }
  }
}

#############################
# SERVICE
#############################

resource "kubernetes_service_v1" "svc" {
  metadata {
    name      = "soat-tech-service"
    namespace = "default"
    labels = {
      app = "soat-tech"
    }
  }

  spec {
    selector = {
      app = "soat-tech"
    }

    port {
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
