-- ============================================================
-- PHASE IV: Memory & Archive Configuration - Prison Management System
-- ============================================================
-- Group: D
-- Student ID: 27453
-- Student Name: IRERA Mukawera Jockebed
-- Database: grpD_27453_jockebed_PrisonManagementSystem_db
-- ============================================================

-- IMPORTANT: Execute as SYSDBA in the PDB
-- Connection: sqlplus sys/password@grpD_27453_jockebed_PrisonManagementSystem_db as sysdba

-- Set session to PDB
ALTER SESSION SET CONTAINER = grpD_27453_jockebed_PrisonManagementSystem_db;

PROMPT ============================================================
PROMPT Configuring Memory Parameters and Archive Logging
PROMPT ============================================================

-- ============================================================
-- PART 1: DISPLAY CURRENT MEMORY CONFIGURATION
-- ============================================================

PROMPT
PROMPT Current Memory Settings:
PROMPT

SHOW PARAMETER sga_target;
SHOW PARAMETER sga_max_size;
SHOW PARAMETER pga_aggregate_target;
SHOW PARAMETER memory_target;
SHOW PARAMETER shared_pool_size;
SHOW PARAMETER db_cache_size;

-- ============================================================
-- PART 2: CONFIGURE SGA (SYSTEM GLOBAL AREA)
-- ============================================================

PROMPT
PROMPT Configuring SGA (System Global Area)...
PROMPT

-- Set SGA target to 512MB (can use up to 1GB max)
ALTER SYSTEM SET sga_target = 512M SCOPE=BOTH;
ALTER SYSTEM SET sga_max_size = 1G SCOPE=SPFILE;

-- Configure shared pool (dictionary cache, SQL areas)
ALTER SYSTEM SET shared_pool_size = 200M SCOPE=BOTH;

-- Configure database buffer cache (data blocks)
ALTER SYSTEM SET db_cache_size = 200M SCOPE=BOTH;

PROMPT SGA configured: 512MB target, 1GB maximum

-- ============================================================
-- PART 3: CONFIGURE PGA (PROGRAM GLOBAL AREA)
-- ============================================================

PROMPT
PROMPT Configuring PGA (Program Global Area)...
PROMPT

-- Set PGA aggregate target to 256MB
ALTER SYSTEM SET pga_aggregate_target = 256M SCOPE=BOTH;

PROMPT PGA configured: 256MB

-- ============================================================
-- PART 4: CONFIGURE ADDITIONAL PERFORMANCE PARAMETERS
-- ============================================================

PROMPT
PROMPT Configuring Performance Parameters...
PROMPT

-- Set undo retention (15 minutes)
ALTER SYSTEM SET undo_retention = 900 SCOPE=BOTH;

-- Configure maximum number of processes
ALTER SYSTEM SET processes = 300 SCOPE=SPFILE;

-- Configure maximum number of sessions (derived from processes)
ALTER SYSTEM SET sessions = 335 SCOPE=SPFILE;

-- Configure open cursors per session
ALTER SYSTEM SET open_cursors = 300 SCOPE=BOTH;

PROMPT Performance parameters configured

-- ============================================================
-- PART 5: CONFIGURE ARCHIVE LOGGING
-- ============================================================

PROMPT
PROMPT Configuring Archive Logging...
PROMPT

-- Check current archive log mode
ARCHIVE LOG LIST;

-- Set archive log destination
ALTER SYSTEM SET log_archive_dest_1 = 
'LOCATION=/u01/app/oracle/archivelog/grpD_27453_jockebed_PrisonManagementSystem_db VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=grpD_27453_jockebed_PrisonManagementSystem_db' 
SCOPE=BOTH;

-- Set archive log format
ALTER SYSTEM SET log_archive_format = 'pms_arch_%t_%s_%r.arc' SCOPE=SPFILE;

-- Set archive log naming convention
ALTER SYSTEM SET log_archive_max_processes = 4 SCOPE=BOTH;

PROMPT Archive logging configured

-- ============================================================
-- PART 6: ENABLE ARCHIVE LOG MODE (CDB LEVEL)
-- ============================================================

PROMPT
PROMPT NOTE: To enable ARCHIVELOG mode, execute the following
PROMPT commands at CDB level (as SYSDBA in CDB$ROOT):
PROMPT
PROMPT ALTER SESSION SET CONTAINER = CDB$ROOT;
PROMPT SHUTDOWN IMMEDIATE;
PROMPT STARTUP MOUNT;
PROMPT ALTER DATABASE ARCHIVELOG;
PROMPT ALTER DATABASE OPEN;
PROMPT ALTER PLUGGABLE DATABASE ALL OPEN;
PROMPT

-- ============================================================
-- PART 7: CONFIGURE AUTOEXTEND PARAMETERS
-- ============================================================

PROMPT
PROMPT Configuring Autoextend Parameters...
PROMPT

-- Ensure redo logs have appropriate size
-- Note: Redo logs are managed at CDB level
ALTER SYSTEM SET db_recovery_file_dest_size = 10G SCOPE=BOTH;
ALTER SYSTEM SET db_recovery_file_dest = '/u01/app/oracle/fast_recovery_area' SCOPE=BOTH;

PROMPT Autoextend and recovery parameters configured

-- ============================================================
-- PART 8: VERIFICATION AND SUMMARY
-- ============================================================

PROMPT
PROMPT ============================================================
PROMPT Memory Configuration Verification
PROMPT ============================================================
PROMPT

-- Verify memory parameters
SELECT 
    name,
    value,
    CASE 
        WHEN name LIKE '%size%' OR name LIKE '%target%' 
        THEN ROUND(value/1024/1024, 2) || ' MB'
        ELSE value
    END as display_value,
    description
FROM v$parameter 
WHERE name IN (
    'sga_target', 
    'sga_max_size', 
    'pga_aggregate_target',
    'shared_pool_size', 
    'db_cache_size', 
    'memory_target',
    'processes',
    'sessions',
    'open_cursors',
    'undo_retention'
)
ORDER BY name;

PROMPT
PROMPT Archive Log Configuration:
PROMPT

SELECT 
    dest_name,
    status,
    destination,
    error
FROM v$archive_dest 
WHERE status != 'INACTIVE';

PROMPT
PROMPT Current Memory Usage:
PROMPT

-- Show SGA components
SELECT 
    name,
    ROUND(bytes/1024/1024, 2) as size_mb
FROM v$sgainfo
WHERE name IN ('Fixed SGA Size', 'Redo Buffers', 'Buffer Cache Size', 
               'Shared Pool Size', 'Large Pool Size', 'Java Pool Size');

-- Show PGA usage
SELECT 
    ROUND(value/1024/1024, 2) as pga_mb
FROM v$pgastat 
WHERE name = 'total PGA allocated';

PROMPT
PROMPT ============================================================
PROMPT Configuration Summary
PROMPT ============================================================
PROMPT
PROMPT Memory Configuration:
PROMPT   SGA Target: 512 MB (Maximum: 1 GB)
PROMPT   PGA Target: 256 MB
PROMPT   Shared Pool: 200 MB
PROMPT   Buffer Cache: 200 MB
PROMPT
PROMPT Performance Settings:
PROMPT   Max Processes: 300
PROMPT   Max Sessions: 335
PROMPT   Undo Retention: 900 seconds (15 minutes)
PROMPT   Open Cursors: 300
PROMPT
PROMPT Archive Logging:
PROMPT   Status: Configured
PROMPT   Destination: /u01/app/oracle/archivelog/grpD_27453_jockebed_PrisonManagementSystem_db
PROMPT   Format: pms_arch_%t_%s_%r.arc
PROMPT
PROMPT Autoextend:
PROMPT   Recovery Area: 10 GB
PROMPT   All datafiles configured with autoextend
PROMPT
PROMPT ============================================================
PROMPT IMPORTANT: Database restart required for SPFILE changes
PROMPT Execute: SHUTDOWN IMMEDIATE; STARTUP;
PROMPT ============================================================
PROMPT Next Step: Execute 04_configure_users.sql
PROMPT ============================================================
