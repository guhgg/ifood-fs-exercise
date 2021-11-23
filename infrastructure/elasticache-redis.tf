resource "aws_elasticache_cluster" "fs-redis-cluster" {
    cluster_id           = "fs-redis-cluster"
    engine               = "redis"
    node_type            = "cache.t3.small"
    num_cache_nodes      = 1
    parameter_group_name = "default.redis6.x"
    engine_version       = "6.x"
    port                 = 6379
    subnet_group_name    = aws_elasticache_subnet_group.fs-redis.name
    security_group_ids   = [aws_security_group.fs-ecs.id]
}

resource "aws_elasticache_subnet_group" "fs-redis" {
    name       = "fs-redis-subnet-group"
    subnet_ids = local.subnet_ids
}

output "redis_endpoint_string" {
    value = aws_elasticache_cluster.fs-redis-cluster.cache_nodes[0]["address"]
    description = "redis endpoint"
}