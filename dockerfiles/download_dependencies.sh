

# FLINK_VERSION=1.17.0
# FLINK_MINOR_VERSION=1.17
# SCALA_VERSION=2.12
# FLINK_CDC_VERSION=3.1.0
# HIVE_VERSION=2.3.9    # NOTE: 2.3.6 is not available for later Flink versions.
# KAFKA_CLIENTS_VERSION=3.4.0
# ICEBERG_VERSION=1.6.1
# HADOOP_VERSION=2.10.2
# FLINK_SHADED_HADOOP_2_UBER_VERSION=2.8.3-10.0
# MYSQL_CONNECTOR_JAVA_VERSION=8.0.27

# # can't parameterize this url, paimon just publishes snapshots?
# # Make sure this matches flink version!
# # paimon flink/lib
# FLINK_PAIMON_URL=https://repository.apache.org/content/groups/snapshots/org/apache/paimon/paimon-flink-1.17/0.9-SNAPSHOT/paimon-flink-1.17-0.9-20240904.002346-78.jar

# # paimon action CLI jars
# FLINK_PAIMON_ACTION_URL=https://repository.apache.org/content/groups/snapshots/org/apache/paimon/paimon-flink-action/0.9-SNAPSHOT/paimon-flink-action-0.9-20240904.002346-77.jar


download_dir=$1

function download {
    url=$1
    subdir=${2:-""}

    dest_dir=$download_dir/$subdir
    mkdir -p $dest_dir

    dest_file=$dest_dir/$(basename $url)
    test -f $dest_file ||
        (
            echo "Downloading $url to $dest_file" &&
            curl -Lo $dest_file $url
        )
}

set -e

# flink shaded hadoop 2
download https://repo1.maven.org/maven2/org/apache/flink/flink-shaded-hadoop-2-uber/$FLINK_SHADED_HADOOP_2_UBER_VERSION/flink-shaded-hadoop-2-uber-$FLINK_SHADED_HADOOP_2_UBER_VERSION.jar flink/lib

# flink mysql-connector-java
download https://repo1.maven.org/maven2/mysql/mysql-connector-java/$MYSQL_CONNECTOR_JAVA_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_JAVA_VERSION.jar flink/lib

# hive-exec. Needed for org.apache.hadoop.hive.metastore.api.NoSuchObjectException
download https://repo1.maven.org/maven2/org/apache/hive/hive-exec/$HIVE_VERSION/hive-exec-$HIVE_VERSION.jar flink/lib


# Flink SQL connectors saved to flink/opt/.
# To use these, pass paths in to sql-client.sh with --jar
# flink-sql-connector-hive
download https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-${HIVE_VERSION}_$SCALA_VERSION/$FLINK_VERSION/flink-sql-connector-hive-${HIVE_VERSION}_$SCALA_VERSION-$FLINK_VERSION.jar flink/opt

# flink-sql-connector-kafka - put in flink/lib for paimon action?
download https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/$FLINK_VERSION/flink-sql-connector-kafka-$FLINK_VERSION.jar flink/opt


# # flink paimon
download $FLINK_PAIMON_URL flink/opt


# === flink cdc sql connctors
# flink mysql-cdc sql connector
download https://repo1.maven.org/maven2/com/ververica/flink-sql-connector-mysql-cdc/$FLINK_CDC_VERSION/flink-sql-connector-mysql-cdc-$FLINK_CDC_VERSION.jar flink/opt

# flink iceberg sql connector
download https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-$FLINK_MINOR_VERSION/$ICEBERG_VERSION/iceberg-flink-runtime-$FLINK_MINOR_VERSION-$ICEBERG_VERSION.jar flink/opt


# === flink-cdc distribution

# flink-cdc dist allows us to run flink-cdc pipeline launcher script.
# NOTE This is a tar.gz file, needs to be extracted in image
download https://archive.apache.org/dist/flink/flink-cdc-$FLINK_CDC_VERSION/flink-cdc-$FLINK_CDC_VERSION-bin.tar.gz flink-cdc
test -f $download_dir/flink-cdc/flink-cdc-$FLINK_CDC_VERSION || tar xvzf ./$download_dir/flink-cdc/flink-cdc-$FLINK_CDC_VERSION-bin.tar.gz -C $download_dir/flink-cdc

# === flink cdc pipeline connectors -- these go in flink-cdc/lib, not in flink/lib or flink/opt
# flink mysql-cdc pipeline connector
download https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-mysql/$FLINK_CDC_VERSION/flink-cdc-pipeline-connector-mysql-$FLINK_CDC_VERSION.jar flink-cdc/flink-cdc-$FLINK_CDC_VERSION/lib

# flink paimon pipeline connector
download https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-paimon/$FLINK_CDC_VERSION/flink-cdc-pipeline-connector-paimon-$FLINK_CDC_VERSION.jar flink-cdc/flink-cdc-$FLINK_CDC_VERSION/lib

# flink kafka pipeline connector
download https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-kafka/$FLINK_CDC_VERSION/flink-cdc-pipeline-connector-kafka-$FLINK_CDC_VERSION.jar flink-cdc/flink-cdc-$FLINK_CDC_VERSION/lib



# === Get paimon action jars (for launching pipelines via CLI
# https://paimon.apache.org/docs/master/flink/action-jars/
download $FLINK_PAIMON_ACTION_URL paimon-action


wait


echo "Done downloading dependencies to $download_dir"
ls -lhR $download_dir