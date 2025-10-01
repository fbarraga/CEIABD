# Filtered Indexes en SQL Server

Els **Filtered Indexes** (índexs filtrats) són índexs no clúster que inclouen només un subconjunt de files d'una taula, definit per una condició WHERE.

## Característiques principals

- **Només indexen part de les dades**: Utilitzen una clàusula WHERE per filtrar quines files s'inclouen
- **Més eficients**: Ocupen menys espai i són més ràpids de mantenir
- **Millor rendiment**: Ideals per a consultes que sempre filtren pels mateixos criteris
- **Disponibles des de**: SQL Server 2008

## Sintaxi bàsica

```sql
CREATE NONCLUSTERED INDEX IX_NomIndex
ON NomTaula (Columna1, Columna2)
WHERE CondicióFiltre;
```

## Exemples pràctics

### Exemple 1: Indexar només registres actius

```sql
-- Taula amb molts registres inactius
CREATE TABLE Clients (
    ClientID INT PRIMARY KEY,
    Nom VARCHAR(100),
    Email VARCHAR(100),
    Actiu BIT,
    DataAlta DATE
);

-- Filtered index només per clients actius
CREATE NONCLUSTERED INDEX IX_Clients_Actius
ON Clients (Nom, Email)
WHERE Actiu = 1;

-- Aquesta consulta usarà l'índex filtrat
SELECT Nom, Email
FROM Clients
WHERE Actiu = 1 AND Nom LIKE 'Mar%';
```

### Exemple 2: Indexar només valors no nuls

```sql
CREATE TABLE Comandes (
    ComandaID INT PRIMARY KEY,
    ClientID INT,
    DataComanda DATE,
    DataEnviament DATE NULL,
    Total DECIMAL(10,2)
);

-- Index només per comandes pendents d'enviament
CREATE NONCLUSTERED INDEX IX_Comandes_Pendents
ON Comandes (DataComanda, ClientID)
WHERE DataEnviament IS NULL;

-- Consulta optimitzada
SELECT ComandaID, ClientID, DataComanda
FROM Comandes
WHERE DataEnviament IS NULL
ORDER BY DataComanda;
```

### Exemple 3: Indexar rang de dates

```sql
-- Index només per registres recents (últims 6 mesos)
CREATE NONCLUSTERED INDEX IX_Vendes_Recents
ON Vendes (DataVenda, Import)
WHERE DataVenda >= DATEADD(MONTH, -6, GETDATE());

-- O per un any específic
CREATE NONCLUSTERED INDEX IX_Vendes_2024
ON Vendes (Mes, Import)
WHERE YEAR(DataVenda) = 2024;
```

### Exemple 4: Combinació de condicions

```sql
CREATE TABLE Productes (
    ProducteID INT PRIMARY KEY,
    Nom VARCHAR(100),
    Preu DECIMAL(10,2),
    Stock INT,
    Categoria VARCHAR(50),
    Actiu BIT
);

-- Index per productes actius amb stock baix en categoria específica
CREATE NONCLUSTERED INDEX IX_Productes_StockBaix
ON Productes (Nom, Stock, Preu)
WHERE Actiu = 1 
  AND Stock < 10 
  AND Categoria = 'Electrònica';
```

## Avantatges dels Filtered Indexes

### 1. **Estalvi d'espai**
- Només indexen les files rellevants
- Redueixen l'ús de disc significativament

```sql
-- Exemple: 1 milió de clients, només 50.000 actius
-- Index tradicional: indexa 1.000.000 files
-- Filtered index: indexa només 50.000 files (95% menys espai)
```

### 2. **Manteniment més ràpid**
- Les operacions INSERT/UPDATE/DELETE són més ràpides
- Només s'actualitza l'índex si la fila compleix el filtre

### 3. **Millor rendiment de consultes**
- Plans d'execució més eficients
- Menys pàgines d'índex per llegir

### 4. **Estadístiques més precises**
- Les estadístiques són més representatives del subconjunt utilitzat
- Millors decisions de l'optimitzador de consultes

## Limitacions i consideracions

### Restriccions de la clàusula WHERE

**ES PODEN usar:**
- Comparacions simples: `=, <>, >, >=, <, <=`
- Operadors lògics: `AND, OR, NOT`
- `IS NULL` i `IS NOT NULL`
- `IN` amb valors constants

**NO ES PODEN usar:**
- Subconsultes
- Funcions no deterministes (`GETDATE()`, `NEWID()`)
- Columnes computades
- Tipus de dades: `text`, `ntext`, `image`, `varchar(max)`, `nvarchar(max)`, `varbinary(max)`, `xml`
- Operador `LIKE`

### Exemple de limitacions

```sql
-- ✓ CORRECTE
CREATE NONCLUSTERED INDEX IX_Valid1
ON Taula (Col1)
WHERE Col2 = 'Valor' AND Col3 > 100;

CREATE NONCLUSTERED INDEX IX_Valid2
ON Taula (Col1)
WHERE Col2 IN ('A', 'B', 'C');

-- ✗ INCORRECTE
CREATE NONCLUSTERED INDEX IX_Invalid1
ON Taula (Col1)
WHERE DataCreacio > GETDATE(); -- Funció no determinista

CREATE NONCLUSTERED INDEX IX_Invalid2
ON Taula (Col1)
WHERE Nom LIKE 'A%'; -- LIKE no permès

CREATE NONCLUSTERED INDEX IX_Invalid3
ON Taula (Col1)
WHERE Col2 IN (SELECT Val FROM AltraTaula); -- Subconsulta no permesa
```

## Quan usar Filtered Indexes

### Casos d'ús ideals:

1. **Columnes amb valors molt desiguals**
   - 95% de registres tenen `Estat = 'Actiu'`
   - Només consultes els actius

2. **Valors NULL predominants**
   - La majoria de files tenen `DataEnviament IS NULL`
   - Només t'interessen les comandes pendents

3. **Particions lògiques**
   - Diferents índexs per diferents categories/tipus
   - Consultes que sempre filtren per categoria

4. **Dades històriques vs actuals**
   - Index per dades recents (últims 3 mesos)
   - Les consultes rares vegades toquen dades antigues

5. **Estats del cicle de vida**
   - Comandes: Pendent, Processant, Completat, Cancel·lat
   - Cada estat necessita un índex diferent

## Comparació: Index Normal vs Filtered Index

```sql
-- Escenari: Taula amb 1 milió de clients, 50.000 actius

-- Opció 1: Index tradicional
CREATE NONCLUSTERED INDEX IX_Clients_Tradicional
ON Clients (Nom, Email);
-- Espai: ~100 MB
-- Manteniment: Cada INSERT/UPDATE/DELETE actualitza l'índex

-- Opció 2: Filtered index
CREATE NONCLUSTERED INDEX IX_Clients_Filtrat
ON Clients (Nom, Email)
WHERE Actiu = 1;
-- Espai: ~5 MB (95% menys)
-- Manteniment: Només es toca si Actiu = 1

-- Consulta que es beneficia
SELECT Nom, Email
FROM Clients
WHERE Actiu = 1 AND Nom LIKE 'M%';
-- Amb filtered index: Molt més ràpid i eficient
```

## Verificar que s'usa el Filtered Index

```sql
-- 1. Veure el pla d'execució
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Nom, Email
FROM Clients
WHERE Actiu = 1;

-- 2. Consultar metadades de l'índex
SELECT 
    i.name AS IndexName,
    i.filter_definition AS FilterCondition
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('Clients')
  AND i.has_filter = 1;
```

## Consells i millors pràctiques

1. **Analitza les teves consultes**: Identifica filtres que sempre apliques
2. **Revisa la distribució de dades**: Els filtered indexes són millors quan filtren una minoria de files
3. **Combina amb INCLUDE**: Crea covering filtered indexes per màxima eficiència
4. **Manteniment**: Els filtered indexes requereixen menys manteniment que els tradicionals
5. **Monitoritza l'ús**: Usa DMVs per verificar que s'utilitzen els índexs

```sql
-- Estadístiques d'ús d'índexs
SELECT 
    OBJECT_NAME(s.object_id) AS TableName,
    i.name AS IndexName,
    i.filter_definition,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i 
    ON s.object_id = i.object_id 
    AND s.index_id = i.index_id
WHERE i.has_filter = 1
ORDER BY s.user_seeks + s.user_scans + s.user_lookups DESC;
```

## Resum

| Aspecte | Index Tradicional | Filtered Index |
|---------|------------------|----------------|
| **Files indexades** | Totes | Només les que compleixen el filtre |
| **Espai en disc** | Més gran | Més petit (pot ser 50-95% menys) |
| **Rendiment de consultes** | Bo | Excel·lent (per consultes filtrades) |
| **Cost de manteniment** | Alt | Baix |
| **Complexitat** | Simple | Requereix anàlisi de patrons de consulta |
| **Cas d'ús** | General | Consultes amb filtres constants |

---

**Conclusió**: Els Filtered Indexes són una eina potent per optimitzar el rendiment quan les teves consultes sempre filtren per les mateixes condicions. Estalvien espai, milloren el rendiment i redueixen el cost de manteniment.
