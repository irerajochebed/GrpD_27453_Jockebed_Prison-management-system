-- ============================================================
-- PHASE IV: User Configuration - Prison Management System
-- ============================================================
-- Group: D
-- Student ID: 27453
-- Student Name: IRERA Mukawera Jockebed
-- Database: grpD_27453_jockebed_PrisonManagementSystem_db
-- ============================================================

-- IMPORTANT: Execute as jockebed_admin or SYSDBA in the PDB
-- Connection: sqlplus jockebed_admin/Jockebed@grpD_27453_jockebed_PrisonManagementSystem_db

-- Set session to PDB
ALTER SESSION SET CONTAINER = grpD_27453_jockebed_PrisonManagementSystem_db;

PROMPT ============================================================
PROMPT Configuring Users and Privileges for Prison Management System
PROMPT ============================================================

-- ============================================================
-- PART 1: CONFIGURE ADMIN USER WITH SUPER ADMIN PRIVILEGES
-- ============================================================

PROMPT
PROMPT Configuring Super Admin User: jockebed_admin
PROMPT

-- Grant DBA role (Super Admin privileges)
GRANT DBA TO jockebed_admin;

-- Grant additional system privileges
GRANT CREATE SESSION TO jockebed_admin;
GRANT CREATE TABLE TO jockebed_admin;
GRANT CREATE VIEW TO jockebed_admin;
GRANT CREATE SEQUENCE TO jockebed_admin;
GRANT CREATE PROCEDURE TO jockebed_admin;
GRANT CREATE TRIGGER TO jockebed_admin;
GRANT CREATE SYNONYM TO jockebed_admin;
GRANT CREATE USER TO jockebed_admin;
GRANT CREATE ROLE TO jockebed_admin;
GRANT ALTER USER TO jockebed_admin;
GRANT DROP USER TO jockebed_admin;

-- Grant unlimited tablespace quota
ALTER USER jockebed_admin QUOTA UNLIMITED ON pms_data;
ALTER USER jockebed_admin QUOTA UNLIMITED ON pms_indexes;

-- Set default and temporary tablespaces
ALTER USER jockebed_admin DEFAULT TABLESPACE pms_data;
ALTER USER jockebed_admin TEMPORARY TABLESPACE pms_temp;

PROMPT Super Admin configured: jockebed_admin

-- ============================================================
-- PART 2: CREATE PASSWORD PROFILE FOR SECURITY
-- ============================================================

PROMPT
PROMPT Creating Password Security Profile...
PROMPT

-- Create a password profile with security policies
CREATE PROFILE pms_security_profile LIMIT
    SESSIONS_PER_USER 3
    CPU_PER_SESSION UNLIMITED
    CPU_PER_CALL UNLIMITED
    CONNECT_TIME UNLIMITED
    IDLE_TIME 30
    LOGICAL_READS_PER_SESSION UNLIMITED
    LOGICAL_READS_PER_CALL UNLIMITED
    PRIVATE_SGA UNLIMITED
    COMPOSITE_LIMIT UNLIMITED
    PASSWORD_LIFE_TIME 90
    PASSWORD_REUSE_TIME 365
    PASSWORD_REUSE_MAX 5
    PASSWORD_LOCK_TIME 1
    PASSWORD_GRACE_TIME 7
    FAILED_LOGIN_ATTEMPTS 5;

PROMPT Password profile created: pms_security_profile

-- ============================================================
-- PART 3: CREATE APPLICATION ROLES
-- ============================================================

PROMPT
PROMPT Creating Application Roles...
PROMPT

-- Create Administrator Role
CREATE ROLE pms_admin_role;
GRANT CREATE SESSION TO pms_admin_role;
GRANT CREATE TABLE TO pms_admin_role;
GRANT CREATE VIEW TO pms_admin_role;
GRANT CREATE PROCEDURE TO pms_admin_role;
GRANT CREATE SEQUENCE TO pms_admin_role;

-- Create Officer Role
CREATE ROLE pms_officer_role;
GRANT CREATE SESSION TO pms_officer_role;

-- Create Viewer Role
CREATE ROLE pms_viewer_role;
GRANT CREATE SESSION TO pms_viewer_role;

PROMPT Application roles created

-- ============================================================
-- PART 4: CREATE APPLICATION USERS
-- ============================================================

PROMPT
PROMPT Creating Application Users...
PROMPT

-- Create Prison Administrator User
CREATE USER pms_admin IDENTIFIED BY Admin123
DEFAULT TABLESPACE pms_data
TEMPORARY TABLESPACE pms_temp
PROFILE pms_security_profile
QUOTA UNLIMITED ON pms_data
QUOTA 100M ON pms_indexes
ACCOUNT UNLOCK;

GRANT pms_admin_role TO pms_admin;
GRANT CREATE SESSION TO pms_admin;

PROMPT Created user: pms_admin (Administrator - Full Access)

-- Create Prison Officer User
CREATE USER pms_officer IDENTIFIED BY Officer123
DEFAULT TABLESPACE pms_data
TEMPORARY TABLESPACE pms_temp
PROFILE pms_security_profile
QUOTA 10M ON pms_data
ACCOUNT UNLOCK;

GRANT pms_officer_role TO pms_officer;
GRANT CREATE SESSION TO pms_officer;

PROMPT Created user: pms_officer (Officer - Insert/Update/Select)

-- Create Prison Viewer User
CREATE USER pms_viewer IDENTIFIED BY Viewer123
DEFAULT TABLESPACE pms_data
TEMPORARY TABLESPACE pms_temp
PROFILE pms_security_profile
ACCOUNT UNLOCK;

GRANT pms_viewer_role TO pms_viewer;
GRANT CREATE SESSION TO pms_viewer;

PROMPT Created user: pms_viewer (Viewer - Read-Only Access)

-- ============================================================
-- PART 5: VERIFICATION
-- ============================================================

PROMPT
PROMPT ============================================================
PROMPT User Configuration Verification
PROMPT ============================================================
PROMPT

-- Display all users
PROMPT Database Users:
PROMPT

SELECT 
    username,
    account_status,
    default_tablespace,
    temporary_tablespace,
    profile,
    TO_CHAR(created, 'YYYY-MM-DD HH24:MI:SS') as created_date
FROM dba_users
WHERE username IN ('JOCKEBED_ADMIN', 'PMS_ADMIN', 'PMS_OFFICER', 'PMS_VIEWER')
ORDER BY username;

PROMPT
PROMPT System Privileges:
PROMPT

-- Display system privileges
SELECT 
    grantee,
    privilege,
    admin_option
FROM dba_sys_privs
WHERE grantee IN ('JOCKEBED_ADMIN', 'PMS_ADMIN', 'PMS_OFFICER', 'PMS_VIEWER',
                  'PMS_ADMIN_ROLE', 'PMS_OFFICER_ROLE', 'PMS_VIEWER_ROLE')
ORDER BY grantee, privilege;

PROMPT
PROMPT Role Assignments:
PROMPT

-- Display role privileges
SELECT 
    grantee,
    granted_role,
    admin_option,
    default_role
FROM dba_role_privs
WHERE grantee IN ('JOCKEBED_ADMIN', 'PMS_ADMIN', 'PMS_OFFICER', 'PMS_VIEWER')
ORDER BY grantee, granted_role;

PROMPT
PROMPT Tablespace Quotas:
PROMPT

-- Display tablespace quotas
SELECT 
    username,
    tablespace_name,
    CASE 
        WHEN max_bytes = -1 THEN 'UNLIMITED'
        ELSE ROUND(max_bytes/1024/1024, 2) || ' MB'
    END as quota,
    ROUND(bytes/1024/1024, 2) as used_mb
FROM dba_ts_quotas
WHERE username IN ('JOCKEBED_ADMIN', 'PMS_ADMIN', 'PMS_OFFICER', 'PMS_VIEWER')
ORDER BY username, tablespace_name;

PROMPT
PROMPT Password Profile Details:
PROMPT

-- Display profile settings
SELECT 
    profile,
    resource_name,
    resource_type,
    limit
FROM dba_profiles
WHERE profile = 'PMS_SECURITY_PROFILE'
ORDER BY resource_type, resource_name;

PROMPT
PROMPT ============================================================
PROMPT User Configuration Summary
PROMPT ============================================================
PROMPT
PROMPT Super Administrator:
PROMPT   Username: jockebed_admin
PROMPT   Password: Jockebed
PROMPT   Role: DBA (Full Super Admin Access)
PROMPT   Quota: Unlimited on pms_data and pms_indexes
PROMPT
PROMPT Application Users:
PROMPT   1. pms_admin
PROMPT      Password: Admin123
PROMPT      Role: Administrator
PROMPT      Access: Full CRUD operations on all tables
PROMPT      Quota: Unlimited on pms_data, 100MB on pms_indexes
PROMPT
PROMPT   2. pms_officer
PROMPT      Password: Officer123
PROMPT      Role: Officer
PROMPT      Access: Insert, Update, Select on prisoner records
PROMPT      Quota: 10MB on pms_data
PROMPT
PROMPT   3. pms_viewer
PROMPT      Password: Viewer123
PROMPT      Role: Viewer
PROMPT      Access: Read-only access to all tables
PROMPT      Quota: No direct table creation
PROMPT
PROMPT Security Profile: pms_security_profile
PROMPT   - Password expires in 90 days
PROMPT   - Account locks after 5 failed login attempts
PROMPT   - Session idle timeout: 30 minutes
PROMPT   - Maximum 3 concurrent sessions per user
PROMPT
PROMPT ============================================================
PROMPT User Configuration Complete!
PROMPT ============================================================
PROMPT Next Step: Create database schema (tables, sequences, etc.)
PROMPT ============================================================
