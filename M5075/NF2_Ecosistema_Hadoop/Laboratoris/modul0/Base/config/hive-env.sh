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
