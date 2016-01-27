/*
Author: Luke Simmons (VGR IT)
Date: 2015-09-30
Description: Import a database schema via a database link. This script will create your user, database link and entry for the scheduler
*/

/* Create the appropriate users on each side of the database. That means you will need to create the same user on the remote end! */
create directory backup as '&&backup_directory';
create user &&username identified by &&password;
grant create session, connect, resource,create table to &&username;
grant read, write on directory backup to &&username;
grant EXP_FULL_DATABASE to &&username;
grant IMP_FULL_DATABASE to &&username;
grant SCHEDULER_ADMIN TO &&username;
alter user &&username quota unlimited on users;

create directory backup as '&&backup_directory';

conn &&username/&&password

create database link &&database_link connect to &&username identified by &&password using '&&remote_sid';

/* Create your stored procedure */
CREATE OR REPLACE PROCEDURE RESERVE_ROUTINE (
        v_database_link in varchar2,
        v_schema in varchar2)
  IS
        v_handle number;
        v_job_state varchar(4000);
        v_row PLS_INTEGER;
        v_logs ku$_LogEntry;
        l_sts KU$_STATUS;

BEGIN
        v_handle := DBMS_DATAPUMP.OPEN(
                operation => 'IMPORT',
                job_name => 'RESERVE_ROUTINE_IMPORT',
                job_mode => 'SCHEMA',
                remote_link => v_database_link,
                version => 'LATEST');

	/* Replace existing schema if any */
        DBMS_DATAPUMP.SET_PARAMETER(v_handle, 'TABLE_EXISTS_ACTION', 'TRUNCATE');

	/* Import only a schema */
        DBMS_DATAPUMP.METADATA_FILTER(
                v_handle,
                'SCHEMA_LIST',
                ''''||upper(v_schema)||'''');

	/* Exclude a table */
	/* Uncomment this if you need to exclude a particular table. */
	/*
	DBMS_DATAPUMP.METADATA_FILTER(
		handle => v_handle,
		name => 'NAME_EXPR',
		value => '!= ''DONOR_FINGERPRINT''',
		object_type => 'TABLE'

	);
	*/

        DBMS_DATAPUMP.START_JOB(v_handle);
        DBMS_DATAPUMP.WAIT_FOR_JOB(v_handle,v_job_state);
        DBMS_OUTPUT.PUT_LINE(v_job_state);

EXCEPTION
        WHEN OTHERS THEN
                dbms_datapump.get_status(NULL, 8, 0, v_job_state, l_sts);
                v_logs := l_sts.error;
                v_row := v_logs.FIRST;
        LOOP
        EXIT WHEN v_row IS NULL;
        dbms_output.put_line('logLineNumber=' || v_logs(v_row).logLineNumber);
        dbms_output.put_line('errorNumber=' || v_logs(v_row).errorNumber);
        dbms_output.put_line('LogText=' || v_logs(v_row).LogText);
        v_row := v_logs.NEXT(v_row);
        END LOOP;
RAISE;

END;
/

BEGIN
DBMS_SCHEDULER.create_job(
        job_name => 'RESERVE_ROUTINE_JOB',
        job_type => 'PLSQL_BLOCK',
        job_action => 'BEGIN RESERVE_ROUTINE(''&&database_link'', ''&&schema_to_import''); END;',
        auto_drop => FALSE,
        repeat_interval => 'FREQ=DAILY',
        start_date => '01-OCT-15 01:00:00 AM',
        enabled => TRUE
);

END;
/
