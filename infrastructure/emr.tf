resource "aws_emr_cluster" "cluster" {
    depends_on = [aws_msk_cluster.fs-msk, aws_elasticache_cluster.fs-redis-cluster]
    name          = "fs-ifood-exercise-emr"
    release_label = "emr-6.4.0"
    applications  = ["Spark", "Hive", "Hadoop"]
    termination_protection            = false
    keep_job_flow_alive_when_no_steps = true

    ec2_attributes {
        subnet_id                         = local.subnet_ids[0]
        emr_managed_master_security_group = aws_security_group.fs-emr.id
        emr_managed_slave_security_group  = aws_security_group.fs-emr.id
        instance_profile                  = aws_iam_instance_profile.fs-emr.arn
    }

    master_instance_group {
        instance_type = "m4.large"
    }

    core_instance_group {
        instance_type  = "c4.large"
        instance_count = 1

        ebs_config {
          size                 = "40"
          type                 = "gp2"
          volumes_per_instance = 1
        }
    }

    ebs_root_volume_size = 100

    configurations_json = <<EOF
[
   {
      "classification":"spark",
      "properties":{
         "maximizeResourceAllocation":"true"
      },
      "configurations":[
         
      ]
   },
   {
      "classification":"hive-site",
      "properties":{
         "hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
      },
      "configurations":[
         
      ]
   },
   {
      "classification":"spark-hive-site",
      "properties":{
         "hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
      },
      "configurations":[
         
      ]
   }
]
EOF
    service_role = aws_iam_role.emr_role.arn

    step {
        action_on_failure = "CONTINUE"
        name              = "fs-batch-emr-step"

        hadoop_jar_step {
            jar  = "command-runner.jar"
            args = ["spark-submit", "--packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.1,io.delta:delta-core_2.12:1.0.0", 
            "--master", "yarn", "--deploy-mode", "client", 
            "--class", "com.featurestore.FeatureStore", "s3://ifood-fs-exercise-spark-code/batch-assembly-0.1.0-SNAPSHOT.jar"]
        }
    }
    
    step {
        action_on_failure = "TERMINATE_CLUSTER"
        name              = "fs-streaming-emr-step"

        hadoop_jar_step {
            jar  = "command-runner.jar"
            args = ["spark-submit", "--packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.1,io.delta:delta-core_2.12:1.0.0", 
            "--master", "yarn", "--deploy-mode", "client", 
            "--class", "com.featurestore.FeatureStore", "s3://ifood-fs-exercise-spark-code/streaming-assembly-0.1.0-SNAPSHOT.jar", 
            "${var.aws_region}", "${aws_elasticache_cluster.fs-redis-cluster.cache_nodes[0]["address"]}", "${aws_msk_cluster.fs-msk.bootstrap_brokers}"]
        }
    }

}
