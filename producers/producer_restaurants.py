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
                "id": str(row["id"]),
                "created_at": str(row["created_at"]),
                "enabled": bool(row["enabled"]),
                "price_range": int(row["price_range"]),
                "average_ticket": float(row["average_ticket"]),
                "takeout_time": float(row["takeout_time"]),
                "delivery_time": float(row["delivery_time"]),
                "minimum_order_value": float(row["minimum_order_value"]),
                "merchant_zip_code": int(row["merchant_zip_code"]),
                "merchant_city": str(row["merchant_city"]),
                "merchant_state": str(row["merchant_state"]),
                "merchant_country": str(row["merchant_country"]),
                "event_time": producer.time_millis()
            }
        )
        producer.producer.poll(0)
    
def main():
    key_schema = avro.load("./schemas/restaurant_key.json")
    value_schema = avro.load("./schemas/restaurant_value.json")

    topic_name = "ifood.app.restaurants"
    producer = Producer(topic_name, key_schema, value_schema)

    df  = pd.read_csv("./data/restaurant.csv.gz")
    
    send_message(producer, topic_name, df)

    producer.producer.close()

if __name__ == "__main__":
    main()