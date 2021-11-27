package com.featurestore

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import za.co.absa.abris.avro.functions.from_avro
import org.apache.spark.sql.types.{DateType, IntegerType, LongType, StringType, StructField, StructType}
import za.co.absa.abris.config
import za.co.absa.abris.config._
import org.apache.log4j.{Level, Logger}
import org.apache.spark.sql.streaming.{GroupState, GroupStateTimeout}
import com.redislabs.provider.redis._
import org.apache.spark.sql.Row
import org.apache.spark.sql.functions._
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.SaveMode
import io.delta.tables._

case class Order(order_id: String, status_id: String, value: String)
case class Customer(orders: Seq[Order])

object FeatureStore {
    val rootLogger = Logger.getRootLogger()
    rootLogger.setLevel(Level.ERROR)

    Logger.getLogger("org.apache.spark").setLevel(Level.WARN)
    Logger.getLogger("org.spark-project").setLevel(Level.WARN)

    def main(args: Array[String]) {

        val spark = SparkSession.builder()
            .master("yarn")
            .appName("Streaming")
            .config("spark.redis.host", args(1))
            .getOrCreate()
        
        import spark.implicits._ 

        val schemaRegistryAddress = "http://fs-schema-registry.fs_ecs.local:8002"
        val servers = args(2)
        val orderTopic = "ifood.app.orders"
        val statusTopic = "ifood.app.status"
    
        val restaurantStaticDF = spark.read.format("delta").load("s3://fs-landing-zone/transformation-zone/restaurants")
        val consumerStaticDF   = spark.read.format("delta").load("s3://fs-landing-zone/transformation-zone/consumers")
        
        val orderDF = spark.readStream
            .format("kafka")
            .option("kafka.bootstrap.servers", servers)
            .option("subscribe", orderTopic)
            .load()
            .select(from_avro(col("value"), getAvroSchema(orderTopic, schemaRegistryAddress)) as "data")

        val statusDF = spark.readStream
            .format("kafka")
            .option("kafka.bootstrap.servers", servers)
            .option("subscribe", statusTopic)
            .load()
            .select(from_avro(col("value"), getAvroSchema(statusTopic, schemaRegistryAddress)) as "data")

        val orderWatermark = orderDF
            .withColumn("event_time", from_unixtime(col("data.event_time")).cast("Timestamp"))
            .select(
                "data.customer_id", 
                "data.customer_name",
                "data.order_id",
                "data.order_total_amount",
                "data.items",
                "data.origin_platform",
                "data.merchant_id",
                "data.order_created_at",
                "event_time")
            .alias("order")
            .withWatermark("event_time", "10 seconds")
            .dropDuplicates("customer_id", "order_created_at")

        val statusWatermark = statusDF
            .withColumn("event_time", from_unixtime(col("data.event_time")).cast("Timestamp"))
            .select(
                "data.order_id", 
                "data.status_id",
                "data.value",
                "data.created_at",
                "event_time")
            .alias("status")
            .withWatermark("event_time", "10 seconds")
            .dropDuplicates("status_id", "created_at")
        

        statusWatermark
        .where(not(isnull($"order_id")) && not(isnull($"status.status_id"))).as[Order]
        .groupByKey(_.order_id)
        .mapGroupsWithState(GroupStateTimeout.ProcessingTimeTimeout())(updateStatusSession)
        .select("value.orders.order_id", "value.orders.status_id", "value.orders.value")
        .writeStream
        .outputMode("update")
        .option("checkpointLocation", "s3://fs-landing-zone/streaming_checkpoint/status_order")
        .foreachBatch { (batchDF: DataFrame, batchId: Long) =>
            batchDF
            .write
            .format("org.apache.spark.sql.redis")
            .option("table", "status_order")
            .mode(SaveMode.Append)
            .save()	

            batchDF
            .write
            .format("delta")
            .mode(SaveMode.Append)
            .save("s3://fs-landing-zone/presentation-zone/status_order")
        }
        .start()
    
        orderWatermark
        .writeStream
        .outputMode("update")
        .option("checkpointLocation", "s3://fs-landing-zone/streaming_checkpoint/order")
        .foreachBatch { (batchDF: DataFrame, batchId: Long) =>
            batchDF
            .write
            .format("org.apache.spark.sql.redis")
            .option("table", "order")
            .option("key.column", "customer_id")
            .mode(SaveMode.Append)
            .save()

            batchDF
            .write
            .format("delta")
            .mode(SaveMode.Append)
            .save("s3://fs-landing-zone/presentation-zone/orders")
        }
        .start()

        spark.streams.awaitAnyTermination()
    }
    
    def updateStatusSession(
        customer_id: String,
        orders: Iterator[Order],
        state: GroupState[Customer]): Option[Customer] = {
        if (state.hasTimedOut) {
            state.remove()
            state.getOption
        } else {
            val currentState = state.getOption
            val updatedStatusSession = currentState.fold(Customer(orders.toSeq))(currentStatusSession => Customer(currentStatusSession.orders ++ orders.toSeq))
                
            if (!updatedStatusSession.orders.filter(_.value == "CONCLUDED").isEmpty) {
                state.remove()
            
                Option(updatedStatusSession)
                
            } else {
                state.update(updatedStatusSession)
                state.setTimeoutDuration("1 minute")
                None
            }
        }	
    }

    def getAvroSchema(kafkaTopic: String, schemaRegistryAddress: String): FromAvroConfig = {
        val abrisConfig: FromAvroConfig = AbrisConfig.
            fromConfluentAvro.
            downloadReaderSchemaByLatestVersion.
            andTopicNameStrategy(kafkaTopic).
            usingSchemaRegistry(schemaRegistryAddress)

        abrisConfig
    }
}

