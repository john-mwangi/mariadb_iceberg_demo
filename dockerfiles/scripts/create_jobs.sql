SET execution.checkpointing.interval = '3s';

-- Create sources from DB
CREATE TABLE user_source (
    database_name STRING METADATA VIRTUAL,
    table_name STRING METADATA VIRTUAL,
    `id` DECIMAL(20, 0) NOT NULL,
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
    `id`          DECIMAL(20, 0) NOT NULL,
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
    `id` DECIMAL(20, 0) NOT NULL,
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
  `id`          DECIMAL(20, 0) NOT NULL,
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
-- **************    PAIMON CATALOG    *************
-- *************************************************

-- Set checkpoint interval
-- Create Kafka sources

CREATE CATALOG paimon_catalog WITH (
    'type' = 'paimon',
    'catalog-type'='hadoop',
    'warehouse' = 'file:///tmp/paimon/warehouse'
);

USE CATALOG paimon_catalog;

-- Create a Kafka sink in Paimon
CREATE TABLE all_users_sink_kafka_paimon (
  database_name STRING,
  table_name    STRING,
  topic         STRING,
  `id`          DECIMAL(20, 0) NOT NULL,
  name          STRING,
  address       STRING,
  phone_number  STRING,
  email         STRING,
  PRIMARY KEY (database_name, table_name, `id`) NOT ENFORCED
);

  -- Start a streaming job
INSERT INTO all_users_sink_kafka_paimon SELECT * FROM user_source_kafka;

-- Monitor the table in the dw
SELECT * FROM all_users_sink_kafka_paimon;