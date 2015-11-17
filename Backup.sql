/*****************************
 *   Lesson  - backup *
 * mysql01 - source
 * mysqlo2 - dest
 * 14.11.2015 - baruch@brillix.co.il created 
 ****************************/



/*
create database test on mysql01
*/
create database test;
use test;

CREATE TABLE t(c1 INT) engine=InnoDB;



DROP PROCEDURE IF EXISTS loop_test;


DELIMITER //
CREATE PROCEDURE loop_test()
BEGIN
  DECLARE int_val INT DEFAULT 0;
  test_loop : LOOP
    IF (int_val = 1000) THEN
      LEAVE test_loop;
    END IF;
    SET int_val = int_val +1;
    insert into test.t values(RAND());
  END LOOP;
END;//

DELIMITER ;


call test.loop_test;


/*
create backup via file syetem
*/
/*only code*/
mysqldump --sock=/u01/data/mysql01/mysql.sock  -u root -p  --routines --no-create-info --no-data --no-create-db --skip-opt --database test > test_code.sql
/*only DDL*/
mysqldump --sock=/u01/data/mysql01/mysql.sock  -u root -p --no-data  --database test  > test_ddl.sql
/*only data */
SHOW OPEN TABLES WHERE  In_use > 0;
mysqldump  --sock=/u01/data/mysql01/mysql.sock  -u root -p --no-create-db --set-gtid-purged=OFF --single-transaction --no-create-info --database test > test_dataonly.sql

/*restore on mysql02 */
mysql -u root -p oracle --port 3307 test < test_code.sql
mysql -u root -p oracle --port 3307 test < test_ddl.sql
mysql -u root -p oracle --port 3307 test < test_dataonly.sql

show create procedure loop_test\G
select count(*) from test.t;



/*
Or you can use create backup via percona
*/
--one database
innobackupex --socket=/u01/data/mysql01/mysql.sock --port=3306 --databases=world --user=root --password=oracle /u01/backup/
-- or all databases
innobackupex --socket=/u01/data/mysql01/mysql.sock  --user=root --password=oracle /backup/
--- roll logs for gape
innobackupex --socket=/u01/data/mysql01/mysql.sock --user=root --password=oracle --apply-log /backup/






/*MySQL Enterprise Backup */

/usr/bin/mysqlbackup --port=3306 --protocol=tcp --user=root --password=oracle --with-timestamp --backup-dir=/backup backup-and-apply-log




/* on mysql02 */
use test;
-- crate table for the .frm
CREATE TABLE t(c1 INT) engine=InnoDB;
--- delete tablespace
ALTER TABLE t DISCARD TABLESPACE;


/* on mysql01*/
use test;
FLUSH TABLES t FOR EXPORT;
-- copy the tabalespace
UNLOCK TABLES;

/* on mysql02*/
use test;
ALTER TABLE t IMPORT TABLESPACE;
