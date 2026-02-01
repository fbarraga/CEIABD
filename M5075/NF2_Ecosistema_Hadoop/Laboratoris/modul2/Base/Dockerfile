FROM eclipse-temurin:11-jre

# Set environment variables
ENV HADOOP_VERSION=3.4.1
ENV HIVE_VERSION=2.3.9
ENV SPARK_VERSION=3.5.0
ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/hive
ENV SPARK_HOME=/opt/spark
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV LANG=es_ES.UTF-8
ENV LANGUAGE=es_ES:es
ENV LC_ALL=es_ES.UTF-8
ENV PYSPARK_PYTHON=python3
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    bash \
    wget \
    rsync \
    sudo \
    curl \
    dos2unix \
    coreutils \
    vim \
    procps \
    locales \
    python3 \
    python3-pip \
    python3-venv \
    net-tools \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/es_ES.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen es_ES.UTF-8 \
    && update-locale LANG=es_ES.UTF-8 LANGUAGE=es_ES:es LC_ALL=es_ES.UTF-8

# Create hadoop user and group
RUN groupadd hadoop && \
    useradd -ms /bin/bash -g hadoop hadoop && \
    echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH for hadoop user
RUN mkdir -p /home/hadoop/.ssh && \
    ssh-keygen -t rsa -f /home/hadoop/.ssh/id_rsa -q -N "" && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chown -R hadoop:hadoop /home/hadoop/.ssh && \
    chmod 600 /home/hadoop/.ssh/authorized_keys && \
    chmod 700 /home/hadoop/.ssh

# Copy downloads directory (para caché local de Hadoop y Hive)
COPY downloads/ /tmp/downloads/

# Download and Install Hadoop (usa caché local si existe)
RUN if [ -f /tmp/downloads/hadoop-${HADOOP_VERSION}.tar.gz ]; then \
    echo "✅ Usando Hadoop desde caché local..."; \
    cp /tmp/downloads/hadoop-${HADOOP_VERSION}.tar.gz /tmp/hadoop.tar.gz; \
    else \
    echo "⬇️  Descargando Hadoop desde Internet..."; \
    wget -q https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -O /tmp/hadoop.tar.gz; \
    fi && \
    tar -xzf /tmp/hadoop.tar.gz -C /usr/local/ && \
    mv /usr/local/hadoop-${HADOOP_VERSION} $HADOOP_HOME && \
    rm /tmp/hadoop.tar.gz && \
    chown -R hadoop:hadoop $HADOOP_HOME

# Download and Install Hive (usa caché local si existe)
RUN if [ -f /tmp/downloads/apache-hive-${HIVE_VERSION}-bin.tar.gz ]; then \
    echo "✅ Usando Hive desde caché local..."; \
    cp /tmp/downloads/apache-hive-${HIVE_VERSION}-bin.tar.gz /tmp/hive.tar.gz; \
    else \
    echo "⬇️  Descargando Hive desde Internet..."; \
    wget -q https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz -O /tmp/hive.tar.gz; \
    fi && \
    tar -xzf /tmp/hive.tar.gz -C /usr/local/ && \
    mv /usr/local/apache-hive-${HIVE_VERSION}-bin $HIVE_HOME && \
    rm /tmp/hive.tar.gz && \
    chown -R hadoop:hadoop $HIVE_HOME

# Download and Install Spark (usa caché local si existe)
RUN if [ -f /tmp/downloads/spark-${SPARK_VERSION}-bin-hadoop3.tgz ]; then \
    echo "✅ Usando Spark desde caché local..."; \
    cp /tmp/downloads/spark-${SPARK_VERSION}-bin-hadoop3.tgz /tmp/spark.tgz; \
    else \
    echo "⬇️  Descargando Spark desde Internet..."; \
    wget -q https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -O /tmp/spark.tgz; \
    fi && \
    tar -xzf /tmp/spark.tgz -C /opt/ && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop3 $SPARK_HOME && \
    rm /tmp/spark.tgz && \
    chown -R hadoop:hadoop $SPARK_HOME

# Instalar librerías Python para Data Science
RUN pip3 install --no-cache-dir --break-system-packages \
    pyspark==${SPARK_VERSION} \
    pandas==2.1.3 \
    numpy==1.26.2 \
    matplotlib==3.8.2 \
    seaborn==0.13.0 \
    jupyter==1.0.0 \
    jupyterlab==4.0.9 \
    notebook==7.0.6 \
    ipykernel==6.27.1 \
    findspark==2.0.1 \
    pyarrow==14.0.1


# Configuración Hadoop
COPY modulo2/Base/config/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY modulo2/Base/config/hadoop-env.sh $HADOOP_HOME/etc/hadoop/
COPY modulo2/Base/config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/

## Nombres de los nodos
COPY modulo2/Base/config/workers $HADOOP_HOME/etc/hadoop/

# Añdir líneas al bashrc del contenedor
COPY modulo2/Base/config/bashrc /tmp/bashrc
RUN cat /tmp/bashrc >> /home/hadoop/.bashrc && \
    rm /tmp/bashrc && \
    chown hadoop:hadoop /home/hadoop/.bashrc

# Coniguración YARN
COPY modulo2/Base/config/mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY modulo2/Base/config/yarn-site.xml $HADOOP_HOME/etc/hadoop/

# Configuración Hive
COPY modulo2/Base/config/hive-site.xml $HIVE_HOME/conf/
COPY modulo2/Base/config/hive-env.sh $HIVE_HOME/conf/

# Configuración Spark
COPY modulo2/Base/config/spark-defaults.conf $SPARK_HOME/conf/
COPY modulo2/Base/config/spark-env.sh $SPARK_HOME/conf/
COPY modulo2/Base/config/log4j2.properties $SPARK_HOME/conf/

# Normalizar finales de línea de los ficheros copiados (evita problemas CRLF)
RUN dos2unix \
    $HADOOP_HOME/etc/hadoop/core-site.xml \
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    $HADOOP_HOME/etc/hadoop/hdfs-site.xml \
    $HADOOP_HOME/etc/hadoop/workers \
    $HADOOP_HOME/etc/hadoop/mapred-site.xml \
    $HADOOP_HOME/etc/hadoop/yarn-site.xml \
    $HADOOP_HOME/etc/hadoop/yarn-site.xml \
    $HIVE_HOME/conf/hive-site.xml \
    $HIVE_HOME/conf/hive-env.sh \
    $SPARK_HOME/conf/spark-defaults.conf \
    $SPARK_HOME/conf/spark-env.sh \
    $SPARK_HOME/conf/log4j2.properties || true

# Damos permisos de ejecución los scripts con variables de entorno
RUN chmod +x $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    chmod +x $HIVE_HOME/conf/hive-env.sh && \
    chmod +x $SPARK_HOME/conf/spark-env.sh && \
    chown -R hadoop:hadoop $HADOOP_HOME/etc/hadoop/ && \
    chown -R hadoop:hadoop $HIVE_HOME/conf/ && \
    chown -R hadoop:hadoop $SPARK_HOME/conf/

# Configure SSH to allow connections without host key verification
RUN echo "Host *" >> /home/hadoop/.ssh/config && \
    echo "   StrictHostKeyChecking no" >> /home/hadoop/.ssh/config && \
    echo "   UserKnownHostsFile=/dev/null" >> /home/hadoop/.ssh/config && \
    chown hadoop:hadoop /home/hadoop/.ssh/config && \
    chmod 600 /home/hadoop/.ssh/config

# Copy the start script
COPY modulo2/Base/start-hadoop.sh /start-hadoop.sh
RUN chmod +x /start-hadoop.sh && \
    chown hadoop:hadoop /start-hadoop.sh
RUN dos2unix /start-hadoop.sh

# Create necessary directories
RUN mkdir -p /var/run/sshd && \
    mkdir -p $HADOOP_HOME/logs && \
    mkdir -p $HIVE_HOME/logs && \
    mkdir -p /tmp/hive && \
    chown -R hadoop:hadoop $HADOOP_HOME/logs && \
    chown -R hadoop:hadoop $HIVE_HOME/logs && \
    chown -R hadoop:hadoop /tmp/hive && \
    mkdir -p $SPARK_HOME/logs \
    $SPARK_HOME/work \
    $SPARK_HOME/tmp \
    /home/hadoop/notebooks \
    /home/hadoop/data && \
    chown -R hadoop:hadoop $SPARK_HOME /home/hadoop

# Expose ports
EXPOSE 9870 8088 9000 8042 22 10000 10002 9083 8080 7077 4040 18080 8888

# Set entry point
CMD ["/start-hadoop.sh"]
