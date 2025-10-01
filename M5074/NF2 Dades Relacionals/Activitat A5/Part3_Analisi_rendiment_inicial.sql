-- =============================================
-- M5074 - BigData i IA
-- Part 3: Anàlisi de Rendiment Inicial i Configuració
-- =============================================

USE VendesBigData;
GO

-- =============================================
-- SECCIÓ 1: CONFIGURACIÓ DEL SERVIDOR
-- =============================================

PRINT '============================================================';
PRINT 'CONFIGURACIÓ ACTUAL DEL SERVIDOR';
PRINT '============================================================';
PRINT '';

-- Memòria configurada
SELECT 
    'Memòria Màxima (MB)' AS Configuracio,
    CAST(value_in_use AS VARCHAR) AS Valor
FROM sys.configurations
WHERE name = 'max server memory (MB)'
UNION ALL
SELECT 
    'Memòria Mínima (MB)',
    CAST(value_in_use AS VARCHAR)
FROM sys.configurations
WHERE name = 'min server memory (MB)'
UNION ALL
SELECT 
    'Grau Màxim Paral·lelisme (MAXDOP)',
    CAST(value_in_use AS VARCHAR)
FROM sys.configurations
WHERE name = 'max degree of parallelism'
UNION ALL
SELECT 
    'Cost Threshold for Parallelism',
    CAST(value_in_use AS VARCHAR)
FROM sys.configurations
WHERE name = 'cost threshold for parallelism'
UNION ALL
SELECT 
    'Optimize for Ad Hoc Workloads',
    CAST(value_in_use AS VARCHAR)
FROM sys.configurations
WHERE name = 'optimize for ad hoc workloads';
GO

-- =============================================
-- OPTIMITZACIONS RECOMANADES PER SERVIDOR
-- =============================================

PRINT '';
PRINT '============================================================';
PRINT 'APLICANT OPTIMITZACIONS RECOMANADES';
PRINT '============================================================';

-- Configurar memòria màxima (deixar 20% pel SO)
DECLARE @TotalMemoryMB BIGINT;
DECLARE @RecommendedMaxMemory BIGINT;

SELECT @TotalMemoryMB = total_physical_memory_kb / 1024
FROM sys.dm_os_sys_memory;

SET @RecommendedMaxMemory = @TotalMemoryMB * 0.8;

PRINT 'Memòria física total: ' + CAST(@TotalMemoryMB AS VARCHAR) + ' MB';
PRINT 'Memòria recomanada per SQL Server: ' + CAST(@RecommendedMaxMemory AS VARCHAR) + ' MB';

-- Descomentar per aplicar:
-- EXEC sp_configure 'show advanced options', 1;
-- RECONFIGURE;
-- EXEC sp_configure 'max server memory (MB)', @RecommendedMaxMemory;
-- RECONFIGURE;

-- Configurar MAXDOP (regla general: número de cores fins a 8)
DECLARE @NumCPUs INT = (SELECT cpu_count FROM sys.dm_os_sys_info);
DECLARE @RecommendedMAXDOP INT = CASE 
    WHEN @NumCPUs >= 8 THEN 8 
    ELSE @NumCPUs 
END;

PRINT 'CPUs disponibles: ' + CAST(@NumCPUs AS VARCHAR);
PRINT 'MAXDOP recomanat: ' + CAST(@RecommendedMAXDOP AS VARCHAR);

-- Descomentar per aplicar:
-- EXEC sp_configure 'max degree of parallelism', @RecommendedMAXDOP;
-- RECONFIGURE;

-- Cost Threshold for Parallelism (recomanat: 50)
PRINT 'Cost Threshold recomanat: 50';
-- EXEC sp_configure 'cost threshold for parallelism', 50;
-- RECONFIGURE;

-- Optimize for Ad Hoc Workloads
PRINT 'Activar Optimize for Ad Hoc Workloads: 1';
-- EXEC sp_configure 'optimize for ad hoc workloads', 1;
-- RECONFIGURE;

GO

-- =============================================
-- SECCIÓ 2: CONFIGURACIÓ DE LA BASE DE DADES
-- =============================================

PRINT '';
PRINT '============================================================';
PRINT 'CONFIGURACIÓ ACTUAL DE LA BASE DE DADES';
PRINT '============================================================';

-- Opcions de BD
SELECT 
    'Recovery Model' AS Opcio,
    recovery_model_desc AS Valor
FROM sys.databases
WHERE name = 'VendesBigData'
UNION ALL
SELECT 
    'Compatibility Level',
    CAST(compatibility_level AS VARCHAR)
FROM sys.databases
WHERE name = 'VendesBigData'
UNION ALL
SELECT 
    'Page Verify Option',
    page_verify_option_desc
FROM sys.databases
WHERE name = 'VendesBigData'
UNION ALL
SELECT 
    'Auto Create Statistics',
    CAST(is_auto_create_stats_on AS VARCHAR)
FROM sys.databases
WHERE name = 'VendesBigData'
UNION ALL
SELECT 
    'Auto Update Statistics',
    CAST(is_auto_update_stats_on AS VARCHAR)
FROM sys.databases
WHERE name = 'VendesBigData'
UNION ALL
SELECT 
    'Auto Update Statistics Async',
    CAST(is_auto_update_stats_async_on AS VARCHAR)
FROM sys.databases
WHERE name = 'VendesBigData';
GO

-- =============================================
-- OPTIMITZACIONS DE BASE DE DADES
-- =============================================

PRINT '';
PRINT '============================================================';
PRINT 'APLICANT OPTIMITZACIONS DE BASE DE DADES';
PRINT '============================================================';

-- Canviar a mode SIMPLE si només és per desenvolupament/testing
-- (EVITA en producció!)

PRINT 'Configurant Recovery Model a SIMPLE per millor rendiment en càrregues...';

ALTER DATABASE VendesBigData SET RECOVERY SIMPLE;

-- Activar estadístiques automàtiques asíncrones
PRINT 'Activant Auto Update Statistics Async...';
ALTER DATABASE VendesBigData SET AUTO_UPDATE_STATISTICS_ASYNC ON;

-- Configurar auto-growth adequat
PRINT 'Configurant creixement automàtic de fitxers...';
ALTER DATABASE VendesBigData 
MODIFY FILE (NAME = VendesBigData_Data, FILEGROWTH = 512MB);

ALTER DATABASE VendesBigData 
MODIFY FILE (NAME = VendesBigData_Log, FILEGROWTH = 256MB);

-- Activar Query Store per anàlisi de rendiment
PRINT 'Activant Query Store...';
ALTER DATABASE VendesBigData SET QUERY_STORE = ON;
ALTER DATABASE VendesBigData SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO
);

PRINT '';
PRINT 'Optimitzacions aplicades correctament!';
GO

-- =============================================
-- SECCIÓ 3: ANÀLISI ÚS DE RECURSOS
-- =============================================

PRINT '';
PRINT '============================================================';
PRINT 'ANÀLISI ÚS DE RECURSOS';
PRINT '============================================================';

-- Tamanys de taules
PRINT '';
PRINT 'TAMANY DE TAULES:';
SELECT 
    t.name AS NomTaula,
    p.rows AS NumRegistres,
    CAST(SUM(a.total_pages) * 8 / 1024.0 AS DECIMAL(18,2)) AS TamanyTotalMB,
    CAST(SUM(a.used_pages) * 8 / 1024.0 AS DECIMAL(18,2)) AS EspaiUtilitzatMB,
    CAST((SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024.0 AS DECIMAL(18,2)) AS EspaiLliureMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
GROUP BY t.name, p.rows
ORDER BY SUM(a.total_pages) DESC;
GO

-- Índexs existents i el seu ús
PRINT '';
PRINT 'ÍNDEXS I EL SEU ÚS:';
SELECT 
    OBJECT_NAME(i.object_id) AS NomTaula,
    i.name AS NomIndex,
    i.type_desc AS TipusIndex,
    CAST(SUM(ps.used_page_count) * 8 / 1024.0 AS DECIMAL(18,2)) AS TamanyMB,
    ISNULL(us.user_seeks, 0) AS Seeks,
    ISNULL(us.user_scans, 0) AS Scans,
    ISNULL(us.user_lookups, 0) AS Lookups,
    ISNULL(us.user_updates, 0) AS Updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats us ON i.object_id = us.object_id AND i.index_id = us.index_id AND us.database_id = DB_ID()
LEFT JOIN sys.dm_db_partition_stats ps ON i.object_id = ps.object_id AND i.index_id = ps.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
GROUP BY OBJECT_NAME(i.object_id), i.name, i.type_desc, us.user_seeks, us.user_scans, us.user_lookups, us.user_updates
ORDER BY OBJECT_NAME(i.object_id)
GO

-- =============================================
-- SECCIÓ 4: CONSULTES DE PROVA (BASELINE)
-- =============================================

PRINT '';
PRINT '============================================================';
PRINT 'PROVES DE RENDIMENT INICIAL (BASELINE)';
PRINT '============================================================';

-- Activar estadístiques de temps i IO
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

PRINT '';
PRINT 'TEST 1: Consulta simple amb agregació';
PRINT '----------------------------------------';
-- Consulta 1: Resum de vendes per mes
SELECT 
    YEAR(DataComanda) AS Anyo,
    MONTH(DataComanda) AS Mes,
    COUNT(*) AS NumComandes,
    SUM(ImportTotal) AS TotalVendes,
    AVG(ImportTotal) AS MitjanaVendes
FROM Comandes
WHERE DataComanda >= DATEADD(YEAR, -1, GETDATE())
GROUP BY YEAR(DataComanda), MONTH(DataComanda)
ORDER BY Anyo, Mes;
GO

PRINT '';
PRINT 'TEST 2: JOIN complexe amb múltiples taules';
PRINT '----------------------------------------';
-- Consulta 2: Top 10 clients per volum de compres
SELECT TOP 10
    c.ClientID,
    cl.NomClient,
    COUNT(DISTINCT c.ComandaID) AS NumComandes,
    SUM(lc.Quantitat) AS TotalUnitats,
    SUM(lc.ImportLinia) AS TotalComprat
FROM Comandes c
INNER JOIN Clients cl ON c.ClientID = cl.ClientID
INNER JOIN LiniesComanda lc ON c.ComandaID = lc.ComandaID
WHERE c.DataComanda >= DATEADD(MONTH, -6, GETDATE())
GROUP BY c.ClientID, cl.NomClient
ORDER BY TotalComprat DESC;
GO

PRINT '';
PRINT 'TEST 3: Consulta amb subqueries';
PRINT '----------------------------------------';
-- Consulta 3: Productes més venuts per categoria
SELECT 
    jp.Nivell1 AS Departament,
    jp.Nivell2 AS Categoria,
    p.NomProducte,
    SUM(lc.Quantitat) AS TotalVenuts,
    SUM(lc.ImportLinia) AS TotalFacturat
FROM LiniesComanda lc
INNER JOIN Productes p ON lc.ProducteID = p.ProducteID
INNER JOIN JerarquiaProductes jp ON p.JerarquiaProducteID = jp.JerarquiaProducteID
INNER JOIN Comandes c ON lc.ComandaID = c.ComandaID
WHERE c.DataComanda >= DATEADD(MONTH, -3, GETDATE())
GROUP BY jp.Nivell1, jp.Nivell2, p.NomProducte
HAVING SUM(lc.Quantitat) > 10
ORDER BY jp.Nivell1, jp.Nivell2, TotalVenuts DESC;
GO

PRINT '';
PRINT 'TEST 4: Anàlisi de rendiment per segment de client';
PRINT '----------------------------------------';
-- Consulta 4: Rendiment per segment de client
SELECT 
    jc.Nivell1 AS TipusClient,
    jc.Nivell2 AS Segment,
    COUNT(DISTINCT c.ClientID) AS NumClients,
    COUNT(DISTINCT co.ComandaID) AS NumComandes,
    SUM(co.ImportTotal) AS TotalVendes,
    AVG(co.ImportTotal) AS MitjanaPerComanda,
    SUM(co.ImportTotal) / NULLIF(COUNT(DISTINCT c.ClientID), 0) AS VendesPerClient
FROM Clients c
INNER JOIN JerarquiaClients jc ON c.JerarquiaClientID = jc.JerarquiaClientID
LEFT JOIN Comandes co ON c.ClientID = co.ClientID AND co.DataComanda >= DATEADD(YEAR, -1, GETDATE())
GROUP BY jc.Nivell1, jc.Nivell2
ORDER BY TotalVendes DESC;
GO

PRINT '';
PRINT 'TEST 5: Cerca històric de client (simulant CRM)';
PRINT '----------------------------------------';
-- Consulta 5: Històric complet d'un client
DECLARE @ClientID INT = (SELECT TOP 1 ClientID FROM Clients ORDER BY NEWID());

SELECT 
    c.ComandaID,
    c.NumeroComanda,
    c.DataComanda,
    c.Estat,
    COUNT(lc.LiniaComandaID) AS NumLinies,
    SUM(lc.Quantitat) AS TotalUnitats,
    c.ImportTotal
FROM Comandes c
LEFT JOIN LiniesComanda lc ON c.ComandaID = lc.ComandaID
WHERE c.ClientID = @ClientID
GROUP BY c.ComandaID, c.NumeroComanda, c.DataComanda, c.Estat, c.ImportTotal
ORDER BY c.DataComanda DESC;
GO

PRINT '';
PRINT 'TEST 6: Anàlisi de tendències temporals';
PRINT '----------------------------------------';
-- Consulta 6: Evolució de vendes per dia de la setmana
SELECT 
    DATENAME(WEEKDAY, DataComanda) AS DiaSemana,
    DATEPART(WEEKDAY, DataComanda) AS NumeroDia,
    COUNT(*) AS NumComandes,
    SUM(ImportTotal) AS TotalVendes,
    AVG(ImportTotal) AS MitjanaComanda
FROM Comandes
WHERE DataComanda >= DATEADD(MONTH, -3, GETDATE())
GROUP BY DATENAME(WEEKDAY, DataComanda), DATEPART(WEEKDAY, DataComanda)
ORDER BY NumeroDia;
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- =============================================
-- SECCIÓ 5: IDENTIFICAR PROBLEMES DE RENDIMENT
-- =============================================

PRINT '';
PRINT '============================================================';
PRINT 'IDENTIFICACIÓ DE PROBLEMES DE RENDIMENT';
PRINT '============================================================';

-- Índexs que mai s'han utilitzat
PRINT '';
PRINT 'ÍNDEXS NO UTILITZATS (candidats per eliminar):';
SELECT 
    OBJECT_NAME(i.object_id) AS NomTaula,
    i.name AS NomIndex,
    CAST(SUM(ps.used_page_count) * 8 / 1024.0 AS DECIMAL(18,2)) AS TamanyMB
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats us ON i.object_id = us.object_id AND i.index_id = us.index_id AND us.database_id = DB_ID()
INNER JOIN sys.dm_db_partition_stats ps ON i.object_id = ps.object_id AND i.index_id = ps.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
    AND i.index_id > 1  -- Excloure clustered index
    AND us.user_seeks IS NULL
    AND us.user_scans IS NULL
    AND us.user_lookups IS NULL
GROUP BY OBJECT_NAME(i.object_id), i.name
ORDER BY TamanyMB DESC;
GO

-- Índexs amb més updates que reads (possibles candidats a revisar)
PRINT '';
PRINT 'ÍNDEXS AMB MÉS WRITES QUE READS:';
SELECT 
    OBJECT_NAME(i.object_id) AS NomTaula,
    i.name AS NomIndex,
    us.user_updates AS Updates,
    us.user_seeks + us.user_scans + us.user_lookups AS Reads,
    CAST(us.user_updates AS FLOAT) / NULLIF(us.user_seeks + us.user_scans + us.user_lookups, 0) AS RatioWriteRead
FROM sys.indexes i
INNER JOIN sys.dm_db_index_usage_stats us ON i.object_id = us.object_id AND i.index_id = us.index_id
WHERE us.database_id = DB_ID()
    AND OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
    AND us.user_updates > (us.user_seeks + us.user_scans + us.user_lookups)
ORDER BY RatioWriteRead DESC;
GO

-- Fragmentació d'índexs
PRINT '';
PRINT 'FRAGMENTACIÓ ÍNDEXS:';
SELECT 
    OBJECT_NAME(ips.object_id) AS NomTaula,
    i.name AS NomIndex,
    ips.index_type_desc AS TipusIndex,
    ips.avg_fragmentation_in_percent AS FragmentacioPercent,
    ips.page_count AS NumPagines,
    CASE 
        WHEN ips.avg_fragmentation_in_percent > 30 THEN 'REBUILD'
        WHEN ips.avg_fragmentation_in_percent > 10 THEN 'REORGANIZE'
        ELSE 'OK'
    END AS Accio
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE OBJECTPROPERTY(ips.object_id, 'IsUserTable') = 1
    AND ips.index_id > 0
    AND ips.page_count > 1000
ORDER BY ips.avg_fragmentation_in_percent DESC;
GO

-- Taules sense índex clustered (heap tables)
PRINT '';
PRINT 'TAULES SENSE ÍNDEX CLUSTERED (HEAPS):';
SELECT 
    t.name AS NomTaula,
    p.rows AS NumRegistres,
    CAST(SUM(a.total_pages) * 8 / 1024.0 AS DECIMAL(18,2)) AS TamanyMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
    AND i.type = 0  -- HEAP
GROUP BY t.name, p.rows
ORDER BY p.rows DESC;
GO

-- Missing Indexes (suggeriments del motor)
PRINT '';
PRINT 'ÍNDEXS SUGGERITS PEL MOTOR SQL SERVER:';
SELECT 
    OBJECT_NAME(mid.object_id) AS NomTaula,
    'CREATE INDEX IX_' + OBJECT_NAME(mid.object_id) + '_' + 
        REPLACE(REPLACE(REPLACE(ISNULL(mid.equality_columns, ''), ', ', '_'), '[', ''), ']', '') AS IndexSuggerit,
    mid.equality_columns AS ColumnesIgualtat,
    mid.inequality_columns AS ColumnesDesigualtat,
    mid.included_columns AS ColumnesIncloses,
    migs.user_seeks AS UserSeeks,
    migs.user_scans AS UserScans,
    migs.avg_user_impact AS ImpacteEstimat,
    migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS BeneficiEstimat
FROM sys.dm_db_missing_index_details mid
INNER JOIN sys.dm_db_missing_index_groups mig ON mid.index_handle = mig.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
WHERE mid.database_id = DB_ID()
ORDER BY BeneficiEstimat DESC;
GO

-- =============================================
-- RESUM I RECOMANACIONS
-- =============================================

PRINT '';
PRINT '============================================================';
PRINT 'RESUM I RECOMANACIONS';
PRINT '============================================================';
PRINT '';
PRINT 'ANÀLISI COMPLETADA!';
PRINT '';
PRINT 'PROPERES PASSES:';
PRINT '1. Revisar els temps d''execució de les consultes baseline';
PRINT '2. Analitzar els índexs suggerits pel motor';
PRINT '3. Eliminar o desactivar índexs no utilitzats';
PRINT '4. Implementar particionament per taules grans (següent part)';
PRINT '5. Crear índexs columnstore per consultes analítiques';
PRINT '6. Optimitzar consultes específiques identificades com a lentes';
PRINT '';
PRINT '============================================================';
GO