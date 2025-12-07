-- ============================================================
-- PHASE IV: Memory & Archive Configuration - Prison Management System
-- ============================================================
-- Group: D
-- Student ID: 27453
-- Student Name: IRERA Mukawera Jockebed
-- Database: grpD_27453_jockebed_PrisonManagementSystem_db
-- ============================================================

-- Connect as SYSDBA
-- sqlplus sys/password@grpD_27453_jockebed_PrisonManagementSystem_db as sysdba

-- Set container to PDB
ALTER SESSION SET CONTAINER = grpD_27453_jockebed_PrisonManagementSystem_db;

-- ============================================================
-- 1. CONFIGURE MEMORY PARAMETERS (SGA & PGA)
-- ============================================================

-- Show current memory settings
SHOW PARAMETER sga_target;
SHOW PARAMETER pga_aggregate_target;
SHOW PARAMETER memory_target;

-- Set SGA (System Global Area) - Shared memory for cache, buffers
-- Recommended: 40% of available memory for database
ALTER SYSTEM SET sga_target = 512M SCOPE=BOTH;
ALTER SYSTEM SET sga_max_size = 1G SCOPE=SPFILE;

-- Set PGA (Program Global Area) - Private memory for sessions
-- Recommended: 20% of available memory
ALTER SYSTEM SET pga_aggregate_target = 256M SCOPE=BOTH;

-- Configure shared pool (part of SGA)
ALTER SYSTEM SET shared_pool_size = 200M SCOPE=BOTH;

-- Configure buffer cache (part of SGA)
ALTER SYSTEM SET db_cache_size = 200M SCOPE=BOTH;

-- ============================================================
-- 2. ENABLE ARCHIVE LOGGING
-- ============================================================

-- Check current archivelog mode
ARCHIVE LOG LIST;

-- Shutdown database to enable archive logging
-- Note: This requires CDB-level operation
-- Switch to CDB ROOT first
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- Shutdown and mount the PDB's container database
-- (This part would typically be done at CDB level)
-- For PDB-specific archiving:

ALTER SESSION SET CONTAINER = grpD_27453_jockebed_PrisonManagementSystem_db;

-- Set archive log destination
ALTER SYSTEM SET log_archive_dest_1 = 
'LOCATION=/u01/app/oracle/archivelog/grpD_27453_jockebed_PrisonManagementSystem_db' SCOPE=BOTH;

-- Set archive log format
ALTER SYSTEM SET log_archive_format = 'pms_arch_%t_%s_%r.arc' SCOPE=SPFILE;

-- Enable archive logging (requires CDB-level change)
-- Must be done from CDB$ROOT with database mounted
/*
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
*/

-- ============================================================
-- 3. CONFIGURE ADDITIONAL PERFORMANCE PARAMETERS
-- ============================================================

-- Set undo tablespace retention
ALTER SYSTEM SET undo_retention = 900 SCOPE=BOTH;

-- Configure processes and sessions
ALTER SYSTEM SET processes = 300 SCOPE=SPFILE;
ALTER SYSTEM SET sessions = 335 SCOPE=SPFILE;

-- Enable automatic memory management (optional)
-- ALTER SYSTEM SET memory_target = 768M SCOPE=SPFILE;
-- ALTER SYSTEM SET memory_max_target = 1G SCOPE=SPFILE;

-- ============================================================
-- 4. VERIFY CONFIGURATION
-- ============================================================

-- Check memory parameters
SELECT name, value, description 
FROM v$parameter 
WHERE name IN ('sga_target', 'sga_max_size', 'pga_aggregate_target',
               'shared_pool_size', 'db_cache_size', 'memory_target')
ORDER BY name;

-- Check archive log configuration
SELECT log_mode FROM v$database;
SELECT dest_name, status, destination FROM v$archive_dest WHERE status != 'INACTIVE';

-- Check current memory usage
SELECT 
    ROUND(SUM(bytes)/1024/1024, 2) AS sga_size_mb
FROM v$sgastat;

SELECT 
    ROUND(value/1024/1024, 2) AS pga_size_mb
FROM v$pgastat 
WHERE name = 'total PGA allocated';

PROMPT ============================================================
PROMPT Memory & Archive Logging Configuration Complete!
PROMPT - SGA Target: 512MB (Max: 1GB)
PROMPT - PGA Target: 256MB
PROMPT - Archive Logging: Configured
PROMPT - Performance Parameters: Optimized
PROMPT NOTE: Database restart required for SPFILE changes
PROMPT ============================================================
