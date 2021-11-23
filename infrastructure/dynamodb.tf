resource "aws_dynamodb_table" "fs-dynamodb-utils-table" {
    name = "fs-dynamodb-utils-table"
    billing_mode = "PROVISIONED"
    read_capacity = 10
    write_capacity = 10
    hash_key = "name"

    attribute {
        name = "name"
        type = "S"
    }
}

resource "aws_dynamodb_table_item" "fs-dynamodb-bootstrap" {
    depends_on = [aws_msk_cluster.fs-msk]
    table_name = aws_dynamodb_table.fs-dynamodb-utils-table.name
    hash_key   = aws_dynamodb_table.fs-dynamodb-utils-table.hash_key

    item = <<ITEM
{
    "name": {
        "S": "bootstrap_servers"
    },
    "value": {
        "S": "${aws_msk_cluster.fs-msk.bootstrap_brokers}"
    }
}
ITEM
}

resource "aws_dynamodb_table_item" "fs-dynamodb-redis" {
    depends_on = [aws_elasticache_cluster.fs-redis-cluster]
    table_name = aws_dynamodb_table.fs-dynamodb-utils-table.name
    hash_key   = aws_dynamodb_table.fs-dynamodb-utils-table.hash_key

    item = <<ITEM
{
    "name": {
        "S": "redis_endpoint"
    },
    "value": {
        "S": "${aws_elasticache_cluster.fs-redis-cluster.cache_nodes[0]["address"]}:6379"
    }
}
ITEM
}