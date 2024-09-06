# Mariadb + Apache Iceberg Demo
## Objectives
Determine the feasibility of:
* Maintaining incrementally updated and queryable MediaWiki MariaDB tables in the Data Lake
* Generating state change events in Kafka from MediaWiki MariaDB
* Document learnings along the way

## Implementation pattern
Mariadb -> Flink CDC -> Kafka -> Iceberg

## Hosts
Flink UI: http://157.245.67.21:8081/

## Implementation process
Below is the implementation procedure that will be followed, to be updated as necessary:
- [x] Install Apache Iceberg with Spark
- [x] Install MariaDB
- [x] Install Apache Flink
- [x] Install Apache Kafka
- [ ] Create a streaming Flink SQL job
    - [x] Create physical tables in Maria DB
    - [x] Create source table in Iceberg
    - [x] Create sink table in Iceberg (Hadoop catalog type)
    - [x] Create Flink SQL streaming job
    - [ ] Test streaming job
    - [ ] Create automation scripts
- [ ] Create a streaming Flink CDC Kafka job
    - [ ] Test Kafka: create a test topic and manually publish a message to it
    - [ ] Create a destination table in Iceberg (test_table_flink)
    - [ ] Test Kafka -> Iceberg: configure Kafka to deliver messages to destination table in Iceberg from our test topic in Kafka
    - [ ] Configure Flink with source (Mariadb database) and sink (Kafka test topic)
    - [ ] Create automation scripts
- [ ] Add authentication
- [ ] Use MediaWiki instance

## Services
* tabulario/spark-iceberg: A simple local setup to try Iceberg. This includes Spark and a Postgres JDBC Catalog.
* tabulario/iceberg-rest: Sample REST image for experimentation and testing with Iceberg RESTCatalog implementations
* minio/minio: Multi-cloud object store compatible with S3
* minio/mc: Minio Client (mc) provides a modern alternative to UNIX commands like ls, cat, cp, mirror, diff etc
* mariadb: MariaDB Server is a high performing open source relational database, forked from MySQL

## Rationale
1. **Why Flink over Debezium?** Though Debezium supports a greater variety of sources and sinks compared to Flink, an internal analysis concluded that the events are very low level and difficult to use them without some translation.

## Relevant links
* https://phabricator.wikimedia.org/T370354
* https://iceberg.apache.org/spark-quickstart/#docker-compose
* https://github.com/tabular-io/docker-spark-iceberg
* https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/
* https://nightlies.apache.org/flink/flink-docs-master/docs/deployment/resource-providers/standalone/docker/
* https://hub.docker.com/r/apache/kafka
