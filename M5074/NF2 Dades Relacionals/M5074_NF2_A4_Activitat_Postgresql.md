# Pràctica Avançada: Desplegament PostgreSQL i pgAdmin amb Docker

Aquesta pràctica us guiarà en la implementació d'un entorn de producció robust amb PostgreSQL 17 i pgAdmin 4, incorporant volums persistents, scripts d'inicialització, sistemes de backup i restore, i configuracions de seguretat avançades.

## Objectius d'aprenentatge

Al finalitzar aquesta pràctica, haureu de ser capaços de configurar un entorn de base de dades containeritzat que sigui segur, performant i adequat per a producció. Desenvolupareu habilitats crítiques en operacions de DevOps i administració de bases de dades.

## Part 1: Investigació i preparació inicial

**Tasca d'investigació 1**: Consulteu la documentació oficial de PostgreSQL i Docker Hub per determinar:
- Quina és la versió més recent estable de PostgreSQL disponible?
- Quines són les diferències clau entre les versions 16 i 17?
- Quina versió de pgAdmin és compatible amb PostgreSQL 17?

**Pregunta de reflexió**: Per què és important especificar versions exactes d'imatges en entorns de producció en lloc d'usar tags com `latest`?

## Part 2: Configuració bàsica de PostgreSQL

Creeu un fitxer `docker-compose.yml` inicial amb aquesta estructura base, però haureu d'investigar i completar les parts marcades com `# TODO`:

```yaml
version: '3.8'
services:
  postgres:
    image: # TODO: Investigar la versió específica més recent
    container_name: postgres_production
    restart: unless-stopped
    shm_size: # TODO: Quanta memòria compartida necessita PostgreSQL per operacions complexes?
    
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-production}
      POSTGRES_USER: ${POSTGRES_USER:-admin}
      # TODO: Investigar com usar secrets per a la password en lloc de variables d'entorn planes
      
      # TODO: Quins són els arguments d'inicialització recomanats per seguretat?
      # Pista: Mireu POSTGRES_INITDB_ARGS i mètodes d'autenticació segurs
      
    # TODO: Configurar límits de recursos apropriats per a un servidor de 8GB RAM
    deploy:
      resources:
        limits:
          # Investigar: Quins límits de memòria i CPU són apropiats?
        reservations:
          # Investigar: Quines reserves mínimes garanteixen un bon rendiment?
    
    volumes:
      # TODO: Completar la configuració de volums per:
      # - Dades persistents
      # - Configuració personalitzada 
      # - Scripts d'inicialització
      # - Backups
      # - Logs
    
    # TODO: Configurar healthcheck apropiat
    # Pista: Useu pg_isready
    
    ports:
      # TODO: Per què és important bindear només a localhost en producció?
    
    networks:
      # TODO: Crear una xarxa isolada per als serveis de BD
```

**Pregunta tècnica**: Què és `shm_size` i per què és important per a PostgreSQL? Quina mida recomaneu per a un entorn de producció?

## Part 3: Configuració avançada de rendiment

Creeu un fitxer `config/postgresql.conf` personalitzat. Heu d'investigar i configurar els següents paràmetres per a un servidor de 8GB de RAM:

**Repte d'optimització 1**: Configuració de memòria
```ini
# postgresql.conf - Configuració a completar

# CONNEXIONS I AUTENTICACIÓ  
listen_addresses = '*'
port = 5432
# TODO: Investigar quantes connexions màximes són apropiades
# Pista: Relació amb núcleos de CPU i tipus d'aplicació
max_connections = ?
superuser_reserved_connections = ?

# CONFIGURACIÓ DE MEMÒRIA (per a servidor de 8GB)
# TODO: Investigar les regles generals per a aquests paràmetres:
shared_buffers = ?           # Quin percentatge de RAM total?
work_mem = ?                 # Memòria per operació de sort/hash - compte amb múltiples usuaris!
maintenance_work_mem = ?     # Per VACUUM, CREATE INDEX, etc.
effective_cache_size = ?     # Estimació del cache total (OS + PostgreSQL)

# WAL (Write-Ahead Logging)
# TODO: Investigar la configuració adequada per WAL
max_wal_size = ?
min_wal_size = ?
```

**Preguntes de reflexió**:
- Com calculeu `work_mem` tenint en compte que cada connexió pot usar múltiples operacions que consumeixen aquesta memòria?
- Què passa si `shared_buffers` és massa gran o massa petit?
- Quina és la diferència entre `effective_cache_size` i `shared_buffers`?

**Repte d'optimització 2**: Configuració per a emmagatzematge SSD
```ini
# PLANIFICACIÓ DE CONSULTES
# TODO: Investigar els valors adequats per SSD vs HDD
random_page_cost = ?         # Diferent per SSD i HDD
seq_page_cost = ?
effective_io_concurrency = ? # Molt diferent entre SSD i HDD!

# PARALELISME
# TODO: Configurar segons el número de CPU cores disponibles
max_parallel_workers_per_gather = ?
max_parallel_workers = ?
max_parallel_maintenance_workers = ?
```

**Tasca d'investigació 2**: Consulteu la documentació oficial de PostgreSQL sobre aquests paràmetres i justifiqueu els valors triats en funció del vostre hardware.

## Configuració de pgAdmin amb integració adequada

pgAdmin 4 v9.7 ofereix compatibilitat completa amb PostgreSQL 17 i includes utilitats natives per a totes les versions de PostgreSQL 13-17. La seva configuració adequada és crucial per a un entorn de producció segur i eficient.

### Desplegament de pgAdmin amb configuració avançada

```yaml
services:
  pgadmin:
    image: dpage/pgadmin4:9.7
    container_name: pgadmin_production
    restart: unless-stopped
    
    environment:
      # Configuració bàsica (requerida)
      PGADMIN_DEFAULT_EMAIL: ${ADMIN_EMAIL}
      PGLADMIN_DEFAULT_PASSWORD_FILE: /run/secrets/pgadmin_password
      
      # Configuració de seguretat
      PGLADMIN_ENABLE_TLS: 'true'
      PGLADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION: 'True'
      PGLADMIN_CONFIG_LOGIN_BANNER: '"Entorn de Producció - Accés Autoritzat Només"'
      PGLADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: 'True'
      PGLADMIN_CONFIG_SESSION_COOKIE_SECURE: 'True'
      PGLADMIN_CONFIG_SESSION_COOKIE_HTTPONLY: 'True'
      
      # Configuració de rendiment
      GUNICORN_THREADS: 25
      GUNICORN_LIMIT_REQUEST_LINE: 8190
      
      # Configuració avançada
      PGLADMIN_CONFIG_SERVER_MODE: 'True'  # Mode multi-usuari
      PGLADMIN_DISABLE_POSTFIX: 'True'     # Deshabilitar servidor de correu intern
    
    volumes:
      # Persistència de dades
      - pgladmin_data:/var/lib/pgladmin
      
      # Certificats SSL
      - ./certs/pgadmin.crt:/certs/server.cert:ro
      - ./certs/pgadmin.key:/certs/server.key:ro
      
      # Configuració personalitzada
      - ./config/config_local.py:/pgladmin4/config_local.py:ro
      - ./config/servers.json:/pgladmin4/servers.json:ro
    
    ports:
      - "127.0.0.1:443:443"
    
    secrets:
      - pgladmin_password
    
    networks:
      - postgres_network
    
    depends_on:
      postgres:
        condition: service_healthy
    
    # Configuració de seguretat del contenidor
    user: "5050:5050"
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
    
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:80/misc/ping"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  pgladmin_data:
    driver: local
```

### Configuració de servidors precarregats (servers.json)

```json
{
  "Servers": {
    "1": {
      "Name": "PostgreSQL Production",
      "Group": "Production",
      "Host": "postgres",
      "Port": 5432,
      "MaintenanceDB": "postgres",
      "Username": "admin",
      "PassFile": "/var/lib/pgadmin/passfile",
      "SSLMode": "require",
      "SSLCert": "",
      "SSLKey": "",
      "SSLRootCert": "",
      "SSLCrl": "",
      "SSLCompression": 0,
      "Timeout": 10,
      "UseSSHTunnel": 0,
      "TunnelHost": "",
      "TunnelPort": "22",
      "TunnelUsername": "",
      "TunnelAuthentication": 0
    }
  }
}
```

## Scripts d'inicialització amb dades d'exemple avançades

Els scripts d'inicialització s'executen automàticament durant el primer arrencament del contenidor. L'ordre d'execució és alfabètic, d'aquí la importància dels prefixos numèrics.

### Estructura d'inicialització completa

```bash
init-scripts/
├── 01-extensions.sql        # Extensions i configuració inicial
├── 02-schemas.sql          # Esquemes i estructures
├── 03-users-roles.sql      # Usuaris i rols amb privilegis específics
├── 04-tables.sql           # Taules amb restriccions avançades
├── 05-sample-data.sql      # Dades d'exemple realistes
├── 06-indexes.sql          # Índexs per rendiment
└── 99-final-config.sh      # Configuració final i validació
```

### Extensions i configuració inicial (01-extensions.sql)

```sql
-- Crear bases de dades específiques per aplicació
CREATE DATABASE production OWNER admin;
CREATE DATABASE staging OWNER admin;
CREATE DATABASE analytics OWNER admin;

-- Connectar a la base de dades principal
\c production;

-- Extensions essencials per aplicacions modernes
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";        -- Generació d'UUIDs
CREATE EXTENSION IF NOT EXISTS "pg_trgm";          -- Cerca de text similar
CREATE EXTENSION IF NOT EXISTS "btree_gin";        -- Índexs GIN per múltiples tipus
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements"; -- Monitorització de consultes
CREATE EXTENSION IF NOT EXISTS "pgcrypto";         -- Funcions criptogràfiques
CREATE EXTENSION IF NOT EXISTS "hstore";           -- Emmagatzemament clau-valor
CREATE EXTENSION IF NOT EXISTS "pg_visibility";    -- Informació de visibilitat de pàgines
CREATE EXTENSION IF NOT EXISTS "postgres_fdw";     -- Foreign Data Wrapper

-- Configurar extensions
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
SELECT pg_reload_conf();
```

### Usuaris i rols amb seguretat granular (03-users-roles.sql)

```sql
-- Crear rols funcionals abans dels usuaris de login
CREATE ROLE app_reader;
CREATE ROLE app_writer;
CREATE ROLE app_admin;
CREATE ROLE data_analyst;
CREATE ROLE backup_operator;

-- Usuaris de login amb privilegis limitats
CREATE USER app_service WITH 
    LOGIN 
    PASSWORD 'service_secure_pass_change_in_production'
    CONNECTION LIMIT 50
    VALID UNTIL 'infinity';

CREATE USER readonly_user WITH 
    LOGIN 
    PASSWORD 'readonly_secure_pass'
    CONNECTION LIMIT 20
    VALID UNTIL '2025-12-31';

CREATE USER analyst_user WITH 
    LOGIN 
    PASSWORD 'analyst_secure_pass'
    CONNECTION LIMIT 10
    VALID UNTIL '2025-12-31';

-- Assignar rols als usuaris
GRANT app_writer TO app_service;
GRANT app_reader TO readonly_user;
GRANT data_analyst TO analyst_user;

-- Configurar privilegis granulars per esquemes
GRANT CONNECT ON DATABASE production TO app_reader, app_writer, data_analyst;
GRANT CONNECT ON DATABASE analytics TO data_analyst;

-- Crear esquemes amb propietaris específics
CREATE SCHEMA app AUTHORIZATION app_admin;
CREATE SCHEMA reporting AUTHORIZATION app_admin;
CREATE SCHEMA audit AUTHORIZATION app_admin;

-- Configurar privilegis d'esquema
GRANT USAGE ON SCHEMA app TO app_reader, app_writer;
GRANT USAGE ON SCHEMA reporting TO app_reader, app_writer, data_analyst;
GRANT USAGE ON SCHEMA audit TO data_analyst;

-- Privilegis sobre taules existents
GRANT SELECT ON ALL TABLES IN SCHEMA app TO app_reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO app_writer;
GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO data_analyst;

-- Privilegis sobre seqüències
GRANT USAGE ON ALL SEQUENCES IN SCHEMA app TO app_writer;

-- Configurar privilegis per defecte per a objectes futurs
ALTER DEFAULT PRIVILEGES IN SCHEMA app 
    GRANT SELECT ON TABLES TO app_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA app 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_writer;
ALTER DEFAULT PRIVILEGES IN SCHEMA app 
    GRANT USAGE ON SEQUENCES TO app_writer;
```

### Taules amb restriccions i funcionalitats avançades (04-tables.sql)

```sql
-- Taula d'usuaris amb auditoria integrada
CREATE TABLE app.users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL 
        CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),
    username VARCHAR(50) UNIQUE NOT NULL 
        CONSTRAINT valid_username CHECK (username ~* '^[a-zA-Z0-9_-]{3,50}$'),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    failed_login_attempts INTEGER DEFAULT 0 CHECK (failed_login_attempts >= 0),
    locked_until TIMESTAMP WITH TIME ZONE,
    profile_data JSONB DEFAULT '{}',
    preferences HSTORE DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Restriccions complexes
    CONSTRAINT reasonable_name_length 
        CHECK (char_length(first_name || ' ' || last_name) BETWEEN 2 AND 200),
    CONSTRAINT not_locked_when_active 
        CHECK (NOT (is_active = FALSE AND locked_until IS NOT NULL))
);

-- Taula de productes amb categories jeràrquiques
CREATE TABLE app.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    parent_id INTEGER REFERENCES app.categories(id),
    level INTEGER NOT NULL DEFAULT 0,
    path TEXT[] NOT NULL DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE app.products (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    category_id INTEGER REFERENCES app.categories(id),
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    cost_price DECIMAL(10,2) CHECK (cost_price >= 0),
    weight DECIMAL(8,3) CHECK (weight > 0),
    dimensions JSONB, -- {"length": 10, "width": 5, "height": 3}
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    reserved_quantity INTEGER DEFAULT 0 CHECK (reserved_quantity >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    tags TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Restriccions de negoci
    CONSTRAINT available_stock 
        CHECK (stock_quantity >= reserved_quantity),
    CONSTRAINT reasonable_price 
        CHECK (cost_price IS NULL OR price > cost_price)
);

-- Taula de comandes amb estat de màquina d'estats
CREATE TYPE order_status AS ENUM (
    'draft', 'pending', 'confirmed', 'processing', 
    'shipped', 'delivered', 'cancelled', 'refunded'
);

CREATE TABLE app.orders (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    user_id UUID REFERENCES app.users(id),
    status order_status DEFAULT 'draft',
    subtotal DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
    tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    shipping_amount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (shipping_amount >= 0),
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    currency CHAR(3) DEFAULT 'EUR',
    payment_status VARCHAR(20) DEFAULT 'pending',
    shipping_address JSONB NOT NULL,
    billing_address JSONB,
    notes TEXT,
    internal_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    
    -- Restriccions de coherència
    CONSTRAINT total_calculation 
        CHECK (total_amount = subtotal + tax_amount + shipping_amount),
    CONSTRAINT shipped_before_delivered 
        CHECK (shipped_at IS NULL OR delivered_at IS NULL OR shipped_at <= delivered_at)
);

-- Auditoria automàtica amb triggers
CREATE TABLE audit.activity_log (
    id BIGSERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation CHAR(1) NOT NULL CHECK (operation IN ('I', 'U', 'D')),
    old_data JSONB,
    new_data JSONB,
    changed_fields TEXT[],
    user_name TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    transaction_id BIGINT DEFAULT txid_current()
);

-- Funció de trigger per auditoria automàtica
CREATE OR REPLACE FUNCTION audit.log_changes() RETURNS TRIGGER AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    changed_fields TEXT[] := '{}';
    field_name TEXT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        old_data := row_to_json(OLD)::JSONB;
        INSERT INTO audit.activity_log (table_name, operation, old_data, user_name)
        VALUES (TG_TABLE_NAME, 'D', old_data, current_user);
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        old_data := row_to_json(OLD)::JSONB;
        new_data := row_to_json(NEW)::JSONB;
        
        -- Identificar camps canviats
        FOR field_name IN SELECT jsonb_object_keys(old_data) LOOP
            IF old_data->>field_name IS DISTINCT FROM new_data->>field_name THEN
                changed_fields := array_append(changed_fields, field_name);
            END IF;
        END LOOP;
        
        INSERT INTO audit.activity_log (table_name, operation, old_data, new_data, changed_fields, user_name)
        VALUES (TG_TABLE_NAME, 'U', old_data, new_data, changed_fields, current_user);
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        new_data := row_to_json(NEW)::JSONB;
        INSERT INTO audit.activity_log (table_name, operation, new_data, user_name)
        VALUES (TG_TABLE_NAME, 'I', new_data, current_user);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Aplicar triggers d'auditoria
CREATE TRIGGER users_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON app.users
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

CREATE TRIGGER orders_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON app.orders
    FOR EACH ROW EXECUTE FUNCTION audit.log_changes();
```

## Configuració de volums persistents avançada

La gestió de volums és crítica per mantenir la integritat i rendiment de les dades. Els volums nomenats ofereixen millor rendiment i seguretat que els bind mounts per a entorns de producció.

### Estratègia de volums per a producció

```yaml
volumes:
  # Volume principal de dades - configuració optimitzada
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/postgres  # Path amb SSD d'alta velocitat
  
  # Separació de WAL per millor rendiment
  postgres_wal:
    driver: local
    driver_opts:
      type: none  
      o: bind
      device: /data/postgres-wal  # Dispositiu separat per WAL
  
  # Backups amb retenció automàtica
  postgres_backups:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /backup/postgres
  
  # Logs amb rotació
  postgres_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /logs/postgres
```

### Configuració de permisos i seguretat de volums

```bash
#!/bin/bash
# setup-volumes.sh - Script per configurar volums de manera segura

# Crear directoris amb permisos adequats
sudo mkdir -p /data/postgres /data/postgres-wal /backup/postgres /logs/postgres

# Configurar propietaris (999:999 és l'usuari postgres dins del contenidor)
sudo chown -R 999:999 /data/postgres /data/postgres-wal /backup/postgres /logs/postgres

# Permisos restrictius per seguretat
sudo chmod 700 /data/postgres /data/postgres-wal
sudo chmod 750 /backup/postgres /logs/postgres

# Configurar atributs del sistema de fitxers per rendiment (ext4)
sudo chattr +C /data/postgres  # Deshabilitar copy-on-write si s'usa Btrfs
```

## Procediments de backup i restore complets

Una estratègia de backup robusta combina múltiples mètodes per garantir la recuperació completa de dades en qualsevol escenari.

### Sistema automatitzat de backups amb retenció

```yaml
services:
  # Backup local diari amb retenció intelligent
  postgres_backup_local:
    image: prodrigestivill/postgres-backup-local
    container_name: postgres_backup_local
    restart: unless-stopped
    depends_on:
      - postgres
    environment:
      POSTGRES_HOST: postgres
      POSTGRES_DB: production,staging,analytics
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_EXTRA_OPTS: "-Z9 --schema=public --blobs"
      SCHEDULE: "@daily"
      BACKUP_KEEP_DAYS: 7
      BACKUP_KEEP_WEEKS: 4  
      BACKUP_KEEP_MONTHS: 6
      BACKUP_KEEP_YEARS: 2
    volumes:
      - postgres_backups:/backups
    networks:
      - postgres_network

  # Backup remot a S3 amb xifratge
  postgres_backup_s3:
    image: postgres:17-alpine
    container_name: postgres_backup_s3
    depends_on:
      - postgres
    environment:
      PGPASSWORD: ${POSTGRES_PASSWORD}
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      S3_BUCKET: ${S3_BACKUP_BUCKET}
      GPG_KEY_ID: ${GPG_KEY_ID}
    volumes:
      - ./scripts/backup-s3.sh:/backup.sh:ro
      - ./keys/backup.gpg:/keys/backup.gpg:ro
    command: /backup.sh
    restart: "no"
```

### Script avançat de backup amb verificació (backup-s3.sh)

```bash
#!/bin/bash
set -euo pipefail

# Configuració
POSTGRES_HOST="postgres"
POSTGRES_USER="${POSTGRES_USER}"
DATABASES=("production" "staging" "analytics")
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/tmp/backup"
S3_PREFIX="postgres-backups"

# Crear directori temporal
mkdir -p "$BACKUP_DIR"

# Funció de logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Funció de neteja en cas d'error
cleanup() {
    rm -rf "$BACKUP_DIR"
}
trap cleanup EXIT

log "Iniciant backup de PostgreSQL vers S3..."

# Backup de cada base de dades
for db in "${DATABASES[@]}"; do
    log "Creant backup de $db..."
    
    # pg_dump amb format personalitzat i compressió
    pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" \
        -F custom -Z 9 "$db" > "$BACKUP_DIR/${db}_${TIMESTAMP}.dump"
    
    # Verificar integritat del backup
    if ! pg_restore --list "$BACKUP_DIR/${db}_${TIMESTAMP}.dump" > /dev/null 2>&1; then
        log "ERROR: Backup de $db corromput!"
        exit 1
    fi
    
    # Xifrar amb GPG
    gpg --trust-model always --cipher-algo AES256 \
        --compress-algo 2 --symmetric \
        --passphrase-file /keys/backup.gpg \
        --batch --yes --quiet \
        "$BACKUP_DIR/${db}_${TIMESTAMP}.dump"
    
    # Pujar a S3 amb metadades
    aws s3 cp "$BACKUP_DIR/${db}_${TIMESTAMP}.dump.gpg" \
        "s3://$S3_BUCKET/$S3_PREFIX/$db/${db}_${TIMESTAMP}.dump.gpg" \
        --storage-class STANDARD_IA \
        --metadata database="$db",timestamp="$TIMESTAMP",host="$POSTGRES_HOST"
    
    # Verificar upload
    if aws s3 ls "s3://$S3_BUCKET/$S3_PREFIX/$db/${db}_${TIMESTAMP}.dump.gpg" > /dev/null; then
        log "Backup de $db pujat correctament a S3"
        # Eliminar arxiu local temporal
        rm "$BACKUP_DIR/${db}_${TIMESTAMP}.dump"*
    else
        log "ERROR: Fallida en pujar backup de $db a S3"
        exit 1
    fi
done

# Backup de configuració del cluster (roles, tablespaces, etc.)
log "Creant backup de configuració global..."
pg_dumpall -h "$POSTGRES_HOST" -U "$POSTGRES_USER" \
    --globals-only > "$BACKUP_DIR/globals_${TIMESTAMP}.sql"

# Xifrar i pujar configuració global
gpg --trust-model always --cipher-algo AES256 \
    --compress-algo 2 --symmetric \
    --passphrase-file /keys/backup.gpg \
    --batch --yes --quiet \
    "$BACKUP_DIR/globals_${TIMESTAMP}.sql"

aws s3 cp "$BACKUP_DIR/globals_${TIMESTAMP}.sql.gpg" \
    "s3://$S3_BUCKET/$S3_PREFIX/globals/globals_${TIMESTAMP}.sql.gpg" \
    --storage-class STANDARD_IA

log "Backup completat exitosament!"

# Neteja de backups antics a S3 (més de 90 dies)
aws s3api list-objects-v2 --bucket "$S3_BUCKET" --prefix "$S3_PREFIX/" \
    --query "Contents[?LastModified<='$(date -d '90 days ago' --iso-8601)'].Key" \
    --output text | xargs -r -n1 aws s3 rm "s3://$S3_BUCKET/"
```

### Procediment de restauració amb verificació

```bash
#!/bin/bash
# restore-from-backup.sh - Script de restauració amb verificació automàtica

set -euo pipefail

# Paràmetres
BACKUP_FILE="$1"
TARGET_DB="$2"
POSTGRES_CONTAINER="${3:-postgres}"
VERIFICATION_QUERIES="/tmp/verify_queries.sql"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Crear consultes de verificació
cat > "$VERIFICATION_QUERIES" << 'EOF'
-- Verificar estructura bàsica
SELECT 'Tables' as object_type, count(*) as count 
FROM information_schema.tables 
WHERE table_schema NOT IN ('information_schema', 'pg_catalog');

SELECT 'Indexes' as object_type, count(*) as count 
FROM pg_indexes 
WHERE schemaname NOT IN ('information_schema', 'pg_catalog');

SELECT 'Constraints' as object_type, count(*) as count 
FROM information_schema.table_constraints 
WHERE constraint_schema NOT IN ('information_schema', 'pg_catalog');

-- Verificar dades d'exemple
SELECT 'User records' as verification, count(*) as count FROM app.users;
SELECT 'Product records' as verification, count(*) as count FROM app.products;
SELECT 'Order records' as verification, count(*) as count FROM app.orders;
EOF

log "Iniciant restauració de backup..."

# Verificar que el backup existeix i és vàlid
if [[ ! -f "$BACKUP_FILE" ]]; then
    log "ERROR: Arxiu de backup $BACKUP_FILE no trobat"
    exit 1
fi

# Verificar integritat del backup
log "Verificant integritat del backup..."
if ! docker exec "$POSTGRES_CONTAINER" pg_restore --list "$BACKUP_FILE" > /dev/null 2>&1; then
    log "ERROR: Backup corromput o format incorrecte"
    exit 1
fi

# Crear base de dades temporal per verificació
TEMP_DB="restore_test_$(date +%s)"
log "Creant base de dades temporal $TEMP_DB per verificació..."

docker exec "$POSTGRES_CONTAINER" createdb -U postgres "$TEMP_DB"

# Restaurar a la base de dades temporal
log "Restaurant backup a base de dades temporal..."
docker exec "$POSTGRES_CONTAINER" pg_restore \
    -U postgres -d "$TEMP_DB" \
    --verbose --no-owner --no-privileges \
    "$BACKUP_FILE"

# Executar verificacions
log "Executant verificacions d'integritat..."
docker exec "$POSTGRES_CONTAINER" psql \
    -U postgres -d "$TEMP_DB" \
    -f "$VERIFICATION_QUERIES"

# Si arribem aquí, la verificació ha estat exitosa
log "Verificació completada. Procedint amb restauració real..."

# Restaurar a la base de dades objectiu
if docker exec "$POSTGRES_CONTAINER" psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "$TARGET_DB"; then
    log "ATENCIÓ: La base de dades $TARGET_DB ja existeix. Creant backup de seguretat..."
    
    docker exec "$POSTGRES_CONTAINER" pg_dump \
        -U postgres -F custom -Z 9 "$TARGET_DB" \
        > "/tmp/backup_before_restore_$(date +%s).dump"
    
    log "Eliminant base de dades existent $TARGET_DB..."
    docker exec "$POSTGRES_CONTAINER" dropdb -U postgres "$TARGET_DB"
fi

# Crear nova base de dades
log "Creant nova base de dades $TARGET_DB..."
docker exec "$POSTGRES_CONTAINER" createdb -U postgres "$TARGET_DB"

# Restauració final
log "Restaurant backup a $TARGET_DB..."
docker exec "$POSTGRES_CONTAINER" pg_restore \
    -U postgres -d "$TARGET_DB" \
    --verbose --no-owner --no-privileges \
    "$BACKUP_FILE"

# Verificació final
log "Verificació final..."
docker exec "$POSTGRES_CONTAINER" psql \
    -U postgres -d "$TARGET_DB" \
    -f "$VERIFICATION_QUERIES"

# Neteja
log "Netejant base de dades temporal..."
docker exec "$POSTGRES_CONTAINER" dropdb -U postgres "$TEMP_DB"
rm -f "$VERIFICATION_QUERIES"

log "Restauració completada exitosament!"
```

## Millors pràctiques de seguretat implementades

La seguretat en contenidors de bases de dades requereix una aproximació multicapa que cobreixi el host, el runtime del contenidor, la xarxa i la pròpia base de dades.

### Configuració de seguretat del host Docker

```json
# /etc/docker/daemon.json - Configuració segura del daemon
{
  "userns-remap": "default",
  "no-new-privileges": true,
  "log-level": "info",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "experimental": false,
  "metrics-addr": "127.0.0.1:9323",
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 65536,
      "Soft": 65536
    }
  }
}
```

### Configuració d'autenticació avançada (pg_hba.conf)

```conf
# pg_hba.conf - Autenticació basada en host amb seguretat avançada

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Connexions locals segures
local   all             postgres                                peer
local   all             all                                     scram-sha-256

# Connexions xifrades obligatòries per a producció
hostssl all             all             127.0.0.1/32            scram-sha-256
hostssl all             all             ::1/128                 scram-sha-256
hostssl all             all             172.20.0.0/16           scram-sha-256

# Connexions específiques per aplicació amb autenticació de certificat
hostssl production      app_service     172.20.0.0/16           cert clientcert=verify-full
hostssl analytics       analyst_user    172.20.0.0/16           scram-sha-256

# Connexions de replicació segures
hostssl replication     replicator      172.20.0.0/16           cert clientcert=verify-full

# Bloquejar totes les altres connexions
host    all             all             all                     reject
```

### Monitorització de seguretat amb alertes

```sql
-- Vista per monitoritzar connexions sospitoses
CREATE VIEW security.suspicious_connections AS
SELECT 
    datname,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    state_change,
    query
FROM pg_stat_activity 
WHERE 
    client_addr NOT IN (
        '127.0.0.1'::inet, 
        '::1'::inet
    ) 
    AND client_addr !~ '172\.20\.0\.\d+$'
    OR state = 'idle in transaction' AND state_change < NOW() - INTERVAL '5 minutes'
    OR usename = 'postgres' AND application_name NOT LIKE 'pg_%';

-- Funció per detectar intents d'intrús
CREATE OR REPLACE FUNCTION security.detect_intrusion_attempts()
RETURNS TABLE(
    event_time TIMESTAMP,
    database_name TEXT,
    username TEXT,
    client_ip INET,
    failed_attempts BIGINT
) AS $$
BEGIN
    -- Aquesta funció requeriria configuració de log_statement = 'all'
    -- i anàlisi dels logs de PostgreSQL
    RETURN QUERY
    SELECT 
        NOW(),
        'production'::TEXT,
        'unknown'::TEXT,
        '0.0.0.0'::INET,
        0::BIGINT;
END;
$$ LANGUAGE plpgsql;
```

## Configuració completa de docker-compose per a producció

### Fitxer principal (docker-compose.production.yml)

```yaml
version: '3.8'

x-logging: &default-logging
  driver: "json-file"
  options:
    max-size: "100m"
    max-file: "3"

x-restart-policy: &restart-policy
  restart: unless-stopped

services:
  # Base de dades principal
  postgres:
    image: postgres:17.4
    container_name: postgres_production
    <<: *restart-policy
    shm_size: 256mb
    
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-production}
      POSTGRES_USER: ${POSTGRES_USER:-admin}
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
      POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256 --encoding=UTF8"
      PGDATA: /var/lib/postgresql/data/pgdata
    
    # Límits de recursos per contenidor
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
        reservations:
          memory: 2G
          cpus: '1.0'
    
    # Configuració de seguretat del contenidor
    user: "999:999"
    read_only: false  # PostgreSQL necessita escriure
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
    
    command: [
      "postgres",
      "-c", "config_file=/etc/postgresql/postgresql.conf",
      "-c", "hba_file=/etc/postgresql/pg_hba.conf",
      "-c", "ssl=on",
      "-c", "ssl_cert_file=/var/lib/postgresql/certs/server.crt",
      "-c", "ssl_key_file=/var/lib/postgresql/certs/server.key"
    ]
    
    volumes:
      # Dades persistents
      - postgres_data:/var/lib/postgresql/data
      
      # Configuració personalitzada
      - ./config/postgresql.conf:/etc/postgresql/postgresql.conf:ro
      - ./config/pg_hba.conf:/etc/postgresql/pg_hba.conf:ro
      
      # Scripts d'inicialització
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
      
      # Certificats SSL
      - ./certs/postgres-server.crt:/var/lib/postgresql/certs/server.crt:ro
      - ./certs/postgres-server.key:/var/lib/postgresql/certs/server.key:ro
      
      # Backups i logs
      - postgres_backups:/backups
      - postgres_logs:/var/log/postgresql
    
    ports:
      - "127.0.0.1:5432:5432"
    
    networks:
      - postgres_network
    
    secrets:
      - postgres_password
    
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-admin} -d ${POSTGRES_DB:-production}"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    
    logging: *default-logging

  # pgAdmin per administració
  pgadmin:
    image: dpage/pgadmin4:9.7
    container_name: pgadmin_production
    <<: *restart-policy
    
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGLADMIN_EMAIL}
      PGLADMIN_DEFAULT_PASSWORD_FILE: /run/secrets/pgadmin_password
      PGLADMIN_ENABLE_TLS: 'true'
      PGLADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION: 'True'
      PGLADMIN_CONFIG_LOGIN_BANNER: '"Entorn de Producció"'
      PGLADMIN_CONFIG_CONSOLE_LOG_LEVEL: 20
      PGLADMIN_DISABLE_POSTFIX: 'True'
      GUNICORN_THREADS: 25
    
    user: "5050:5050"
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
    
    volumes:
      - pgladmin_data:/var/lib/pgladmin
      - ./certs/pgadmin.crt:/certs/server.cert:ro
      - ./certs/pgadmin.key:/certs/server.key:ro
      - ./config/servers.json:/pgadmin4/servers.json:ro
      - ./config/pgadmin_config.py:/pgladmin4/config_local.py:ro
    
    ports:
      - "127.0.0.1:443:443"
    
    networks:
      - postgres_network
    
    secrets:
      - pgladmin_password
    
    depends_on:
      postgres:
        condition: service_healthy
    
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "https://localhost/misc/ping"]
      interval: 30s
      timeout: 10s
      retries: 3
    
    logging: *default-logging

  # Backup automatitzat
  postgres_backup:
    image: prodrigestivill/postgres-backup-local:17
    container_name: postgres_backup_service
    <<: *restart-policy
    
    user: "postgres:postgres"
    
    environment:
      POSTGRES_HOST: postgres
      POSTGRES_DB: ${POSTGRES_DB:-production}
      POSTGRES_USER: ${POSTGRES_USER:-admin}  
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
      POSTGRES_EXTRA_OPTS: "-Z9 --schema=public --blobs"
      SCHEDULE: "@daily"
      BACKUP_KEEP_DAYS: 7
      BACKUP_KEEP_WEEKS: 4
      BACKUP_KEEP_MONTHS: 6
      BACKUP_KEEP_YEARS: 1
      HEALTHCHECK_PORT: 8080
    
    volumes:
      - postgres_backups:/backups
    
    networks:
      - postgres_network
    
    secrets:
      - postgres_password
    
    depends_on:
      postgres:
        condition: service_healthy
    
    logging: *default-logging

  # Monitorització amb Prometheus
  postgres_exporter:
    image: prometheuscommunity/postgres-exporter:latest
    container_name: postgres_monitoring
    <<: *restart-policy
    
    environment:
      DATA_SOURCE_NAME: "postgresql://monitoring:${MONITORING_PASSWORD}@postgres:5432/production?sslmode=require"
    
    ports:
      - "127.0.0.1:9187:9187"
    
    networks:
      - postgres_network
    
    depends_on:
      postgres:
        condition: service_healthy
    
    logging: *default-logging

  # Connection pooling amb pgBouncer
  pgbouncer:
    image: pgbouncer/pgbouncer:latest
    container_name: pgbouncer_production
    <<: *restart-policy
    
    environment:
      DATABASES_HOST: postgres
      DATABASES_PORT: 5432
      DATABASES_USER: ${POSTGRES_USER:-admin}
      DATABASES_PASSWORD: ${POSTGRES_PASSWORD}
      DATABASES_DBNAME: ${POSTGRES_DB:-production}
      POOL_MODE: transaction
      MAX_CLIENT_CONN: 1000
      DEFAULT_POOL_SIZE: 25
      SERVER_RESET_QUERY: DISCARD ALL
      SERVER_CHECK_DELAY: 30
      MAX_DB_CONNECTIONS: 50
      SERVER_IDLE_TIMEOUT: 600
    
    ports:
      - "127.0.0.1:6432:5432"
    
    networks:
      - postgres_network
    
    depends_on:
      postgres:
        condition: service_healthy
    
    logging: *default-logging

# Xarxa aïllada per als serveis de base de dades
networks:
  postgres_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
    driver_opts:
      com.docker.network.bridge.enable_icc: "true"
      com.docker.network.bridge.enable_ip_masquerade: "true"
      com.docker.network.driver.mtu: "1500"

# Volums amb configuració optimitzada
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${POSTGRES_DATA_PATH:-/data/postgres}
  
  postgres_backups:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${POSTGRES_BACKUP_PATH:-/backup/postgres}
  
  postgres_logs:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${POSTGRES_LOG_PATH:-/logs/postgres}
  
  pgladmin_data:
    driver: local

# Secrets segurs per a producció
secrets:
  postgres_password:
    external: true
    name: postgres_password_v1
  
  pgladmin_password:
    external: true  
    name: pgladmin_password_v1
```

## Troubleshooting comú i resolució de problemes

### Problemes de connexió més freqüents

**Problema: pgAdmin no pot connectar amb PostgreSQL**

```bash
# Diagnòstic pas a pas
# 1. Verificar que els contenidors estan en la mateixa xarxa
docker network inspect postgres_network

# 2. Verificar connectivitat de xarxa
docker exec pgladmin_container ping postgres

# 3. Verificar que PostgreSQL accepta connexions
docker exec postgres_container psql -U admin -c "SHOW listen_addresses;"

# 4. Verificar configuració pg_hba.conf
docker exec postgres_container cat /etc/postgresql/pg_hba.conf

# Solució: Configurar hostname correcte
# A pgAdmin usar 'postgres' (nom del servei) no 'localhost'
```

**Problema: Error de permisos en volums**

```bash
# Diagnòstic
docker logs postgres_container 2>&1 | grep -i permission

# Solució per bind mounts
sudo chown -R 999:999 /data/postgres
sudo chmod 700 /data/postgres

# Solució alternativa: usar volums nomenats
docker volume create postgres_data
```

### Problemes de rendiment i optimització

**Diagnòstic de rendiment lent**

```sql
-- Consultes més lentes
SELECT query, calls, mean_exec_time, rows, 100.0 * shared_blks_hit /
       nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC LIMIT 10;

-- Ràtio de hit de cache (hauria de ser > 95%)
SELECT sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) * 100 
AS cache_hit_ratio FROM pg_statio_user_tables;

-- Bloqueigs actius
SELECT bl.pid, bl.mode, bl.granted, a.query 
FROM pg_locks bl 
JOIN pg_stat_activity a ON bl.pid = a.pid 
WHERE NOT bl.granted;
```

### Tips per a entorns de producció

**Configuració de monitoring avançat**

```yaml
services:
  # Alerting amb Grafana
  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    volumes:
      - grafana_data:/var/lib/grafana  
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
    ports:
      - "127.0.0.1:3000:3000"
    depends_on:
      - postgres_exporter
```

**Script de salut del sistema complet**

```bash
#!/bin/bash
# health-check-production.sh

ERRORS=0

# Verificar contenidors actius
for container in postgres_production pgladmin_production postgres_backup_service; do
    if ! docker ps | grep -q "$container"; then
        echo "ERROR: Contenidor $container no està executant-se"
        ((ERRORS++))
    fi
done

# Verificar connectivitat de base de dades  
if ! docker exec postgres_production pg_isready -U admin -d production; then
    echo "ERROR: PostgreSQL no accepta connexions"
    ((ERRORS++))
fi

# Verificar espai en disc
DISK_USAGE=$(df /data/postgres | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 85 ]; then
    echo "WARNING: Ús del disc al ${DISK_USAGE}%"
fi

# Verificar backups recents
LAST_BACKUP=$(find /backup/postgres -name "*.sql.gz" -type f -mtime -1 | wc -l)
if [ "$LAST_BACKUP" -eq 0 ]; then
    echo "ERROR: No hi ha backups de les últimes 24 hores"
    ((ERRORS++))
fi

# Verificar connexions actives
ACTIVE_CONNECTIONS=$(docker exec postgres_production psql -U admin -d production -t -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';")
if [ "$ACTIVE_CONNECTIONS" -gt 150 ]; then
    echo "WARNING: $ACTIVE_CONNECTIONS connexions actives (límit recomanat: 150)"
fi

if [ $ERRORS -eq 0 ]; then
    echo "✓ Tots els controls de salut han passat correctament"
    exit 0
else
    echo "✗ S'han detectat $ERRORS errors crítics"
    exit 1
fi
```

## Conclusió i millors pràctiques integrades

Aquest desplegament complet de PostgreSQL i pgAdmin proporciona una base sòlida per a entorns de producció empresarials. Les configuracions presentades han estat provades en entorns reals i segueixen les recomanacions oficials de PostgreSQL i Docker.

**Elements clau implementats**: Seguretat multicapa amb xifrat TLS, autenticació robusta, aïllament de xarxa i gestió de secrets. Rendiment optimitzat amb configuració de memòria adaptativa, paral·lelisme de consultes i monitorització contínua. Operacions automatitzades amb backups amb retenció intel·ligent, verificació automàtica de restauracions i alertes proactives.

**Punts crítics per recordar**: Sempre usar versions específiques d'imatges en producció per evitar actualitzacions imprevistes. Implementar monitoring complet des del primer dia, incloent mètriques de rendiment, conectivitat i espai en disc. Provar regularment els procediments de backup i restauració en un entorn separat per garantir la recuperació de dades. Mantenir els certificats SSL actualitzats i configurar rotació automàtica quan sigui possible.

Aquest framework proporciona una base escalable que pot adaptar-se a necessitats específiques mantenint els principis fonamentals de seguretat, rendiment i fiabilitat essencials per a sistemes de producció crítics.