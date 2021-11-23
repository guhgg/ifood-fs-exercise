variable "aws_region" {
    description = "AWS Region for deployment"
    type        = string
}

variable "aws_s3_bucket_name" {
    description = "S3 bucket for storing the data"
    type        = string
    default     = ""
}

variable "ecs_cluster_name" {
    description = "Name of the ECS Cluster"
    type        = string
    default     = "fs_ecs_cluster"
}

variable "image_ecs_s3_connect" {
    description = "Docker image of s3 connect"
    type        = string
    default     = "confluentinc/cp-kafka-connect-base:6.1.2"
}

variable "image_ecs_connect_ui" {
    description = "Docker image of connect ui"
    type        = string
    default     = "landoop/kafka-connect-ui:0.9.7"
}

variable "image_ecs_schema_registry" {
    description = "Docker image of schema registry"
    type        = string
    default     = "confluentinc/cp-schema-registry:6.1.1"
}

variable "image_ecs_schema_registry_ui" {
    description = "Docker image of schema registry ui"
    type        = string
    default     = "landoop/schema-registry-ui:0.9.5"
}

variable "image_ecs_kafka_rest_api" {
    description = "Docker image of kafka rest api"
    type        = string
    default     = "confluentinc/cp-kafka-rest:6.2.0"
}

variable "image_fs_ecs_producer" {
    description = "Docker image of producers simulators"
    type        = string
    default     = "public.ecr.aws/n4b2o6w6/ifood_fs_producers"
}

variable "msk_kafka_version" {
    description = "Version of kafka"
    type        = string
    default     = "2.6.0"
}
variable "msk_number_of_brokers" {
    description = "Number of kafka brokers"
    type        = string
    default     = "3"
}
variable "msk_instance_type" {
    description = "MSK instance type"
    type        = string
    default     = "kafka.t3.small"
}
variable "msk_ebs_number_size" {
    description = "Broker volume"
    type        = string
    default     = "100"
}
variable "msk_encryption_in_transit" {
    description = "Encryption for data in transit between kafka cluster"
    type        = string
    default     = "TLS_PLAINTEXT" 
}
variable "msk_configuration_name" {
    description = "Name of the MSK configuration propertie. AWS doesn't allow you to delete the configuration"
    type        = string
}
variable "msk_config_create_topics_enable" {
    description = "Boolean option that enable applications create kafka topics"
    type        = bool
    default     = true
}
variable "msk_config_delete_topic_enable" {
    description = "Boolean option that enable applications delete kafka topics"
    type        = bool
    default     = false
}
variable "msk_config_default_replication_factor" {
    description = "Kafka replication factor"
    type        = number
    default     = 1
}
variable "msk_config_min_insync_replicas" {
    description = "Kafka insync replicas"
    type        = number
    default     = 1
}
variable "msk_config_num_partitions" {
    description = "kafka number of partitions"
    type        = number
    default     = 1
}
variable "msk_config_compression_type" {
    description = "Kafka message compression type"
    type        = string
    default     = "snappy"
}
variable "msk_config_message_max_bytes" {
    description = "Kafka batch message max bytes"
    type        = number
    default     = 1000000
}

variable "fargate_s3_connect_cpu" {
    description = "Fargate cpu for s3 connect"
    type        = number
    default     = 2048
}

variable "fargate_s3_connect_memory" {
    description = "Fargate memory for s3 connect"
    type        = number
    default     = 4096
}

variable "fargate_connect_ui_cpu" {
    description = "Fargate cpu for connect ui"
    type        = number
    default     = 256
}

variable "fargate_connect_ui_memory" {
    description = "Fargate memory for connect ui"
    type        = number
    default     = 1024
}

variable "fargate_schema_registry_cpu" {
    description = "Fargate cpu for schema registry"
    type        = number
    default     = 256
}

variable "fargate_schema_registry_memory" {
    description = "Fargate memory for schema registry"
    type        = number
    default     = 1024
}

variable "fargate_schema_registry_ui_cpu" {
    description = "Fargate cpu for schema registry ui"
    type        = number
    default     = 256
}

variable "fargate_schema_registry_ui_memory" {
    description = "Fargate memory for schema registry ui"
    type        = number
    default     = 1024
}

variable "fargate_kafka_rest_api_cpu" {
    description = "Fargate cpu for kafka rest api"
    type        = number
    default     = 256
}

variable "fargate_kafka_rest_api_memory" {
    description = "Fargate memory for kafka rest api"
    type        = number
    default     = 1024
}

variable "fargate_fs_ecs_producer_cpu" {
    description = "Fargate cpu for producer examples"
    type        = number
    default     = 2048
}

variable "fargate_fs_ecs_producer_memory" {
    description = "Fargate memory for producer examples"
    type        = number
    default     = 4096
}

variable "cloudwatch_log_group_name" {
    description = "Name for cloudwatch log group"
    type        = string
    default     = "ecs/fs-log"
}
variable  "ecs_s3_connect_port" {
    description = "Host port for Kafka Connect s3"
    type        = number
    default     = 8084
}
variable "ecs_kafka_rest_api_port" {
    description = "Host port for kafka rest api"
    type        = number
    default     = 8083
}

variable "ecs_connect_ui_port" {
    description = "Host port for connect ui"
    type        = number
    default     = 8000
}

variable "ecs_schema_registry_port" {
    description = "Host port for schema registry"
    type        = number
    default     = 8002
}

variable "ecs_schema_registry_ui_port" {
    description = "Host port for schema registry ui"
    type        = number
    default     = 8000
}