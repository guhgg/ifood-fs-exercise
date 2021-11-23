from producer import Producer
import pandas as pd
from confluent_kafka import avro
from time import sleep
import gzip

def send_message(producer, topic_name, df):

    for index, row in df.iterrows():
        print(index)
        producer.producer.produce(
        topic=topic_name,
        key={"timestamp": producer.time_millis()},
        value={
                "customer_id": str(row["customer_id"]),
                "language": str(row["language"]),
                "created_at": str(row["created_at"]),
                "active": bool(row["active"]),
                "customer_name": str(row["customer_name"]),
                "customer_phone_area": int(row["customer_phone_area"]),
                "customer_phone_number": int(row["customer_phone_number"]),
                "event_time": producer.time_millis()
            }
        )
        producer.producer.poll(0)
    
def main():
    
    key_schema = avro.load("./schemas/consumer_key.json")
    value_schema = avro.load("./schemas/consumer_value.json")

    topic_name = "ifood.app.consumers"
    producer = Producer(topic_name, key_schema, value_schema)

    df  = pd.read_csv("./data/consumer.csv.gz")
    
    send_message(producer, topic_name, df)

    producer.producer.close()

if __name__ == "__main__":
    main()