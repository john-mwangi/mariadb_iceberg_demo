docker compose run flink-launcher bin/sql-client.sh \
    --jar /opt/flink/opt/flink-sql-connector-hive-2.3.9_2.12-1.17.0.jar \
    --jar /opt/flink/opt/flink-sql-connector-kafka-1.17.0.jar





CREATE CATALOG paimon0 WITH (
    'type'='paimon',
    'warehouse'='file:/tmp/warehouse/paimon0'
);

CREATE CATALOG iceberg0 WITH (
    'type'='iceberg',
    'warehouse'='file:/tmp/warehouse/iceberg0'
);
CREATE TABLE test2 (
    name STRING,
    `id`          DECIMAL(20, 0) NOT NULL,
    PRIMARY KEY (name, `id`) NOT ENFORCED
  ) WITH (
    -- 'connector'='iceberg',
    'catalog-name'='iceberg0',
    'catalog-type'='hadoop',
    'warehouse'='file:///tmp/warehouse/iceberg0',
    'format-version'='2'
  );

  insert into test1 values ('a', 1);


CREATE CATALOG hive_iceberg0 WITH (
    'type'='iceberg',
    'catalog-type'  = 'hive',
    -- 'warehouse'='file:/tmp/warehouse/hive_iceberg0',
    'hive-conf-dir' = './conf'
);
use `hive_iceberg0`.`default`;



CREATE TABLE t_foo2 (c1 varchar, c2 int);

insert into t_foo2 values ('a', 1);


SET execution.checkpointing.interval = '3s';









-- Create sources from DB
CREATE TABLE `default_catalog`.`default`.`revision_source` (
    database_name STRING METADATA VIRTUAL,
    table_name STRING METADATA VIRTUAL,
    rev_id INT NOT NULL,
    name STRING,
    address STRING,
    phone_number STRING,
    email STRING,
    PRIMARY KEY (`rev_id`) NOT ENFORCED
  ) WITH (
    'connector' = 'mysql-cdc',
    'hostname' = 'mariadb-main',
    'port' = '3306',
    'username' = 'root',
    'password' = 'main_root_password',
    'database-name' = 'my_database',
    'table-name' = 'revision'
  );





-- select from kafka cdc debezium table?
CREATE TABLE `default_catalog`.`default_database`.`revision_kafka2` (
  `rev_id` bigint  NOT NULL,
  `rev_page` int  NOT NULL,
  `rev_comment_id` bigint  NOT NULL,
  `rev_actor` bigint  NOT NULL,
  `rev_timestamp` binary NOT NULL,
  `rev_minor_edit` tinyint  NOT NULL,
  `rev_deleted` int  NOT NULL,
  `rev_len` int,
  `rev_parent_id` bigint,
  `rev_sha1` varbinary NOT NULL,
  weight DECIMAL(10, 2)
) WITH (
 'connector' = 'kafka',
 'topic' = 'my_database.revision',
 'properties.bootstrap.servers' = 'PLAINTEXT://broker:29092',
 'properties.group.id' = 'debezium0',
 'format' = 'debezium-json',
 'scan.startup.mode' = 'earliest-offset'
);

select rev_id, rev_page, rev_sha1 from `default_catalog`.`default_database`.`revision_kafka2` limit 10;



CREATE CATALOG hive_iceberg0 WITH (
    'type'='iceberg',
    'catalog-type'  = 'hive',
    -- 'warehouse'='file:/tmp/warehouse/hive_iceberg0',
    'hive-conf-dir' = './conf'
);
use `hive_iceberg0`.`default`;


CREATE TABLE `hive_iceberg0`.`default`.`revision_iceberg0` (
  `rev_id` bigint  NOT NULL,
  `rev_page` int  NOT NULL,
  `rev_comment_id` bigint  NOT NULL,
  `rev_actor` bigint  NOT NULL,
  `rev_timestamp` binary NOT NULL,
  `rev_minor_edit` tinyint  NOT NULL,
  `rev_deleted` int  NOT NULL,
  `rev_len` int,
  `rev_parent_id` bigint,
  `rev_sha1` varbinary NOT NULL,
  weight DECIMAL(10, 2)
);


SET execution.checkpointing.interval = '3s';
insert into `hive_iceberg0`.`default`.`revision_iceberg0`
    select * from `default_catalog`.`default_database`.`revision_kafka2` ;


select rev_id, rev_page, rev_sha1 from `hive_iceberg0`.`default`.`revision_iceberg0` limit 10;



docker compose run flink-launcher bin/flink run \
    /opt/paimon-flink-action/paimon-flink-action.jar mysql_sync_table \
    --warehouse file:/user/hive/warehouse/paimon0 \
    --database mediawiki1 \
    --mysql_conf hostname=mariadb-main \
    --mysql_conf username=root \
    --mysql_conf password=main_root_password \
    --mysql_conf database-name='my_database' \
    --mysql_conf server-time-zone='UTC'




docker compose run flink-launcher /opt/flink-cdc-3.1.0/bin/flink-cdc.sh /tmp/flink-cdc/conf/mysql-cdc-to-kafka.yaml


docker compose run flink-launcher bin/flink run \
    /opt/flink-paimon-action/paimon-flink-action.jar kafka_sync_database \
    --warehouse file:/user/hive/warehouse/paimon0 \
    --database mediawiki1 \
    --kafka_conf properties.bootstrap.servers=PLAINTEXT://broker:29092 \
    --kafka_conf topic=my_database.revision\;my_database.page\;my_database.slots\;my_database.content \
    --kafka_conf scan.startup.mode=earliest-offset \
    --kafka_conf properties.group.id=kafka_paimon0 \
    --kafka_conf value.format=debezium-json \
    --catalog_conf metastore=hive \
    --catalog_conf uri=thrift://hive-metastore:9083 \
    --table_conf changelog-producer=input
