-- =============================================
-- M5074 - BigData i IA
-- Activitat: Optimització de Bases de Dades
-- Part 1: Creació de l'estructura de la BD
-- =============================================
-- 
-- Carpeta Inicial
-- S'ha de tenir la carpeta \SQLData\ creada en les unitats que utilitzeu

-- Crear la base de dades
USE master;
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'VendesBigData')
BEGIN
    ALTER DATABASE VendesBigData SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE VendesBigData;
END
GO

CREATE DATABASE VendesBigData
ON PRIMARY 
(
    NAME = VendesBigData_Data,
    FILENAME = 'o:\SQLData\VendesBigData_Data.mdf',
    SIZE = 1GB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 256MB
)
LOG ON
(
    NAME = VendesBigData_Log,
    FILENAME = 'p:\SQLData\VendesBigData_Log.ldf',
    SIZE = 512MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 128MB
);
GO

USE VendesBigData;
GO

-- =============================================
-- TAULES DE JERARQUIES
-- =============================================

-- Jerarquia de Productes (Categories)
CREATE TABLE JerarquiaProductes (
    JerarquiaProducteID INT IDENTITY(1,1) PRIMARY KEY,
    Nivell1 NVARCHAR(100) NOT NULL,  -- Departament
    Nivell2 NVARCHAR(100),            -- Categoria
    Nivell3 NVARCHAR(100),            -- Subcategoria
    DataCreacio DATETIME2 DEFAULT GETDATE(),
    Actiu BIT DEFAULT 1
);

-- Jerarquia de Clients (Segmentació)
CREATE TABLE JerarquiaClients (
    JerarquiaClientID INT IDENTITY(1,1) PRIMARY KEY,
    Nivell1 NVARCHAR(100) NOT NULL,  -- Tipus client (Particular/Empresa)
    Nivell2 NVARCHAR(100),            -- Segment (Premium/Estàndard/Bàsic)
    Nivell3 NVARCHAR(100),            -- Sub-segment
    DataCreacio DATETIME2 DEFAULT GETDATE(),
    Actiu BIT DEFAULT 1
);

-- =============================================
-- TAULES MESTRES
-- =============================================

-- Taula de Productes
CREATE TABLE Productes (
    ProducteID INT IDENTITY(1,1) PRIMARY KEY,
    CodiProducte NVARCHAR(50) UNIQUE NOT NULL,
    NomProducte NVARCHAR(200) NOT NULL,
    Descripcio NVARCHAR(MAX),
    JerarquiaProducteID INT NOT NULL,
    PreuUnitari DECIMAL(18,2) NOT NULL,
    Cost DECIMAL(18,2) NOT NULL,
    StockActual INT DEFAULT 0,
    DataAlta DATETIME2 DEFAULT GETDATE(),
    DataModificacio DATETIME2 DEFAULT GETDATE(),
    Actiu BIT DEFAULT 1,
    CONSTRAINT FK_Productes_Jerarquia FOREIGN KEY (JerarquiaProducteID) 
        REFERENCES JerarquiaProductes(JerarquiaProducteID)
);

-- Taula de Clients
CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    CodiClient NVARCHAR(50) UNIQUE NOT NULL,
    NomClient NVARCHAR(200) NOT NULL,
    Email NVARCHAR(200),
    Telefon NVARCHAR(20),
    Direccio NVARCHAR(300),
    Poblacio NVARCHAR(100),
    CodiPostal NVARCHAR(10),
    Provincia NVARCHAR(100),
    Pais NVARCHAR(100) DEFAULT 'Espanya',
    JerarquiaClientID INT NOT NULL,
    DataAlta DATETIME2 DEFAULT GETDATE(),
    DataModificacio DATETIME2 DEFAULT GETDATE(),
    Actiu BIT DEFAULT 1,
    CONSTRAINT FK_Clients_Jerarquia FOREIGN KEY (JerarquiaClientID) 
        REFERENCES JerarquiaClients(JerarquiaClientID)
);

-- =============================================
-- TAULES TRANSACCIONALS
-- =============================================

-- Taula de Comandes
CREATE TABLE Comandes (
    ComandaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    NumeroComanda NVARCHAR(50) UNIQUE NOT NULL,
    ClientID INT NOT NULL,
    DataComanda DATETIME2 NOT NULL DEFAULT GETDATE(),
    DataEnviament DATETIME2,
    DataEntrega DATETIME2,
    Estat NVARCHAR(50) NOT NULL DEFAULT 'Pendent', -- Pendent, Processat, Enviat, Entregat, Cancel·lat
    ImportTotal DECIMAL(18,2) DEFAULT 0,
    Descompte DECIMAL(18,2) DEFAULT 0,
    ImportNet DECIMAL(18,2) DEFAULT 0,
    Observacions NVARCHAR(MAX),
    CONSTRAINT FK_Comandes_Client FOREIGN KEY (ClientID) 
        REFERENCES Clients(ClientID)
);

-- Taula de Línies de Comanda
CREATE TABLE LiniesComanda (
    LiniaComandaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ComandaID BIGINT NOT NULL,
    NumeroLinia INT NOT NULL,
    ProducteID INT NOT NULL,
    Quantitat INT NOT NULL,
    PreuUnitari DECIMAL(18,2) NOT NULL,
    Descompte DECIMAL(5,2) DEFAULT 0, -- Percentatge
    ImportLinia DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_LiniesComanda_Comanda FOREIGN KEY (ComandaID) 
        REFERENCES Comandes(ComandaID),
    CONSTRAINT FK_LiniesComanda_Producte FOREIGN KEY (ProducteID) 
        REFERENCES Productes(ProducteID),
    CONSTRAINT UQ_LiniaComanda UNIQUE (ComandaID, NumeroLinia)
);

-- Taula de Factures
CREATE TABLE Factures (
    FacturaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    NumeroFactura NVARCHAR(50) UNIQUE NOT NULL,
    ComandaID BIGINT NOT NULL,
    ClientID INT NOT NULL,
    DataFactura DATETIME2 NOT NULL DEFAULT GETDATE(),
    DataVenciment DATETIME2 NOT NULL,
    BaseImposable DECIMAL(18,2) NOT NULL,
    IVA DECIMAL(18,2) NOT NULL,
    ImportTotal DECIMAL(18,2) NOT NULL,
    Estat NVARCHAR(50) NOT NULL DEFAULT 'Pendent', -- Pendent, Pagat, Vençut, Cancel·lat
    DataPagament DATETIME2,
    FormaPagament NVARCHAR(50), -- Transferència, Targeta, Efectiu, etc.
    Observacions NVARCHAR(MAX),
    CONSTRAINT FK_Factures_Comanda FOREIGN KEY (ComandaID) 
        REFERENCES Comandes(ComandaID),
    CONSTRAINT FK_Factures_Client FOREIGN KEY (ClientID) 
        REFERENCES Clients(ClientID)
);

-- Taula de Línies de Factura
CREATE TABLE LiniesFactura (
    LiniaFacturaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    FacturaID BIGINT NOT NULL,
    NumeroLinia INT NOT NULL,
    ProducteID INT NOT NULL,
    Descripcio NVARCHAR(300),
    Quantitat INT NOT NULL,
    PreuUnitari DECIMAL(18,2) NOT NULL,
    Descompte DECIMAL(18,2) DEFAULT 0,
    BaseImposable DECIMAL(18,2) NOT NULL,
    PercentatgeIVA DECIMAL(5,2) NOT NULL,
    ImportIVA DECIMAL(18,2) NOT NULL,
    ImportTotal DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_LiniesFactura_Factura FOREIGN KEY (FacturaID) 
        REFERENCES Factures(FacturaID),
    CONSTRAINT FK_LiniesFactura_Producte FOREIGN KEY (ProducteID) 
        REFERENCES Productes(ProducteID),
    CONSTRAINT UQ_LiniaFactura UNIQUE (FacturaID, NumeroLinia)
);

-- =============================================
-- ÍNDEXS BÀSICS INICIALS
-- (Més endavant es crearan índexs optimitzats)
-- =============================================

-- Índexs per les jerarquies
CREATE INDEX IX_JerarquiaProductes_Nivells ON JerarquiaProductes(Nivell1, Nivell2, Nivell3);
CREATE INDEX IX_JerarquiaClients_Nivells ON JerarquiaClients(Nivell1, Nivell2, Nivell3);

-- Índexs per cerca de clients i productes
CREATE INDEX IX_Clients_Nom ON Clients(NomClient);
CREATE INDEX IX_Clients_CodiPostal ON Clients(CodiPostal, Provincia);
CREATE INDEX IX_Productes_Nom ON Productes(NomProducte);

-- Índexs per dates (molt importants per consultes analítiques)
CREATE INDEX IX_Comandes_DataComanda ON Comandes(DataComanda) INCLUDE (ClientID, ImportTotal);
CREATE INDEX IX_Factures_DataFactura ON Factures(DataFactura) INCLUDE (ClientID, ImportTotal);

-- Índexs per foreign keys (milloren els JOINs)
CREATE INDEX IX_LiniesComanda_ComandaID ON LiniesComanda(ComandaID);
CREATE INDEX IX_LiniesComanda_ProducteID ON LiniesComanda(ProducteID);
CREATE INDEX IX_LiniesFactura_FacturaID ON LiniesFactura(FacturaID);
CREATE INDEX IX_LiniesFactura_ProducteID ON LiniesFactura(ProducteID);

GO

-- =============================================
-- VISTES BÀSIQUES PER CONSULTES
-- =============================================

-- Vista resum de comandes
CREATE VIEW vw_ResumComandes AS
SELECT 
    c.ComandaID,
    c.NumeroComanda,
    c.DataComanda,
    cl.CodiClient,
    cl.NomClient,
    jc.Nivell1 AS TipusClient,
    jc.Nivell2 AS SegmentClient,
    c.Estat,
    c.ImportTotal,
    COUNT(lc.LiniaComandaID) AS NumLinies
FROM Comandes c
INNER JOIN Clients cl ON c.ClientID = cl.ClientID
INNER JOIN JerarquiaClients jc ON cl.JerarquiaClientID = jc.JerarquiaClientID
LEFT JOIN LiniesComanda lc ON c.ComandaID = lc.ComandaID
GROUP BY c.ComandaID, c.NumeroComanda, c.DataComanda, cl.CodiClient, 
         cl.NomClient, jc.Nivell1, jc.Nivell2, c.Estat, c.ImportTotal;
GO

-- Vista detall de vendes
CREATE VIEW vw_DetallVendes AS
SELECT 
    c.ComandaID,
    c.NumeroComanda,
    c.DataComanda,
    YEAR(c.DataComanda) AS Anyo,
    MONTH(c.DataComanda) AS Mes,
    cl.ClientID,
    cl.NomClient,
    jc.Nivell1 AS TipusClient,
    jc.Nivell2 AS SegmentClient,
    p.ProducteID,
    p.CodiProducte,
    p.NomProducte,
    jp.Nivell1 AS Departament,
    jp.Nivell2 AS Categoria,
    jp.Nivell3 AS Subcategoria,
    lc.Quantitat,
    lc.PreuUnitari,
    lc.Descompte,
    lc.ImportLinia
FROM Comandes c
INNER JOIN Clients cl ON c.ClientID = cl.ClientID
INNER JOIN JerarquiaClients jc ON cl.JerarquiaClientID = jc.JerarquiaClientID
INNER JOIN LiniesComanda lc ON c.ComandaID = lc.ComandaID
INNER JOIN Productes p ON lc.ProducteID = p.ProducteID
INNER JOIN JerarquiaProductes jp ON p.JerarquiaProducteID = jp.JerarquiaProducteID;
GO

PRINT 'Base de dades VendesBigData creada correctament!';
PRINT 'Estructura preparada per carregar dades massives.';
GO


-- Habilitar autenticació mixta (Windows + SQL Server)
USE master;
GO

-- Crear login
-- 1. Crear LOGIN a nivell de servidor
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'alumne')
BEGIN
    CREATE LOGIN alumne WITH PASSWORD = 'Password123!', CHECK_POLICY = OFF;
    PRINT '✓ Login "alumne" creat';
END
ELSE
    PRINT '⚠ Login "alumne" ja existeix';
GO

-- Donar permisos a la base de dades
USE VendesBigData;
GO

DROP USER IF EXISTS alumne;
CREATE USER alumne FOR LOGIN alumne;
GO

-- Donar permisos (segons el que necessitis):
-- Opció A: Permisos complets (per desenvolupament)

ALTER ROLE db_owner ADD MEMBER alumne;
GO

-- Opció B: Permisos específics (més segur)
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO alumne;
GO