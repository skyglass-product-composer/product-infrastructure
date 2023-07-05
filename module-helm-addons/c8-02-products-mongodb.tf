resource "kubernetes_deployment_v1" "products_mongodb_deployment" {
  metadata {
    name = "products-mongodb"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "products-mongodb"
      }          
    }
    strategy {
      type = "Recreate"
    }  
    template {
      metadata {
        labels = {
          app = "products-mongodb"
        }
      }
      spec {       
        container {
          name = "products-mongodb"
          image = "mongo:6.0.4"

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.mongodb_server_credentials.metadata.0.name
            }
          }

          port {
            container_port = 27017
            name = "mongodb"
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

resource "kubernetes_horizontal_pod_autoscaler_v1" "products_mongodb_hpa" {
  metadata {
    name = "products-mongodb-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.products_mongodb_deployment.metadata[0].name
    }
    target_cpu_utilization_percentage = 60
  }
}

resource "kubernetes_service_v1" "products_mongodb_service" {
  metadata {
    name = "products-mongodb"
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.products_mongodb_deployment.spec.0.selector.0.match_labels.app 
    }
    port {
      port        = 27017
    }
    type = "ClusterIP"
    cluster_ip = "None" # This means we are going to use Pod IP   
  }
}