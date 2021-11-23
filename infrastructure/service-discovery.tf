resource "aws_service_discovery_private_dns_namespace" "fs-service-discovery" {
    name = "fs_ecs.local"
    vpc = local.vpc_id
}

resource "aws_service_discovery_service" "fs-s3-connect" {
    name = "fs-s3-connect"
    dns_config {
      namespace_id = aws_service_discovery_private_dns_namespace.fs-service-discovery.id
      dns_records {
        ttl  = 10
        type = "A"
      }
    }
    health_check_custom_config {
        failure_threshold = 1
    }
}

resource "aws_service_discovery_service" "ecs-schema-registry" {
    name = "fs-schema-registry"
    dns_config {
      namespace_id = aws_service_discovery_private_dns_namespace.fs-service-discovery.id
      dns_records {
        ttl  = 10
        type = "A"
      }
    }
    health_check_custom_config {
        failure_threshold = 1
    }
}