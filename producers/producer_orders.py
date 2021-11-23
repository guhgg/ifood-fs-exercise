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
            "cpf": float(row["cpf"]),
            "customer_id": str(row["customer_id"]),
            "customer_name": str(row["customer_name"]),
            "delivery_address_city": str(row["delivery_address_city"]),
            "delivery_address_country": str(row["delivery_address_country"]),
            "delivery_address_district": str(row["delivery_address_district"]),
            "delivery_address_external_id": int(row["delivery_address_external_id"]),
            "delivery_address_latitude": float(row["delivery_address_latitude"]),
            "delivery_address_longitude": float(row["delivery_address_longitude"]),
            "delivery_address_state": str(row["delivery_address_state"]),
            "delivery_address_zip_code": int(row["delivery_address_zip_code"]),
            "items": json.loads(re.sub(r'[\\]{2}','\\\\',row['items'])),
            "merchant_id": str(row["merchant_id"]),
            "merchant_latitude": float(row["merchant_latitude"]),
            "merchant_longitude": float(row["merchant_longitude"]),
            "merchant_timezone": str(row["merchant_timezone"]),
            "order_created_at": str(row["order_created_at"]),
            "order_id": row["order_id"],
            "order_scheduled": row["order_scheduled"],
            "order_total_amount": row["order_total_amount"],
            "origin_platform": str(row["origin_platform"]),
            "event_time": int(round(time.time() * 1000))
        }
    )
    producer.producer.poll(0)


def main():

    key_schema = avro.load("./schemas/order_key.json")
    value_schema = avro.load("./schemas/order_value.json")

    topic_name = "ifood.app.orders"
    
    producer = Producer(topic_name, key_schema, value_schema)


    schema = [
    "cpf",
    "customer_id",
    "customer_name",
    "delivery_address_city",
    "delivery_address_country",
    "delivery_address_district",
    "delivery_address_external_id",
    "delivery_address_latitude",
    "delivery_address_longitude",
    "delivery_address_state",
    "delivery_address_zip_code",
    "items",
    "merchant_id",
    "merchant_latitude",
    "merchant_longitude",
    "merchant_timezone",
    "order_created_at",
    "order_id",
    "order_scheduled",
    "order_total_amount", 
    "origin_platform"]

    count = 0
    with gzip.open("./data/order.json.gz", "r") as file:
        for line in file:
            print(count)
            json_line = file.readline()
            
            order_line = json.loads(json_line)
            schema_json = list(order_line.keys())
            missing_schema = list(set(schema) - set(schema_json))

            if missing_schema != []:
                for key in missing_schema:
                    order_line[key] = 0
            
            send_message(producer, topic_name, order_line)
            sleep(0.05)
            count += 1
    producer.producer.close()

if __name__ == "__main__":
    main()

