# zabbix-rocksdb-migration
Set of scripts to automate migration between InnoDB and RocksDB storage engines for zabbix

## Scripts:

install.sh - builds and installs mariadb-10.2 with all dependencieas.

install_zabbix.sh - builds and installs zabbix with all dependencies. Downloads snmp_builder and unpacks it correctly, 
but does not patch .php to add a menu entry.

zabbix_innodb_to_rocksdb.pl - reads raw sql dump of existing tables with InnoDB engine and produces sql dump with ROCKSDB with
necessary changes in schemas (only on tables without foreign key constraints).

zabbix_rocksdb_to_innodb.pl - (partial) reverse operation to zabbix_innodb_to_rocksdb.pl - changes engine WITHOUT changing 
collations.
