# script-dbms-scheduler-database-import
Import an Oracle database over a database link

## Description
Import an Oracle database over a database link with Oracle's DBMS Scheduler.

## Use case
We received a request to export a database several times a day and import it into a seperate offsite location.

Instead of using cron (nothing against cron) you should keep your Oracle database logic inside Oracle. This helps abstract the database from the OS, which helps as many DBA's don't have access to the OS. 

Moreover, performing an import/export via DBMS scheduler and database links reduces time and space. 

Frankly though, it is kludgy to run a script from cron to export something locally, scp it over to another place and then either run a remote command to import the dump or have another cronjob on the destination side handling it. This is, in my opinion, the superior way to move data regularly from one database to another.

## Using
Make sure you have a connection between the servers you will be using for the export and the import. The requires an entry in tnsnames.ora. Be sure you can ping both nodes:
```
$ tnsping <insert into your tnsnames.ora entry here>
```

Create the appropriate users on each node that will be involved, regardless of whether they will be performing the export or import. This needs to be the same user and have the same permission. This script should help you accomplish this goal. "&&" is simply an sqlplus variable you can use to insert the appropriate information.

```
sqlplus "/as sysdba" @create.user.db.link.sql
```

Then, you'll need to create the database link, create the job and schedule it. This would be done on the destination node. You'll simply be pulling the data via a impdp.

THE JOB HERE WILL TRUNCATE THE EXISTING SCHEMA YOU HAVE IN YOUR DESTINATION NODE!!

```
sqlplus "/as sysdba" @create.import.job.sql
```

To run your job immediately:
```
$ sqlplus "/as sysdba" @run.job.sql
```
or simply connect to sqlplus as your backup user:
```
sqlplus> EXEC DBMS_SCHEDULER.RUN_JOB('<insert name of job here'>);
```

To run drop your job (you will need to drop your job in case the your import job fails):
```
$ sqlplus "/as sysdba" @drop.job.sql
```
or simply connect to sqlplus as your backup user:
```
sqlplus> EXEC DBMS_SCHEDULER.DROP_JOB('<insert name of job here'>);
```
## Author
Luke Simmons
