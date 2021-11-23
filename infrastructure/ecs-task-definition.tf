resource "aws_ecs_task_definition" "fs-ecs-s3-connect" {
    family                   = "fs-ecs-s3-connect"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_s3_connect_cpu
    memory                   = var.fargate_s3_connect_memory
    execution_role_arn       = aws_iam_role.execution_role.arn
    task_role_arn            = aws_iam_role.task_role.arn
    tags                     = local.common_tags 
    container_definitions    = jsonencode(
        [
            {
                name: "fs-ecs-s3-connect"
                container_name: "fs-ecs-s3-connect"
                image = var.image_ecs_s3_connect
                essential = true
                portMappings: [
                    {
                        containerPort = var.ecs_s3_connect_port
                        hostPort      = var.ecs_s3_connect_port
                        protocol      = "tcp"
                    }
                ],
                logConfiguration: {
                    logDriver = "awslogs",
                    options = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "s3-connect"
                    }
                },
                environment = jsondecode("[${join(",\n", formatlist("{\"name\" :\"%s\", \"value\":\"%s\"}", keys(local.s3_connect_variables), values(local.s3_connect_variables)))}]")
                entryPoint = ["sh", "-c"]
                command = [
                    "bash -c | #\necho \"Installing connector plugin\"\nconfluent-hub install --no-prompt confluentinc/kafka-connect-s3:latest\n#\necho \"Launching Kafka Connect worker\"\n/etc/confluent/docker/run & \n#\nsleep infinity\n"
                ]
            }
        ]        
    )
}

resource "aws_ecs_task_definition" "fs-ecs-connect-ui" {
    family                   = "fs-ecs-connect-ui"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_connect_ui_cpu
    memory                   = var.fargate_connect_ui_memory
    execution_role_arn       = aws_iam_role.execution_role.arn
    task_role_arn            = aws_iam_role.task_role.arn
    tags                     = local.common_tags 
    container_definitions    = jsonencode(
        [
            {
                name           = "fs-ecs-connect-ui"
                container_name = "fs-ecs-connect-ui"
                image          = var.image_ecs_connect_ui
                essential      = true
                portMappings   = [
                    {
                        containerPort = var.ecs_connect_ui_port
                        hostPort      = var.ecs_connect_ui_port
                        protocol      = "tcp"
                    }
                ],
                logConfiguration = {
                    logDriver = "awslogs",
                    options   = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "connect-ui"
                    }
                },
                environment = jsondecode("[${join(",\n", formatlist("{\"name\" :\"%s\", \"value\":\"%s\"}", keys(local.connect_ui_variables), values(local.connect_ui_variables)))}]")
            }
        ]        
    )
}

resource "aws_ecs_task_definition" "fs-ecs-schema-registry" {
    family                   = "fs-ecs-schema-registry"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_schema_registry_cpu
    memory                   = var.fargate_schema_registry_memory
    execution_role_arn       = aws_iam_role.execution_role.arn
    task_role_arn            = aws_iam_role.task_role.arn
    tags                     = local.common_tags 
    container_definitions    = jsonencode(
        [
            {
                name           = "fs-ecs-schema-registry"
                container_name = "fs-ecs-schema-registry"
                image          = var.image_ecs_schema_registry
                essential      = true
                portMappings   = [
                    {
                        containerPort = var.ecs_schema_registry_port
                        hostPort      = var.ecs_schema_registry_port
                        protocol      = "tcp"
                    }
                ],
                logConfiguration = {
                    logDriver = "awslogs",
                    options   = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "schema-registry"
                    }
                },
                environment = jsondecode("[${join(",\n", formatlist("{\"name\" :\"%s\", \"value\":\"%s\"}", keys(local.schema_registry_variables), values(local.schema_registry_variables)))}]")
            }
        ]        
    )
}

resource "aws_ecs_task_definition" "fs-ecs-schema-registry-ui" {
    family                   = "fs-ecs-schema-registry-ui"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_schema_registry_ui_cpu
    memory                   = var.fargate_schema_registry_ui_memory
    execution_role_arn       = aws_iam_role.execution_role.arn
    task_role_arn            = aws_iam_role.task_role.arn
    tags                     = local.common_tags 
    container_definitions    = jsonencode(
        [
            {
                name = "fs-ecs-schema-registry-ui"
                container_name = "fs-ecs-schema-registry-ui"
                image = var.image_ecs_schema_registry_ui
                essential = true
                portMappings = [
                    {
                        containerPort = var.ecs_schema_registry_ui_port
                        hostPort      = var.ecs_schema_registry_ui_port
                        protocol      ="tcp"
                    }
                ],
                logConfiguration: {
                    logDriver = "awslogs",
                    options   = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "schema-registry-ui"
                    }
                },
                
                environment = jsondecode("[${join(",\n", formatlist("{\"name\" :\"%s\", \"value\":\"%s\"}", keys(local.schema_registry_ui_variables), values(local.schema_registry_ui_variables)))}]")
            }
        ]        
    )
}

resource "aws_ecs_task_definition" "fs-ecs-kafka-rest-api" {
    family                   = "fs-ecs-kafka-rest-api"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_kafka_rest_api_cpu
    memory                   = var.fargate_kafka_rest_api_memory
    tags                     = local.common_tags 
    execution_role_arn       = aws_iam_role.execution_role.arn
    task_role_arn            = aws_iam_role.task_role.arn
    container_definitions    = jsonencode(
        [
            {
                name = "fs-ecs-kafka-rest-api"
                container_name ="fs-ecs-kafka-rest-api"
                image = var.image_ecs_kafka_rest_api
                essential = true
                portMappings = [
                    {
                        containerPort = var.ecs_kafka_rest_api_port
                        hostPort      = var.ecs_kafka_rest_api_port
                        protocol      = "tcp"
                    }
                ],
                logConfiguration = {
                    logDriver = "awslogs",
                    options   = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "kafka-rest-api"
                    }
                },
                environment = jsondecode("[${join(",\n", formatlist("{\"name\" :\"%s\", \"value\":\"%s\"}", keys(local.kafka_rest_api_variables), values(local.kafka_rest_api_variables)))}]")
            }
        ]        
    )
}

resource "aws_ecs_task_definition" "fs-ecs-producer" {
    family                   = "fs-ecs-producer"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_fs_ecs_producer_cpu
    memory                   = var.fargate_fs_ecs_producer_memory
    execution_role_arn       = aws_iam_role.execution_role.arn
    task_role_arn            = aws_iam_role.task_role.arn
    tags                     = merge(local.common_tags, {
        Role = "Task Definition"
    })

    container_definitions = jsonencode(
        [
            {
                name = "producer-orders"
                container_name = "producer-orders"
                image = var.image_fs_ecs_producer
                essential = true
                logConfiguration = {
                    logDriver = "awslogs",
                    options   = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "producer-orders"
                    }
                },
                command = ["python","producer_orders.py"]
            },
            {
                name = "producer-status"
                container_name = "producer-status"
                image = var.image_fs_ecs_producer
                essential = false
                logConfiguration = {
                    logDriver = "awslogs",
                    options   = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "producer-status"
                    }
                },
                command = ["python","producer_status.py"]
            },
            {
                name = "producer-restaurants"
                container_name = "producer-restaurants"
                image = var.image_fs_ecs_producer
                essential = false
                logConfiguration = {
                    logDriver = "awslogs",
                    options   = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "producer-restaurants"
                    }
                },
                command = ["python","producer_restaurants.py"]
            },
            {
                name = "producer-consumers"
                container_name = "producer-consumers"
                image = var.image_fs_ecs_producer
                essential = false
                logConfiguration = {
                    logDriver = "awslogs",
                    options   = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "producer-consumers"
                    }
                },
                command = ["python","producer_consumers.py"]
            },
            {
                name: "fs-post-ifood-payload"
                container_name: "fs-post-ifood-payload"
                image = var.image_fs_ecs_producer
                essential = false
                logConfiguration: {
                    logDriver = "awslogs",
                    options = {
                        awslogs-group         = aws_cloudwatch_log_group.fs-cloudwatch.name,
                        awslogs-region        = var.aws_region,
                        awslogs-stream-prefix = "fs-post-ifood-payload"
                    }
                }
                command = ["python","producer_s3_connect.py"]
            }
        ]
               
    )
}
