#!/bin/bash
if [ "$1" = "" -o ! -f "$1" ]; then
  echo -ne "Usage\n  ./check_size.sh dump.gz\n"
  exit 1
fi

cp /etc/mysql/my.cnf /etc/mysql/my.cnf.check_size.backup
cp check_size.my.cnf /etc/mysql/my.cnf
/etc/init.d/mysql restart
mysqluser=`cat /etc/mysql/debian.cnf|grep '^user' | head -n 1| awk '{print $3;};'`
mysqlpassword=`cat /etc/mysql/debian.cnf|grep '^password' | head -n 1| awk '{print $3;};'`

report=check_size.report
echo "Purge binary logs:" | tee -a $report
echo "PURGE BINARY LOGS BEFORE now();" | mysql -u$mysqluser -p$mysqlpassword 2>&1 | tee -a $report
if [ "$DO_TEST_INNODB" = "1" ]; then
echo "Check size started" | tee -a $report
date | tee -a $report
echo "DROP:" | tee -a $report
echo "SET GLOBAL binlog_format=ROW;" | mysql -u$mysqluser -p$mysqlpassword 2>&1 | tee -a $report
echo "SHOW VARIABLES;" | mysql -u$mysqluser -p$mysqlpassword 2>&1 | tee -a $report
echo "drop database zabbix_test;" | mysql -u$mysqluser -p$mysqlpassword 2>&1 | tee -a $report
date | tee -a $report
echo "CREATE:" | tee -a $report
echo "create database zabbix_test;" | mysql -u$mysqluser -p$mysqlpassword 2>&1 | tee -a $report
echo "Disk usage of mysql:" | tee -a $report
du -hs /var/lib/mysql | tee -a $report
echo "Load data ($1) start (innodb):" | tee -a $report
date | tee -a $report
gzip -dc < $1 | ../zabbix_rocksdb_to_innodb.pl | dd 2>${report}.innodb.dd | mysql -u$mysqluser -p$mysqlpassword zabbix_test 2>&1 | tee -a $report &
sleep 5
while ps | grep dd; do
  sleep 600
  pid=`ps | grep dd | awk '{print $1;};'`
  kill -USR1 $pid
done

echo "Done" | tee -a $report
date | tee -a $report
echo "Disk usage of mysql:" | tee -a $report
du -hs /var/lib/mysql | tee -a $report
fi

echo "DROP:" | tee -a $report
echo "drop database zabbix_test;" | mysql -u$mysqluser -p$mysqlpassword 2>&1 | tee -a $report
date | tee -a $report
echo "CREATE:" | tee -a $report
echo "create database zabbix_test;" | mysql -u$mysqluser -p$mysqlpassword 2>&1 | tee -a $report
echo "SET GLOBAL binlog_format=ROW;" | mysql -u$mysqluser -p$mysqlpassword 2>&1 | tee -a $report
echo "Disk usage of mysql:" | tee -a $report
du -hs /var/lib/mysql | tee -a $report
echo "Load data ($1) start (rocksdb):" | tee -a $report
date | tee -a $report
gzip -dc < $1 | ../zabbix_innodb_to_rocksdb.pl | dd 2>${report}.rocks.dd | mysql -u$mysqluser -p$mysqlpassword zabbix_test 2>&1 | tee -a $report &
sleep 5
while ps | grep dd ; do
  sleep 600
  pid=`ps | grep dd | awk '{print $1;};'`
  kill -USR1 $pid
done
echo "Done" | tee -a $report
date | tee -a $report
echo "Disk usage of mysql:" | tee -a $report
du -hs /var/lib/mysql | tee -a $report


cp /etc/mysql/my.cnf.check_size.backup /etc/mysql/my.cnf
/etc/init.d/mysql restart

