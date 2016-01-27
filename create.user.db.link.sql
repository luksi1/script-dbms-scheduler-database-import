/*
Create a backup user and give the appropriate permissions.
*/
create user &&username identified by &&password;
grant create session, connect, resource, create table to &&username;
grant read, write on directory backup to &&username;
grant EXP_FULL_DATABASE to &&username;
grant IMP_FULL_DATABASE to &&username;
grant SCHEDULER_ADMIN TO &&username;
alter user &&username quota unlimited on users;
create directory backup as '&&backup_directory';
