# Mòdul 1 - Hadoop Multi-Node

## Descripció

Aquest mòdul proporciona un clúster Hadoop complet amb 3 nodes (1 master + 3 slaves) per simular un entorn distribuït real.

## Característiques

- Hadoop 3.4.1 amb HDFS i YARN
- Hive 2.3.9 per a consultes SQL sobre HDFS
- Clúster de 3 nodes (master + 3 slaves)
- HDFS amb replicació factor 3
- Tolerància a fallades i distribució de dades
- Ideal per aprendre sobre arquitectures distribuïdes

## Requisits Previs

- Docker i Docker Compose instal·lats
- Make instal·lat
- `wget` disponible al sistema (macOS: `brew install wget`)

> **Nota per a Windows 11**: Veure la [guia de configuració WSL2](../README.md#-ús-a-windows-11) al README principal.

## Instal·lació Ràpida

```bash
# 1. Descarregar paquets (Hadoop + Hive) a la memòria cau local
make download-cache

# 2. Construir les imatges Docker
make build

# 3. Aixecar el clúster
make up
```

## Comandes Disponibles

```bash
make help          # Veure totes les comandes disponibles
make download-cache# Descarregar paquets a la memòria cau local
make build         # Construir les imatges Docker
make up            # Aixecar el clúster Hadoop (3 nodes)
make clean         # Aturar i netejar contenidors i volums
make deep-clean    # Neteja profunda (inclou imatges i memòria cau)
make shell-master  # Accedir a la shell del master com a usuari hadoop
make shell-slave1  # Accedir a la shell del slave1 com a usuari hadoop
make shell-slave2  # Accedir a la shell del slave2 com a usuari hadoop
```

## Interfícies Web

- **NameNode UI**: http://localhost:9870
- **ResourceManager UI**: http://localhost:8088
- **MapReduce Job History Server**: http://localhost:19888
- **HiveServer2 Web UI**: http://localhost:10002

## Arquitectura del Clúster

```
┌─────────────────┐
│  hadoop-master  │  NameNode, ResourceManager, HiveServer2
│   (master)      │  Ports: 9870, 8088, 19888, 10000, 10002, 9083
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│slave1 │ │slave2 │  DataNode, NodeManager
│       │ │       │  Ports: 8042, 9864
└───────┘ └───────┘
```

## Exemple d'Ús d'HDFS

```bash
# Accedir al master
make shell-master

# Llistar fitxers a HDFS
hdfs dfs -ls /

# Crear directori
hdfs dfs -mkdir -p /user/hadoop/dades

# Pujar fitxer (es replicarà en 3 nodes)
echo "test data" > /tmp/test.txt
hdfs dfs -put /tmp/test.txt /user/hadoop/dades/

# Verificar replicació
hdfs fsck /user/hadoop/dades/test.txt -files -blocks -locations

# Veure contingut
hdfs dfs -cat /user/hadoop/dades/test.txt
```

## Exemple d'Ús de Hive

```bash
# Accedir al master
make shell-master

# Iniciar Beeline (client Hive)
beeline -u jdbc:hive2://localhost:10000

# Crear taula
CREATE TABLE IF NOT EXISTS empleats (
    id INT,
    nom STRING,
    salari DOUBLE
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

# Carregar dades
LOAD DATA LOCAL INPATH '/tmp/empleats.csv' INTO TABLE empleats;

# Consultar
SELECT * FROM empleats WHERE salari > 50000;
```

## Directori /tmp/hadoop-hadoop

El sistema HDFS s'emmagatzema a `/tmp/hadoop-hadoop`, però forma part d'un volum (tal com es pot veure a `docker-compose.yml`), per la qual cosa en reiniciar el contenidor es munta de nou el volum i les dades no desapareixen.

Veure també:
- Script d'arrencada que utilitza aquesta ruta: `start-hadoop.sh`
- Imatge que l'exposa al contenidor: `Dockerfile`

En fer un `make clean` sí que s'esborra el volum.

## Resolució de Problemes

### Problema d'escriptura WebHDFS

En intentar crear un directori es produïa un error:
```
Permission denied: user=dr.who, access=WRITE, inode="/":hadoop:supergroup:drwxr-xr-x
```

**Solució**: Ja està configurat a `core-site.xml`:

```xml
<property>
  <name>hadoop.http.staticuser.user</name>
  <value>hadoop</value>
</property>
```

Verificar que la propietat estigui activa:

```bash
# Hauria de retornar "hadoop"
hdfs getconf -confKey hadoop.http.staticuser.user

# També hauria de funcionar a través de WebHDFS
curl -i -X PUT "http://master:9870/webhdfs/v1/tmp/prova_webhdfs?op=MKDIRS"
curl -i -X PUT "http://master:9870/webhdfs/v1/tmp/prova_webhdfs2?op=MKDIRS&user.name=hadoop"
```

### "replication = 3" però només hi ha rèpliques en 2 slaves

**Causa**: El master no està executant un DataNode (el master no forma part dels datanodes per defecte).

**Comprovacions ràpides** (executar com a usuari hadoop al master):

```bash
# Veure estat del clúster
hdfs dfsadmin -report

# Verificar blocs i ubicacions
hdfs fsck /test.txt -files -blocks -locations

# Veure si DataNode s'està executant al master
jps
```

**Accions comunes**:

- Si falta el DataNode al master: afegir el seu hostname a `$HADOOP_HOME/etc/hadoop/workers` i arrencar datanode:
  ```bash
  sudo -u hadoop $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode
  ```

- Refrescar nodes si fas servir exclude/include:
  ```bash
  sudo -u hadoop $HADOOP_HOME/bin/hdfs dfsadmin -refreshNodes
  ```

- Forçar i esperar replicació:
  ```bash
  sudo -u hadoop $HADOOP_HOME/bin/hdfs dfs -setrep -w 3 /test.txt
  ```

### El clúster no s'inicia

```bash
# Veure logs de cada contenidor
docker logs hadoop-master
docker logs hadoop-slave1
docker logs hadoop-slave2

# Verificar estat
docker ps -a | grep hadoop
```

### Error de permisos a HDFS

Les comandes HDFS s'han d'executar com a usuari `hadoop`. Si fas servir `docker exec`, afegeix `-u hadoop`:

```bash
docker exec -u hadoop hadoop-master hdfs dfs -ls /

### Error de hive

# Esborra la base de dades Derby existent
rm -rf ~/metastore_db

# Ara inicialitza de nou
schematool -dbType derby -initSchema

# Arrancar el metastore
hive --service metastore &
```

## Diferències amb `modul0`

- **Nodes**: 4 nodes (master + 3 slaves) vs 1 node
- **Replicació**: Factor 3 vs Factor 1
- **Recursos**: Major consum de CPU i memòria
- **Ús**: Simulació de clúster real vs Desenvolupament i proves ràpides
- **Tolerància a fallades**: Sí (pot perdre 1-2 nodes) vs No

## Estructura del Projecte

```
modul1/
├── Makefile                        # Comandes disponibles
├── docker-compose.yml              # Configuració de serveis
└── Base/
    ├── Dockerfile                  # Imatge Docker
    ├── download-cache.sh           # Script de descàrrega
    ├── start-hadoop.sh             # Script d'inici
    ├── config/                     # Configuracions Hadoop/Hive
    │   ├── core-site.xml
    │   ├── hdfs-site.xml
    │   ├── yarn-site.xml
    │   ├── mapred-site.xml
    │   ├── hive-site.xml
    │   ├── workers
    │   └── ...
    └── (descàrregues centralitzades a /downloads a l'arrel del projecte)
```
