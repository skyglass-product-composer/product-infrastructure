resource "kubernetes_ingress_v1" "ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "simple-fanout-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "kubernetes.io/ingress.class" =  "nginx"
    }
  }

  spec {
    ingress_class_name = "nginx"

    default_backend {
     
      service {
        name = "auth-server"
        port {
          number = 80
        }
      }
    }     

    rule {
      host = "product.greeta.net"

      http {

        path {
          path = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "auth-server"
              port {
                number = 80
              }
            }
          }
        }

        path {
          path = "/oauth2"
          path_type = "Prefix"

          backend {
            service {
              name = "auth-server"
              port {
                number = 80
              }
            }
          }

        }

        path {
          path = "/login"
          path_type = "Prefix"

          backend {
            service {
              name = "auth-server"
              port {
                number = 80
              }
            }
          }

        }

        path {
          path = "/error"
          path_type = "Prefix"

          backend {
            service {
              name = "auth-server"
              port {
                number = 80
              }
            }
          }

        }

        path {
          path = "/product-composite"
          path_type = "Prefix"

          backend {
            service {
              name = "product-composite"
              port {
                number = 80
              }
            }
          }

        } 

        path {
          path = "/actuator/health"
          path_type = "Prefix"

          backend {
            service {
              name = "product-composite"
              port {
                number = 80
              }
            }
          }

        }

        path {
          path = "/openapi"
          path_type = "Prefix"

          backend {
            service {
              name = "product-composite"
              port {
                number = 80
              }
            }
          }

        }  

        path {
          path = "/webjars"
          path_type = "Prefix"

          backend {
            service {
              name = "product-composite"
              port {
                number = 80
              }
            }
          }

        }                     



      }
    }

    rule {
      host = "product.greeta.net"
      http {

        path {
          backend {
            service {
              name = "auth-server"
              port {
                number = 80
              }
            }
          }

          path = "/oauth2"
          path_type = "Prefix"
        }
      }
    }

    rule {
      host = "product.greeta.net"
      http {

        path {
          backend {
            service {
              name = "auth-server"
              port {
                number = 80
              }
            }
          }

          path = "/login"
          path_type = "Prefix"
        }
      }
    }

    rule {
      host = "product.greeta.net"
      http {

        path {
          backend {
            service {
              name = "auth-server"
              port {
                number = 80
              }
            }
          }

          path = "/login"
          path_type = "Prefix"
        }
      }
    }    

    
  }
}
