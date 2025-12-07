-- ============================================================
-- Tablespace Configuration for 
-- Prison Management System
-- ============================================================
-- Student: IRERA Mukawera Jockebed | ID: 27453 | Group: D
-- Database: grpD_27453_jockebed_PrisonManagementSystem_db
-- ============================================================
-- Execute as: sqlplus jockebed_admin/Jockebed@grpD_27453_jockebed_PrisonManagementSystem_db
-- ============================================================

PROMPT ============================================================
PROMPT Configuring Tablespaces for Prison Management System
PROMPT ============================================================

-- Ensure we're in the correct PDB
ALTER SESSION SET CONTAINER = grpD_27453_jockebed_PrisonManagementSystem_db;

PROMPT
PROMPT Creating Data Tablespace (PRISON_DATA_TBS)...
PROMPT ============================================================

CREATE TABLESPACE PRISON_DATA_TBS
DATAFILE 'C:\APP\HP\PRODUCT\21C\ORADATA\XE\GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB\prison_data_01.dbf'
SIZE 100M
AUTOEXTEND ON 
NEXT 10M 
MAXSIZE 2G
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

PROMPT ✅ Data tablespace created successfully!
PROMPT

PROMPT Creating Index Tablespace (PRISON_INDEX_TBS)...
PROMPT ============================================================

CREATE TABLESPACE PRISON_INDEX_TBS
DATAFILE 'C:\APP\HP\PRODUCT\21C\ORADATA\XE\GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB\prison_index_01.dbf'
SIZE 50M
AUTOEXTEND ON 
NEXT 5M 
MAXSIZE 1G
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

PROMPT ✅ Index tablespace created successfully!
PROMPT

PROMPT Creating Temporary Tablespace (PRISON_TEMP_TBS)...
PROMPT ============================================================

CREATE TEMPORARY TABLESPACE PRISON_TEMP_TBS
TEMPFILE 'C:\APP\HP\PRODUCT\21C\ORADATA\XE\GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB\prison_temp_01.dbf'
SIZE 50M
AUTOEXTEND ON 
NEXT 5M 
MAXSIZE 500M
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;

PROMPT ✅ Temporary tablespace created successfully!
PROMPT

PROMPT Creating LOB Tablespace for Documents (PRISON_LOB_TBS)...
PROMPT ============================================================

CREATE TABLESPACE PRISON_LOB_TBS
DATAFILE 'C:\APP\HP\PRODUCT\21C\ORADATA\XE\GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB\prison_lob_01.dbf'
SIZE 50M
AUTOEXTEND ON 
NEXT 10M 
MAXSIZE 1G
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO
ONLINE;

PROMPT ✅ LOB tablespace created successfully!
PROMPT

PROMPT Verifying Tablespaces...
PROMPT ============================================================

SELECT 
    tablespace_name,
    status,
    contents,
    ROUND(bytes/1024/1024, 2) AS size_mb,
    ROUND(maxbytes/1024/1024, 2) AS max_size_mb,
    autoextensible
FROM dba_data_files
WHERE tablespace_name LIKE 'PRISON%'
UNION ALL
SELECT 
    tablespace_name,
    status,
    contents,
    ROUND(bytes/1024/1024, 2) AS size_mb,
    ROUND(maxbytes/1024/1024, 2) AS max_size_mb,
    autoextensible
FROM dba_temp_files
WHERE tablespace_name LIKE 'PRISON%'
ORDER BY tablespace_name;

PROMPT
PROMPT Tablespace Summary:
PROMPT ============================================================

SELECT 
    tablespace_name,
    status,
    contents,
    COUNT(*) as file_count
FROM dba_tablespaces
WHERE tablespace_name LIKE 'PRISON%'
GROUP BY tablespace_name, status, contents
ORDER BY tablespace_name;

PROMPT
PROMPT Setting Default Tablespaces for Admin User...
PROMPT ============================================================

ALTER USER jockebed_admin 
    DEFAULT TABLESPACE PRISON_DATA_TBS
    TEMPORARY TABLESPACE PRISON_TEMP_TBS
    QUOTA UNLIMITED ON PRISON_DATA_TBS
    QUOTA UNLIMITED ON PRISON_INDEX_TBS
    QUOTA UNLIMITED ON PRISON_LOB_TBS;

PROMPT ✅ Default tablespaces set for admin user!
PROMPT

PROMPT ============================================================
PROMPT ✅ SUCCESS! Tablespace Configuration Complete
PROMPT ============================================================
PROMPT
PROMPT Tablespaces Created:
PROMPT   1. PRISON_DATA_TBS   - Main data storage (100MB -> 2GB)
PROMPT   2. PRISON_INDEX_TBS  - Index storage (50MB -> 1GB)
PROMPT   3. PRISON_TEMP_TBS   - Temporary operations (50MB -> 500MB)
PROMPT   4. PRISON_LOB_TBS    - Document storage (50MB -> 1GB)
PROMPT
PROMPT All tablespaces have AUTOEXTEND enabled
PROMPT ============================================================
PROMPT
PROMPT Next Step: Run @03_configure_memory_archive.sql
PROMPT ============================================================
