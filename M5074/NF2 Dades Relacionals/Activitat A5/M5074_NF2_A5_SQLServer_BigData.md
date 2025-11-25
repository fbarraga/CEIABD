# M5074 - BigData i IA

## Activitat: Optimització de Bases de Dades SQL Server per grans volums d'informació

## Criteris d'Avaluació

| Criteri | Pes | Descripció |
|---------|-----|------------|
| **Funcionalitat** | 30% | El sistema funciona correctament |
| **Rendiment** | 25% | Millores mesurables de rendiment |
| **Qualitat del codi** | 20% | Scripts ben estructurats i comentats |
| **Documentació** | 15% | Documentació completa i clara |
| **Presentació** | 10% | Comunicació efectiva dels resultats |

## Objectius d'Aprenentatge

En completar aquesta activitat, els alumnes hauran:

* Configurat correctament SQL Server per grans volums
* Implementat estratègies d'indexació efectives
* Utilitzat columnstore per anàlisi massiva
* Particionat taules per millorar rendiment i manteniment
* Optimitzat consultes complexes
* Creat processos de manteniment automàtic
* Mesurat i documentat millores de rendiment

## Recursos Addicionals

### Documentació Oficial

* [SQL Server Index Design Guide](https://docs.microsoft.com/sql/relational-databases/sql-server-index-design-guide)
* [Columnstore Indexes Guide](https://docs.microsoft.com/sql/relational-databases/indexes/columnstore-indexes-overview)
* [Partitioned Tables and Indexes](https://docs.microsoft.com/sql/relational-databases/partitions/partitioned-tables-and-indexes)

### Eines Recomanades

* SQL Server Management Studio (SSMS)
* Azure Data Studio
* SQL Server Profiler
* Database Engine Tuning Advisor

### Lectures Recomanades

* "SQL Server 2019 Administration Inside Out" - William Assaf
* "Expert Performance Indexing" - Jason Strate & Grant Fritchey

## Consells per l'Èxit

1. **Mesurar sempre abans i després** - No optimitzeu sense dades!
2. **Documentar tot el procés** - Serà útil per la memòria final
3. **Començar amb petits canvis** - Optimitzar gradualment
4. **Utilitzar el Query Store** - És una eina potentíssima
5. **Fer backups regulars** - Abans de canvis importants
6. **Compartir experiències** - Aprendre i compartir amb els companys

---

## Índex d'Exercicis

1. [Creació de BD i càrrega inicial de dades](#exercici-1-creació-de-la-base-de-dades-i-càrrega-inicial)
2. [Exercicis de Configuració i Baseline](#exercici-2-configuració-i-anàlisi-baseline)
3. [Exercicis d'Indexació](#exercici-3-optimització-amb-índexs)
4. [Exercicis de Columnstore](#exercici-4-columnstore-indexes)
5. [Exercicis de Particionament](#exercici-5-particionament-de-taules)
6. [Exercicis d'Optimització Avançada](#exercici-6-optimització-avançada)
7. [Projecte Final](#exercici-7-projecte-final) **OPCIONAL**

---

## Exercici 1 Creació de la Base de dades i càrrega inicial

### Objectius E1

* Utilització de SQL Management Studio
* Repàs de comandes DDL
* Repàs de Python y T-SQL
* Processos de càrrega de dades

### Tasques E1

#### 1.1 Execució i Anàlisi de Scripts

* Executar els scripts en ordre:

  1. [Part1_CreacioBaseDades.sql](./Part1_CreacioBaseDades.sql)
  2. [Part2A_GenerarDades.py](./Part2A_GenerarDades.py)
  3. [Part2B_GenerarDades.sql](./Part2B_GenerarDades.sql)
  4. Part3_AnalisiRendiment.sql(./Part3_Analisi_rendiment_inicial)

* Depenen de la màquina que tingueu no agafeu la generació de més de 100000 comandes ja que us tardarà molt.
* Utilitzeu el mateix número de ítems per Python que per T-SQL.

#### 1.2 Execució i Anàlisi de Scripts

* 1.2.1. Durant la creació de la base de dades estem activant constraints. És una bona pràctica?
* 1.2.2. Quant temps ha trigat la càrrega de dades de les dues maneres? Fes-ho detalladament per cadascuna de les taules i mètodes.
* 1.2.3 Quin és el tamany total de la base de dades?
* 1.2.4 Quantes pàgines de dades té la taula més gran? Quina importància tenen les pàgines de dades i la seva grandària?
* 1.2.5 Prova a modificar l'script en Python per generar un fitxer CSV i carregar el fitxer directament a través d'un procés bulk. El fitxer ha d'estar en una carpeta del servidor.
* 1.2.6 Finalment quin és el millor procés per carregar dades? Fes la comparativa de temps.

```sql
BULK INSERT dbo.TuTabla
FROM 'C:\ruta\archivo.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,  -- Si tiene encabezados
    TABLOCK
);
```

---

## Exercici 2 Configuració i Anàlisi Baseline

### Objectius E2

* Entendre la configuració inicial del servidor
* Establir mètriques baseline
* Identificar coll d'ampolla inicials
* Justifica quin mètode ha trigat més en generar les dades.

### Tasques E2

#### 2.1 Revisa la configuració inicial del servidor

Comenta breument perquè serveix cadascun dels paràmetres que analitza en el script Part3_Analisi_rendiment_inicial.sql a la secció 1 (SGBD) i a la secció 3 (BD)

#### 2.2 Anàlisi de les Consultes Baseline

Executeu les 6 consultes de prova de la Part3 secció 4 i documenteu:

| Consulta | CPU Time (ms) | Elapsed Time (ms) | Logical Reads | Physical Reads |
|----------|---------------|-------------------|---------------|----------------|
| Test 1   |               |                   |               |                |
| Test 2   |               |                   |               |                |
| Test 3   |               |                   |               |                |
| Test 4   |               |                   |               |                |
| Test 5   |               |                   |               |                |
| Test 6   |               |                   |               |                |

Què pot indicar que una consulta estigui fent molts Physical Reads?

### 2.3 Identificació de Problemes

Executeu aquests scripts i documenteu els resultats:

```sql
-- 1. Índexs no utilitzats
SELECT * FROM sys.dm_db_index_usage_stats 
WHERE database_id = DB_ID() AND user_seeks = 0 AND user_scans = 0;

-- 2. Missing Indexes
SELECT * FROM sys.dm_db_missing_index_details WHERE database_id = DB_ID();

-- 3. Fragmentació
SELECT 
    OBJECT_NAME(object_id) AS Taula,
    index_id,
    avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 10
ORDER BY avg_fragmentation_in_percent DESC;
```

**Preguntes:*

* Realitza l'informe amb les mètriques baseline i llista de problemes identificats. Proposa accions que es podrien fer per milllorar la fragmentació.

---

## Exercici 3 Optimització amb Índexs

### Objectius E3

* Crear índexs adequats per millorar consultes
* Comparar diferents tipus d'índexs
* Entendre covering indexes i filtered indexes

### Tasques E3

#### 3.1 Implementació d'Índexs Bàsics

**Escenari:** Cal optimitzar aquestes consultes freqüents:

* 3.1.1 Crear índexs apropiats per cada consulta
* 3.1.2 Mesurar el rendiment abans i després
* 3.1.3 Documentar els resultats

```sql
-- Consulta A: Comandes d'un client específic
SELECT * FROM Comandes WHERE ClientID = 12345;

-- Consulta B: Productes d'una categoria
SELECT * FROM Productes 
WHERE JerarquiaProducteID = 5 AND Actiu = 1;

-- Consulta C: Factures pendents de pagament
SELECT * FROM Factures 
WHERE Estat = 'Pendent' AND DataVenciment < GETDATE();
```

| Consulta | Abans (ms) | Després (ms) | Millora (%) | Tipus d'Índex |
|----------|------------|--------------|-------------|---------------|
| A        |            |              |             |               |
| B        |            |              |             |               |
| C        |            |              |             |               |

#### 3.2 Covering Indexes

**Escenari:** Aquesta consulta s'executa milers de cops al dia:

* 3.2.1 Analitzar el pla d'execució actual. Inclou printscreens d'abans i després d'aplicar millores.
* 3.2.2 Identificar [Key Lookups o RID Lookups](./doc00_key_rid_lookup.md)
* 3.2.3 Crear un covering index (Un covering index en SQL Server es un índex que inclou totes les columnes necessaries per una consulta, evitant així que el motor hagi d'accedir a la taula base.) que elimini els lookups
* 3.2.4 Comparar el rendiment

**Pistes:**

* Utilitzar INCLUDE per columnes addicionals
* Ordre de columnes: igualtat → desigualtat → inclusió

```sql
SELECT 
    c.NumeroComanda,
    c.DataComanda,
    cl.NomClient,
    cl.Email,
    c.ImportTotal
FROM Comandes c
INNER JOIN Clients cl ON c.ClientID = cl.ClientID
WHERE c.DataComanda >= DATEADD(MONTH, -1, GETDATE())
    AND c.Estat = 'Entregat';
```

#### 3.3 Filtered Indexes

Els [filtered index](./doc01_filtered-indexes-sqlserver.md) són indexs que només indexen un subconjunt de files d'una taula.

**Escenari:** El 95% de les consultes sobre Comandes són només per estats actius ('Pendent', 'Processat', 'Enviat').

* 3.3.1. Crear un filtered index només per estats actius
* 3.3.2. Comparar el tamany amb un índex normal
* 3.3.3. Mesurar el rendiment en consultes sobre estats actius vs tots els estats

```sql
-- Comparativa de tamany
SELECT 
    i.name,
    i.type_desc,
    SUM(ps.used_page_count) * 8 / 1024.0 AS TamanyMB
FROM sys.indexes i
INNER JOIN sys.dm_db_partition_stats ps ON i.object_id = ps.object_id
WHERE i.object_id = OBJECT_ID('Comandes')
GROUP BY i.name, i.type_desc;
```

#### 3.4 Índexs Compostos

Els [Índexs Compostos](./doc02_composite-indexes-sqlserver.md) són índexs que combinen dues o més columnes. L'ordre de les columnes és crucial i determina quines consultes es poden optimitzar eficientment. Funcionen com una guia telefònica: primer ordenen per cognom, després per nom, després per ciutat.

**Escenari:** Crear l'índex òptim per aquesta consulta analítica:

```sql
SELECT 
    YEAR(DataComanda) AS Any,
    MONTH(DataComanda) AS Mes,
    ClientID,
    COUNT(*) AS NumComandes,
    SUM(ImportTotal) AS TotalVendes
FROM Comandes
WHERE DataComanda BETWEEN '2024-01-01' AND '2024-12-31'
    AND Estat IN ('Entregat', 'Enviat')
GROUP BY YEAR(DataComanda), MONTH(DataComanda), ClientID;
```

* 3.4.1. Determinar l'ordre òptim de columnes
* 3.4.2. Decidir quines columnes incloure amb INCLUDE
* 3.4.3. Implementar i provar

**Lliurable:** Document amb tots els índexs creats, scripts i comparatives de rendiment.

---

## Exercici 4 Columnstore Indexes

Els [Columnstore Indexes](./doc03_columnstore-indexes-sqlserver.md) són índexs que emmagatzemen dades per columnes en lloc de per files. Ofereixen una compressió massiva (10-20x) i un rendiment extraordinari per a consultes analítiques, agregacions i escanejos de grans volums de dades.

### Objectius E4

* Implementar columnstore indexes
* Comparar rowstore vs columnstore per anàlisi
* Entendre la compressió de dades

### Tasques E4

#### 4.1 Creació de Taula Analítica amb Columnstore

Crear una taula d'anàlisi de vendes amb columnstore clustered index.

```sql
-- 1. Crear taula amb dades denormalitzades
SELECT 
    c.ComandaID,
    c.DataComanda,
    YEAR(c.DataComanda) AS Any,
    MONTH(c.DataComanda) AS Mes,
    DATEPART(QUARTER, c.DataComanda) AS Trimestre,
    DATENAME(WEEKDAY, c.DataComanda) AS DiaSemana,
    c.ClientID,
    -- COMPLETAR: Afegir més columnes rellevants
INTO VendesAnalisi_Alumne
FROM Comandes c
INNER JOIN Clients cl ON c.ClientID = cl.ClientID
INNER JOIN LiniesComanda lc ON c.ComandaID = lc.ComandaID
INNER JOIN Productes p ON lc.ProducteID = p.ProducteID;

-- 2. Crear columnstore clustered index
-- COMPLETAR

-- 3. Mesurar compressió
```

**Preguntes:**

- Quina és la ràtio de compressió aconseguida?
- Quin és el tamany abans i després del columnstore?

#### 4.2 Comparativa Rowstore vs Columnstore

Executeu aquestes consultes analítiques en ambdues versions:

```sql
-- Query 1: Agregació simple
SELECT 
    Anyo, Mes,
    COUNT(*) AS NumVendes,
    SUM(ImportTotal) AS TotalVendes,
    AVG(ImportTotal) AS MitjanaVenda
FROM [TAULA]
GROUP BY Any, Mes
ORDER BY Any, Mes;

-- Query 2: Anàlisi per múltiples dimensions
SELECT 
    TipusClient,
    Departament,
    Anyo,
    SUM(Quantitat) AS TotalUnitats,
    SUM(ImportLinia) AS TotalFacturat
FROM [TAULA]
GROUP BY TipusClient, Departament, Any;

-- Query 3: Top productes
SELECT TOP 100
    ProducteID,
    SUM(Quantitat) AS TotalVenuts,
    SUM(ImportLinia) AS TotalFacturat
FROM [TAULA]
GROUP BY ProducteID
ORDER BY TotalFacturat DESC;
```

**Documentar:**

| Query | Rowstore Time | Columnstore Time | Millora | Logical Reads Before | Logical Reads After |
|-------|---------------|------------------|---------|----------------------|---------------------|
| 1     |               |                  |         |                      |                     |
| 2     |               |                  |         |                      |                     |
| 3     |               |                  |         |                      |                     |

#### 4.3 Nonclustered Columnstore (HTAP)

**Escenari:** Voleu mantenir la taula Comandes optimitzada per OLTP però afegir capacitat analítica.

**Tasques:**

1. Crear un nonclustered columnstore index a Comandes
2. Provar consultes OLTP (INSERT, UPDATE, SELECT puntuals)
3. Provar consultes analítiques (agregacions)
4. Documentar l'impacte en cada tipus de càrrega

**Lliurable:** Informe amb comparatives, gràfics de rendiment i conclusions sobre quan usar columnstore.

---

## Exercici 5 Particionament de Taules

El [Particionament](./doc04_table-partitioning-sqlserver.md) divideix una taula gran en múltiples fragments més petits (particions) basant-se en una columna. Cada partició es gestiona independentment però es consulta com una sola taula, millorant el rendiment i la mantenibilitat de taules massives.

### Objectius E5

- Implementar particionament temporal
- Gestionar particions (SPLIT/MERGE/SWITCH)
- Verificar partition elimination

### Tasques E5

#### 5.1 Implementació de Particionament

**Tasca:** Particionar la taula Factures per trimestres dels últims 2 anys.

```sql
-- 1. Crear partition function
CREATE PARTITION FUNCTION PF_Factures_Trimestral (DATETIME2)
AS RANGE RIGHT FOR VALUES (
    -- COMPLETAR amb límits trimestrals
);

-- 2. Crear partition scheme
-- COMPLETAR

-- 3. Crear taula particionada
-- COMPLETAR

-- 4. Migrar dades
-- COMPLETAR
```

#### 5.2 Verificació de Partition Elimination

* 5.2.1 Activar el pla d'execució gràfic (Ctrl+M)
* 5.2.2 Executar aquestes consultes:

```sql
-- Consulta A: Amb filtre de data (hauria d'accedir poques particions)
SELECT COUNT(*), SUM(ImportTotal)
FROM FacturesParticionades
WHERE DataFactura >= '2025-01-01' AND DataFactura < '2025-04-01';

-- Consulta B: Sense filtre de data (accedeix totes)
SELECT COUNT(*), SUM(ImportTotal)
FROM FacturesParticionades;

-- Consulta C: Filtre no alineat amb particionament
SELECT COUNT(*), SUM(ImportTotal)
FROM FacturesParticionades
WHERE ClientID = 12345;
```

* 5.2.3 Al pla d'execució, identificar "Actual Partition Count"
* 5.2.4 Documentar quantes particions s'accedeixen en cada cas

**Preguntes:**

- Per què la Consulta C no beneficia del partition elimination?
- Com podríeu optimitzar-la?

#### 5.3 Gestió de Particions - Sliding Window

**Escenari:** Cal implementar un procés automàtic que:

* Cada mes afegeixi una nova partició
* Elimini particions amb més de 2 anys

**Tasques:**

1. Implementar el procediment sp_SlidingWindowFactures
2. Simular l'execució per 6 mesos
3. Verificar que les particions antigues s'eliminen
4. Documentar el procés

#### 5.4 Càrrega amb SWITCH Partition

**Escenari:** Cal carregar 500.000 factures noves del mes actual de forma eficient.

**Tasques:**

1. Crear taula staging amb les mateixes característiques
2. Carregar dades a staging
3. Crear índexs a staging
4. Executar SWITCH
5. Comparar temps amb INSERT directe

```sql
-- Mètode 1: INSERT directe
SET STATISTICS TIME ON;
INSERT INTO FacturesParticionades SELECT ...
-- Temps: ?

-- Mètode 2: SWITCH
CREATE TABLE FacturesStaging ...
INSERT INTO FacturesStaging SELECT ...
CREATE INDEX ...
ALTER TABLE FacturesStaging SWITCH TO FacturesParticionades PARTITION X;
-- Temps: ?
```

**Lliurable:** Informe complet sobre particionament amb scripts, mètriques i recomanacions.

---

## Exercici 6 Optimització Avançada

### Objectius E6

- Optimitzar consultes complexes
- Utilitzar Query Store
- Implementar manteniment automàtic

### Tasques E6

#### 6.1 Optimització de Consulta Complexa

**Consulta problemàtica:**

```sql
SELECT 
    c.ClientID,
    cl.NomClient,
    COUNT(DISTINCT co.ComandaID) AS NumComandes,
    COUNT(DISTINCT lc.ProducteID) AS ProductesUnics,
    SUM(lc.Quantitat) AS TotalUnitats,
    SUM(lc.ImportLinia) AS TotalGastat,
    AVG(co.ImportTotal) AS MitjanaComanda,
    MAX(co.DataComanda) AS DarreraCompra,
    (SELECT TOP 1 p.NomProducte 
     FROM LiniesComanda lc2 
     INNER JOIN Productes p ON lc2.ProducteID = p.ProducteID
     WHERE lc2.ComandaID IN (SELECT ComandaID FROM Comandes WHERE ClientID = c.ClientID)
     GROUP BY p.NomProducte
     ORDER BY SUM(lc2.Quantitat) DESC) AS ProducteFavorit
FROM Clients c
LEFT JOIN Comandes co ON c.ClientID = co.ClientID
LEFT JOIN LiniesComanda lc ON co.ComandaID = lc.ComandaID
INNER JOIN JerarquiaClients jc ON c.JerarquiaClientID = jc.JerarquiaClientID
WHERE co.DataComanda >= DATEADD(YEAR, -1, GETDATE())
    AND jc.Nivell1 = 'Empresa'
GROUP BY c.ClientID, cl.NomClient
HAVING COUNT(DISTINCT co.ComandaID) > 5
ORDER BY TotalGastat DESC;
```

**Tasques:**

* 6.1.1 Analitzar el pla d'execució actual
* 6.1.2 Identificar els operadors més costosos
* 6.1.3 Proposar i implementar millores (índexs, reescriptura, etc.)
*6.1.4 Documentar la millora aconseguida

**Pistes:**

* Eliminar la subquery correlacionada
* Crear índexs apropiats
* Considerar materialitzar resultats intermedis

#### 6.2 Query Store Analysis

**Tasques:**

1. Activar Query Store si no està actiu
2. Executar les consultes de l'exercici anterior diverses vegades
3. Analitzar al Query Store:
   - Top queries per durada
   - Queries amb regressió de rendiment
   - Plans d'execució forçats

```sql
-- Consultar Query Store
SELECT 
    qsq.query_id,
    qsqt.query_sql_text,
    qsrs.count_executions,
    qsrs.avg_duration / 1000.0 AS avg_duration_ms,
    qsrs.avg_logical_io_reads
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qsqt ON qsq.query_text_id = qsqt.query_text_id
JOIN sys.query_store_plan qsp ON qsq.query_id = qsp.query_id
JOIN sys.query_store_runtime_stats qsrs ON qsp.plan_id = qsrs.plan_id
WHERE qsrs.last_execution_time >= DATEADD(HOUR, -1, GETDATE())
ORDER BY qsrs.avg_duration DESC;
```

#### 6.3 Manteniment Automàtic

**Tasca:** Crear un SQL Agent Job (o documentar el procediment) que:

1. **Diàriament:**
   - Actualitzar estadístiques de taules grans
   - Reorganitzar índexs amb 10-30% fragmentació

2. **Setmanalment:**
   - Rebuild índexs amb >30% fragmentació
   - Purgar dades antigues de staging tables
   - Generar informe d'ús d'índexs

3. **Mensualment:**
   - Executar sliding window
   - Anàlisi de creixement de taules
   - Identificar i eliminar índexs no utilitzats

**Crear scripts per:**

```sql
-- Script 1: Manteniment diari
CREATE PROCEDURE sp_MantenimentDiari AS
BEGIN
    -- COMPLETAR
END;

-- Script 2: Manteniment setmanal
CREATE PROCEDURE sp_MantenimentSetmanal AS
BEGIN
    -- COMPLETAR
END;

-- Script 3: Manteniment mensual
CREATE PROCEDURE sp_MantenimentMensual AS
BEGIN
    -- COMPLETAR
END;
```

**Lliurable:** Scripts complets de manteniment i documentació d'execució.

---

## Exercici 7 Projecte Final

### Objectiu E7

Aplicar tots els coneixements en un escenari real i complet.

### Escenari 

Una empresa de comerç electrònic amb:

* 500.000 clients
* 50.000 productes
* 5 milions de comandes (3 anys d'històric)
* 20 milions de línies de comanda
* Sistema híbrid: transaccional + analític

### Requisits del Projecte

#### 1. Arquitectura de Dades (20%)

Dissenyar i implementar:

* Estratègia de particionament per taules transaccionals
* Taules analítiques amb columnstore
* Política de retenció de dades (mantenir 3 anys)
* Distribució en filegroups

**Lliurable:** Diagrama d'arquitectura i scripts DDL

#### 2. Optimització de Consultes (30%)

Optimitzar aquestes consultes clau del negoci:

**A. Dashboard executiu (temps real)**

```sql
-- Vendes avui, aquesta setmana, aquest mes
-- Top 10 productes
-- Top 10 clients
-- Comandes pendents
```

**B. Anàlisi de tendències**

```sql
-- Evolució mensual de vendes per categoria
-- Anàlisi de cohorts de clients
-- Productes amb més creixement
```

**C. Operacions transaccionals**

```sql
-- Crear comanda nova
-- Actualitzar estat comanda
-- Cerca de productes
-- Històric de client
```

**Lliurable:** 

- Índexs creats
- Comparativa abans/després
- Plans d'execució optimitzats

#### 3. Processos ETL (20%)

Implementar:

**A. Càrrega incremental diària**

- Carregar noves comandes del dia
- Actualitzar taules analítiques
- Utilitzar SWITCH si és apropiat

**B. Càrrega històrica mensual**

- Consolid dades del mes tancat
- Actualitzar agregacions
- Arxivar dades antigues

**Lliurable:** Procediments ETL complets i documentats

#### 4. Monitorització i Manteniment (15%)

Crear un sistema complet de:

**A. Monitorització**

- Dashboard amb mètriques clau (Query Store)
- Alertes per consultes lentes
- Seguiment de creixement

**B. Manteniment**

- Jobs automàtics (diari, setmanal, mensual)
- Gestió de particions
- Optimització d'índexs

**Lliurable:** Scripts de monitorització i jobs configurats

#### 5. Documentació i Presentació (15%)

**Document tècnic amb:**

1. Introducció i objectius
2. Arquitectura implementada
3. Optimitzacions realitzades
4. Mètriques de rendiment (abans/després)
5. Proves de càrrega i resultats
6. Conclusions i recomanacions

**Presentació (15 minuts):**

- Demostració en viu
- Resultats aconseguits
- Lliçons apreses



[def]: #exercici-1:-creació-de-la-base-de-dades-i-carrega-inicial
