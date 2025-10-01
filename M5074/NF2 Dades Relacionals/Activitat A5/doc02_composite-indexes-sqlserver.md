# Índexs Compostos en SQL Server

Els **Índexs Compostos** (o Composite Indexes) són índexs que inclouen dues o més columnes. L'ordre de les columnes és **crucial** per al rendiment de les consultes.

## Característiques principals

- **Múltiples columnes**: Combinen dues o més columnes en un sol índex
- **Ordre importa**: La seqüència de les columnes determina l'eficiència
- **Versàtils**: Poden servir per diferents consultes segons l'ordre
- **Més eficients**: Millor que crear múltiples índexs d'una sola columna

## Sintaxi bàsica

```sql
CREATE NONCLUSTERED INDEX IX_NomIndex
ON NomTaula (Columna1, Columna2, Columna3)
INCLUDE (ColumnaAddicional1, ColumnaAddicional2);
```

## Com funcionen: Analogia amb la guia telefònica

Imagina una guia telefònica ordenada per:
1. **Cognom** (primera columna)
2. **Nom** (segona columna)
3. **Ciutat** (tercera columna)

```
García, Anna, Barcelona
García, Anna, Madrid
García, Joan, Barcelona
García, Marc, València
Martínez, Laura, Barcelona
```

### Consultes eficients (segueixen l'ordre):

✓ **Buscar per cognom**: "García" → Molt ràpid
✓ **Buscar per cognom + nom**: "García, Anna" → Molt ràpid
✓ **Buscar per cognom + nom + ciutat**: "García, Anna, Barcelona" → Molt ràpid

### Consultes ineficients (no segueixen l'ordre):

✗ **Buscar només per nom**: "Anna" → Has de revisar tota la guia
✗ **Buscar només per ciutat**: "Barcelona" → Has de revisar tota la guia
✗ **Buscar per nom + ciutat**: "Anna, Barcelona" → Ineficient

## La regla d'or: Ordre de les columnes

### Principi fonamental

L'ordre de les columnes en un índex compost ha de seguir aquesta prioritat:

1. **Igualtat** (`=`) → Columnes amb condicions d'igualtat
2. **Rang** (`>, <, BETWEEN`) → Columnes amb condicions de rang
3. **Ordenació** (`ORDER BY`) → Columnes utilitzades per ordenar

```sql
-- Consulta:
SELECT * 
FROM Comandes
WHERE ClientID = 123        -- Igualtat
  AND DataComanda >= '2024-01-01'  -- Rang
ORDER BY Total DESC;        -- Ordenació

-- Índex òptim:
CREATE NONCLUSTERED INDEX IX_Comandes_Optim
ON Comandes (ClientID, DataComanda, Total);
--              ↑           ↑          ↑
--          Igualtat     Rang     Ordenació
```

## Exemples pràctics

### Exemple 1: Índex bàsic de dues columnes

```sql
CREATE TABLE Empleats (
    EmpleatID INT PRIMARY KEY,
    Nom VARCHAR(100),
    Departament VARCHAR(50),
    Ciutat VARCHAR(50),
    Salari DECIMAL(10,2)
);

-- Índex compost per departament i ciutat
CREATE NONCLUSTERED INDEX IX_Empleats_Dept_Ciutat
ON Empleats (Departament, Ciutat);

-- ✓ Consultes que s'aprofiten de l'índex:
SELECT * FROM Empleats 
WHERE Departament = 'Vendes';  -- Usa l'índex

SELECT * FROM Empleats 
WHERE Departament = 'Vendes' 
  AND Ciutat = 'Barcelona';  -- Usa l'índex completament

-- ✗ Consulta que NO usa l'índex eficientment:
SELECT * FROM Empleats 
WHERE Ciutat = 'Barcelona';  -- No pot usar l'índex (salta primera columna)
```

### Exemple 2: Tres columnes amb INCLUDE

```sql
CREATE TABLE Comandes (
    ComandaID INT PRIMARY KEY,
    ClientID INT,
    DataComanda DATE,
    Estat VARCHAR(20),
    Total DECIMAL(10,2)
);

-- Índex compost amb columnes addicionals
CREATE NONCLUSTERED INDEX IX_Comandes_Client_Data_Estat
ON Comandes (ClientID, DataComanda, Estat)
INCLUDE (Total);

-- Consulta coberta completament (covering index)
SELECT ClientID, DataComanda, Estat, Total
FROM Comandes
WHERE ClientID = 100
  AND DataComanda >= '2024-01-01'
  AND Estat = 'Pendent';
-- No necessita Key Lookup perquè Total està a INCLUDE
```

### Exemple 3: Ordre incorrecte vs correcte

```sql
-- ❌ INCORRECTE: Ordre subòptim
CREATE NONCLUSTERED INDEX IX_Productes_Mal
ON Productes (Categoria, Preu, Actiu);

-- Consulta amb igualtat a Actiu i rang a Preu
SELECT * FROM Productes
WHERE Actiu = 1           -- Igualtat
  AND Preu BETWEEN 10 AND 100  -- Rang
  AND Categoria = 'Electrònica';  -- Igualtat

-- ✓ CORRECTE: Igualtat primer, després rang
CREATE NONCLUSTERED INDEX IX_Productes_Be
ON Productes (Actiu, Categoria, Preu);
--              ↑        ↑         ↑
--          Igualtat  Igualtat   Rang
```

### Exemple 4: Múltiples consultes, un índex

```sql
CREATE TABLE Vendes (
    VendaID INT PRIMARY KEY,
    ClientID INT,
    ProducteID INT,
    DataVenda DATE,
    Quantitat INT,
    Import DECIMAL(10,2)
);

-- Un índex que serveix per múltiples consultes
CREATE NONCLUSTERED INDEX IX_Vendes_Multi
ON Vendes (ClientID, DataVenda, ProducteID)
INCLUDE (Quantitat, Import);

-- Consulta 1: Vendes per client
SELECT * FROM Vendes 
WHERE ClientID = 50;  -- ✓ Usa l'índex

-- Consulta 2: Vendes per client en un període
SELECT * FROM Vendes 
WHERE ClientID = 50 
  AND DataVenda BETWEEN '2024-01-01' AND '2024-12-31';  -- ✓ Usa l'índex

-- Consulta 3: Vendes per client, data i producte
SELECT * FROM Vendes 
WHERE ClientID = 50 
  AND DataVenda >= '2024-01-01'
  AND ProducteID = 100;  -- ✓ Usa l'índex completament

-- Consulta 4: Només per data
SELECT * FROM Vendes 
WHERE DataVenda = '2024-06-15';  -- ✗ NO usa l'índex eficientment
```

## El concepte de "Leftmost Prefix"

Un índex compost pot ser utilitzat per consultes que usen:
- La **primera columna**
- Les **dues primeres columnes**
- Les **tres primeres columnes**
- I així successivament...

Però **NO** pot ser usat eficientment si saltes la primera columna.

```sql
-- Índex: (A, B, C)

-- ✓ Consultes que poden usar l'índex:
WHERE A = valor
WHERE A = valor AND B = valor
WHERE A = valor AND B = valor AND C = valor
WHERE A = valor AND C = valor  -- Usa A, però no pot usar C eficientment

-- ✗ Consultes que NO poden usar l'índex:
WHERE B = valor
WHERE C = valor
WHERE B = valor AND C = valor
```

### Exemple pràctic de Leftmost Prefix

```sql
CREATE NONCLUSTERED INDEX IX_Exemple
ON Taula (Cognom, Nom, Edat);

-- ✓ Usa l'índex completament
SELECT * FROM Taula 
WHERE Cognom = 'García' 
  AND Nom = 'Anna' 
  AND Edat = 30;

-- ✓ Usa l'índex (Cognom + Nom)
SELECT * FROM Taula 
WHERE Cognom = 'García' 
  AND Nom = 'Anna';

-- ✓ Usa l'índex (només Cognom)
SELECT * FROM Taula 
WHERE Cognom = 'García';

-- ⚠️ Usa l'índex només per Cognom, Edat no s'aprofita
SELECT * FROM Taula 
WHERE Cognom = 'García' 
  AND Edat = 30;

-- ✗ NO usa l'índex eficientment (salta Cognom)
SELECT * FROM Taula 
WHERE Nom = 'Anna';

-- ✗ NO usa l'índex eficientment (salta Cognom)
SELECT * FROM Taula 
WHERE Nom = 'Anna' 
  AND Edat = 30;
```

## Selectivitat de les columnes

La **selectivitat** és la capacitat d'una columna per filtrar dades:

- **Alta selectivitat**: Pocs valors duplicats (ex: Email, DNI, ClientID)
- **Baixa selectivitat**: Molts valors duplicats (ex: Sexe, Actiu, Estat)

### Regla general

Col·loca les columnes **més selectives** primer en l'índex.

```sql
-- Exemple: Taula amb 1 milió de registres
-- - ClientID: 100.000 valors únics (alta selectivitat)
-- - Estat: 3 valors (baixa selectivitat: Pendent/Completat/Cancel·lat)

-- ✓ MILLOR: Columna selectiva primer
CREATE NONCLUSTERED INDEX IX_Comandes_Optim
ON Comandes (ClientID, Estat);

-- ✗ PITJOR: Columna poc selectiva primer
CREATE NONCLUSTERED INDEX IX_Comandes_Suboptim
ON Comandes (Estat, ClientID);

-- Per què? Amb ClientID primer:
-- WHERE ClientID = 123 AND Estat = 'Pendent'
-- → Filtra primer a ~10 comandes (ClientID), després a ~3 (Estat)

-- Amb Estat primer:
-- WHERE ClientID = 123 AND Estat = 'Pendent'
-- → Filtra primer a ~333.000 comandes (Estat), després a 1 (ClientID)
```

### Excepció: Patrons de consulta

Si les teves consultes **sempre** filtren per una columna específica, aquesta hauria d'anar primer independentment de la selectivitat.

```sql
-- Si SEMPRE consultes per Estat primer:
SELECT * FROM Comandes 
WHERE Estat = 'Pendent';  -- 90% de les teves consultes

-- Llavors aquest índex té sentit:
CREATE NONCLUSTERED INDEX IX_Comandes_Estat
ON Comandes (Estat, ClientID, DataComanda);
```

## Índexs compostos amb ORDER BY

L'ordre de les columnes també afecta les clàusules ORDER BY.

```sql
CREATE TABLE Articles (
    ArticleID INT PRIMARY KEY,
    Categoria VARCHAR(50),
    DataPublicacio DATE,
    Visites INT,
    Titol VARCHAR(200)
);

-- Índex per ordenació
CREATE NONCLUSTERED INDEX IX_Articles_Cat_Data
ON Articles (Categoria, DataPublicacio DESC)
INCLUDE (Titol, Visites);

-- ✓ Consulta que aprofita l'índex per filtrar i ordenar
SELECT Titol, DataPublicacio, Visites
FROM Articles
WHERE Categoria = 'Tecnologia'
ORDER BY DataPublicacio DESC;
-- Resultats ja estan ordenats a l'índex!

-- ⚠️ Consulta que necessita ordenació addicional
SELECT Titol, DataPublicacio, Visites
FROM Articles
WHERE Categoria = 'Tecnologia'
ORDER BY Visites DESC;
-- L'índex ajuda a filtrar, però ha d'ordenar per Visites
```

## Millors pràctiques

### ✓ Fer

1. **Analitza patrons de consulta** abans de crear índexs
2. **Segueix l'ordre**: Igualtat → Rang → Ordenació
3. **Usa INCLUDE** per columnes de només lectura
4. **Considera la selectivitat** de les columnes
5. **Revisa plans d'execució** per validar l'ús
6. **Monitoritza l'ús** dels índexs regularment

### ✗ Evitar

1. **No crear** índexs sense analitzar consultes
2. **No ignorar** l'ordre de les columnes
3. **No fer** índexs amb massa columnes (més de 5-6)
4. **No duplicar** índexs innecessàriament
5. **No mantenir** índexs no utilitzats

## Resum comparatiu

| Aspecte | Índex Simple | Índex Compost |
|---------|--------------|---------------|
| **Columnes** | Una | Dues o més |
| **Complexitat** | Baixa | Mitjana-Alta |
| **Flexibilitat** | Limitada | Alta (leftmost prefix) |
| **Manteniment** | Baix | Mitjà |
| **Rendiment** | Bo per una columna | Excel·lent per múltiples filtres |
| **Espai** | Menys | Més (però menys que múltiples simples) |
| **Quan usar** | Consultes amb un filtre | Consultes amb múltiples filtres |

---

## Conclusió

Els índexs compostos són una eina poderosa per optimitzar consultes amb múltiples filtres. La clau de l'èxit està en:

1. **Comprendre els teus patrons de consulta**
2. **Respectar l'ordre correcte de les columnes**
3. **Aplicar el principi de leftmost prefix**
4. **Equilibrar rendiment de lectura vs escriptura**
5. **Monitoritzar i ajustar regularment**

Recorda: **Un índex compost ben dissenyat val més que diversos índexs simples mal planificats**.
