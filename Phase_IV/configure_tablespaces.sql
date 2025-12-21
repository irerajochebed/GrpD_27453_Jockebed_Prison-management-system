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

 CREATE TABLESPACE PMS_DATA  DATAFILE 'C:\APP\HP\PRODUCT\21C\ORADATA\XE\GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB\pms_data01.dbf'   SIZE 200M  AUTOEXTEND ON  NEXT 50M  MAXSIZE UNLIMITED  EXTENT MANAGEMENT LOCAL  SEGMENT SPACE MANAGEMENT AUTO;


PROMPT ✅ Data tablespace created successfully!
PROMPT

PROMPT Creating Index Tablespace (PRISON_INDEX_TBS)...
PROMPT ============================================================

CREATE TABLESPACE PMS_INDEXES  DATAFILE 'C:\APP\HP\PRODUCT\21C\ORADATA\XE\GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB\pms_indexes01.dbf'  SIZE 100M  AUTOEXTEND ON  NEXT 25M  MAXSIZE UNLIMITED  EXTENT MANAGEMENT LOCAL  SEGMENT SPACE MANAGEMENT AUTO;

PROMPT ✅ Index tablespace created successfully!
PROMPT

PROMPT Creating Temporary Tablespace (PRISON_TEMP_TBS)...
PROMPT ============================================================

CREATE TEMPORARY TABLESPACE PMS_TEMP  TEMPFILE 'C:\APP\HP\PRODUCT\21C\ORADATA\XE\GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB\pms_temp01.dbf'  SIZE 100M  AUTOEXTEND ON  NEXT 20M  MAXSIZE UNLIMITED;
PROMPT ✅ Temporary tablespace created successfully!
PROMPT

PROMPT Creating LOB Tablespace for Documents (PRISON_LOB_TBS)...
PROMPT ============================================================


PROMPT Verifying Tablespaces...
PROMPT ============================================================

SELECT tablespace_name, status, contents FROM dba_tablespaces WHERE tablespace_name IN ('PMS_DATA', 'PMS_INDEXES', 'PMS_TEMP');



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

PROMPT
PROMPT All tablespaces have AUTOEXTEND enabled
PROMPT ============================================================
PROMPT
PROMPT Next Step: Run @03_configure_memory_archive.sql
PROMPT ============================================================
