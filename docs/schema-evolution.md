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
- [x] Addition of columns
- [ ] Modification of data type
- [ ] Renaming of columns
- [ ] Dropping columns

## Limitations
- Does not reliably work. For instance, schema changes due to addition of 
columns will not reflect in Paimon if a non-supported change is ran first.
