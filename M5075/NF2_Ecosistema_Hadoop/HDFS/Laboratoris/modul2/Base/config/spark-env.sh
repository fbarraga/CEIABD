#!/usr/bin/env bash

export JAVA_HOME=/opt/java/openjdk

export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

export SPARK_MASTER_HOST=master
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=8080

#export SPARK_WORKER_CORES=2
#export SPARK_WORKER_MEMORY=2g
#export SPARK_DAEMON_MEMORY=1g
export SPARK_WORKER_CORES=1
export SPARK_WORKER_MEMORY=1g
export SPARK_DAEMON_MEMORY=512m

export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=python3
