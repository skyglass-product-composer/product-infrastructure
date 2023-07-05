resource "kubernetes_secret_v1" "rabbitmq-credentials" {
  metadata {
    name = "rabbitmq-credentials"
  }

  data = {
    SPRING_RABBITMQ_USERNAME = "rabbit-user-dev"
    SPRING_RABBITMQ_PASSWORD = "rabbit-pwd-dev"
  }
}

resource "kubernetes_secret_v1" "rabbitmq_server_credentials" {
  metadata {
    name = "rabbitmq-server-credentials"
  }

  data = {
    RABBITMQ_DEFAULT_USER = "rabbit-user-dev"
    RABBITMQ_DEFAULT_PASS = "rabbit-pwd-dev"
  }
}

resource "kubernetes_secret_v1" "rabbitmq-zipkin-credentials" {
  metadata {
    name = "rabbitmq-zipkin-credentials"
  }

  data = {
    RABBIT_USER     = "rabbit-user-dev"
    RABBIT_PASSWORD = "rabbit-pwd-dev"
  }
}

resource "kubernetes_secret_v1" "mongodb-credentials" {
  metadata {
    name = "mongodb-credentials"
  }

  data = {
    SPRING_DATA_MONGODB_AUTHENTICATION_DATABASE = "admin"
    SPRING_DATA_MONGODB_USERNAME                = "mongodb-user-prod"
    SPRING_DATA_MONGODB_PASSWORD                = "mongodb-pwd-prod"
  }
}

resource "kubernetes_secret_v1" "mongodb_server_credentials" {
  metadata {
    name = "mongodb-server-credentials"
  }

  data = {
    MONGO_INITDB_ROOT_USERNAME = "mongodb-user-dev"
    MONGO_INITDB_ROOT_PASSWORD = "mongodb-pwd-dev"
  }
}

resource "kubernetes_secret_v1" "mysql-credentials" {
  metadata {
    name = "mysql-credentials"
  }

  data = {
    SPRING_DATASOURCE_USERNAME = "mysql-user-prod"
    SPRING_DATASOURCE_PASSWORD = "mysql-pwd-prod"
  }
}

resource "kubernetes_secret_v1" "mysql_server_credentials" {
  metadata {
    name = "mysql-server-credentials"
  }

  data = {
    MYSQL_ROOT_PASSWORD = "rootpwd"
    MYSQL_DATABASE     = "review-db"
    MYSQL_USER         = "mysql-user-dev"
    MYSQL_PASSWORD     = "mysql-pwd-dev"
  }
}