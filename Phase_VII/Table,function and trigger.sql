-- SYSTEM_HOLIDAYS Table
CREATE TABLE system_holidays (
    holiday_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    holiday_date  DATE NOT NULL UNIQUE,
    holiday_name  VARCHAR2(100) NOT NULL,
    description   VARCHAR2(500),
    created_date  DATE DEFAULT SYSDATE,
    created_by    VARCHAR2(50) DEFAULT USER
);

-- PMS_AUDIT_LOG Table
CREATE TABLE pms_audit_log (
    audit_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name        VARCHAR2(50) NOT NULL,
    operation_type    VARCHAR2(10) NOT NULL,
    record_id         NUMBER,
    operation_date    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    db_user           VARCHAR2(50) DEFAULT USER NOT NULL,
    os_user           VARCHAR2(50),
    terminal          VARCHAR2(50),
    ip_address        VARCHAR2(50),
    session_id        NUMBER,
    status            VARCHAR2(20) NOT NULL,
    error_message     VARCHAR2(1000),
    old_values        CLOB,
    new_values        CLOB,
    restriction_reason VARCHAR2(200),
    module_name       VARCHAR2(50)
);

-- CHECK_PMS_OPERATION_ALLOWED Function
CREATE OR REPLACE FUNCTION check_pms_operation_allowed
RETURN VARCHAR2
IS
    v_current_date      DATE := TRUNC(SYSDATE);
    v_day_of_week       VARCHAR2(20);
    v_is_holiday        NUMBER := 0;
    v_error_message     VARCHAR2(200);
BEGIN
    v_day_of_week := TO_CHAR(v_current_date, 'DAY', 'NLS_DATE_LANGUAGE=ENGLISH');
    v_day_of_week := TRIM(v_day_of_week);
    
    IF v_day_of_week IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY') THEN
        BEGIN
            SELECT COUNT(*)
            INTO v_is_holiday
            FROM system_holidays
            WHERE holiday_date >= TRUNC(v_current_date, 'MM')
              AND holiday_date < ADD_MONTHS(TRUNC(v_current_date, 'MM'), 1)
              AND holiday_date = v_current_date;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN v_is_holiday := 0;
        END;
        
        IF v_is_holiday > 0 THEN
            SELECT 'PUBLIC HOLIDAY: ' || holiday_name || 
                   ' - Prison management operations restricted'
            INTO v_error_message
            FROM system_holidays
            WHERE holiday_date = v_current_date
            AND ROWNUM = 1;
            
            RETURN v_error_message;
        ELSE
            RETURN 'WEEKDAY RESTRICTION: Prison data modifications are only allowed on weekends (Saturday-Sunday) for security review';
        END IF;
    ELSE
        RETURN NULL;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'SYSTEM ERROR checking restrictions: ' || SQLERRM;
END;
/

-- TRG_PRISONERS_SECURE Trigger
CREATE OR REPLACE TRIGGER trg_prisoners_secure
BEFORE INSERT OR UPDATE OR DELETE ON prisoners
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_restriction VARCHAR2(200);
    v_operation VARCHAR2(10);
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN 
        v_operation := 'INSERT';
        v_record_id := :NEW.prisoner_id;
    ELSIF UPDATING THEN 
        v_operation := 'UPDATE';
        v_record_id := :NEW.prisoner_id;
    ELSE 
        v_operation := 'DELETE';
        v_record_id := :OLD.prisoner_id;
    END IF;
    
    v_restriction := check_pms_operation_allowed();
    
    IF v_restriction IS NOT NULL THEN
        INSERT INTO pms_audit_log (
            table_name, module_name, operation_type, record_id,
            db_user, status, error_message, restriction_reason
        ) VALUES (
            'PRISONERS', 'PRISONER_MGMT', v_operation, v_record_id,
            USER, 'DENIED', v_restriction, v_restriction
        );
        
        COMMIT;
        RAISE_APPLICATION_ERROR(-20901, 
            'PMS SECURITY VIOLATION: ' || v_restriction);
    ELSE
        INSERT INTO pms_audit_log (
            table_name, module_name, operation_type, record_id,
            db_user, status
        ) VALUES (
            'PRISONERS', 'PRISONER_MGMT', v_operation, v_record_id,
            USER, 'SUCCESS'
        );
        
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- TRG_PRISONERS_COMPOUND Trigger (Optional)
CREATE OR REPLACE TRIGGER trg_prisoners_compound
FOR INSERT OR UPDATE OR DELETE ON prisoners
COMPOUND TRIGGER

    TYPE t_audit_rec IS RECORD (
        record_id NUMBER,
        operation VARCHAR2(10)
    );
    
    TYPE t_audit_tab IS TABLE OF t_audit_rec;
    g_audit_data t_audit_tab := t_audit_tab();
    
    g_restriction_reason VARCHAR2(200);

    BEFORE STATEMENT IS
    BEGIN
        g_restriction_reason := check_pms_operation_allowed();
        
        IF g_restriction_reason IS NOT NULL THEN
            INSERT INTO pms_audit_log (
                table_name, module_name, operation_type, record_id,
                db_user, status, error_message, restriction_reason
            ) VALUES (
                'PRISONERS', 'PRISONER_MGMT',
                CASE 
                    WHEN INSERTING THEN 'INSERT'
                    WHEN UPDATING THEN 'UPDATE'
                    WHEN DELETING THEN 'DELETE'
                END,
                NULL, USER, 'DENIED', 
                'Bulk operation: ' || g_restriction_reason, 
                g_restriction_reason
            );
            COMMIT;
            
            RAISE_APPLICATION_ERROR(-20903, 
                'BULK OPERATION BLOCKED: ' || g_restriction_reason);
        END IF;
        
        g_audit_data.delete;
    END BEFORE STATEMENT;
    
    BEFORE EACH ROW IS
    BEGIN
        g_audit_data.extend;
        g_audit_data(g_audit_data.count).record_id := 
            COALESCE(:NEW.prisoner_id, :OLD.prisoner_id);
            
        IF INSERTING THEN
            g_audit_data(g_audit_data.count).operation := 'INSERT';
        ELSIF UPDATING THEN
            g_audit_data(g_audit_data.count).operation := 'UPDATE';
        ELSE
            g_audit_data(g_audit_data.count).operation := 'DELETE';
        END IF;
    END BEFORE EACH ROW;
    
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1..g_audit_data.COUNT LOOP
            INSERT INTO pms_audit_log (
                table_name, module_name, operation_type, record_id,
                db_user, status
            ) VALUES (
                'PRISONERS', 'PRISONER_MGMT',
                g_audit_data(i).operation,
                g_audit_data(i).record_id,
                USER, 'SUCCESS'
            );
        END LOOP;
        COMMIT;
    END AFTER STATEMENT;
    
END trg_prisoners_compound;
/

-- Validation Queries
-- 1. Check trigger status
SELECT trigger_name, status, table_name 
FROM user_triggers 
WHERE table_name = 'PRISONERS';

-- 2. Check function status
SELECT object_name, status 
FROM user_objects 
WHERE object_name = 'CHECK_PMS_OPERATION_ALLOWED';

-- 3. Audit log summary
SELECT 
    status,
    COUNT(*) AS attempts,
    MIN(operation_date) AS first_attempt,
    MAX(operation_date) AS last_attempt
FROM pms_audit_log
GROUP BY status;

-- 4. Business rule validation
SELECT 
    'Weekday Restriction Active: ' ||
    CASE 
        WHEN check_pms_operation_allowed() LIKE 'WEEKDAY%' 
        THEN 'YES'
        ELSE 'NO'
    END AS validation
FROM DUAL;
