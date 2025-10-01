-- =============================================
-- M5074 - BigData i IA
-- Part 2B: Generació de dades amb T-SQL
-- Procediments emmagatzemats per generar dades massives
-- =============================================

USE VendesBigData;
GO

-- =============================================
-- Procediment 1: Generar Jerarquies de Productes
-- =============================================
CREATE OR ALTER PROCEDURE sp_GenerarJerarquiesProductes
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT 'Generant jerarquies de productes...';
    
    -- Departaments i categories predefinides
    INSERT INTO JerarquiaProductes (Nivell1, Nivell2, Nivell3, Actiu)
    VALUES
    -- Electrònica
    ('Electrònica', 'Ordinadors', 'Premium', 1),
    ('Electrònica', 'Ordinadors', 'Estàndard', 1),
    ('Electrònica', 'Ordinadors', 'Econòmic', 1),
    ('Electrònica', 'Telèfons', 'Premium', 1),
    ('Electrònica', 'Telèfons', 'Estàndard', 1),
    ('Electrònica', 'Tauletes', 'Premium', 1),
    ('Electrònica', 'Tauletes', 'Estàndard', 1),
    ('Electrònica', 'Accessoris', 'Diversos', 1),
    -- Llar
    ('Llar', 'Mobles', 'Saló', 1),
    ('Llar', 'Mobles', 'Dormitori', 1),
    ('Llar', 'Mobles', 'Cuina', 1),
    ('Llar', 'Decoració', 'Modern', 1),
    ('Llar', 'Decoració', 'Clàssic', 1),
    ('Llar', 'Il·luminació', 'LED', 1),
    ('Llar', 'Tèxtil', 'Llençols', 1),
    ('Llar', 'Tèxtil', 'Cortines', 1),
    -- Moda
    ('Moda', 'Roba Home', 'Formal', 1),
    ('Moda', 'Roba Home', 'Casual', 1),
    ('Moda', 'Roba Dona', 'Formal', 1),
    ('Moda', 'Roba Dona', 'Casual', 1),
    ('Moda', 'Calçat', 'Esportiu', 1),
    ('Moda', 'Calçat', 'Formal', 1),
    ('Moda', 'Complements', 'Bosses', 1),
    ('Moda', 'Complements', 'Cinturons', 1),
    -- Esports
    ('Esports', 'Fitness', 'Peses', 1),
    ('Esports', 'Fitness', 'Màquines', 1),
    ('Esports', 'Ciclisme', 'Bicicletes', 1),
    ('Esports', 'Ciclisme', 'Accessoris', 1),
    ('Esports', 'Outdoor', 'Càmping', 1),
    ('Esports', 'Natació', 'Banyadors', 1),
    -- Llibres
    ('Llibres', 'Novel·la', 'Ficció', 1),
    ('Llibres', 'Novel·la', 'No Ficció', 1),
    ('Llibres', 'Tècnic', 'Informàtica', 1),
    ('Llibres', 'Infantil', '0-6 anys', 1),
    ('Llibres', 'Comics', 'Manga', 1);
    
    PRINT 'Jerarquies de productes generades: ' + CAST(@@ROWCOUNT AS VARCHAR);
END
GO

-- =============================================
-- Procediment 2: Generar Jerarquies de Clients
-- =============================================
CREATE OR ALTER PROCEDURE sp_GenerarJerarquiesClients
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT 'Generant jerarquies de clients...';
    
    INSERT INTO JerarquiaClients (Nivell1, Nivell2, Nivell3, Actiu)
    VALUES
    ('Particular', 'Premium', 'VIP', 1),
    ('Particular', 'Premium', 'Gold', 1),
    ('Particular', 'Premium', 'Silver', 1),
    ('Particular', 'Estàndard', 'Freqüent', 1),
    ('Particular', 'Estàndard', 'Regular', 1),
    ('Particular', 'Bàsic', 'Ocasional', 1),
    ('Particular', 'Bàsic', 'Nou', 1),
    ('Empresa', 'Gran Empresa', 'Nacional', 1),
    ('Empresa', 'Gran Empresa', 'Internacional', 1),
    ('Empresa', 'Gran Empresa', 'Multinacional', 1),
    ('Empresa', 'PIME', 'Mitjana', 1),
    ('Empresa', 'PIME', 'Petita', 1),
    ('Empresa', 'Autònom', 'Professional', 1),
    ('Empresa', 'Autònom', 'Freelance', 1);
    
    PRINT 'Jerarquies de clients generades: ' + CAST(@@ROWCOUNT AS VARCHAR);
END
GO

-- =============================================
-- Procediment 3: Generar Clients
-- =============================================
-- =============================================
-- Procediment 3: Generar Clients
-- =============================================
CREATE OR ALTER PROCEDURE sp_GenerarClients
    @NumClients INT = 100000
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @i INT = 1;
    
    PRINT 'Generant ' + CAST(@NumClients AS VARCHAR) + ' clients...';
    PRINT 'Inici: ' + CONVERT(VARCHAR, GETDATE(), 120);
    
    WHILE @i <= @NumClients
    BEGIN
        DECLARE @CodiClient NVARCHAR(50) = 'CLI-' + RIGHT('00000000' + CAST(@i AS VARCHAR), 8);
        DECLARE @NomClient NVARCHAR(200);
        DECLARE @Email NVARCHAR(200) = LOWER(REPLACE(CAST(NEWID() AS NVARCHAR(36)), '-', '')) + '@email.com';
        DECLARE @Telefon NVARCHAR(20) = '+34' + CAST(600000000 + (ABS(CHECKSUM(NEWID())) % 100000000) AS VARCHAR);
        DECLARE @Direccio NVARCHAR(300) = 'Carrer ' + CAST((ABS(CHECKSUM(NEWID())) % 100) + 1 AS VARCHAR) + ', ' + CAST((ABS(CHECKSUM(NEWID())) % 50) + 1 AS VARCHAR);
        DECLARE @Poblacio NVARCHAR(100);
        DECLARE @CodiPostal NVARCHAR(10);
        DECLARE @Provincia NVARCHAR(100);
        DECLARE @JerarquiaID INT = 1 + (ABS(CHECKSUM(NEWID())) % 14);
        DECLARE @Rand INT = ABS(CHECKSUM(NEWID())) % 10;
        
        -- Nom del client (70% persones, 30% empreses)
        IF @Rand < 7
            SET @NomClient = CASE (ABS(CHECKSUM(NEWID())) % 20)
                WHEN 0 THEN 'García Martínez'
                WHEN 1 THEN 'López Sánchez'
                WHEN 2 THEN 'González Pérez'
                WHEN 3 THEN 'Rodríguez Fernández'
                WHEN 4 THEN 'Gómez Díaz'
                WHEN 5 THEN 'Martín Jiménez'
                WHEN 6 THEN 'Ruiz Hernández'
                WHEN 7 THEN 'Moreno Álvarez'
                WHEN 8 THEN 'Romero Torres'
                WHEN 9 THEN 'Ramírez Gil'
                WHEN 10 THEN 'Pérez García'
                WHEN 11 THEN 'Sánchez López'
                WHEN 12 THEN 'Fernández González'
                WHEN 13 THEN 'Díaz Rodríguez'
                WHEN 14 THEN 'Torres Gómez'
                WHEN 15 THEN 'Jiménez Martín'
                WHEN 16 THEN 'Hernández Ruiz'
                WHEN 17 THEN 'Álvarez Moreno'
                WHEN 18 THEN 'Gil Romero'
                ELSE 'Martínez Ramírez'
            END;
        ELSE
            SET @NomClient = CASE (ABS(CHECKSUM(NEWID())) % 16)
                WHEN 0 THEN 'Distribucions García SL'
                WHEN 1 THEN 'Serveis López SL'
                WHEN 2 THEN 'Consultoria González SL'
                WHEN 3 THEN 'Tecnologies Pérez SL'
                WHEN 4 THEN 'Solucions Martínez SL'
                WHEN 5 THEN 'Innovació Sánchez SL'
                WHEN 6 THEN 'Desenvolupament Rodríguez SL'
                WHEN 7 THEN 'Gestió Fernández SL'
                WHEN 8 THEN 'Assessoria Gómez SL'
                WHEN 9 THEN 'Comerç Díaz SL'
                WHEN 10 THEN 'Indústries Ruiz SL'
                WHEN 11 THEN 'Productes Moreno SL'
                WHEN 12 THEN 'Sistemes Torres SL'
                WHEN 13 THEN 'Global Jiménez SL'
                WHEN 14 THEN 'Internacional Hernández SL'
                ELSE 'Nacional Álvarez SL'
            END;
        
        -- Província i codi postal
        SET @Rand = ABS(CHECKSUM(NEWID())) % 15;
        IF @Rand = 0 BEGIN SET @Provincia = 'Barcelona'; SET @CodiPostal = '08' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 1 BEGIN SET @Provincia = 'Madrid'; SET @CodiPostal = '28' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 2 BEGIN SET @Provincia = 'València'; SET @CodiPostal = '46' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 3 BEGIN SET @Provincia = 'Sevilla'; SET @CodiPostal = '41' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 4 BEGIN SET @Provincia = 'Saragossa'; SET @CodiPostal = '50' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 5 BEGIN SET @Provincia = 'Màlaga'; SET @CodiPostal = '29' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 6 BEGIN SET @Provincia = 'Múrcia'; SET @CodiPostal = '30' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 7 BEGIN SET @Provincia = 'Palma'; SET @CodiPostal = '07' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 8 BEGIN SET @Provincia = 'Bilbao'; SET @CodiPostal = '48' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 9 BEGIN SET @Provincia = 'Alacant'; SET @CodiPostal = '03' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 10 BEGIN SET @Provincia = 'Còrdova'; SET @CodiPostal = '14' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 11 BEGIN SET @Provincia = 'Valladolid'; SET @CodiPostal = '47' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 12 BEGIN SET @Provincia = 'Vigo'; SET @CodiPostal = '36' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE IF @Rand = 13 BEGIN SET @Provincia = 'Gijón'; SET @CodiPostal = '33' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        ELSE BEGIN SET @Provincia = 'Granada'; SET @CodiPostal = '18' + RIGHT('000' + CAST((ABS(CHECKSUM(NEWID())) % 1000) AS VARCHAR), 3); END
        
        SET @Poblacio = @Provincia;
        
        INSERT INTO Clients (CodiClient, NomClient, Email, Telefon, Direccio, Poblacio, CodiPostal, Provincia, Pais, JerarquiaClientID, Actiu)
        VALUES (@CodiClient, @NomClient, @Email, @Telefon, @Direccio, @Poblacio, @CodiPostal, @Provincia, 'Espanya', @JerarquiaID, 1);
        
        SET @i = @i + 1;
        
        IF @i % 10000 = 0
            PRINT '  Processats: ' + CAST(@i AS VARCHAR) + ' clients';
    END
    
    PRINT 'Fi: ' + CONVERT(VARCHAR, GETDATE(), 120);
    DECLARE @TotalClients INT;
    SET @TotalClients = (SELECT COUNT(*) FROM Clients); 

    PRINT 'Total clients generats: ' + CAST(@TotalClients AS VARCHAR);
    
  
END
GO

-- =============================================
-- Procediment 4: Generar Productes
-- =============================================
CREATE OR ALTER PROCEDURE sp_GenerarProductes
    @NumProductes INT = 10000
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @i INT = 1;
    DECLARE @MaxJerarquia INT;
    SET @MaxJerarquia= (SELECT COUNT(*) FROM JerarquiaProductes);
    
    PRINT 'Generant ' + CAST(@NumProductes AS VARCHAR) + ' productes...';
    PRINT 'Inici: ' + CONVERT(VARCHAR, GETDATE(), 120);
    
    WHILE @i <= @NumProductes
    BEGIN
        DECLARE @CodiProducte NVARCHAR(50) = 'PROD-' + RIGHT('00000000' + CAST(@i AS VARCHAR), 8);
        DECLARE @NomProducte NVARCHAR(200);
        DECLARE @Prefix NVARCHAR(50);
        DECLARE @Sufix NVARCHAR(50);
        DECLARE @Base NVARCHAR(50);
        DECLARE @JerarquiaID INT = 1 + (ABS(CHECKSUM(NEWID())) % @MaxJerarquia);
        DECLARE @Preu DECIMAL(18,2) = 5 + (ABS(CHECKSUM(NEWID())) % 1995);
        DECLARE @Cost DECIMAL(18,2) = @Preu * (0.4 + (CAST(ABS(CHECKSUM(NEWID())) % 30 AS DECIMAL) / 100));
        DECLARE @Stock INT = ABS(CHECKSUM(NEWID())) % 1000;
        
        -- Generar nom
        SET @Prefix = CASE (ABS(CHECKSUM(NEWID())) % 12)
            WHEN 0 THEN 'Pro'
            WHEN 1 THEN 'Super'
            WHEN 2 THEN 'Mega'
            WHEN 3 THEN 'Ultra'
            WHEN 4 THEN 'Max'
            WHEN 5 THEN 'Premium'
            WHEN 6 THEN 'Elite'
            WHEN 7 THEN 'Smart'
            WHEN 8 THEN 'Digital'
            WHEN 9 THEN 'Tech'
            WHEN 10 THEN 'Advanced'
            ELSE 'Basic'
        END;
        
        SET @Base = CASE (ABS(CHECKSUM(NEWID())) % 20)
            WHEN 0 THEN 'Ordinador'
            WHEN 1 THEN 'Telèfon'
            WHEN 2 THEN 'Tauleta'
            WHEN 3 THEN 'Monitor'
            WHEN 4 THEN 'Teclat'
            WHEN 5 THEN 'Ratolí'
            WHEN 6 THEN 'Cadira'
            WHEN 7 THEN 'Taula'
            WHEN 8 THEN 'Llum'
            WHEN 9 THEN 'Armari'
            WHEN 10 THEN 'Camisa'
            WHEN 11 THEN 'Pantalons'
            WHEN 12 THEN 'Sabates'
            WHEN 13 THEN 'Bicicleta'
            WHEN 14 THEN 'Raqueta'
            WHEN 15 THEN 'Llibre'
            WHEN 16 THEN 'Mochila'
            WHEN 17 THEN 'Rellotge'
            WHEN 18 THEN 'Gorra'
            ELSE 'Bufanda'
        END;
        
        SET @Sufix = CASE (ABS(CHECKSUM(NEWID())) % 10)
            WHEN 0 THEN 'Plus'
            WHEN 1 THEN 'Pro'
            WHEN 2 THEN 'Advanced'
            WHEN 3 THEN 'Deluxe'
            WHEN 4 THEN 'Standard'
            WHEN 5 THEN 'Basic'
            WHEN 6 THEN 'Lite'
            WHEN 7 THEN 'Master'
            WHEN 8 THEN 'Expert'
            ELSE 'Prime'
        END;
        
        SET @NomProducte = @Prefix + ' ' + @Base + ' ' + @Sufix;
        
        INSERT INTO Productes (CodiProducte, NomProducte, Descripcio, JerarquiaProducteID, PreuUnitari, Cost, StockActual, Actiu)
        VALUES (@CodiProducte, @NomProducte, 'Descripció del producte amb característiques principals.', @JerarquiaID, @Preu, @Cost, @Stock, 1);
        
        SET @i = @i + 1;
        
        IF @i % 5000 = 0
            PRINT '  Processats: ' + CAST(@i AS VARCHAR) + ' productes';
    END
    
    PRINT 'Fi: ' + CONVERT(VARCHAR, GETDATE(), 120);
    DECLARE @TotalProductes INT;
    SET @TotalProductes = (SELECT COUNT(*) FROM Productes); 
    PRINT 'Total productes generats: ' + CAST(@TotalProductes AS VARCHAR);
END
GO

-- =============================================
-- Procediment 5: Generar Comandes i Línies
-- =============================================
CREATE OR ALTER PROCEDURE sp_GenerarComandes
    @NumComandes INT = 100000,
    @DataInici DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @DataInici IS NULL
        SET @DataInici = DATEADD(YEAR, -3, GETDATE());
    
    DECLARE @i INT = 1;
    DECLARE @BatchSize INT = 5000;
    DECLARE @MaxClients INT = (SELECT MAX(ClientID) FROM Clients);
    DECLARE @MaxProductes INT = (SELECT MAX(ProducteID) FROM Productes);
    DECLARE @DiesTotal INT = DATEDIFF(DAY, @DataInici, GETDATE());
    
    PRINT 'Generant ' + CAST(@NumComandes AS VARCHAR) + ' comandes amb línies...';
    PRINT 'Rang de dates: ' + CAST(@DataInici AS VARCHAR) + ' fins ' + CAST(GETDATE() AS VARCHAR);
    PRINT 'Inici: ' + CONVERT(VARCHAR, GETDATE(), 120);
    
    -- Deshabilitar temporalment triggers i constrains per millorar rendiment
    ALTER TABLE LiniesComanda NOCHECK CONSTRAINT ALL;
    
    WHILE @i <= @NumComandes
    BEGIN
        -- Generar lot de comandes
        INSERT INTO Comandes (NumeroComanda, ClientID, DataComanda, DataEnviament, 
                             DataEntrega, Estat, ImportTotal, Descompte, ImportNet)
        SELECT TOP (@BatchSize)
            'COM-' + RIGHT('0000000000' + CAST(@i + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS VARCHAR), 10),
            1 + ABS(CHECKSUM(NEWID())) % @MaxClients,
            DATEADD(DAY, ABS(CHECKSUM(NEWID())) % @DiesTotal, @DataInici),
            NULL,
            NULL,
            CASE ABS(CHECKSUM(NEWID())) % 100
                WHEN 0 THEN 'Cancel·lat'
                WHEN 1 THEN 'Cancel·lat'
                WHEN 2 THEN 'Cancel·lat'
                WHEN 3 THEN 'Cancel·lat'
                WHEN 4 THEN 'Cancel·lat'
                WHEN 5 THEN 'Pendent'
                WHEN 6 THEN 'Pendent'
                WHEN 7 THEN 'Pendent'
                WHEN 8 THEN 'Pendent'
                WHEN 9 THEN 'Pendent'
                WHEN 10 THEN 'Processat'
                WHEN 11 THEN 'Processat'
                WHEN 12 THEN 'Processat'
                WHEN 13 THEN 'Processat'
                WHEN 14 THEN 'Processat'
                WHEN 15 THEN 'Enviat'
                WHEN 16 THEN 'Enviat'
                WHEN 17 THEN 'Enviat'
                WHEN 18 THEN 'Enviat'
                WHEN 19 THEN 'Enviat'
                ELSE 'Entregat'
            END,
            0,
            0,
            0
        FROM sys.all_columns;
        
        -- Actualitzar dates segons estat
        UPDATE Comandes
        SET DataEnviament = DATEADD(DAY, 1 + ABS(CHECKSUM(NEWID())) % 5, DataComanda),
            DataEntrega = DATEADD(DAY, 3 + ABS(CHECKSUM(NEWID())) % 5, DataComanda)
        WHERE ComandaID BETWEEN @i AND @i + @BatchSize - 1
        AND Estat IN ('Enviat', 'Entregat');
        
        UPDATE Comandes
        SET DataEnviament = DATEADD(DAY, 1 + ABS(CHECKSUM(NEWID())) % 5, DataComanda)
        WHERE ComandaID BETWEEN @i AND @i + @BatchSize - 1
        AND Estat = 'Enviat';
        
        -- Generar línies per cada comanda del lot
        DECLARE @ComandaID BIGINT;
        DECLARE @NumLinies INT;
        DECLARE @NumLinia INT;
        
        DECLARE cursor_comandes CURSOR FAST_FORWARD FOR
        SELECT ComandaID
        FROM Comandes
        WHERE ComandaID BETWEEN @i AND @i + @BatchSize - 1;
        
        OPEN cursor_comandes;
        FETCH NEXT FROM cursor_comandes INTO @ComandaID;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @NumLinies = 1 + ABS(CHECKSUM(NEWID())) % 8;
            SET @NumLinia = 1;
            
            WHILE @NumLinia <= @NumLinies
            BEGIN
                DECLARE @ProducteID INT = 1 + ABS(CHECKSUM(NEWID())) % @MaxProductes;
                DECLARE @Quantitat INT = 1 + ABS(CHECKSUM(NEWID())) % 10;
                DECLARE @PreuUnitari DECIMAL(18,2) = (SELECT PreuUnitari FROM Productes WHERE ProducteID = @ProducteID);
                DECLARE @Descompte DECIMAL(5,2) = CASE ABS(CHECKSUM(NEWID())) % 10
                    WHEN 0 THEN 5
                    WHEN 1 THEN 10
                    WHEN 2 THEN 15
                    ELSE 0
                END;
                DECLARE @ImportLinia DECIMAL(18,2) = @Quantitat * @PreuUnitari * (1 - @Descompte / 100);
                
                INSERT INTO LiniesComanda (ComandaID, NumeroLinia, ProducteID, Quantitat,
                                          PreuUnitari, Descompte, ImportLinia)
                VALUES (@ComandaID, @NumLinia, @ProducteID, @Quantitat,
                        @PreuUnitari, @Descompte, @ImportLinia);
                
                SET @NumLinia = @NumLinia + 1;
            END
            
            FETCH NEXT FROM cursor_comandes INTO @ComandaID;
        END
        
        CLOSE cursor_comandes;
        DEALLOCATE cursor_comandes;
        
        SET @i = @i + @BatchSize;
        
        IF @i % 25000 = 0
            PRINT '  Processades: ' + CAST(@i AS VARCHAR) + ' comandes';
    END
    
    -- Rehabilitar constrains
    ALTER TABLE LiniesComanda CHECK CONSTRAINT ALL;
    
    -- Actualitzar imports totals de comandes
    PRINT 'Actualitzant imports totals...';
    UPDATE c
    SET ImportTotal = ISNULL(totals.Total, 0),
        ImportNet = ISNULL(totals.Total, 0)
    FROM Comandes c
    LEFT JOIN (
        SELECT ComandaID, SUM(ImportLinia) as Total
        FROM LiniesComanda
        GROUP BY ComandaID
    ) totals ON c.ComandaID = totals.ComandaID;
    
    PRINT 'Fi: ' + CONVERT(VARCHAR, GETDATE(), 120);
    DECLARE @TotalComandes INT;
    DECLARE @TotalLiniesComanda INT;
    SET @TotalComandes = (SELECT COUNT(*) FROM Comandes); 
    SET @TotalLiniesComanda = (SELECT COUNT(*) FROM LiniesComanda); 

    PRINT 'Total comandes generades: ' + CAST((@TotalComandes) AS VARCHAR);
    PRINT 'Total línies generades: ' + CAST((@TotalLiniesComanda) AS VARCHAR);
END
GO

-- =============================================
-- Procediment 6: Generar Factures i Línies
-- =============================================
-- =============================================
-- Procediment 6: Generar Factures i Línies
-- =============================================
CREATE OR ALTER PROCEDURE sp_GenerarFactures
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT 'Generant factures per comandes entregades...';
    PRINT 'Inici: ' + CONVERT(VARCHAR, GETDATE(), 120);
    
    -- Només facturem comandes entregades
    INSERT INTO Factures (NumeroFactura, ComandaID, ClientID, DataFactura, DataVenciment,
                         BaseImposable, IVA, ImportTotal, Estat, FormaPagament)
    SELECT 
        'FAC-' + RIGHT('0000000000' + CAST(ROW_NUMBER() OVER (ORDER BY c.ComandaID) AS VARCHAR), 10),
        c.ComandaID,
        c.ClientID,
        DATEADD(DAY, 1, ISNULL(c.DataEntrega, c.DataComanda)),
        DATEADD(DAY, 31, ISNULL(c.DataEntrega, c.DataComanda)),
        c.ImportNet,
        c.ImportNet * 0.21,
        c.ImportNet * 1.21,
        CASE 
            WHEN DATEDIFF(DAY, DATEADD(DAY, 1, ISNULL(c.DataEntrega, c.DataComanda)), GETDATE()) > 30 
                 AND (ABS(CHECKSUM(NEWID())) % 10) < 2 THEN 'Vençut'
            WHEN (ABS(CHECKSUM(NEWID())) % 10) < 8 THEN 'Pagat'
            ELSE 'Pendent'
        END,
        CASE (ABS(CHECKSUM(NEWID())) % 4)
            WHEN 0 THEN 'Transferència'
            WHEN 1 THEN 'Targeta'
            WHEN 2 THEN 'Efectiu'
            ELSE 'PayPal'
        END
    FROM Comandes c
    WHERE c.Estat = 'Entregat';
    
    -- Actualitzar data de pagament per factures pagades
    UPDATE Factures
    SET DataPagament = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 25, DataFactura)
    WHERE Estat = 'Pagat';
    
    PRINT 'Generant línies de factura...';
    
    -- Generar línies de factura basades en les línies de comanda
    INSERT INTO LiniesFactura (FacturaID, NumeroLinia, ProducteID, Descripcio, Quantitat,
                              PreuUnitari, Descompte, BaseImposable, PercentatgeIVA, 
                              ImportIVA, ImportTotal)
    SELECT 
        f.FacturaID,
        lc.NumeroLinia,
        lc.ProducteID,
        p.NomProducte,
        lc.Quantitat,
        lc.PreuUnitari,
        lc.ImportLinia * (lc.Descompte / 100),
        lc.ImportLinia,
        21.00,
        lc.ImportLinia * 0.21,
        lc.ImportLinia * 1.21
    FROM Factures f
    INNER JOIN LiniesComanda lc ON f.ComandaID = lc.ComandaID
    INNER JOIN Productes p ON lc.ProducteID = p.ProducteID;
    
    PRINT 'Fi: ' + CONVERT(VARCHAR, GETDATE(), 120);
    DECLARE @TotalFactures INT;
    DECLARE @TotalLiniesFactura INT;
    SET @TotalFactures = (SELECT COUNT(*) FROM Factures); 
    SET @TotalLiniesFactura = (SELECT COUNT(*) FROM LiniesFactura); 
    PRINT 'Total factures generades: ' + CAST((@TotalFactures) AS VARCHAR);
    PRINT 'Total línies factura generades: ' + CAST((@TotalLiniesFactura) AS VARCHAR);
END
GO
-- =============================================
-- Procediment PRINCIPAL: Executar tot el procés
-- =============================================
-- =============================================
-- Procediment PRINCIPAL: Executar tot el procés
-- =============================================
CREATE OR ALTER PROCEDURE sp_GenerarTotesDades
    @NumClients INT = 10000,
    @NumProductes INT = 1000,
    @NumComandes INT = 10000
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Inici DATETIME2 = GETDATE();
    
    PRINT '============================================================';
    PRINT 'ESBORRAT MASSIU DE DADES - VENDESBigData';
    PRINT '============================================================';

    TRUNCATE TABLE LINIESCOMANDA;
    TRUNCATE TABLE LINIESFACTURA;
    TRUNCATE TABLE COMANDES;
    TRUNCATE TABLE FACTURES;
    TRUNCATE TABLE CLIENTS;
    TRUNCATE TABLE PRODUCTES;
    TRUNCATE TABLE JERARQUIACLIENTS;
    TRUNCATE TABLE JERARQUIAPRODUCTES;



    PRINT '============================================================';
    PRINT 'GENERACIÓ MASSIVA DE DADES - VENDESBD';
    PRINT '============================================================';
    PRINT 'Inici procés: ' + CONVERT(VARCHAR, @Inici, 120);
    PRINT '';
    PRINT 'AVÍS: Aquest procés pot trigar força temps amb volums grans.';
    PRINT 'Paràmetres:';
    PRINT '  - Clients: ' + CAST(@NumClients AS VARCHAR);
    PRINT '  - Productes: ' + CAST(@NumProductes AS VARCHAR);
    PRINT '  - Comandes: ' + CAST(@NumComandes AS VARCHAR);
    PRINT '';
    
    -- Executar procediments
    BEGIN TRY
        EXEC sp_GenerarJerarquiesProductes;
        PRINT '';
        
        EXEC sp_GenerarJerarquiesClients;
        PRINT '';
        
        EXEC sp_GenerarClients @NumClients;
        PRINT '';
        
        EXEC sp_GenerarProductes @NumProductes;
        PRINT '';
        
        EXEC sp_GenerarComandes @NumComandes;
        PRINT '';
        
        EXEC sp_GenerarFactures;
        PRINT '';
        
        -- Reconstruir índexs
        PRINT 'Reconstruint índexs...';
        ALTER INDEX ALL ON LiniesComanda REBUILD;
        ALTER INDEX ALL ON LiniesFactura REBUILD;
        ALTER INDEX ALL ON Comandes REBUILD;
        ALTER INDEX ALL ON Factures REBUILD;
        PRINT '✓ Índexs reconstruïts';
        
        -- Actualitzar estadístiques
        PRINT '';
        PRINT 'Actualitzant estadístiques...';
        UPDATE STATISTICS Clients WITH FULLSCAN;
        UPDATE STATISTICS Productes WITH FULLSCAN;
        UPDATE STATISTICS Comandes WITH FULLSCAN;
        UPDATE STATISTICS LiniesComanda WITH FULLSCAN;
        UPDATE STATISTICS Factures WITH FULLSCAN;
        UPDATE STATISTICS LiniesFactura WITH FULLSCAN;
        PRINT '✓ Estadístiques actualitzades';
        
        DECLARE @Fi DATETIME2 = GETDATE();
        DECLARE @Durada INT = DATEDIFF(SECOND, @Inici, @Fi);
        

        declare @TotalJerarquiesProductes INT;
        set @TotalJerarquiesProductes=(SELECT COUNT(*) FROM JerarquiaProductes);
        declare @TotalJerarquiesClients INT;
        set @TotalJerarquiesClients=(SELECT COUNT(*) FROM JerarquiaClients);
        declare @TotalClients INT;
        set @TotalClients=(SELECT COUNT(*) FROM Clients);
        declare @TotalProductes INT;
        set @TotalProductes=(SELECT COUNT(*) FROM Productes)
        declare @TotalComandes INT;
        set @TotalComandes=(SELECT COUNT(*) FROM Comandes);
        declare @TotalLiniesComanda INT;
        set @TotalLiniesComanda=(SELECT COUNT(*) FROM LiniesComanda);
        declare @TotalFactures INT;
        set @TotalFactures=(SELECT COUNT(*) FROM Factures);
        declare @TotalLiniesFactura INT;
        set @TotalLiniesFactura=(SELECT COUNT(*) FROM LiniesFactura);



        PRINT '';
        PRINT '============================================================';
        PRINT 'RESUM FINAL';
        PRINT '============================================================';
        PRINT 'Jerarquies Productes: ' + CAST((@TotalJerarquiesProductes) AS VARCHAR);
        PRINT 'Jerarquies Clients: ' + CAST((@TotalJerarquiesClients) AS VARCHAR);
        PRINT 'Clients: ' + CAST((@TotalClients) AS VARCHAR);
        PRINT 'Productes: ' + CAST((@TotalProductes) AS VARCHAR);
        PRINT 'Comandes: ' + CAST((@TotalComandes) AS VARCHAR);
        PRINT 'Línies Comanda: ' + CAST((@TotalLiniesComanda) AS VARCHAR);
        PRINT 'Factures: ' + CAST((@TotalFactures) AS VARCHAR);
        PRINT 'Línies Factura: ' + CAST((@TotalLiniesFactura) AS VARCHAR);
        PRINT '';
        PRINT 'Fi procés: ' + CONVERT(VARCHAR, @Fi, 120);
        PRINT 'Durada total: ' + CAST(@Durada / 60 AS VARCHAR) + ' minuts ' + CAST(@Durada % 60 AS VARCHAR) + ' segons';
        PRINT '============================================================';
        PRINT '';
        PRINT '✓✓✓ PROCÉS COMPLETAT AMB ÈXIT! ✓✓✓';
        
    END TRY
    BEGIN CATCH
        PRINT '';
        PRINT '============================================================';
        PRINT '❌ ERROR EN EL PROCÉS DE GENERACIÓ';
        PRINT '============================================================';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT '============================================================';
        
        -- Rollback si hi ha transacció activa
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH
END
GO

-- =============================================
-- EXEMPLE D'ÚS
-- =============================================
/*
-- IMPORTANT: Comença amb volums petits per provar!

-- Prova petita (ràpida, ~1-2 minuts):
EXEC sp_GenerarTotesDades 
    @NumClients = 1000,
    @NumProductes = 100,
    @NumComandes = 1000;

-- Prova mitjana (~5-10 minuts):
EXEC sp_GenerarTotesDades 
    @NumClients = 10000,
    @NumProductes = 1000,
    @NumComandes = 10000;

-- Volum gran (~30-60 minuts):
EXEC sp_GenerarTotesDades 
    @NumClients = 100000,
    @NumProductes = 10000,
    @NumComandes = 100000;

-- Volum MOLT gran (vàries hores):
EXEC sp_GenerarTotesDades 
    @NumClients = 100000,
    @NumProductes = 10000,
    @NumComandes = 1000000;

-- Generar només una part específica:
EXEC sp_GenerarJerarquiesProductes;
EXEC sp_GenerarJerarquiesClients;
EXEC sp_GenerarClients @NumClients = 5000;
EXEC sp_GenerarProductes @NumProductes = 500;
EXEC sp_GenerarComandes @NumComandes = 5000;
EXEC sp_GenerarFactures;
*/

-- =============================================
-- EXEMPLE D'ÚS
-- =============================================
/*
-- Generar totes les dades amb valors per defecte:
EXEC sp_GenerarTotesDades;

-- O especificar quantitats personalitzades:
EXEC sp_GenerarTotesDades 
    @NumClients = 50000,
    @NumProductes = 5000,
    @NumComandes = 200000;

-- Generar només una part:
EXEC sp_GenerarJerarquiesProductes;
EXEC sp_GenerarJerarquiesClients;
EXEC sp_GenerarClients @NumClients = 10000;
EXEC sp_GenerarProductes @NumProductes = 1000;
EXEC sp_GenerarComandes @NumComandes = 50000;
EXEC sp_GenerarFactures;
*/