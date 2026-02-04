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

    echo "Iniciando Spark Master..."
    sudo -u hadoop $SPARK_HOME/sbin/start-master.sh

    echo "Iniciando Spark Worker..."
    sudo -u hadoop $SPARK_HOME/sbin/start-worker.sh spark://$(hostname):7077

    echo "Iniciando Spark History Server..."
    sudo -u hadoop $SPARK_HOME/sbin/start-history-server.sh

    # Configurar Jupyter
    sudo -u hadoop mkdir -p /home/hadoop/.jupyter
    sudo -u hadoop cat > /home/hadoop/.jupyter/jupyter_notebook_config.py <<EOF
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.token = ''
c.NotebookApp.password = ''
c.NotebookApp.notebook_dir = '/home/hadoop/notebooks'
c.NotebookApp.allow_root = True
EOF

    echo "Iniciando Jupyter Notebook..."
    sudo -u hadoop nohup jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root > /opt/spark/logs/jupyter.log 2>&1 &

    echo "==========================================="
    echo "✅ Cluster Hadoop + Spark iniciado correctamente"
    echo "📊 NameNode UI: http://localhost:9870"
    echo "📊 ResourceManager UI: http://localhost:8088"
    echo "⚡ Spark Master UI: http://localhost:8080"
    echo "📓 Jupyter Notebook: http://localhost:8888"
    echo "📜 Spark History Server: http://localhost:18080"
    echo "==========================================="

elif [ "$NODE_TYPE" = "slave" ]; then
    echo "Nodo SLAVE $(hostname) en espera..."
fi

# Mantener el contenedor en ejecución
tail -f /dev/null
