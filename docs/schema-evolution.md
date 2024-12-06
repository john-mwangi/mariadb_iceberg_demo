# About
This implements schema change evolution support. By using the schema definitions 
captured in the generated CDC messages, database tables can be automatically 
created in the data warehouse without having to be explicitly defined by the 
user. These destination schemas are also automatically updated when the source 
tables are updated. The functionality is currently supported in Paimon.

![Alt text](./cdc-ingestion-schema-evolution.png "Schema Change Evolution")

# Implementation
1. Create Docker services: `docker compose -f docker-compose.yml up --build --remove-orphans -d`
1. Access Kafka UI to monitor Kafka messages: http://localhost:8082 (u: admin, p:admin)
1. Access Flink dashboard to monitor streaming jobs: http://localhost:8081
1. Open the Flink SQL terminal: `docker compose run sql-client`
1. Open the jobmanager terminal: `docker exec -ti jobmanager bash`

# Operation
The commands for the following operations are in `scripts/create_jobs.sql`
1. Create the `paimon_catalog` in Flink SQL
1. To sync one Paimon table to one Kafka topic, use `kafka_sync_table` command in the jobmanager terminal
1. To sync several Kafka topics to one Paimon database, use `kafka_sync_database` command in the jobmanager terminal
1. Monitor data warehouse contents: Use the command in `scripts/create_jobs.sql`
1. Perform schema changes in Maria DB: Run commands in `scripts/run_crud.sql`
1. Accessing Maria DB:
```
docker exec -ti mariadb bash
mariadb -uroot -pmypass
```

## Supported changes
For these schema changes to reflect, a CRUD operation has to be 
performed so that a CDC message containing the new schema can be propagated to Kafka.
- [x] Addition of columns
- [x] Modification of data type - [Official docs](https://paimon.apache.org/docs/0.9/flink/cdc-ingestion/overview/#schema-change-evolution) 
- [x] Renaming of columns - the original column will have a NULL value
- [x] Dropping columns - deleted columns will have a NULL value

## Limitations
- Paimon Iceberg Compatibility Mode feature seems to have a bug: you can describe 
a table but running a query on the same table returns a `Table does not exist` 
error. Though part of the [v0.9 release](https://paimon.apache.org/docs/0.9/maintenance/configurations/), 
it has not been documented and is undergoing significant revision for the 
[v1.0 release](https://paimon.apache.org/docs/master/maintenance/configurations/). 
This includes replacing `metadata.iceberg-compatible (bool)` with `metadata.iceberg.storage (enum)`
