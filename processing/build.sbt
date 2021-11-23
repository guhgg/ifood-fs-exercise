version := "0.1"

ThisBuild / scalaVersion := "2.12.3"





lazy val lakebatch = (project in file("batch"))
    .settings(
        name:= "batch",
        assemblySettings,
        libraryDependencies ++= commonDependencies
    )

lazy val lakestreaming = (project in file("streaming"))
    .settings(
        name:= "streaming",
        assemblySettings,
        resolvers += "confluent" at "https://packages.confluent.io/maven/",
        libraryDependencies ++= commonDependencies ++ Seq(
            dependencies.sparkafka,
            dependencies.absa,
            dependencies.log4j,
            dependencies.redis
        )
    )


lazy val dependencies =
    new {
        val sparkVersion         = "3.1.1"
        val deltaVersion         = "1.0.0"
        val sparkDynamodbVersion = "1.1.2"
        val absaVersion          = "4.2.0"
        val log4jVersion         = "1.2.17"
        val redisVersion         = "2.5.0"


        val sparkSql       = "org.apache.spark"    %% "spark-sql"            % sparkVersion
        val sparkCore      = "org.apache.spark"    %% "spark-core"           % sparkVersion
        val sparkafka      = "org.apache.spark"    %% "spark-sql-kafka-0-10" % sparkVersion
        val delta          = "io.delta"            %% "delta-core"           % deltaVersion
        val sparkDynamodb  = "com.audienceproject" %% "spark-dynamodb"       % sparkDynamodbVersion
        val absa           = "za.co.absa"          %% "abris"                % absaVersion
        val log4j          = "log4j"               % "log4j"                % log4jVersion
        val redis          = "com.redislabs"       %% "spark-redis"         % redisVersion

    }


lazy val commonDependencies = Seq(
    dependencies.sparkSql,
    dependencies.sparkCore,
    dependencies.delta,
    dependencies.sparkDynamodb
)


lazy val assemblySettings = Seq(
    assemblyMergeStrategy in assembly := {
        case PathList("META-INF", xs @ _*) => MergeStrategy.discard
        case x                             => MergeStrategy.first
    }
)
