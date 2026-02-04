#!/bin/bash

# Script para descargar Hadoop y Hive al caché local
# Esto acelera significativamente las reconstrucciones de contenedores

# Directorio central de downloads en la raíz del proyecto
DOWNLOAD_DIR="../../downloads"
HADOOP_VERSION="3.4.1"
HIVE_VERSION="2.3.9"
SPARK_VERSION="3.5.0"

download_with_resume() {
    local url="$1"; shift
    local out="$1"; shift
    wget -q -c --show-progress \
        --tries=10 \
        --timeout=30 \
        --read-timeout=30 \
        --connect-timeout=10 \
        --dns-timeout=10 \
        --waitretry=5 \
        --retry-connrefused \
        "$url" -O "$out"
}

echo "================================================"
echo "📦 Descargando archivos al caché local"
echo "================================================"
echo ""

# Crear directorio si no existe
mkdir -p "$DOWNLOAD_DIR"

# Descargar Hadoop si no existe
if [ ! -f "$DOWNLOAD_DIR/hadoop-${HADOOP_VERSION}.tar.gz" ]; then
    echo "⬇️  Descargando Hadoop ${HADOOP_VERSION}..."
    download_with_resume \
        "https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
        "$DOWNLOAD_DIR/hadoop-${HADOOP_VERSION}.tar.gz"
    echo "✅ Hadoop descargado"
else
    echo "✅ Hadoop ${HADOOP_VERSION} ya existe en caché"
fi

echo ""

# Descargar Hive si no existe
if [ ! -f "$DOWNLOAD_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz" ]; then
    echo "⬇️  Descargando Hive ${HIVE_VERSION}..."
    download_with_resume \
        "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
        "$DOWNLOAD_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz"
    echo "✅ Hive descargado"
else
    echo "✅ Hive ${HIVE_VERSION} ya existe en caché"
fi

echo ""

# Descargar Spark si no existe
if [ ! -f "$DOWNLOAD_DIR/spark-${SPARK_VERSION}-bin-hadoop3.tgz" ]; then
    echo "⬇️  Descargando Spark ${SPARK_VERSION}..."
    download_with_resume \
        "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" \
        "$DOWNLOAD_DIR/spark-${SPARK_VERSION}-bin-hadoop3.tgz"
    echo "✅ Spark descargado"
else
    echo "✅ Spark ${SPARK_VERSION} ya existe en caché"
fi

echo ""
echo "================================================"
echo "✅ Caché actualizado"
echo "================================================"
echo ""
echo "Archivos en caché:"
ls -lh "$DOWNLOAD_DIR"
echo ""
echo "💡 Ahora las reconstrucciones serán mucho más rápidas"
echo "   usando: make build"
