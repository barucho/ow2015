/*****************************
 *   Lesson  - Replication *
 * mysql01 - master
 * mysql02 - slave
 * 14.11.2015 - baruch@brillix.co.il created
 ****************************/
/* on mysql01 */

 -- Add to  my.cnf
server-id               = 1
log-bin                 = /u01/data/mysql01/mysql-bin
relay-log-recovery=1
master-info-repository=TABLE
relay-log-info-repository=TABLE
gtid-mode=ON
enforce-gtid-consistency

 # !!! do not use binlog-do-db option use #replicate_do_db=test!!!!

/*create replication user*/

 grant replication slave on *.* TO repuser@192.168.56.200 identified by 'oracle';
 flush privileges;


/*
create backup via file syetem
*/
/*only code*/
mysqldump --sock=/u01/data/mysql01/mysql.sock  -u root -p  --routines --no-create-info --no-data --no-create-db --skip-opt --database test > test_code.sql
/*only DDL*/
mysqldump --sock=/u01/data/mysql01/mysql.sock  -u root -p --no-data  --database test  > test_ddl.sql
/*only data */
SHOW OPEN TABLES WHERE  In_use > 0;
mysqldump  --sock=/u01/data/mysql01/mysql.sock  -u root -p --no-create-db --single-transaction --no-create-info --database test > test_dataonly.sql

/*
Or you can use create backup via percona
*/
--one database
innobackupex --socket=/u01/data/mysql01/mysql.sock --port=3306 --databases=world --user=root --password=oracle /u01/backup/
-- or all databases
innobackupex --socket=/u01/data/mysql01/mysql.sock  --user=root --password=oracle /backup/
--- roll logs for gape
innobackupex --socket=/u01/data/mysql01/mysql.sock --user=root --password=oracle --apply-log /backup/



--- shutdown the slave
 mysqladmin shutdown -u root -p -P 3307 --socket=/data/mysql02/mysql.sock



-- after backup copy to slave server
cp -rpf /u01/backup/  /u01/data/mysql02/
--- fix premitions
chown -R mysql.mysql /u01/data/mysql02


-- fix  auto.cnf file to diffrent UUID !!
-- you can select uuid() from diffrent server to gen new UUDI
[auto]
server_uuid=8a94f357-aab4-11df-86ab-c80aa9429562

/*On mysql01*/
show master status

/*on slave mysql02*/
-- Add to my.cnf
server-id               = 2
log-bin                  = /u01/data/mysql02/mysql-bin relay-log-recovery=1
master-info-repository=TABLE
relay-log-info-repository=TABLE
gtid-mode=ON
enforce-gtid-consistency
#if you need to replicate only one database  !!! do not use binlog-do-db option!!!!
replicate_do_db=test


--- start mysql02
/* on mysql02 */
reset slave;
-- use MASTER_AUTO_POSITION = 1 for GTID-based replication protocol.
CHANGE MASTER TO MASTER_PORT=3306,MASTER_HOST='192.168.56.200',MASTER_USER='repuser', MASTER_PASSWORD='oracle',MASTER_AUTO_POSITION = 1;
start slave;

/*on mysql01*/
SELECT @@server_uuid;
show MASTER status

/*on mysql02*/
SHOW SLAVE HOSTS
show slave stauts\G

---Tets
begin; insert into t values(1); commit;

show slave stauts\G

/*mysql-utils */
mysqlrplcheck --slave=root:oracle@localhost:3307 --master=root:oracle@localhost:3306
mysqlrpladmin --master=root:oracle@localhost:3306 --slave=root:oracle@localhost:3307 health
mysqlrplshow --master=root:oracle@localhost:3307 --discover-slaves-login=root;
mysqlrplshow --master=root:oracle@localhost:3306 --discover-slaves-login=root

/*create repli via util */
mysqlreplicate --slave=root:oracle@localhost:3307 --master=root:oracle@localhost:3306 --rpl-user=repuser:oracle
mysqlrpladmin --master=root:oracle@localhost:3306 --new-master=root:oracle@localhost:3307 --demote-master --discover-slaves-login=root switchover
