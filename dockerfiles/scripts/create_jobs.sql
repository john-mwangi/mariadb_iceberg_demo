-- *************************************************
-- **************    FLINK SQL    ******************
-- *************************************************

-- SET execution.checkpointing.interval = '3s'; --set on docker-compose

-- Create sources from DB
CREATE TABLE user_source (
    database_name STRING METADATA VIRTUAL,
    table_name STRING METADATA VIRTUAL,
    `id` INTEGER NOT NULL,
    name STRING,
    address STRING,
    phone_number STRING,
    email STRING,
    PRIMARY KEY (`id`) NOT ENFORCED
  ) WITH (
    'connector' = 'mysql-cdc',
    'hostname' = 'mariadb',
    'port' = '3306',
    'username' = 'root',
    'password' = 'mypass',
    'database-name' = 'db_[0-9]+',
    'table-name' = 'user_[0-9]+'
  );

-- Create a sink in the DW
CREATE TABLE all_users_sink (
    database_name STRING,
    table_name    STRING,
    `id`          INTEGER NOT NULL,
    name          STRING,
    address       STRING,
    phone_number  STRING,
    email         STRING,
    PRIMARY KEY (database_name, table_name, `id`) NOT ENFORCED
  ) WITH (
    'connector'='iceberg',
    'catalog-name'='iceberg_catalog',
    'catalog-type'='hadoop',  
    'warehouse'='file:///tmp/iceberg/warehouse',
    'format-version'='2'
  );

-- Start a streaming job
INSERT INTO all_users_sink select * from user_source;

-- Monitor the data warehouse
SELECT * FROM all_users_sink; 


-- *************************************************
-- **************    KAFKA SINK    *****************
-- *************************************************

-- Set checkpoint interval

-- Create sources from Kafka
CREATE TABLE user_source_kafka (
    database_name STRING METADATA FROM 'value.source.database' VIRTUAL,
    table_name STRING METADATA FROM 'value.source.table' VIRTUAL,
    topic STRING METADATA FROM 'topic' VIRTUAL,
    `id` INTEGER NOT NULL,
    name STRING,
    address STRING,
    phone_number STRING,
    email STRING,
    PRIMARY KEY (`id`) NOT ENFORCED
  ) WITH (
    'connector' ='kafka',
    -- 'topic' = 'users.db_1.user_1;users.db_1.user_2;users.db_2.user_1;users.db_2.user_2',
    'topic-pattern' = 'users\.db_[0-9]+\.user_[0-9]+',
    'properties.bootstrap.servers' = 'kafka:9092',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'debezium-json',
    'debezium-json.schema-include' = 'true'
  );

-- Create a Kafka sink in Iceberg
CREATE TABLE all_users_sink_kafka (
  database_name STRING,
  table_name    STRING,
  topic         STRING,
  `id`          INTEGER NOT NULL,
  name          STRING,
  address       STRING,
  phone_number  STRING,
  email         STRING,
  PRIMARY KEY (database_name, table_name, `id`) NOT ENFORCED
) WITH (
    'connector'='iceberg',
    'catalog-name'='iceberg_catalog',
    'catalog-type'='hadoop',
    'warehouse'='file:///tmp/iceberg/warehouse',
    'format-version'='2'
  );

-- Start a streaming job
INSERT INTO all_users_sink_kafka SELECT * FROM user_source_kafka;

-- Monitor the table in the dw
SELECT * FROM all_users_sink_kafka;

-- *************************************************
-- *****    PAIMON KAFKA TABLE SYNC ACTION    ******
-- *************************************************


CREATE CATALOG paimon_catalog WITH (
    'type' = 'paimon',
    'warehouse' = 'file:///tmp/paimon/warehouse'
);


docker exec -ti jobmanager bash

# Synchronisation of one Paimon table to one Kafka topic.
flink run \
    /opt/flink/lib/paimon-flink-action-0.9.0.jar \
    kafka_sync_table \
    --warehouse file:///tmp/paimon/warehouse \
    --database users_ta \
    --table user_2 \
    --primary_keys id \
    --kafka_conf properties.bootstrap.servers=kafka:9092 \
    --kafka_conf topic=users.db_1.user_2 \
    --kafka_conf value.format=debezium-json \
    --table_conf changelog-producer=input \
    --kafka_conf scan.startup.mode=earliest-offset

SELECT * FROM paimon_catalog.users_ta.user_2;

-- *************************************************
-- ******    PAIMON KAFKA DB SYNC ACTION    ********
-- *************************************************

-- Create paimon_catalog

docker exec -ti jobmanager bash

# Synchronization from multiple Kafka topics to a Paimon database.
# This action will create one database (users_da) with 2 tables:
# - user_1 (merging all tables called user_1)
# - user_2 (merging all tables called user_2)

flink run \
    /opt/flink/lib/paimon-flink-action-0.9.0.jar \
    kafka_sync_database \
    --warehouse file:///tmp/paimon/warehouse \
    --database users_da \
    --primary_keys id \
    --kafka_conf properties.bootstrap.servers=kafka:9092 \
    --kafka_conf topic-pattern=users\.db_[0-9]+\.user_[0-9]+ \
    --kafka_conf value.format=debezium-json \
    --table_conf changelog-producer=input \
    --kafka_conf scan.startup.mode=earliest-offset \
    --table_conf bucket=4 \
    --table_conf auto-create=true

  SHOW DATABASES IN paimon_catalog;
  SHOW TABLES IN paimon_catalog.users_da;
  SELECT * FROM paimon_catalog.users_da.user_1;
  SELECT * FROM paimon_catalog.users_da.user_2;