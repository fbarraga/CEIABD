#!/bin/bash

# Script para descargar Hadoop y Hive al caché local
# Esto acelera significativamente las reconstrucciones de contenedores

# Directorio central de downloads en la raíz del proyecto
DOWNLOAD_DIR="../../downloads"
HADOOP_VERSION="3.4.1"
HIVE_VERSION="2.3.9"

echo "================================================"
echo "📦 Descargando archivos al caché local"
echo "================================================"
echo ""

# Crear directorio si no existe
mkdir -p "$DOWNLOAD_DIR"

# Descargar Hadoop si no existe
if [ ! -f "$DOWNLOAD_DIR/hadoop-${HADOOP_VERSION}.tar.gz" ]; then
    echo "⬇️  Descargando Hadoop ${HADOOP_VERSION}..."
    wget -q --show-progress \
        https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
        -O "$DOWNLOAD_DIR/hadoop-${HADOOP_VERSION}.tar.gz"
    echo "✅ Hadoop descargado"
else
    echo "✅ Hadoop ${HADOOP_VERSION} ya existe en caché"
fi

echo ""

# Descargar Hive si no existe
if [ ! -f "$DOWNLOAD_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz" ]; then
    echo "⬇️  Descargando Hive ${HIVE_VERSION}..."
    wget -q --show-progress \
        https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
        -O "$DOWNLOAD_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz"
    echo "✅ Hive descargado"
else
    echo "✅ Hive ${HIVE_VERSION} ya existe en caché"
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
