import requests

def main():

    print("POST S3 Connect")

    headers = {"Content-Type": "application/json"}

    payload = {   
        "name": "s3-ifood",
        "config": {
            "connector.class": "io.confluent.connect.s3.S3SinkConnector",
            "s3.region": "us-east-2",
            "topics.dir": "landing-zone",
            "flush.size": "10000",
            "auto.register.schemas": "false",
            "tasks.max": "1",
            "timezone": "America/Sao_Paulo",
            "locale": "en-US",
            "schema.registry.url": "http://fs-schema-registry.fs_ecs.local:8002",
            "s3.credentials.provider.class": "com.amazonaws.auth.DefaultAWSCredentialsProviderChain",
            "format.class": "io.confluent.connect.s3.format.parquet.ParquetFormat",
            "value.converter": "io.confluent.connect.avro.AvroConverter",
            "s3.bucket.name": "fs-landing-zone",
            "key.converter": "org.apache.kafka.connect.storage.StringConverter",
            "s3.part.size": "5242880",
            "parquet.codec": "snappy",
            "topics.regex": "ifood.app.(.*)",
            "value.converter.schema.registry.url": "http://fs-schema-registry.fs_ecs.local:8002",
            "partitioner.class": "io.confluent.connect.storage.partitioner.TimeBasedPartitioner",
            "storage.class": "io.confluent.connect.s3.storage.S3Storage",
            "rotate.schedule.interval.ms": "600000",
            "partition.duration.ms": "600000",
            "rotate.interval.ms": "600000",
            "path.format": "YYYY/MM/dd/HH/mm",
            "timestamp.extractor": "Record",
            "decimal.handling.mode": "double"
        }
    }
    
    url = "http://fs-s3-connect.fs_ecs.local:8084/connectors"

    r = requests.post(url, json=payload, headers=headers)

    print(r.text)

if __name__ == "__main__":
    main()