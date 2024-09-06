FROM flink:1.16.0-scala_2.12

WORKDIR /opt/flink/lib

RUN apt-get update && \
    apt-get install -y curl tree && \
    curl https://repo1.maven.org/maven2/com/ververica/flink-sql-connector-mysql-cdc/3.0.1/flink-sql-connector-mysql-cdc-3.0.1.jar -Lo flink-sql-connector-mysql-cdc-3.0.1.jar && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop-2-uber/2.7.5-10.0/flink-shaded-hadoop-2-uber-2.7.5-10.0.jar -Lo flink-shaded-hadoop-2-uber-2.7.5-10.0.jar && \
    curl https://repo.maven.apache.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.16/1.3.1/iceberg-flink-runtime-1.16-1.3.1.jar -Lo iceberg-flink-runtime-1.16-1.3.1.jar && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
