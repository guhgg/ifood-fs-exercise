from producer import Producer
from confluent_kafka import avro
import json
import re
import gzip
import time
from time import sleep

def send_message(producer, topic_name, row):
    producer.producer.produce(
        topic=topic_name,
        key={"timestamp": producer.time_millis()},
        value={
            "created_at": str(row["created_at"]),
            "order_id": str(row["order_id"]),
            "status_id": str(row["status_id"]),
            "value": str(row["value"]),
            "event_time": int(round(time.time() * 1000))
        }
    )
    producer.producer.poll(0)


def main():

    key_schema = avro.load("./schemas/status_key.json")
    value_schema = avro.load("./schemas/status_value.json")

    topic_name = "ifood.app.status"
    
    producer = Producer(topic_name, key_schema, value_schema)


    schema = [
    "created_at",
    "order_id",
    "status_id",
    "value"]

    count = 0
    with gzip.open("./data/status.json.gz", "r") as file:
        for line in file:
            print(count)
            json_line = file.readline()
            
            status_line = json.loads(json_line)
            schema_json = list(status_line.keys())
            missing_schema = list(set(schema) - set(schema_json))

            if missing_schema != []:
                for key in missing_schema:
                    status_line[key] = 0
            
            send_message(producer, topic_name, status_line)
            sleep(0.05)
            count += 1
    producer.producer.close()

if __name__ == "__main__":
    main()

