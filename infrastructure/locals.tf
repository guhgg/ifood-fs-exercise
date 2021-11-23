locals {
    common_tags = {
        App = "feature-store-exercise"
        Name = "feature-store-exercise",
        Company = "ifood"
        Owner = "gustavo.souza"
    }

    vpc_id = aws_vpc.fs-vpc.id
    subnet_ids = [aws_subnet.fs-private-subnet-a.id, aws_subnet.fs-private-subnet-b.id, aws_subnet.fs-private-subnet-c.id]
    
    s3_connect_variables = {
        CONNECT_BOOTSTRAP_SERVERS: aws_msk_cluster.fs-msk.bootstrap_brokers,
        CONNECT_GROUP_ID: "kafka-connect-group",
        CONNECT_CONFIG_STORAGE_TOPIC: "kafka-connect-config",
        CONNECT_OFFSET_STORAGE_TOPIC: "kafka-connect-offset",
        CONNECT_STATUS_STORAGE_TOPIC: "kafka-connect-status",
        CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR: "1",
        CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR: "1",
        CONNECT_STATUS_STORAGE_REPLICATION_FACTOR: "1",
        CONNECT_KEY_CONVERTER: "io.confluent.connect.avro.AvroConverter",
        CONNECT_VALUE_CONVERTER: "io.confluent.connect.avro.AvroConverter",
        CONNECT_INTERNAL_KEY_CONVERTER: "org.apache.kafka.connect.json.JsonConverter",
        CONNECT_INTERNAL_VALUE_CONVERTER: "org.apache.kafka.connect.json.JsonConverter",
        CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL: "http://fs-schema-registry.fs_ecs.local:${var.ecs_schema_registry_port}",
        CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL: "http://fs-schema-registry.fs_ecs.local:${var.ecs_schema_registry_port}",
        CONNECT_REST_ADVERTISED_HOST_NAME: "fs-ecs-s3-connect",
        CONNECT_REST_PORT: 8084,
        CONNECT_PLUGIN_PATH: "/usr/share/java,/usr/share/confluent-hub-components/,/connectors/",
        CONNECT_LOG4J_ROOT_LOGLEVEL: "INFO",
        CONNECT_LOG4J_LOGGERS: "org.apache.kafka.connect.runtime.rest=WARN,org.=reflectionsERROR",
    }

    connect_ui_variables = {
        CONNECT_URL: "http://fs-s3-connect.fs_ecs.local:${var.ecs_s3_connect_port}"
        PROXY: "true"
    }

    schema_registry_variables = {
        SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: "PLAINTEXT://${aws_msk_cluster.fs-msk.bootstrap_brokers}",
        SCHEMA_REGISTRY_HOST_NAME: "fs-ecs-schema-registry",
        SCHEMA_REGISTRY_LISTENERS: "http://0.0.0.0:${var.ecs_schema_registry_port}"
    }

    schema_registry_ui_variables = {
        SCHEMAREGISTRY_URL: "http://fs-schema-registry.fs_ecs.local:${var.ecs_schema_registry_port}/",
        PROXY: "true"
    }

    kafka_rest_api_variables = {
        KAFKA_REST_BOOTSTRAP_SERVERS: "PLAINTEXT://${aws_msk_cluster.fs-msk.bootstrap_brokers}",
        KAFKA_REST_SCHEMA_REGISTRY_URL: "http://fs-schema-registry.fs_ecs.local:${var.ecs_schema_registry_port}/",
        KAFKA_REST_LISTENERS: "http://0.0.0.0:${var.ecs_kafka_rest_api_port}",
        KAFKA_REST_HOST_NAME: "fs-ecs-kafka-rest-api"
    }
}