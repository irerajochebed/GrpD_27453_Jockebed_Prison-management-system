# Prison Management System (PMS) - Database Setup

**Group:** D  
**Student ID:** 27453  
**Name:** IRERA Mukawera Jockebed  
**Project:** Prison Management System  
**Database Name:** `grpD_27453_jockebed_PrisonManagementSystem_db`

---

## Project Overview

The Prison Management System (PMS) is a centralized software application designed to modernize and streamline the administrative operations of a correctional facility. It replaces inefficient, paper-based record-keeping with a secure, digital solution.

### Key Features
- **Inmate Registration:** Register new inmates upon intake with complete personal and offense details
- **Record Management:** Update prisoner details including behavioral notes, medical needs, and transfer requests
- **Search & View:** Comprehensive prisoner lists and individual profiles with advanced filtering
- **Release Management:** Update inmate status and archive records upon sentence completion
- **Cell Management:** Track housing assignments, capacity, and occupancy
- **Proactive Alerts:** Automatic notifications for overcrowding and upcoming releases
- **Data Analytics:** Visual dashboards for population demographics and trends
- **Audit Trail:** Complete logging of all changes with user accountability
- **Role-Based Access Control:** Granular permissions for different user types

---

## Database Architecture

### Core Tables

1. **prisoners** (Central table)
   - prisoner_id (PK)
   - national_id, first_name, last_name, date_of_birth, gender
   - entry_date, expected_release_date, status
   - cell_id (FK to cells)

2. **cells** (Housing management)
   - cell_id (PK)
   - cell_number, block_name
   - capacity, current_occupancy

3. **offenses** (Charge tracking)
   - offense_id (PK)
   - prisoner_id (FK to prisoners)
   - description, sentence_length, date_charged

4. **users** (System access control)
   - user_id (PK)
   - username, password_hash, role

---

## Installation Instructions

### Prerequisites
- Oracle Database 12c or higher (with support for Pluggable Databases)
- SQL*Plus or Oracle SQL Developer
- SYSDBA privileges for initial setup

### Step 1: Create Pluggable Database

Connect as SYSDBA to your Container Database (CDB):

```bash
sqlplus sys/your_password@CDB as sysdba
```

Execute the database creation script:

```sql
@1_create_pluggable_database.sql
```

**What this does:**
- Creates the pluggable database `grpD_27453_jockebed_PrisonManagementSystem_db`(CREATE PLUGGABLE DATABASE grpD_27453_jockebed_PrisonManagementSystem_db
ADMIN USER jockebed_admin IDENTIFIED BY Jockebed;)
- Creates admin user `jockebed_admin` with password `Jockebed`
- Configures initial storage parameters
- Opens the PDB and saves state for automatic startup

### Step 2: Configure Tablespaces

Connect as the admin user:

```bash
sqlplus jockebed_admin/Jockebed@grpD_27453_jockebed_PrisonManagementSystem_db
```

Execute the tablespace configuration:

```sql
@2_configure_tablespaces.sql
```

**What this does:**
- Creates `pms_data` tablespace (200MB, autoextend to 2GB) for application data
- Creates `pms_indexes` tablespace (100MB, autoextend to 1GB) for indexes
- Creates `pms_temp` temporary tablespace (100MB, autoextend to 500MB)
- Sets default tablespaces

  ---sql
    CREATE TABLESPACE pms_data
    DATAFILE '/u01/app/oracle/oradata/grpD_27453_jockebed_PrisonManagementSystem_db/pms_data01.dbf'
    SIZE 200M
    AUTOEXTEND ON NEXT 20M MAXSIZE 2G
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO
    ONLINE;
 ---

### Step 3: Configure Memory & Archive Logging

Connect as SYSDBA to the PDB:

```bash
sqlplus sys/your_password@grpD_27453_jockebed_PrisonManagementSystem_db as sysdba
```

Execute the memory configuration:

```sql
@3_configure_memory_archiving.sql
```

**What this does:**
- Configures SGA (System Global Area): 512MB target, 1GB maximum
- Configures PGA (Program Global Area): 256MB
- Enables archive logging for backup and recovery
- Sets performance parameters (processes, sessions, undo retention)

**Note:** Some changes require database restart:
```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

### Step 4: Setup Users & Privileges

Connect as the admin user:

```bash
sqlplus jockebed_admin/Jockebed@grpD_27453_jockebed_PrisonManagementSystem_db
```

Execute the user setup:

```sql
@4_user_setup.sql
```

**What this does:**
- Grants super admin privileges to `jockebed_admin`
- Creates application users with role-based access:
  - `pms_admin` (Full CRUD access)
  - `pms_officer` (Insert, Update, Select)
  - `pms_viewer` (Read-only)
- Implements password policies and security profiles

---

## Database Configuration Summary

### Admin Credentials
- **Username:** `jockebed_admin`
- **Password:** `Jockebed`
- **Privileges:** DBA (Super Admin)

### Database Name
- **Full Name:** `grpD_27453_jockebed_PrisonManagementSystem_db`
- **Format:** GrpName_StudentId_FirstName_ProjectName_DB

### Tablespaces
| Tablespace | Type | Initial Size | Max Size | Autoextend |
|------------|------|--------------|----------|------------|
| pms_data | Data | 200 MB | 2 GB | Yes (20 MB) |
| pms_indexes | Index | 100 MB | 1 GB | Yes (10 MB) |
| pms_temp | Temporary | 100 MB | 500 MB | Yes (10 MB) |

### Memory Configuration
- **SGA Target:** 512 MB (Max: 1 GB)
- **PGA Target:** 256 MB
- **Shared Pool:** 200 MB
- **Buffer Cache:** 200 MB

### Archive Logging
- **Status:** Enabled
- **Location:** `/u01/app/oracle/archivelog/grpD_27453_jockebed_PrisonManagementSystem_db`
- **Format:** `pms_arch_%t_%s_%r.arc`

### Application Users
| Username | Password | Role | Access Level |
|----------|----------|------|--------------|
| pms_admin | Admin123 | Administrator | Full CRUD |
| pms_officer | Officer123 | Officer | Insert, Update, Select |
| pms_viewer | Viewer123 | Viewer | Read-only |

---

## Verification Commands

After running all scripts, verify the setup:

```sql
-- Check PDB status
SELECT name, open_mode, restricted FROM v$pdbs 
WHERE name = 'GRPD_27453_JOCKEBED_PRISONMANAGEMENTSYSTEM_DB';

-- Check tablespaces
SELECT tablespace_name, status, contents FROM dba_tablespaces
WHERE tablespace_name LIKE 'PMS%';

-- Check users
SELECT username, account_status, default_tablespace FROM dba_users
WHERE username IN ('JOCKEBED_ADMIN', 'PMS_ADMIN', 'PMS_OFFICER', 'PMS_VIEWER');

-- Check memory configuration
SHOW PARAMETER sga_target;
SHOW PARAMETER pga_aggregate_target;

-- Check archive mode
ARCHIVE LOG LIST;
```

---

## Troubleshooting

### Issue: PDB doesn't start automatically
```sql
ALTER PLUGGABLE DATABASE grpD_27453_jockebed_PrisonManagementSystem_db SAVE STATE;
```

### Issue: Insufficient privileges
```sql
GRANT DBA TO jockebed_admin;
```

### Issue: Tablespace full
```sql
ALTER DATABASE DATAFILE '/path/to/datafile.dbf' AUTOEXTEND ON NEXT 50M MAXSIZE 5G;
```

### Issue: Archive destination full
- Monitor archive log destination space
- Configure RMAN backup to remove old archive logs
- Adjust retention policy

---

## Security Best Practices

✅ Change default passwords immediately in production  
✅ Use strong password policies (already configured)  
✅ Enable audit trail for sensitive operations  
✅ Regularly backup database and archive logs  
✅ Restrict network access to database ports  
✅ Use encrypted connections (TLS/SSL)  
✅ Regularly review user privileges  
✅ Monitor failed login attempts  


**© 2024 IRERA Mukawera Jockebed - Group D**
