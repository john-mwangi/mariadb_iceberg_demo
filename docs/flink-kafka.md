# About
This implements the a streaming pipeline from Maria DB to Iceberg with Kafka as the message broker.
It uses Flink SQL instead of Kafka Connect to connect Kafka to Iceberg.

# Implementation
1. Create Docker services: `docker compose -f docker-compose.yml up --build --remove-orphans -d`
1. Access Kafka UI to monitor Kafka messages: http://localhost:8082
1. Access Flink dashboard to monitor streaming jobs: http://localhost:8081
1. Access Flink SQL terminal: `docker compose run sql-client`

# Operation
The following operations are perform on the Flink SQL terminal to demostrate the functionality of the streaming pipeline.
1. Create streaming job: Run commands in `scripts/create_jobs.sql`
1. Monitor data warehouse contents: Use the command in `scripts/create_jobs.sql`
1. Perform CRUD operations in Maria DB: Run commands in `scripts/run_crud.sql`
1. Accessing Maria DB:
```
docker exec -ti mariadb bash
mariadb -uroot -pmypass
```