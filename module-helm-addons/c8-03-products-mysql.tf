resource "kubernetes_deployment_v1" "products_mysql_deployment" {
  metadata {
    name = "products-mysql"

    labels = {
      db = "products-mysql"
    }
  }

  spec {
    selector {
      match_labels = {
        db = "products-mysql"
      }
    }

    template {
      metadata {
        labels = {
          db = "products-mysql"
        }
      }

      spec {
        container {
          name  = "products-mysql"
          image = "registry.hub.docker.com/library/mysql:5.7.32"
          image_pull_policy = "IfNotPresent"

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.mysql_server_credentials.metadata.0.name
            }
          }          

          args = ["--ignore-db-dir=lost+found"]

          port {
            container_port = 3306
          }

          resources {
            limits = {
              memory = "350Mi"
            }
          }
        }

      }
    }
  }
}

resource "kubernetes_service_v1" "products_mysql" {
  metadata {
    name = "products-mysql"

    labels = {
      db = "products-mysql"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      db = "products-mysql"
    }

    port {
      protocol    = "TCP"
      port        = 3306
      target_port = 3306
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "products_mysql_hpa" {
  metadata {
    name = "products-mysql-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.products_mysql_deployment.metadata[0].name 
    }
    target_cpu_utilization_percentage = 60
  }
}