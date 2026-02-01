#!/bin/bash

# Variables
JAR="/opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar"
INPUT_LOCAL="/home/hadoop/ejercicios/quijote.txt"
INPUT_HDFS="/quijote.txt"
OUTPUT_HDFS="/quijote_salida"

echo "🚀 Preparando ejecución (INTERNAL)..."

# 1. Copiar datos a HDFS
echo "📂 Subiendo datos a HDFS..."
hdfs dfs -put -f $INPUT_LOCAL $INPUT_HDFS

# 2. Limpiar salida anterior
echo "🧹 Limpiando salida anterior..."
hdfs dfs -rm -r -f $OUTPUT_HDFS

# 3. Ejecutar MapReduce
echo "▶️ Ejecutando MapReduce..."
hadoop jar $JAR \
    -files /home/hadoop/ejercicios/mapper.py,/home/hadoop/ejercicios/reducer.py \
    -mapper "python3 mapper.py" \
    -reducer "python3 reducer.py" \
    -input $INPUT_HDFS \
    -output $OUTPUT_HDFS

# 4. Mostrar resultados
echo "✅ Ejecución completada. Resultados:"
hdfs dfs -cat $OUTPUT_HDFS/part-00000 | head -n 20
