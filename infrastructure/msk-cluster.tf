resource "aws_kms_key" "fs-msk" {
    description = "fs-msk"
}

resource "aws_msk_cluster" "fs-msk" {
    cluster_name = "fs-msk"
    kafka_version = var.msk_kafka_version
    number_of_broker_nodes = var.msk_number_of_brokers
    tags = local.common_tags

    broker_node_group_info {
        instance_type   = var.msk_instance_type
        ebs_volume_size = var.msk_ebs_number_size
        client_subnets  = local.subnet_ids
        security_groups = [aws_security_group.fs-msk.id]
    }

    encryption_info {
        encryption_at_rest_kms_key_arn = aws_kms_key.fs-msk.arn
        encryption_in_transit {
          client_broker = var.msk_encryption_in_transit
          in_cluster = true
        }
    }

    configuration_info {
      arn      = aws_msk_configuration.fs-msk.arn
      revision = aws_msk_configuration.fs-msk.latest_revision
    }
}

resource "aws_msk_configuration" "fs-msk" {
    kafka_versions    = [var.msk_kafka_version]
    name              = var.msk_configuration_name
    server_properties = <<PROPERTIES
auto.create.topics.enable  = ${var.msk_config_create_topics_enable}
delete.topic.enable        = ${var.msk_config_delete_topic_enable}
default.replication.factor = ${var.msk_config_default_replication_factor}
min.insync.replicas        = ${var.msk_config_min_insync_replicas}
num.partitions             = ${var.msk_config_num_partitions}
compression.type           = ${var.msk_config_compression_type}
message.max.bytes          = ${var.msk_config_message_max_bytes}
PROPERTIES
}

output "msk-bootstrap-brokers" {
    value       = aws_msk_cluster.fs-msk.bootstrap_brokers
    description = "brokers string for connection"
}

output "zookeeper_connect_string" {
    value = aws_msk_cluster.fs-msk.zookeeper_connect_string
    description = "zookeeper string for connection"
}