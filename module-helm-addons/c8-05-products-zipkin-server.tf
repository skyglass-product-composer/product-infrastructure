resource "kubernetes_deployment_v1" "products_zipkin" {
  metadata {
    name = "products-zipkin"
    labels = {
      app = "products-zipkin"
    }
  }
 
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "products-zipkin"
      }
    }
    template {
      metadata {
        labels = {
          app = "products-zipkin"
        }
      }
      spec {

        container {
          name = "zipkin-server"
          image = "registry.hub.docker.com/openzipkin/zipkin:2.23.2"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "RABBIT_ADDRESSES"
            value = "products-rabbitmq:5672"
          }

          env {
            name  = "STORAGE_TYPE"
            value = "mem"
          }

          env {
            name  = "LOGGING_LEVEL_ROOT"
            value = "WARN"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.rabbitmq-zipkin-credentials.metadata[0].name
            }
          }          

          liveness_probe {
            failure_threshold = 20

            http_get {
              path = "/actuator/info"
              port = 9411
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
              path = "/actuator/health"
              port = 9411
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 2
          }

          port {
            container_port = 9411
          }

          resources {
            requests = {
              memory = "300Mi"
            }
            limits = {
              memory = "300Mi"
            }
          }
        }

  
      }
    }  
  }
}


resource "kubernetes_horizontal_pod_autoscaler_v1" "products_zipkin_hpa" {
  metadata {
    name = "products-zipkin-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.products_zipkin.metadata[0].name 
    }
    target_cpu_utilization_percentage = 50
  }
}

resource "kubernetes_service_v1" "products_zipkin_service" {
  metadata {
    name = "products-zipkin"
  }
  spec {
    selector = {
      app = "products-zipkin"
    }
    port {
      port = 9411
    }
  }
}