
# Big Data Aplicat - Laboratori

Repositori de laboratoris per al curs de Big Data Aplicat. Inclou entorns Docker per a Hadoop, Spark i altres tecnologies de l'ecosistema Big Data.

* Darrera Modificació: 01/02/2026
* Autor: Francesc Barragán
* Institut Sa Palomera


## Agraiments

Basat en el repositori de Josep Garcia (https://github.com/josepgarcia/BigDataAplicadoLab-2526.git)[https://github.com/josepgarcia/BigDataAplicadoLab-2526.git]

## 📚 Mòduls Disponibles

### [Mòdul 1 - Hadoop Multi-Node](modul1/README.md)

Clúster Hadoop amb 3 nodes (1 master + 2 slaves) per simular un entorn distribuït real.

- Hadoop 3.4.1 amb HDFS i YARN
- Hive 2.3.9 per a consultes SQL
- Replicació factor 3
- Ideal per aprendre sobre distribució de dades i tolerància a fallades

**[📖 Veure documentació completa →](modul1/README.md)**

### [Mòdul 1 Simple - Hadoop Single Node](modul0/README.md)

Versió simplificada de Hadoop en un sol node per a desenvolupament i proves ràpides.

- Hadoop 3.4.1 en mode pseudo-distribuït
- HDFS amb replicació factor 1
- Carpeta compartida amb exemples MapReduce
- Menor consum de recursos

**[📖 Veure documentació completa →](modul0/README.md)**

### [Mòdul 2 - Hadoop & Spark Single Node](modul2/README.md)

Entorn optimitzat amb Hadoop i Apache Spark en un sol node.

- Hadoop 3.4.1 (HDFS + YARN)
- Apache Spark 3.5.0 (Master + Worker)
- PySpark amb Jupyter Notebook
- Optimitzat per a baix consum de recursos
- Connexió amb HDFS

**[📖 Veure documentació completa →](modul2/README.md)**

## 🚀 Inici Ràpid

```bash
# Clonar el repositori
git clone https://github.com/fbarraga/CEIABD.git
cd ./CEIABD/M5075/NF2_Ecosistema_Hadoop/Laboratoris

# Si tens descàrregues prèvies en carpetes locals, migrar-les al sistema centralitzat
chmod +x ./migrate-downloads.sh
./migrate-downloads.sh

# Triar un mòdul i seguir el seu README
cd modul2  # o modul0, modulo1
make download-cache  # Descarrega a /downloads (compartit per tots els mòduls)
make build
make up
```

## 📦 Sistema Centralitzat de Downloads

Tots els mòduls comparteixen un únic directori `/downloads` a l'arrel del projecte. Això significa que:

- **Una sola descàrrega**: Si un mòdul descarrega un fitxer, tots els altres mòduls poden utilitzar-lo
- **Estalvi d'espai**: No hi ha duplicació de fitxers entre mòduls
- **Més ràpid**: Els Makefiles verifiquen si el fitxer ja existeix abans de descarregar

### Migració des del Sistema Anterior

Si tens descàrregues prèvies en carpetes locals (`modulo1/Base/downloads`, etc.), executa l'script de migració:

```bash
./migrate-downloads.sh
```

Aquest script mourà tots els fitxers al directori central `/downloads` sense duplicar fitxers existents.

## 📋 Requisits Previs

- **Docker** i **Docker Compose** instal·lats
- **Make** instal·lat
- **wget** disponible al sistema
  - macOS: `brew install wget`
  - Linux: generalment preinstal·lat
  - Windows: veure secció WSL2 a continuació

## 🪟 Ús a Windows 11

### Opció Recomanada: WSL2 + Docker Desktop

Per executar aquests mòduls a Windows 11, es recomana usar **WSL2 (Windows Subsystem for Linux 2)** amb Docker Desktop:

#### 1. Instal·lar WSL2

```powershell
# A PowerShell com a administrador
wsl --install
```

Això instal·larà Ubuntu per defecte. Reinicia l'equip si és necessari.

#### 1.1 Instal·lar WSL2

```powershell
# A PowerShell com a administrador
wsl.exe --install Ubuntu-22.04
```

#### 2. Instal·lar Docker Desktop

- Descarrega des de [docker.com](https://www.docker.com/products/docker-desktop/)
- Durant la instal·lació, assegura't d'habilitar la integració amb WSL2
- A Docker Desktop → Settings → Resources → WSL Integration, activa la teva distribució Ubuntu

#### 3. Configurar l'entorn a WSL2

```bash
# Obrir terminal WSL (Ubuntu)
# Instal·lar dependències
sudo apt update
sudo apt install make wget git

# Clonar el repositori
cd ~
git clone https://github.com/fbarraga/CEIABD.git
cd BigDataAplicadoLab-2526
```

#### 4. Executar comandes normalment

```bash
cd modulo1simple  # o el mòdul que prefereixis
make download-cache
make build
make up
make test  # si està disponible
```

### ⚠️ Consideracions Importants per a Windows

- **Finals de línia**: Git a Windows pot convertir LF a CRLF. Configura Git per mantenir LF:

  ```bash
  git config --global core.autocrlf input
  ```

- **Rendiment**: Treballa sempre dins del sistema de fitxers de WSL2 (`/home/usuari/...`) en lloc de `/mnt/c/...` per a millor rendiment.

- **Accés a interfícies web**: Les URLs funcionen igual des de Windows (localhost)

- **PowerShell vs WSL**: Executa les comandes `make` des del terminal WSL (Ubuntu), no des de PowerShell o CMD.

### Alternativa: Git Bash (No Recomanat)

Si prefereixes no usar WSL2, pots intentar amb Git Bash, però poden sorgir problemes de compatibilitat amb scripts bash i permisos. WSL2 és l'opció més robusta i compatible.

## 🛠️ Comandes Comunes

Cada mòdul inclou un `Makefile` amb comandes útils:

```bash
make help          # Veure totes les comandes disponibles
make download-cache# Descarregar paquets a la memòria cau local
make build         # Construir imatges Docker
make up            # Aixecar serveis
make down          # Aturar serveis
make clean         # Netejar contenidors i volums
make logs          # Veure logs
make shell-*       # Accedir a la shell d'un contenidor
```

## 📂 Estructura del Repositori

```
BigDataAplicadoLab-2526/
├── downloads/            # Memòria cau centralitzada de descàrregues (compartida per tots els mòduls)
├── modulo0/        # Hadoop single-node
│   ├── README.md
│   ├── Makefile
│   ├── docker-compose.yml
│   ├── Base/
│   └── ejercicios/       # Scripts i dades d'exemple
├── modul1/              # Hadoop multi-node (3 nodes)
│   ├── README.md
│   ├── Makefile
│   ├── docker-compose.yml
│   └── Base/
├── modul2/              # Hadoop & Spark Single Node (Optimitzat)
│   ├── README.md
│   ├── Makefile
│   ├── docker-compose.yml
│   ├── Base/
│   ├── ejercicios/
│   ├── data/
│   └── notebooks/
├── migrate-downloads.sh   # Script de migració al sistema centralitzat
└── README.md             # Aquest fitxer
```

## 🔗 Enllaços Útils

- [Documentació Apache Hadoop](https://hadoop.apache.org/docs/stable/)
- [Documentació Apache Spark](https://spark.apache.org/docs/latest/)
- [Documentació Docker](https://docs.docker.com/)
- [Documentació WSL2](https://learn.microsoft.com/en-us/windows/wsl/)


## 📄 Llicència

Aquest projecte és d'ús educatiu per al curs de Big Data Aplicat.
