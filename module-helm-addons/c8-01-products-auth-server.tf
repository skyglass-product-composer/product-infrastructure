resource "kubernetes_config_map_v1" "auth_server_config" {
  metadata {
    name      = "auth-server-config"
    labels = {
      app = "auth-server"
    }
  }

  data = {
    "application.yml" = file("${path.module}/app-conf/application.yml")
    "auth-server.yml" = file("${path.module}/app-conf/auth-server.yml")
  }
}


resource "kubernetes_deployment_v1" "auth_server" {
  metadata {
    name = "auth-server"
    labels = {
      app = "auth-server"
    }
  }
 
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "auth-server"
      }
    }
    template {
      metadata {
        labels = {
          app = "auth-server"
        }
      }
      spec {

        container {
          image = "ghcr.io/skyglass-product-composer/authorization-server"
          name  = "auth-server"
          image_pull_policy = "Always"

          env {
            name  = "SPRING_CONFIG_LOCATION"
            value = "file:/config-repo/application.yml,file:/config-repo/auth-server.yml"
          }

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "docker,prod"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.rabbitmq-credentials.metadata[0].name
            }
          }

          liveness_probe {
            failure_threshold = 20

            http_get {
              path   = "/actuator/health/liveness"
              port   = 80
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 2
          }

          readiness_probe {
            failure_threshold = 3

            http_get {
              path   = "/actuator/health/readiness"
              port   = 80
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 2
          }

          port {
            container_port = 80
            name           = "http"
            protocol       = "TCP"
          }

          resources {
            requests = {
              memory = "600Mi"
            }
            limits = {
              memory = "800Mi"
            }
          }

          volume_mount {
            name       = "auth-server"
            mount_path = "/config-repo"
          }
        }

        volume {
          name = "auth-server"

          config_map {
            name = "auth-server-config"
          }
        }    
      }
    }  
  }
}


resource "kubernetes_horizontal_pod_autoscaler_v1" "auth_server_hpa" {
  metadata {
    name = "auth-server-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.auth_server.metadata[0].name 
    }
    target_cpu_utilization_percentage = 50
  }
}

resource "kubernetes_service_v1" "auth_server_service" {
  metadata {
    name = "auth-server"
  }
  spec {
    selector = {
      app = "auth-server"
    }
    port {
      port = 80
    }
  }
}