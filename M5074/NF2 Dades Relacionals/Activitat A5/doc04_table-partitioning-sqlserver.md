# Particionament de Taules en SQL Server

El **Particionament de Taules** és una tècnica per dividir una taula gran en múltiples fragments més petits (particions) basant-se en els valors d'una columna específica. Cada partició es pot gestionar i consultar de manera independent, millorant significativament el rendiment i la mantenibilitat.

## Característiques principals

- **Divisió transparent**: La taula es divideix físicament, però es consulta com una sola taula
- **Millor rendiment**: Les consultes només accedeixen a les particions rellevants
- **Gestió simplificada**: Facilita operacions com arxivat, purga i manteniment
- **Escalabilitat**: Permet gestionar taules de terabytes eficientment
- **Disponible en**: SQL Server Enterprise, Developer i Evaluation editions

## Conceptes fonamentals

### Components del particionament

1. **Partition Function** (Funció de partició)
   - Defineix com es divideixen les dades
   - Especifica els valors límit (boundary values)

2. **Partition Scheme** (Esquema de partició)
   - Mapeja les particions a filegroups
   - Determina on s'emmagatzema cada partició

3. **Partitioned Table/Index** (Taula/Índex particionat)
   - La taula o índex que usa l'esquema de partició

### Tipus de particionament

#### RANGE LEFT (Per defecte)
Els valors límit pertanyen a la partició de l'esquerra.

#### RANGE RIGHT
Els valors límit pertanyen a la partició de la dreta.

## Procés de creació pas a pas

### Pas 1: Crear Filegroups (opcional però recomanat)

```sql
-- Crear filegroups per cada any
ALTER DATABASE MevaBaseDeDades
ADD FILEGROUP FG_2022;

ALTER DATABASE MevaBaseDeDades
ADD FILEGROUP FG_2023;

ALTER DATABASE MevaBaseDeDades
ADD FILEGROUP FG_2024;
```

### Pas 2: Crear la Partition Function

```sql
-- Particionament per any amb RANGE RIGHT
CREATE PARTITION FUNCTION PF_Anys (INT)
AS RANGE RIGHT FOR VALUES (2022, 2023, 2024, 2025);
```

### Pas 3: Crear el Partition Scheme

```sql
-- Mapear particions a filegroups
CREATE PARTITION SCHEME PS_Anys
AS PARTITION PF_Anys
TO (FG_2022, FG_2022, FG_2023, FG_2024, [PRIMARY]);

-- O usar PRIMARY per tot:
CREATE PARTITION SCHEME PS_Anys_Simple
AS PARTITION PF_Anys
ALL TO ([PRIMARY]);
```

### Pas 4: Crear la taula particionada

```sql
-- Taula nova particionada
CREATE TABLE Vendes (
    VendaID BIGINT IDENTITY(1,1),
    Any INT NOT NULL,
    Mes INT,
    DataVenda DATE,
    ClientID INT,
    ProducteID INT,
    Import DECIMAL(12,2),
    CONSTRAINT PK_Vendes PRIMARY KEY (VendaID, Any)
) ON PS_Anys(Any);
```

## Exemples pràctics

### Exemple 1: Particionament per data (monthly)

```sql
CREATE PARTITION FUNCTION PF_Mesos2024 (DATE)
AS RANGE RIGHT FOR VALUES (
    '2024-02-01', '2024-03-01', '2024-04-01', 
    '2024-05-01', '2024-06-01', '2024-07-01',
    '2024-08-01', '2024-09-01', '2024-10-01',
    '2024-11-01', '2024-12-01'
);

CREATE PARTITION SCHEME PS_Mesos2024
AS PARTITION PF_Mesos2024
ALL TO ([PRIMARY]);

CREATE TABLE Transaccions (
    TransaccioID BIGINT IDENTITY(1,1),
    DataTransaccio DATE NOT NULL,
    ClientID INT,
    Import DECIMAL(10,2),
    CONSTRAINT PK_Transaccions PRIMARY KEY (TransaccioID, DataTransaccio)
) ON PS_Mesos2024(DataTransaccio);
```

### Exemple 2: Particionament per rang de valors

```sql
CREATE PARTITION FUNCTION PF_RangsPreus (DECIMAL(10,2))
AS RANGE RIGHT FOR VALUES (100.00, 500.00, 1000.00, 5000.00);

CREATE PARTITION SCHEME PS_RangsPreus
AS PARTITION PF_RangsPreus
ALL TO ([PRIMARY]);

CREATE TABLE Productes (
    ProducteID INT PRIMARY KEY,
    Nom VARCHAR(100),
    Preu DECIMAL(10,2) NOT NULL,
    Categoria VARCHAR(50)
) ON PS_RangsPreus(Preu);
```

## Partition Elimination

El motor de SQL Server només llegeix les particions necessàries quan hi ha un filtre sobre la columna de partició.

```sql
-- Consulta amb partition elimination
SELECT * 
FROM Vendes
WHERE Any = 2024;
-- Només accedeix a la partició de 2024

-- Consulta òptima
SELECT * 
FROM Vendes
WHERE Any = 2024 
  AND DataVenda >= '2024-01-01';
```

## Gestió de particions

### 1. Veure informació de particions

```sql
SELECT 
    OBJECT_NAME(p.object_id) AS TableName,
    p.partition_number,
    p.rows AS NumRows,
    fg.name AS FileGroupName
FROM sys.partitions p
LEFT JOIN sys.allocation_units au 
    ON p.partition_id = au.container_id
LEFT JOIN sys.filegroups fg 
    ON au.data_space_id = fg.data_space_id
WHERE OBJECT_NAME(p.object_id) = 'Vendes'
ORDER BY p.partition_number;
```

### 2. Afegir nova partició (SPLIT)

```sql
ALTER PARTITION SCHEME PS_Anys
NEXT USED [PRIMARY];

ALTER PARTITION FUNCTION PF_Anys()
SPLIT RANGE (2026);
```

### 3. Eliminar partició buida (MERGE)

```sql
ALTER PARTITION FUNCTION PF_Anys()
MERGE RANGE (2022);
```

### 4. Switching particions (molt ràpid)

```sql
-- Crear taula d'arxiu
CREATE TABLE Vendes_2022_Arxiu (
    VendaID BIGINT,
    Any INT NOT NULL,
    DataVenda DATE,
    Import DECIMAL(12,2),
    CONSTRAINT PK_Vendes_2022_Arxiu PRIMARY KEY (VendaID, Any),
    CONSTRAINT CK_Vendes_2022_Arxiu CHECK (Any = 2022)
) ON [PRIMARY];

-- Fer switch (operació instantània)
ALTER TABLE Vendes
SWITCH PARTITION 2 TO Vendes_2022_Arxiu;
```

### 5. Truncar una partició específica

```sql
-- Eliminar totes les dades d'una partició
TRUNCATE TABLE Vendes
WITH (PARTITIONS (1));

-- Truncar múltiples particions
TRUNCATE TABLE Vendes
WITH (PARTITIONS (1, 2, 3));
```

## Estratègies de particionament

### 1. Sliding Window (Finestra lliscant)

Tècnica per mantenir un nombre fix de particions, afegint-ne noves i eliminant les antigues.

### 2. Particionament per calor de dades

Separar dades calentes (accedides freqüentment) de dades fredes (rares vegades accedides).

### 3. Particionament aligned

Particionar taula i índexs amb el mateix esquema per màxim rendiment.

## Avantatges del particionament

### 1. Rendiment de consultes
- Partition elimination: Només llegeix particions rellevants
- Consultes paral·leles: Cada partició es pot processar en paral·lel
- Millor cache: Particions petites caben millor a memòria

### 2. Gestió de dades
- Manteniment ràpid: Rebuild d'índexs per partició
- Arxivat eficient: SWITCH OUT instantani
- Càrregues massives: SWITCH IN per bulk load
- Purga ràpida: TRUNCATE per partició

### 3. Disponibilitat
- Manteniment online: Rebuild d'una partició mentre altres estan disponibles
- Backup incremental: Backup per filegroup/partició
- Recovery més ràpid: Restaurar només particions necessàries

## Consideracions i limitacions

### Restriccions importants

1. **Columna de partició en Primary Key**
   - La columna de partició SEMPRE ha d'estar a la Primary Key

2. **Només una columna**
   - Només es pot particionar per UNA columna

3. **Edició Enterprise**
   - El particionament només està disponible a Enterprise, Developer i Evaluation

### Millors pràctiques

**Fer:**
1. Particionar taules grans (més de 50-100GB)
2. Usar dates per particionament temporal
3. Crear filegroups separats per millor gestió
4. Alinear índexs amb la taula
5. Implementar sliding window per dades històriques
6. Monitoritzar distribució de dades entre particions
7. Usar SWITCH per operacions massives

**Evitar:**
1. Particionar taules petites (menys de 10GB)
2. Crear massa particions (més de 1000)
3. Particionar per columnes amb distribució desigual
4. Oblidar la columna de partició a la Primary Key
5. Consultes sense partition elimination

## Monitoratge i optimització

### 1. Verificar partition elimination

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT * 
FROM Vendes
WHERE Any = 2024;
```

### 2. Analitzar distribució de dades

```sql
SELECT 
    p.partition_number,
    p.rows,
    au.total_pages * 8 / 1024.0 AS SizeMB
FROM sys.partitions p
INNER JOIN sys.allocation_units au 
    ON p.partition_id = au.container_id
WHERE p.object_id = OBJECT_ID('Vendes')
  AND p.index_id IN (0, 1)
ORDER BY p.partition_number;
```

### 3. Manteniment d'índexs per partició

```sql
-- Rebuild índex d'una partició específica
ALTER INDEX IX_Vendes_Client ON Vendes
REBUILD PARTITION = 4;

-- Reorganize d'una partició
ALTER INDEX IX_Vendes_Client ON Vendes
REORGANIZE PARTITION = 4;
```

## Casos d'ús reals

### 1. Sistema de facturació (per any)

```sql
CREATE PARTITION FUNCTION PF_Factures_Anys (INT)
AS RANGE RIGHT FOR VALUES (2020, 2021, 2022, 2023, 2024, 2025);

CREATE PARTITION SCHEME PS_Factures_Anys
AS PARTITION PF_Factures_Anys
ALL TO ([PRIMARY]);

CREATE TABLE Factures (
    FacturaID BIGINT IDENTITY(1,1),
    Any INT NOT NULL,
    NumeroFactura VARCHAR(20),
    ClientID INT,
    DataFactura DATE,
    Import DECIMAL(12,2),
    CONSTRAINT PK_Factures PRIMARY KEY (FacturaID, Any)
) ON PS_Factures_Anys(Any);
```

### 2. Logs d'aplicació (per mes)

```sql
CREATE PARTITION FUNCTION PF_Logs_Mesos (DATE)
AS RANGE RIGHT FOR VALUES (
    '2024-08-01', '2024-09-01', '2024-10-01',
    '2024-11-01', '2024-12-01', '2025-01-01'
);

CREATE PARTITION SCHEME PS_Logs_Mesos
AS PARTITION PF_Logs_Mesos
ALL TO ([PRIMARY]);

CREATE TABLE Logs (
    LogID BIGINT IDENTITY(1,1),
    DataHora DATETIME2 NOT NULL,
    Nivell VARCHAR(20),
    Missatge NVARCHAR(MAX),
    CONSTRAINT PK_Logs PRIMARY KEY (LogID, DataHora)
) ON PS_Logs_Mesos(DataHora);
```

### 3. Data Warehouse (per trimestre)

```sql
CREATE PARTITION FUNCTION PF_Trimestres (INT)
AS RANGE RIGHT FOR VALUES (
    202301, 202304, 202307, 202310,
    202401, 202404, 202407, 202410
);

CREATE PARTITION SCHEME PS_Trimestres
AS PARTITION PF_Trimestres
ALL TO ([PRIMARY]);

CREATE TABLE FactVendes (
    VendaID BIGINT,
    PeriodeID INT NOT NULL,
    DataVenda DATE,
    ProducteID INT,
    Import DECIMAL(12,2),
    CONSTRAINT PK_FactVendes PRIMARY KEY (VendaID, PeriodeID)
) ON PS_Trimestres(PeriodeID);
```

## Comparativa: Amb vs Sense Particionament

| Aspecte | Sense Particionament | Amb Particionament |
|---------|---------------------|-------------------|
| **Taula única** | Sí | Dividida en múltiples particions |
| **Consultes** | Escaneja tota la taula | Partition elimination |
| **Manteniment** | Rebuild complet | Per partició |
| **Arxivat** | DELETE lent | SWITCH instantani |
| **Backup** | Tota la taula | Per filegroup/partició |
| **Purga** | DELETE/TRUNCATE tot | TRUNCATE per partició |
| **Complexitat** | Baixa | Mitjana-Alta |
| **Escalabilitat** | Limitada | Excel·lent |
| **Millor per** | Taules menys de 50GB | Taules més de 100GB |

---

## Conclusió

El **Particionament de Taules** és una tècnica poderosa per gestionar taules molt grans en SQL Server:

### Beneficis clau:
- Millor rendiment amb partition elimination
- Manteniment simplificat per particions
- Gestió eficient de dades històriques
- Operacions instantànies amb SWITCH
- Escalabilitat per taules massives

### Recordar:
- Usar en taules grans (més de 50-100GB)
- Particionar per data/temps quan sigui possible
- La columna de partició ha d'estar a la Primary Key
- Implementar sliding window per dades temporals
- Monitoritzar distribució de dades regularment

**El particionament transforma com gestionem i consultem taules massives en SQL Server.**
