resource "aws_lb" "fs-ecs-application-lb" {
    name               = "fs-ecs-application-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.fs-ecs-application-lb.id, aws_security_group.fs-ecs.id]
    subnets            = local.subnet_ids

    enable_deletion_protection = false
}

resource "aws_lb_target_group" "fs-ecs-schema-registry-ui" {
    name        = "fs-ecs-schema-registry-ui"
    port        = var.ecs_schema_registry_ui_port
    protocol    = "HTTP"
    vpc_id      = local.vpc_id
    depends_on  = [aws_lb.fs-ecs-application-lb]
    target_type = "ip"

    health_check {
        port                = var.ecs_schema_registry_ui_port
        protocol            = "HTTP"
        interval            = 30
        unhealthy_threshold = 5
        matcher             = "200-399"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_lb_listener" "fs-ecs-schema-registry-ui" {
    load_balancer_arn = aws_lb.fs-ecs-application-lb.arn
    port              = 9000
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.fs-ecs-schema-registry-ui.arn
    }
}

resource "aws_lb_target_group" "fs-ecs-connect-ui" {
    name        = "fs-ecs-connect-ui"
    port        = var.ecs_connect_ui_port
    protocol    = "HTTP"
    vpc_id      = local.vpc_id
    depends_on  = [aws_lb.fs-ecs-application-lb]
    target_type = "ip"

    health_check {
        port                = var.ecs_connect_ui_port
        protocol            = "HTTP"
        interval            = 30
        unhealthy_threshold = 5
        matcher             = "200-399"
    }


    lifecycle {
        create_before_destroy = true
    }

}

resource "aws_lb_listener" "fs-ecs-connect-ui" {
    load_balancer_arn = aws_lb.fs-ecs-application-lb.arn
    port              = 9001
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.fs-ecs-connect-ui.arn
    }
}

resource "aws_lb_target_group" "fs-ecs-kafka-rest-api" {
    name        = "fs-ecs-kafka-rest-api"
    port        = var.ecs_kafka_rest_api_port
    protocol    = "HTTP"
    vpc_id      = local.vpc_id
    depends_on  = [aws_lb.fs-ecs-application-lb]
    target_type = "ip"

    health_check {
        port                = var.ecs_kafka_rest_api_port
        protocol            = "HTTP"
        interval            = 30
        unhealthy_threshold = 5
        matcher             = "200-399"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_lb_listener" "fs-ecs-kafka-rest-api" {
    load_balancer_arn = aws_lb.fs-ecs-application-lb.arn
    port              = 9002
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.fs-ecs-kafka-rest-api.arn
    }
}