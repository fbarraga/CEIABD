# Columnstore Indexes en SQL Server

Els **Columnstore Indexes** són un tipus d'índex dissenyat per a consultes analítiques i de data warehousing. Emmagatzemen i gestionen dades en un format orientat a columnes en lloc de files (rowstore tradicional).

## Característiques principals

- **Emmagatzematge per columnes**: Les dades s'organitzen per columnes en lloc de files
- **Compressió massiva**: Redueixen l'espai fins a 10x o més
- **Rendiment analític**: Optimitzats per consultes d'agregació i escaneig de moltes files
- **Batch Mode Processing**: Processen múltiples files alhora (fins a 900)
- **Disponibles des de**: SQL Server 2012 (millores significatives en 2016+)

## Rowstore vs Columnstore

### Rowstore (Tradicional)

Emmagatzematge per files: Totes les columnes d'una fila es guarden juntes
- Òptim per: SELECT *, INSERT, UPDATE, DELETE de files individuals
- Usat en: Sistemes OLTP (transaccionals)

### Columnstore

Emmagatzematge per columnes: Cada columna es guarda separadament
- Òptim per: Agregacions (SUM, AVG, COUNT), escaneig de moltes files
- Usat en: Sistemes OLAP (analítics), Data Warehouses

## Tipus de Columnstore Indexes

### 1. Clustered Columnstore Index

L'estructura principal de la taula. **Tota la taula** s'emmagatzema com un columnstore.

```sql
-- Crear una taula amb clustered columnstore
CREATE TABLE Vendes (
    VendaID INT,
    DataVenda DATE,
    ProducteID INT,
    ClientID INT,
    Quantitat INT,
    Import DECIMAL(10,2)
);

CREATE CLUSTERED COLUMNSTORE INDEX CCI_Vendes
ON Vendes;
```

**Característiques:**
- Només pot haver-n'hi un per taula
- La taula sencera està en format columnstore
- Màxima compressió i rendiment per analítica
- Ideal per taules de fets en data warehouses
- No suporta índexs únics ni primary keys tradicionals
- Menys eficient per consultes de files individuals

### 2. Nonclustered Columnstore Index

Un índex secundari en format columnstore sobre una taula rowstore tradicional.

```sql
-- Taula rowstore tradicional
CREATE TABLE Comandes (
    ComandaID INT PRIMARY KEY,
    ClientID INT,
    DataComanda DATE,
    Total DECIMAL(10,2),
    Estat VARCHAR(20)
);

-- Afegir columnstore per analítica
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Comandes
ON Comandes (ClientID, DataComanda, Total, Estat);
```

**Característiques:**
- Pot coexistir amb índexs rowstore tradicionals
- La taula segueix sent rowstore
- Permet operacions OLTP normals
- Millora consultes analítiques sense canviar l'estructura
- Només lectura fins SQL Server 2016 (després actualitzable)
- Ocupa espai addicional

## Com funciona la compressió

### Compressió per segments

Els columnstore indexes divideixen les dades en **row groups** de fins a 1.048.576 files.

### Tècniques de compressió

1. **Dictionary encoding**: Valors repetits es guarden una sola vegada
2. **Run-length encoding**: Seqüències de valors iguals es comprimen
3. **Bit packing**: Valors numèrics es guarden amb el mínim de bits necessaris

## Exemples pràctics

### Exemple 1: Crear taula amb Clustered Columnstore

```sql
-- Taula de fets de vendes (Data Warehouse)
CREATE TABLE FactVendes (
    VendaID BIGINT,
    DataID INT,
    ProducteID INT,
    ClientID INT,
    BotiguaID INT,
    Quantitat INT,
    PreuUnitari DECIMAL(10,2),
    Import DECIMAL(12,2),
    Descompte DECIMAL(10,2)
);

-- Crear clustered columnstore index
CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactVendes
ON FactVendes
WITH (DATA_COMPRESSION = COLUMNSTORE);
```

### Exemple 2: Nonclustered Columnstore per analítica

```sql
-- Taula OLTP tradicional
CREATE TABLE Transaccions (
    TransaccioID INT PRIMARY KEY IDENTITY,
    ClientID INT,
    DataTransaccio DATETIME,
    Import DECIMAL(10,2),
    TipusTransaccio VARCHAR(50),
    Estat VARCHAR(20),
    INDEX IX_Client (ClientID),
    INDEX IX_Data (DataTransaccio)
);

-- Afegir columnstore per reports i analítica
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Transaccions_Analytics
ON Transaccions (
    ClientID,
    DataTransaccio,
    Import,
    TipusTransaccio,
    Estat
);

-- Consulta analítica aprofita el columnstore
SELECT 
    YEAR(DataTransaccio) AS Any,
    MONTH(DataTransaccio) AS Mes,
    TipusTransaccio,
    COUNT(*) AS NumTransaccions,
    SUM(Import) AS ImportTotal,
    AVG(Import) AS ImportMitja
FROM Transaccions
WHERE DataTransaccio >= '2023-01-01'
GROUP BY 
    YEAR(DataTransaccio),
    MONTH(DataTransaccio),
    TipusTransaccio
ORDER BY Any, Mes;
```

### Exemple 3: Consultes que beneficien de Columnstore

```sql
-- EXCEL·LENT: Agregació sobre moltes files
SELECT 
    ProducteID,
    SUM(Quantitat) AS QuantitatTotal,
    SUM(Import) AS ImportTotal,
    AVG(Import) AS ImportMitja,
    COUNT(*) AS NumVendes
FROM FactVendes
WHERE DataID BETWEEN 20240101 AND 20241231
GROUP BY ProducteID;

-- BO: Filtrar i agregar
SELECT 
    BotiguaID,
    MONTH(DataVenda) AS Mes,
    SUM(Import) AS Vendes
FROM FactVendes
WHERE YEAR(DataVenda) = 2024
  AND ProducteID IN (100, 101, 102)
GROUP BY BotiguaID, MONTH(DataVenda);

-- INEFICIENT: Buscar una fila específica
SELECT *
FROM FactVendes
WHERE VendaID = 123456;
-- Millor usar un índex rowstore tradicional per això
```

## Batch Mode vs Row Mode

### Row Mode (Traditional)

- Processa **una fila alhora**
- Usat per índexs rowstore tradicionals
- Bo per consultes OLTP

### Batch Mode

- Processa **900-1000 files alhora**
- Usat automàticament amb columnstore indexes
- Molt més eficient per agregacions i escanejos

## Segment Elimination

Els columnstore indexes guarden **estadístiques min/max** per cada segment (row group), permetent saltar segments sencers.

## Deltastore: Gestió de canvis

Quan insertes files en un columnstore, primer van al **deltastore** (format rowstore temporal).

### Tuple Mover

Un procés en segon pla mou files del deltastore al columnstore:

```sql
-- Forçar compressió del deltastore manualment
ALTER INDEX CCI_Vendes ON Vendes
REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);
```

## Quan usar Columnstore Indexes

### Casos d'ús ideals

1. **Data Warehouses i taules de fets**
   - Milions/bilions de files
   - Consultes d'agregació freqüents
   - Actualitzacions poc freqüents

2. **Reports i analítica**
   - SUM, AVG, COUNT, GROUP BY
   - Escaneig de moltes files
   - Poques columnes seleccionades

3. **Taules d'arxiu/històriques**
   - Dades antigues poc consultades
   - Necessiten compressió màxima
   - Només lectura o actualitzacions mínimes

4. **Logs i telemetria**
   - Volums massius de dades
   - Consultes d'anàlisi temporal
   - Agregacions sobre períodes

### Quan NO usar Columnstore

1. **Sistemes OLTP amb moltes transaccions individuals**
   - INSERT/UPDATE/DELETE freqüents de files individuals
   - SELECT * WHERE ID = valor

2. **Taules petites**
   - Menys de 1 milió de files
   - El overhead no compensa

3. **Consultes que sempre retornen totes les columnes**
   - SELECT * és menys eficient en columnstore

4. **Necessitat de claus primàries/úniques tradicionals**
   - Clustered columnstore no suporta constraints únics

## Monitoratge i manteniment

### 1. Veure estat dels Row Groups

```sql
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    index_id,
    partition_number,
    row_group_id,
    state_desc,
    total_rows,
    deleted_rows,
    size_in_bytes / 1024.0 / 1024.0 AS SizeMB
FROM sys.dm_db_column_store_row_group_physical_stats
WHERE OBJECT_NAME(object_id) = 'FactVendes'
ORDER BY row_group_id;
```

### 2. Identificar fragmentació

```sql
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    100.0 * (ISNULL(SUM(rgs.deleted_rows), 0)) / NULLIF(SUM(rgs.total_rows), 0) AS FragmentationPercent
FROM sys.indexes i
INNER JOIN sys.dm_db_column_store_row_group_physical_stats rgs
    ON i.object_id = rgs.object_id
    AND i.index_id = rgs.index_id
WHERE i.type IN (5, 6)
GROUP BY i.object_id, i.name
HAVING SUM(rgs.total_rows) > 0;
```

### 3. Reorganitzar i reconstruir

```sql
-- Reorganitzar (comprimir deltastore)
ALTER INDEX CCI_Vendes ON Vendes
REORGANIZE;

-- Reconstruir (compressió completa)
ALTER INDEX CCI_Vendes ON Vendes
REBUILD;

-- Reorganitzar comprimint tots els row groups
ALTER INDEX CCI_Vendes ON Vendes
REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);
```

## Millors pràctiques

### Fer

1. **Usar en taules grans** (més de 1 milió de files)
2. **Optimitzar càrregues massives** (bulk insert)
3. **Reorganitzar regularment** per comprimir deltastore
4. **Particionar taules molt grans** per millor gestió
5. **Usar columnstore archive** per dades fredes
6. **Monitoritzar fragmentació** i row groups
7. **Combinar amb rowstore** per queries mixtes (HTAP)

### Evitar

1. **No usar en taules petites** (menys de 1M files)
2. **No fer updates/deletes individuals** freqüents
3. **No ignorar el deltastore** (pot créixer massa)
4. **No crear columnstore** en totes les taules sense analitzar
5. **No oblidar estadístiques** (encara són importants)

## Comparativa: Rowstore vs Columnstore

| Aspecte | Rowstore | Columnstore |
|---------|----------|-------------|
| **Emmagatzematge** | Per files | Per columnes |
| **Compressió** | Moderada (2-3x) | Excel·lent (10-20x) |
| **Tipus de consultes** | OLTP, transaccional | OLAP, analític |
| **SELECT específic** | Excel·lent | Bo |
| **Agregacions** | Bo | Excel·lent |
| **INSERT/UPDATE/DELETE** | Excel·lent | Bo (amb deltastore) |
| **Escaneig complet** | Lent | Molt ràpid |
| **Espai en disc** | Més | Menys (molt menys) |
| **Mode de processament** | Row Mode | Batch Mode |
| **Cas d'ús** | E-commerce, CRM, ERP | Data Warehouse, BI, Analytics |

## Arquitectura híbrida (HTAP)

Pots combinar rowstore i columnstore en la mateixa taula:

```sql
-- Taula rowstore per OLTP
CREATE TABLE Comandes (
    ComandaID INT PRIMARY KEY,
    ClientID INT,
    DataComanda DATETIME,
    Total DECIMAL(10,2),
    INDEX IX_Client (ClientID)
);

-- Afegir columnstore per analítica
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Comandes
ON Comandes (ClientID, DataComanda, Total);

-- Transaccions OLTP usen rowstore
INSERT INTO Comandes VALUES (1, 100, GETDATE(), 500.00);
UPDATE Comandes SET Total = 550.00 WHERE ComandaID = 1;

-- Reports analítics usen columnstore automàticament
SELECT 
    ClientID,
    YEAR(DataComanda) AS Any,
    SUM(Total) AS VendesAnuals
FROM Comandes
GROUP BY ClientID, YEAR(DataComanda);
```

## Casos d'ús reals

### 1. Data Warehouse de retail

```sql
-- Taula de fets amb bilions de transaccions
CREATE TABLE FactTransaccions (
    TransaccioID BIGINT,
    DataID INT,
    BotiguaID INT,
    ProducteID INT,
    ClientID INT,
    Quantitat INT,
    Import DECIMAL(12,2)
);

CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactTransaccions
ON FactTransaccions;

-- Consulta: Vendes mensuals per botiga
SELECT 
    BotiguaID,
    DataID / 100 AS Mes,
    SUM(Import) AS VendesMensuals
FROM FactTransaccions
WHERE DataID BETWEEN 20240101 AND 20241231
GROUP BY BotiguaID, DataID / 100;
-- Processa milions de files en segons
```

### 2. Logs d'aplicació

```sql
CREATE TABLE LogsAplicacio (
    LogID BIGINT IDENTITY,
    DataHora DATETIME2,
    Aplicacio VARCHAR(50),
    Nivell VARCHAR(20),
    Missatge NVARCHAR(MAX),
    Usuari VARCHAR(100)
);

CREATE CLUSTERED COLUMNSTORE INDEX CCI_Logs
ON LogsAplicacio;

-- Analítica de logs
SELECT 
    Aplicacio,
    Nivell,
    CAST(DataHora AS DATE) AS Data,
    COUNT(*) AS NumErrors
FROM LogsAplicacio
WHERE Nivell = 'ERROR'
  AND DataHora >= DATEADD(DAY, -7, GETDATE())
GROUP BY Aplicacio, Nivell, CAST(DataHora AS DATE);
```

### 3. Telemetria IoT

```sql
CREATE TABLE SensorsIoT (
    SensorID INT,
    Timestamp DATETIME2,
    Temperatura DECIMAL(5,2),
    Humitat DECIMAL(5,2),
    Pressio DECIMAL(7,2)
);

CREATE CLUSTERED COLUMNSTORE INDEX CCI_Sensors
ON SensorsIoT;

-- Agregacions per hora
SELECT 
    SensorID,
    DATEPART(HOUR, Timestamp) AS Hora,
    AVG(Temperatura) AS TempMitjana,
    MIN(Temperatura) AS TempMinima,
    MAX(Temperatura) AS TempMaxima
FROM SensorsIoT
WHERE Timestamp >= DATEADD(DAY, -1, GETDATE())
GROUP BY SensorID, DATEPART(HOUR, Timestamp);
```

---

## Conclusió

Els **Columnstore Indexes** són una tecnologia revolucionària per a analítica i data warehousing:

### Beneficis clau:
- 10-100x més ràpid per consultes analítiques
- 10-20x menys espai gràcies a la compressió
- Batch mode processing automàtic
- Ideal per agregacions i Business Intelligence

### Recordar:
- Usar en taules grans (més de 1M files)
- Optimitzar per OLAP, no OLTP
- Combinar amb rowstore per arquitectures híbrides
- Monitoritzar i mantenir regularment

**Els columnstore indexes han canviat com emmagatzemem i consultem grans volums de dades en SQL Server.**
