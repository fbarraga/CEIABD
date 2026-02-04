# Mòdul 2 - Hadoop & Spark Single Node

## Descripció

Aquest mòdul proporciona un entorn Hadoop i Spark simplificat d'un sol node (pseudo-distribuït) per a desenvolupament i proves ràpides.

## Característiques

- Hadoop 3.4.1 en mode pseudo-distribuït (single-node)
- Apache Spark 3.5.0 (Master + Worker)
- HDFS amb replicació factor 1
- YARN per a execució de treballs MapReduce
- Jupyter Notebook amb PySpark preconfigurat
- Carpeta compartida `ejercicios/` per a scripts i dades
- Persistència de dades a `data/` i notebooks a `notebooks/`
- Scripts de prova MapReduce inclosos

## Requisits Previs

- Docker i Docker Compose instal·lats
- Make instal·lat
- `wget` disponible al sistema (macOS: `brew install wget`)

> **Nota per a Windows 11**: Veure la [guia de configuració WSL2](../README.md#-ús-a-windows-11) al README principal.

## Instal·lació Ràpida

```bash
# 1. Descarregar paquets (Hadoop + Hive) a la memòria cau local
make download-cache

# 2. Construir la imatge Docker
make build

# 3. Aixecar el contenidor
make up
```

## Comandes Disponibles

```bash
make help          # Veure totes les comandes disponibles
make download-cache# Descarregar paquets a la memòria cau local
make build         # Construir la imatge Docker
make up            # Aixecar el clúster Hadoop (1 node)
make clean         # Aturar i netejar contenidors i volums
make deep-clean    # Neteja profunda (inclou imatges i memòria cau)
make shell-master  # Accedir a la shell del contenidor com a usuari hadoop
make test          # Executar test MapReduce (word count)
```

## Interfícies Web

- **NameNode UI**: http://localhost:9870
- **ResourceManager UI**: http://localhost:8088
- **Spark Master UI**: http://localhost:8080
- **Spark Application UI**: http://localhost:4040, http://localhost:4041, http://localhost:4042
- **Jupyter Notebook**: http://localhost:8888
- **Spark History Server**: http://localhost:18080

## Carpeta Compartida `ejercicios/`

La carpeta `ejercicios/` està muntada al contenidor a `/home/hadoop/ejercicios`, permetent compartir fitxers entre el host i el contenidor.

Contingut inclòs:
- `mapper.py` - Script mapper per a MapReduce
- `reducer.py` - Script reducer per a MapReduce
- `quijote.txt` - Dades d'exemple (El Quixot)
- `test_docker.sh` - Script per executar test des del host
- `test_bash.sh` - Script per executar test des de dins del contenidor

## Executar Test MapReduce

### Des del host (recomanat)

```bash
make test
```

Aquesta comanda executa `test_docker.sh`, que:
1. Puja `quijote.txt` a HDFS
2. Executa un treball MapReduce de comptatge de paraules
3. Mostra els primers 20 resultats

### Des de dins del contenidor

```bash
# Accedir al contenidor
make shell-master

# Executar el test
cd ejercicios
bash test_bash.sh
```

## Exemple d'Ús d'HDFS

```bash
# Accedir al contenidor
make shell-master

# Llistar fitxers a HDFS
hdfs dfs -ls /

# Crear directori
hdfs dfs -mkdir /user/hadoop/dades

# Pujar fitxer
hdfs dfs -put /home/hadoop/ejercicios/quijote.txt /user/hadoop/dades/

# Veure contingut
hdfs dfs -cat /user/hadoop/dades/quijote.txt | head -n 10
```

## Exemple d'Ús de Spark

### PySpark Shell

```bash
# Accedir al contenidor
make shell-master

# Iniciar PySpark
pyspark
```

### Jupyter Notebook

1. Aixecar l'entorn (`make up`).
2. Obrir http://localhost:8888 al navegador.
3. Crear un nou notebook Python 3.
4. Provar el següent codi:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("Test").getOrCreate()
df = spark.createDataFrame([(1, "a"), (2, "b")], ["id", "val"])
df.show()
```

## Resolució de Problemes

### El contenidor no s'inicia

```bash
# Veure logs del contenidor
docker logs hadoop-master-simple

# Verificar estat
docker ps -a | grep hadoop-master-simple
```

### Error de permisos a HDFS

Les comandes HDFS s'han d'executar com a usuari `hadoop`. Si fas servir `docker exec`, afegeix `-u hadoop`:

```bash
docker exec -u hadoop hadoop-master-simple hdfs dfs -ls /
```

### Netejar i reiniciar

```bash
# Neteja completa
make clean

# Reconstruir i aixecar
make build
make up
```

## Optimitzacions per a Màquines Menys Potents

Aquest mòdul està optimitzat per funcionar en màquines amb recursos limitats. Les següents optimitzacions s'han aplicat:

### Límits de Recursos Docker
- **Memòria màxima**: 2GB (límit) / 1GB (reservat)
- **CPU màxima**: 1.5 cores (límit) / 0.5 cores (reservat)

### Optimitzacions de Hadoop
- **NameNode**: Heap reduït a 512MB (per defecte ~1GB)
- **DataNode**: Heap reduït a 256MB
- **ResourceManager**: Heap reduït a 512MB
- **NodeManager**: Heap reduït a 256MB
- **JobHistoryServer**: Heap reduït a 256MB
- **Garbage Collector**: G1GC optimitzat per a baix consum

### Optimitzacions de YARN
- **Memòria total disponible**: 1GB (per defecte 8GB)
- **Memòria mínima per contenidor**: 128MB
- **Memòria màxima per contenidor**: 512MB
- **vCores disponibles**: 1 (en lloc de cores físics)
- **Interval de monitoratge**: 3 segons (overhead reduït)

### Optimitzacions de MapReduce
- **Memòria per tasca Map**: 256MB (per defecte 1024MB)
- **Memòria per tasca Reduce**: 256MB (per defecte 1024MB)
- **Memòria ApplicationMaster**: 512MB
- **Map tasks per defecte**: 2
- **Reduce tasks per defecte**: 1

### Optimitzacions de Hive
- **HiveServer2 heap**: 512MB
- **Hive Metastore heap**: 256MB
- **Reducers màxims**: 2 (per defecte 1009)
- **Paral·lelisme deshabilitat**: Per reduir l'ús de recursos
- **Execució vectoritzada**: Habilitada per a millor rendiment amb menys recursos

### Optimitzacions de Spark
- **Driver Memory**: 512MB (per defecte 1GB)
- **Executor Memory**: 512MB (per defecte 1GB)
- **Executor Cores**: 1 (per defecte tots els disponibles)
- **Worker Memory**: 1GB
- **Daemon Memory**: 512MB

## Diferències amb `modulo1`

- **Nodes**: 1 node (master) vs 3 nodes (master + 2 slaves)
- **Replicació**: Factor 1 vs Factor 3
- **Recursos**: Menor consum de CPU i memòria (optimitzat per a màquines menys potents)
- **Ús**: Desenvolupament i proves vs Simulació de clúster

## Estructura del Projecte

```
modulo2/
├── Makefile                        # Comandes disponibles
├── docker-compose.yml              # Configuració del servei
├── Base/
│   ├── Dockerfile                  # Imatge Docker
│   ├── download-cache.sh           # Script de descàrrega
│   ├── start-hadoop.sh             # Script d'inici
│   ├── config/                     # Configuracions Hadoop i Spark
│   └── (descàrregues centralitzades a /downloads a l'arrel del projecte)
├── ejercicios/                     # Carpeta compartida
│   ├── mapper.py                   # Mapper MapReduce
│   ├── reducer.py                  # Reducer MapReduce
│   ├── quijote.txt                 # Dades d'exemple
│   ├── test_docker.sh              # Test des del host
│   └── test_bash.sh                # Test des del contenidor
├── data/                           # Persistència de dades HDFS/Local
└── notebooks/                      # Persistència de Jupyter Notebooks
```

