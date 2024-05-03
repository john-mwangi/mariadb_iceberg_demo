


# Apache Paimon + MediaWiki demo

Screen Recording:
https://vimeo.com/942403540?share=copy

## Setup

- Install MediaWiki with MariaDB with replication enabled
-- https://gerrit.wikimedia.org/g/mediawiki/core/+/HEAD/DEVELOPERS.md#quickstart
-- https://www.mediawiki.org/wiki/MediaWiki-Docker/Configuration_recipes/Alternative_databases#MariaDB_(database_replication)

- Download Flink 1.19
- Download required dependency jars into flink lib/ directory
-- paimon-flink-1.19-0.8-20240501.002151-33.jar
-- flink-shaded-hadoop-2-uber-2.8.3-10.0.jar
-- flink-sql-connector-mysql-cdc-3.0.1.jar


- Edit conf/config.yaml and increase `taskmanager.numberOfTaskSlots: 2` to at least 2.
  See: https://paimon.apache.org/docs/master/flink/quick-start/

- Start Flink cluster: `./bin/start-cluster.sh`

- Start Flink Paimon database sync job:
  https://paimon.apache.org/docs/master/flink/cdc-ingestion/mysql-cdc/#synchronizing-databases

```bash
./bin/flink run ../paimon-flink-action-0.8-20240501.002151-76.jar mysql_sync_database \
    --warehouse file:/tmp/paimon \
    --database mediawiki1 \
    --mysql_conf hostname=localhost \
    --mysql_conf username=root \
    --mysql_conf password=main_root_password \
    --mysql_conf database-name='my_database' \
    --mysql_conf server-time-zone='UTC'
```

Check Flink UI to see all the crazy tasks syncing all MariaDB tables!


## Flink Batch SQL Query

Start Flink SQL client
```./bin/sql-client.sh```

Create the (temporary) Paimon catalog, and create an empty 'mediawiki' database.
```sql

CREATE CATALOG my_catalog WITH (
    'type'='paimon',
    'warehouse'='file:/tmp/paimon'
);

USE CATALOG my_catalog;

-- Database already created by paimon mysql_sync_database job
USE mediawiki1;
```






```sql
-- use tableau result mode
SET 'sql-client.execution.result-mode' = 'tableau';

-- switch to batch mode
RESET 'execution.checkpointing.interval';
SET 'execution.runtime-mode' = 'batch';


SHOW TABLES;
DESCRIBE page;

-- Join and select page_title, rev_id, content_body WHERE page_id = 4

/*
NOTE: 
We have to DECODE to UTF-8 because MediaWiki stores strings as varbinary, 
and Flink mysql-cdc doesn't know about that :/
 */
SELECT 
    DECODE(page.page_title, 'UTF-8') as page_title, 
    revision.rev_id, 
    DECODE(text.old_text, 'UTF-8') as content_body
FROM page, revision, slots, content, text
WHERE 
    /*
    NOTE: 
    In local dev wiki, the content_address looks like tt:1.
    Here we get the text.old_id join via SUBSTRING. 
    We also have to cast string to int so join can be done.
    In prod we couldn't join like this, as the 'text' table doesn't exist; 
    it is in 'external storage'
    */
    CAST(SUBSTRING(DECODE(content.content_address, 'UTF-8'), 4) AS BIGINT)  = text.old_id AND
    slots.slot_content_id = content.content_id AND
    revision.rev_id = slots.slot_revision_id AND
    revision.rev_page = page.page_id AND
    page_id = 4
;
```


Streaming queries are also possible via
```sql
SET 'execution.runtime-mode' = 'streaming';
```

Locally, I have not allocated enough resources and it takes a while for the replication updates to propagate


## Query with Spark

TODO!!!  

