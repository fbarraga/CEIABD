#!/bin/bash

# Iniciar el servicio SSH (requiere privilegios de root)
sudo service ssh start

# Configurar /etc/hosts para resolución de nombres
echo "127.0.0.1 localhost" | sudo tee /etc/hosts > /dev/null
echo "$(hostname -i) $(hostname)" | sudo tee -a /etc/hosts > /dev/null

# Crear y asignar permisos a los directorios de datos de Hadoop
sudo mkdir -p /tmp/hadoop-hadoop/dfs/name
sudo mkdir -p /tmp/hadoop-hadoop/dfs/data
sudo chown -R hadoop:hadoop /tmp/hadoop-hadoop
sudo chmod -R 755 /tmp/hadoop-hadoop

# Esperar a que el master esté disponible si este es un nodo esclavo
if [ "$NODE_TYPE" = "slave" ]; then
    echo "==========================================="
    echo "Nodo SLAVE $(hostname) esperando al master..."
    echo "==========================================="
    # Esperar 15 segundos para que el master esté listo
    sleep 15
    echo "Nodo SLAVE $(hostname) listo"
fi

# Ejecutar acciones específicas según el tipo de nodo
if [ "$NODE_TYPE" = "master" ]; then
    echo "==========================================="
    echo "Iniciando nodo MASTER"
    echo "==========================================="

    # Formatear HDFS si es la primera vez (ejecutar como usuario hadoop)
    if [ ! -d "/tmp/hadoop-hadoop/dfs/name/current" ]; then
        echo "Formateando HDFS..."
        sudo -u hadoop $HADOOP_HOME/bin/hdfs namenode -format -force
    fi

    # Esperar a que los slaves estén disponibles
    echo "Esperando 20 segundos a que los slaves estén listos..."
    sleep 20

    # Iniciar servicios de Hadoop desde el master (como usuario hadoop)
    echo "Iniciando HDFS..."
    sudo -u hadoop $HADOOP_HOME/sbin/start-dfs.sh

    echo "Iniciando YARN..."
    sudo -u hadoop $HADOOP_HOME/sbin/start-yarn.sh

    echo "==========================================="
    echo "✅ Cluster Hadoop iniciado correctamente"
    echo "📊 NameNode UI: http://localhost:9870"
    echo "📊 ResourceManager UI: http://localhost:8088"
    echo "==========================================="

elif [ "$NODE_TYPE" = "slave" ]; then
    echo "Nodo SLAVE $(hostname) en espera..."
fi

# Mantener el contenedor en ejecución
tail -f /dev/null
