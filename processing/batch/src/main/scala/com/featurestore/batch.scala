package com.featurestore

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types.{DateType, IntegerType, LongType, StringType, TimestampType}
import org.apache.spark.sql._
import io.delta.tables._
import org.json4s._
import org.json4s.jackson.JsonMethods._
import org.json4s.jackson.Serialization.{read, write}
import com.audienceproject.spark.dynamodb.implicits._

case class EventsTable(event: String, event_id: String, first_load: Boolean)

object FeatureStore { 
    val spark = SparkSession.builder()
    .appName("Incremental insertion")
    .master("yarn")
    .config("spark.sql.warehouse.dir", "hdfs:///user/spark/warehouse")
    .config("spark.sql.catalogImplementation", "hive") 
    .config("spark.databricks.hive.metastore.glueCatalog.enabled", "true")
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
    .getOrCreate()

    def main(args: Array[String]): Unit = {
        val eventsList: List[EventsTable] = List(
            EventsTable("restaurants", "id", true),
            EventsTable("consumers", "customer_id", true)
        )
        
        eventsList.foreach{ event =>
            println(event.event)
            val eventDF = spark.read.parquet(s"s3://fs-landing-zone/landing-zone/ifood.app.${event.event}/2021/*/*/*/*")
            
            if(event.first_load) firstLoad(event.event, eventDF, event.event_id)

            else incremental(event.event, eventDF, event.event_id)
        }
    }

    def firstLoad(event: String, eventDF: DataFrame, eventID: String): Unit = {
        println(s"first load $event")
        
        val latestChangesKey = eventDF
                    .selectExpr(s"$eventID as key", "struct(*) as AllColumns")
                    .groupBy("key")
                    .agg(max("AllColumns").as("latest"))
                    .selectExpr("key", "latest.*")
                    .drop(eventID)
                    .withColumnRenamed("key", eventID)

        val tablePath = s"s3://fs-landing-zone/transformation-zone/$event"
        
        latestChangesKey.write.format("delta").mode("overwrite").save(tablePath)

        spark.sql(s"CREATE DATABASE IF NOT EXISTS fs_delta")
        spark.sql(s"CREATE TABLE IF NOT EXISTS fs_delta.${event} USING DELTA LOCATION '${tablePath}'" )
    }

    def incremental(event: String, eventDF: DataFrame, eventID: String): Unit = {
        println(s"incremental $event")
        val deltaTable = DeltaTable.forName(s"fs_delta_table.{event}")
        
        val latestChangesKey = eventDF
                    .selectExpr(s"$eventID as key", "struct(*) as AllColumns")
                    .groupBy("key")
                    .agg(max("AllColumns").as("latest"))
                    .selectExpr("key", "latest.*")
                    .drop(eventID)
                    .withColumnRenamed("key", eventID)


        val columns = latestChangesKey.columns
        val mapColumns = columns zip columns.map(column => s"u.$column") toMap

        deltaTable.as("t")
        .merge(
        latestChangesKey.as("u"),
        s"u.$eventID = t.$eventID")
        .whenMatched().updateAll()
        .whenNotMatched().insertAll()
        .execute()
    }
} 