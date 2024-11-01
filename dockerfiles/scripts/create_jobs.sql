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