resource "aws_ecs_cluster" "fs-ecs" {
    name = var.ecs_cluster_name
    capacity_providers = ["FARGATE_SPOT", "FARGATE"]

    default_capacity_provider_strategy {
      capacity_provider = "FARGATE_SPOT"
    }

    lifecycle {
        create_before_destroy = true
    }

    tags = local.common_tags
}