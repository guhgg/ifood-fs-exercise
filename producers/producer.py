import logging
import time
import boto3
from confluent_kafka import avro
from confluent_kafka.admin import AdminClient, NewTopic
from confluent_kafka.avro import AvroProducer

logger = logging.getLogger(__name__)

dynamodb_client = boto3.client('dynamodb')

response = dynamodb_client.get_item(
    TableName="fs-dynamodb-utils-table",
    Key={
        'name': {'S': 'bootstrap_servers'},
    }
)

BROKER_URL = f"PLAINTEXT://{response['Item']['value']['S']}"
SCHEMA_REGISTRY_URL = "http://fs-schema-registry.fs_ecs.local:8002"

class Producer:

    existing_topics = set([])

    def __init__(self, topic_name, key_schema, value_schema=None, num_partitions=1, num_replicas=1):
        
        self.topic_name = topic_name
        self.key_schema = key_schema
        self.value_schema = value_schema
        self.num_partitions = num_partitions
        self.num_replicas = num_replicas

        self.broker_properties = {
            "bootstrap.servers": BROKER_URL,
            "schema.registry.url": SCHEMA_REGISTRY_URL
        }

        self.admClient = AdminClient({"bootstrap.servers": BROKER_URL})

        if self.topic_name not in Producer.existing_topics:
            self.create_topic()
            Producer.existing_topics.add(self.topic_name)

        self.producer = AvroProducer(self.broker_properties,
                                     default_key_schema=key_schema,
                                     default_value_schema=value_schema)
    def create_topic(self):

        if self.topic_exists(self.topic_name):
            return

        
        future = self.admClient.create_topics([NewTopic(
            topic=self.topic_name, num_partitions=self.num_partitions, replication_factor=self.num_replicas)])

        for _, future in future.items():
            try:
                future.result()
                logger.error(f"{self.topic_name} created")
            except Exception as e:
                logger.error(f"{self.topic_name} not created: {e}")

    def topic_exists(self, topic_name):
        topic_metadata = self.admClient.list_topics(timeout=5)
        return topic_name in set(t.topic for t in iter(topic_metadata.topics.values()))

    def time_millis(self):
        return int(round(time.time() * 1000))

    def close(self):
        self.producer.flush(timeout=10)