# Key Lookups i RID Lookups en SQL Server

Els **Key Lookups** i **RID Lookups** són operacions costoses que es produeixen quan SQL Server necessita buscar dades addicionals a la taula base després de consultar un índex.

## RID Lookup

**RID** = Row Identifier (Identificador de Fila)

Es produeix quan:

- La taula **NO té clustered index** (és un heap)
- Un nonclustered index troba les files, però necessita columnes addicionals que no estan a l'índex
- SQL Server usa el RID (punter físic) per buscar la fila completa al heap

```sql
-- Taula sense clustered index
CREATE TABLE Productes (
    ProducteID INT,
    Nom VARCHAR(100),
    Preu DECIMAL(10,2)
);

CREATE NONCLUSTERED INDEX IX_Nom ON Productes(Nom);

-- Aquesta consulta causa RID Lookup
SELECT Nom, Preu 
FROM Productes 
WHERE Nom = 'Portàtil';
-- L'índex troba el Nom, però necessita buscar Preu al heap
```

## Key Lookup

Es produeix quan:
- La taula **SÍ té clustered index**
- Un nonclustered index troba les files, però necessita columnes addicionals
- SQL Server usa la clau del clustered index per buscar les dades que falten

```sql
-- Taula amb clustered index
CREATE TABLE Productes (
    ProducteID INT PRIMARY KEY CLUSTERED,  -- Clustered index
    Nom VARCHAR(100),
    Preu DECIMAL(10,2)
);

CREATE NONCLUSTERED INDEX IX_Nom ON Productes(Nom);

-- Aquesta consulta causa Key Lookup
SELECT Nom, Preu 
FROM Productes 
WHERE Nom = 'Portàtil';
-- L'índex IX_Nom troba el registre, però necessita buscar Preu
-- usant el clustered index (ProducteID)
```

## Per què són problemàtics?

Tots dos són operacions **costoses** perquè:
- Requereixen accessos addicionals d'I/O
- Per cada fila trobada a l'índex, cal fer una cerca addicional
- Si afecten moltes files, el rendiment es degrada significativament

## Com eliminar-los

Usa un **covering index**:

```sql
-- Solució: incloure les columnes necessàries
CREATE NONCLUSTERED INDEX IX_Nom_Covering 
ON Productes(Nom)
INCLUDE (Preu);

-- Ara aquesta consulta NO necessita lookup
SELECT Nom, Preu 
FROM Productes 
WHERE Nom = 'Portàtil';
```

## Com detectar-los

Al pla d'execució de SQL Server, veuràs:
- **Key Lookup (Clustered)** - operador groc/taronja
- **RID Lookup** - operador groc/taronja

Si veus molts lookups als teus plans d'execució, és un senyal clar que necessites millorar els teus índexs amb columnes INCLUDE.

---

## Resum

| Tipus | Quan es produeix | Solució |
|-------|------------------|---------|
| **RID Lookup** | Taula sense clustered index (heap) | Crear covering index o afegir clustered index |
| **Key Lookup** | Taula amb clustered index | Crear covering index amb columnes INCLUDE |
