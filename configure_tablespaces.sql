-- ============================================================
-- Prison Management System (PMS)
-- Tablespace Configuration Script
-- Group D | Student ID: 27453 | Name: IRERA Mukawera Jockebed
-- ============================================================

-- Connect to PDB as admin
-- sqlplus jockebed_admin/Jockebed@grpD_27453_jockebed_PrisonManagementSystem_db

-- Set container to PDB (if not already)
ALTER SESSION SET CONTAINER = grpD_27453_jockebed_PrisonManagementSystem_db;

-- ============================================================
-- 1. CREATE DATA TABLESPACE for Prison Management Data
-- ============================================================
CREATE TABLESPACE pms_data
DATAFILE '/u01/app/oracle/oradata/grpD_27453_jockebed_PrisonManagementSystem_db/pms_data01.dbf'
SIZE 200M
AUTOEXTEND ON NEXT 20M MAXSIZE 2G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

-- ============================================================
-- 2. CREATE INDEX TABLESPACE for Indexes
-- ============================================================
CREATE TABLESPACE pms_indexes
DATAFILE '/u01/app/oracle/oradata/grpD_27453_jockebed_PrisonManagementSystem_db/pms_indexes01.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE 1G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

-- ============================================================
-- 3. CREATE TEMPORARY TABLESPACE
-- ============================================================
CREATE TEMPORARY TABLESPACE pms_temp
TEMPFILE '/u01/app/oracle/oradata/grpD_27453_jockebed_PrisonManagementSystem_db/pms_temp01.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL;

-- ============================================================
-- 4. SET DEFAULT TABLESPACES
-- ============================================================
ALTER DATABASE DEFAULT TABLESPACE pms_data;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE pms_temp;

-- ============================================================
-- 5. VERIFY TABLESPACE CREATION
-- ============================================================
SELECT tablespace_name, status, contents, extent_management, 
       segment_space_management, block_size
FROM dba_tablespaces
WHERE tablespace_name IN ('PMS_DATA', 'PMS_INDEXES', 'PMS_TEMP')
ORDER BY tablespace_name;

-- Check datafile configuration
SELECT file_name, tablespace_name, bytes/1024/1024 as size_mb, 
       maxbytes/1024/1024 as max_size_mb, autoextensible
FROM dba_data_files
WHERE tablespace_name IN ('PMS_DATA', 'PMS_INDEXES')
UNION ALL
SELECT file_name, tablespace_name, bytes/1024/1024 as size_mb,
       maxbytes/1024/1024 as max_size_mb, autoextensible
FROM dba_temp_files
WHERE tablespace_name = 'PMS_TEMP'
ORDER BY tablespace_name;

PROMPT ============================================================
PROMPT Tablespaces Configured Successfully!
PROMPT - Data Tablespace: pms_data (200MB, max 2GB)
PROMPT - Index Tablespace: pms_indexes (100MB, max 1GB)
PROMPT - Temporary Tablespace: pms_temp (100MB, max 500MB)
PROMPT ============================================================
