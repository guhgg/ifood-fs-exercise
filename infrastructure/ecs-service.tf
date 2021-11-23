resource "aws_ecs_service" "ecs-s3-connect" {
    cluster = aws_ecs_cluster.fs-ecs.id
    desired_count = 1
    name = "s3-connect"
    scheduling_strategy = "REPLICA"
    task_definition = aws_ecs_task_definition.fs-ecs-s3-connect.arn
    
    network_configuration {
        subnets          = local.subnet_ids
        assign_public_ip = true
        security_groups  = [aws_security_group.fs-ecs.id]
    }

    capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
        weight            = 100
    }
    
    service_registries {
        registry_arn   = aws_service_discovery_service.fs-s3-connect.arn
        container_name = "fs-ecs-s3-connect"
    }

}

resource "aws_ecs_service" "ecs-connect-ui" {
    cluster = aws_ecs_cluster.fs-ecs.id
    desired_count = 1
    name = "connect-ui"
    scheduling_strategy = "REPLICA"
    task_definition = aws_ecs_task_definition.fs-ecs-connect-ui.arn
    health_check_grace_period_seconds = 120
    
    network_configuration {
        subnets          = local.subnet_ids
        assign_public_ip = true
        security_groups  = [aws_security_group.fs-ecs.id]
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.fs-ecs-connect-ui.arn
        container_name   = "fs-ecs-connect-ui"
        container_port   = var.ecs_connect_ui_port
    }

    capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
        weight            = 100
    }
}

resource "aws_ecs_service" "ecs-schema-registry" {
    cluster = aws_ecs_cluster.fs-ecs.id
    desired_count = 1
    name = "schema-registry"
    scheduling_strategy = "REPLICA"
    task_definition = aws_ecs_task_definition.fs-ecs-schema-registry.arn
    
    network_configuration {
        subnets          = local.subnet_ids
        assign_public_ip = true
        security_groups  = [aws_security_group.fs-ecs.id]
    }

    capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
        weight            = 100
    }

    service_registries {
        registry_arn   = aws_service_discovery_service.ecs-schema-registry.arn
        container_name = "fs-ecs-schema-registry"
    }
}

resource "aws_ecs_service" "ecs-schema-registry-ui" {
    cluster = aws_ecs_cluster.fs-ecs.id
    desired_count = 1
    name = "schema-registry-ui"
    scheduling_strategy = "REPLICA"
    task_definition = aws_ecs_task_definition.fs-ecs-schema-registry-ui.arn
    health_check_grace_period_seconds = 120
    
    network_configuration { 
        subnets          = local.subnet_ids
        assign_public_ip = true
        security_groups  = [aws_security_group.fs-ecs.id]
    }
    
    load_balancer {
        target_group_arn = aws_lb_target_group.fs-ecs-schema-registry-ui.arn
        container_name   = "fs-ecs-schema-registry-ui"
        container_port   = var.ecs_schema_registry_ui_port
    }

    capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
        weight            = 100
    }
}

resource "aws_ecs_service" "fs-ecs-kafka-rest-api" {
    cluster = aws_ecs_cluster.fs-ecs.id
    desired_count = 1
    name = "kafka-rest-api"
    scheduling_strategy = "REPLICA"
    task_definition = aws_ecs_task_definition.fs-ecs-kafka-rest-api.arn
    health_check_grace_period_seconds = 120
    
    network_configuration {
        subnets          = local.subnet_ids
        assign_public_ip = true
        security_groups  = [aws_security_group.fs-ecs.id]
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.fs-ecs-kafka-rest-api.arn
        container_name   = "fs-ecs-kafka-rest-api"
        container_port   = var.ecs_kafka_rest_api_port
    }

    capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
        weight            = 100
    }
}

resource "aws_ecs_service" "fs-ecs-producer" {
    depends_on = [aws_msk_cluster.fs-msk]
    cluster = aws_ecs_cluster.fs-ecs.id
    desired_count = 1
    name = "fs-ecs-producer"
    scheduling_strategy = "REPLICA"
    task_definition = aws_ecs_task_definition.fs-ecs-producer.arn
    
    network_configuration {
        subnets          = local.subnet_ids
        assign_public_ip = true
        security_groups  = [aws_security_group.fs-ecs.id]
    }

    capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
        weight            = 100
    }
}