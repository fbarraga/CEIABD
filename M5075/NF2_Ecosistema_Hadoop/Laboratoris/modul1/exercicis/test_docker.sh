#!/bin/bash

CONTAINER="hadoop-master-simple"

echo "🚀 Lanzando test desde el HOST..."
docker exec -u hadoop $CONTAINER bash /home/hadoop/ejercicios/test_bash.sh