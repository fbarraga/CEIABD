#!/bin/bash

# Java settings
export JAVA_HOME=/opt/java/openjdk
export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/hive

# Hadoop configuration
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HIVE_CONF_DIR=$HIVE_HOME/conf

# Add Hadoop jars to classpath
export HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/yarn/lib/*

# Hive log directory
export HIVE_LOG_DIR=$HIVE_HOME/logs

# Optimización de memoria para Hive en máquinas menos potentes
# HiveServer2: reducido a 512MB
export HADOOP_HEAPSIZE=512
export HADOOP_CLIENT_OPTS="-Xmx512m -XX:+UseG1GC"

# Hive Metastore: reducido a 256MB
export HIVE_METASTORE_HEAPSIZE=256

# Optimización de GC para Hive
export HADOOP_OPTS="$HADOOP_OPTS -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
