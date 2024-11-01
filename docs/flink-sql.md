# About
This implements a streaming pipeline using Flink SQL that will stream from Maria DB to Apache Iceberg.

# Implementation
1. Create Docker services: `docker compose -f docker-compose.yaml -up --build --remove-orphans -d`
1. Access Flink dashboard: http://localhost:8081
1. Access Flink SQL terminal: `docker-compose run sql-client`

# Operation
The following operations are perform on the Flink SQL terminal to demostrate the functionality of the streaming pipeline.
1. Create sources & desitnations: Run the commands in `scripts/create_tables.sql`
1. Create streaming job: Run commands in `scripts/create_jobs.sql`
1. Perform CRUD operations: Run commands in `scripts/run_crud.sql`
1. Monitor the data warehouse: Use the command in `scripts/create_jobs.sql`