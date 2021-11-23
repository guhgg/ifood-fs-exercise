resource "aws_cloudwatch_log_group" "fs-cloudwatch" {
    name              = var.cloudwatch_log_group_name
    retention_in_days = 1
    tags              = local.common_tags
}
