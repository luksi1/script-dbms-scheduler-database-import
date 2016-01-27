# script-dbms-scheduler-database-import
Import an Oracle database over a database link

## Description
Import an Oracle database over a database link with Oracle's DBMS Scheduler.

## Use case
Instead of using cron (nothing against cron) you can keep your Oracle database logic inside Oracle. This helps abstract the database from the OS, which helps as many DBA's don't have access to the OS. Moreover, it saves space and time, but most importantly, my time! I can initiate the job and in a second and it's done. 

Frankly though, it seems a bit kludgy to run a script from cron to export something locally, scp it over to another place and then either run a remote command to import the dump or have another cronjob on the destination side handling it. This is, in my opinion, the superior way to move data regularly from one database to another.

## Author
Luke Simmons
