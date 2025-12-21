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

-- ============================================
-- STEP 1: VERIFY TABLESPACES
-- ============================================
ALTER SESSION SET CONTAINER = GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB;

SELECT tablespace_name, status, contents 
FROM dba_tablespaces
WHERE tablespace_name IN ('PMS_DATA', 'PMS_INDEXES', 'PMS_TEMP');

-- ============================================
-- STEP 2: CONFIGURE MEMORY (CDB LEVEL)
-- ============================================
CONNECT sys/your_password AS SYSDBA;

ALTER SYSTEM SET memory_target = 2G SCOPE = SPFILE;
ALTER SYSTEM SET memory_max_target = 4G SCOPE = SPFILE;
ALTER SYSTEM SET shared_pool_size = 256M SCOPE = SPFILE;
ALTER SYSTEM SET db_cache_size = 512M SCOPE = SPFILE;
ALTER SYSTEM SET processes = 300 SCOPE = SPFILE;

-- ============================================
-- STEP 3: ENABLE ARCHIVE LOGGING
-- ============================================
SELECT name, log_mode FROM v$database;

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ALTER PLUGGABLE DATABASE ALL OPEN;

SELECT name, log_mode FROM v$database;

-- ============================================
-- STEP 4: VERIFY AUTOEXTEND
-- ============================================
ALTER SESSION SET CONTAINER = GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB;

SELECT 
    tablespace_name,
    autoextensible,
    maxbytes/1024/1024 AS max_mb
FROM dba_data_files
WHERE tablespace_name IN ('PMS_DATA', 'PMS_INDEXES')
UNION ALL
SELECT 
    tablespace_name,
    autoextensible,
    maxbytes/1024/1024 AS max_mb
FROM dba_temp_files
WHERE tablespace_name = 'PMS_TEMP';

-- ============================================
-- FINAL VERIFICATION - ALL REQUIREMENTS
-- ============================================
PROMPT ===== PHASE IV REQUIREMENTS CHECK =====

PROMPT 1. Tablespaces Created:
SELECT tablespace_name, status FROM dba_tablespaces
WHERE tablespace_name IN ('PMS_DATA', 'PMS_INDEXES', 'PMS_TEMP');

PROMPT 2. Archive Logging Status:
CONNECT sys/your_password AS SYSDBA;
SELECT name, log_mode FROM v$database;

PROMPT 3. Memory Parameters:
SELECT name, value FROM v$parameter
WHERE name IN ('memory_target', 'sga_target', 'pga_aggregate_target');

PROMPT 4. Autoextend Status:
ALTER SESSION SET CONTAINER = GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB;
SELECT tablespace_name, autoextensible FROM dba_data_files
WHERE tablespace_name IN ('PMS_DATA', 'PMS_INDEXES')
UNION ALL
SELECT tablespace_name, autoextensible FROM dba_temp_files
WHERE tablespace_name = 'PMS_TEMP';

PROMPT ===== ALL CHECKS COMPLETE =====
