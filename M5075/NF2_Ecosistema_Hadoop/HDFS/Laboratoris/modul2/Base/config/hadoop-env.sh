#!/bin/bash

# Java settings
export JAVA_HOME=/opt/java/openjdk
export HADOOP_HOME=/opt/hadoop

# MapReduce settings
#export HADOOP_MAPRED_HOME=$HADOOP_HOME
#export HADOOP_COMMON_HOME=$HADOOP_HOME
#export HADOOP_HDFS_HOME=$HADOOP_HOME
#export YARN_HOME=$HADOOP_HOME
#export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

# User settings for daemons
#export HDFS_NAMENODE_USER=hadoop
#export HDFS_DATANODE_USER=hadoop
#export HDFS_SECONDARYNAMENODE_USER=hadoop
#export YARN_RESOURCEMANAGER_USER=hadoop
#export YARN_NODEMANAGER_USER=hadoop

# Hadoop options
#export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true"

# Optimización de memoria para máquinas menos potentes
# NameNode: reducido a 512MB (por defecto suele ser 1GB o más)
export HDFS_NAMENODE_OPTS="-Xms512m -Xmx512m -XX:+UseG1GC"

# DataNode: reducido a 256MB
export HDFS_DATANODE_OPTS="-Xms256m -Xmx256m -XX:+UseG1GC"

# ResourceManager: reducido a 512MB
export YARN_RESOURCEMANAGER_OPTS="-Xms512m -Xmx512m -XX:+UseG1GC"

# NodeManager: reducido a 256MB
export YARN_NODEMANAGER_OPTS="-Xms256m -Xmx256m -XX:+UseG1GC"

# JobHistoryServer: reducido a 256MB
export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=256

# Garbage Collector optimizado para bajo consumo
export HADOOP_OPTS="$HADOOP_OPTS -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
