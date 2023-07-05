# resource "kubernetes_config_map_v1" "products_rabbitmq_config" {
#   metadata {
#     name = "products-rabbitmq-config"
#     labels = {
#       db = "products-rabbitmq"
#     }
#   }

#   data = {
#     "rabbitmq.conf" = <<EOF
#       default_user = user
#       default_pass = password
#       vm_memory_high_watermark.relative = 1.0
#     EOF
#   }
# }

resource "kubernetes_deployment_v1" "products_rabbitmq_deployment" {
  metadata {
    name = "products-rabbitmq"
    labels = {
      db = "products-rabbitmq"
    }
  }

  spec {
    selector {
      match_labels = {
        db = "products-rabbitmq"
      }
    }

    template {
      metadata {
        labels = {
          db = "products-rabbitmq"
        }
      }

      spec {
        container {
          name = "rabbitmq"
          image = "registry.hub.docker.com/library/rabbitmq:3.8.11-management"
          image_pull_policy = "IfNotPresent"

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.rabbitmq_server_credentials.metadata.0.name
            }
          }          

          readiness_probe {
            failure_threshold = 20

            http_get {
              path = "/api/aliveness-test/%2F"
              port = 15672
              scheme = "HTTP"

              http_header {
                name  = "Authorization"
                value = "Basic cmFiYml0LXVzZXItZGV2OnJhYmJpdC1wd2QtZGV2"
              }
            }

            initial_delay_seconds = 10
            period_seconds        = 5
            success_threshold     = 1
            timeout_seconds       = 3
          }

          port {
            container_port = 5671
          }

          port {
            container_port = 5672
          }

          port {
            container_port = 15672
          }

          resources {
            limits = {
              memory = "350Mi"
            }
          }
        }

        # volume {
        #   name = "products-rabbitmq-config-volume"

        #   config_map {
        #     name = kubernetes_config_map_v1.products_rabbitmq_config.metadata.0.name
        #   }
        # }
      }
    }
  }
}

resource "kubernetes_service_v1" "products_rabbitmq" {
  metadata {
    name = "products-rabbitmq"
    labels = {
      db = "products-rabbitmq"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      db = "products-rabbitmq"
    }

    port {
      name       = "amqp"
      protocol   = "TCP"
      port       = 5672
      target_port = 5672
    }

    port {
      name       = "management"
      protocol   = "TCP"
      port       = 15672
      target_port = 15672
    }
  }
}

# Resource: Polar RabbitMQ Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v1" "products_rabbitmq_hpa" {
  metadata {
    name = "products-rabbitmq-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.products_rabbitmq_deployment.metadata[0].name 
    }
    target_cpu_utilization_percentage = 60
  }
}