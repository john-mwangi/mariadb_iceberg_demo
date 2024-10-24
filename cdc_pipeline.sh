

# flink-cdc.sh is flink-cdc's pipeline job launcher
# /tmp/flink-cdc/conf is mounted from ./cache/flink/
#


# launch mediawiki mariadb -> kafka flink-cdc pipeline
docker compose run flink-launcher /opt/flink-cdc-3.1.0/bin/flink-cdc.sh \
    /tmp/flink-cdc-pipeline-conf/mysql-cdc-to-kafka.yaml



