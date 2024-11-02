# Mariadb + Apache Iceberg Demo
## Objectives
Determine the feasibility of:
* Maintaining incrementally updated and queryable MediaWiki MariaDB tables in the Data Lake
* Generating state change events in Kafka from MediaWiki MariaDB
* Document learnings along the way

## Implementation pattern
Mariadb -> Flink CDC -> Kafka -> Iceberg

## Set up
### 1. Build the services
```
docker compose -f docker-compose.yml up --build --remove-orphans -d
```
### 2. Create a streaming job
- Log into Flink SQL Client
```
docker compose -f docker-compose.yml run sql-client
```
- Refer to `dockerfiles/scripts/create_jobs.sql` to create sources and sinks in the DW

### 3. Monitor streaming job
- Flink UI: http://localhost:8081/

## Implementation process
Below is the implementation procedure that will be followed, to be updated as necessary:
- [x] Install required services
    - [x] Install Apache Iceberg with Spark
    - [x] Install MariaDB
    - [x] Install Apache Flink
    - [x] Install Apache Kafka
- [x] Create a streaming Flink SQL job
    - [x] Create physical tables in Maria DB
    - [x] Create source table in Iceberg
    - [x] Create sink table in Iceberg (Hadoop catalog type)
    - [x] Create Flink SQL streaming job
    - [x] Test streaming job
    - [x] Create automation scripts
- [ ] Create a streaming Flink CDC Kafka job [1]
    - [ ] Downgrade to [Flink 1.17](https://nightlies.apache.org/flink/flink-cdc-docs-master/docs/connectors/flink-sources/overview/#supported-flink-versions)
    - [ ] Test Kafka: create a test topic and manually publish a message to it
    - [ ] Create a destination table in Iceberg (test_table_flink)
    - [ ] Test Kafka -> Iceberg: configure Kafka to deliver messages to destination table in Iceberg from our test topic in Kafka
    - [ ] Configure Flink with source (Mariadb database) and sink (Kafka test topic)
    - [ ] Create automation scripts
- [ ] Create streaming job using Debezium
    - [x] Prepare an implementation guide doc
    - [x] Create services
    - [x] Source (db) configuration
    - [ ] Connector configuration
        - [x] Source
        - [x] Sink
        - [ ] Destination
- [ ] Add MediaWiki instance
    - [ ] Create replication user
    - [ ] Add authentication
    - [ ] Use MediaWiki docker

## Notes
1. Current Flink CDC version doesn't capture the schema. This is planned for [Flink CDC v3.3](https://issues.apache.org/jira/browse/FLINK-36611)

## Services
* mariadb: MariaDB Server is a high performing open source relational database, forked from MySQL
* sql-client: Interface for creating source and sink tables using SQL, and submitting SQL queries
* jobmanager: In charge of generating the Flink topological graph and dispatching the jobs to workers
* taskmanager: Execute the tasks of a dataflow, and buffer and exchange the data streams

## Rationale
**Why Flink over Debezium?** Though Debezium supports a greater variety of sources and sinks compared to Flink, an internal analysis concluded that the events are very low level and difficult to use them without some translation.

## Relevant links
* https://phabricator.wikimedia.org/T370354
* https://iceberg.apache.org/spark-quickstart/#docker-compose
* https://github.com/tabular-io/docker-spark-iceberg
* https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/
* https://nightlies.apache.org/flink/flink-docs-master/docs/deployment/resource-providers/standalone/docker/
* https://hub.docker.com/r/apache/kafka
