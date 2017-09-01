#!/usr/bin/perl
$tablename='';
$has_constraints=0;
print "SET sql_log_bin=0;\n";
while(<>) {
  s/CHARACTER SET latin1//;
  if(/CREATE TABLE `(.*)`/) {
    $tablename=$1;
    $has_constraints=0;
  };
  if(/CONSTRAINT/) {
    $has_constraints=1;
  };
  if(/ENGINE=InnoDB/ and $has_constraints==0) {
     s/ENGINE=InnoDB/ENGINE=ROCKSDB/;
     s/CHARSET=([^ ^;]+)/CHARSET=$1 COLLATE=$1_bin/;
  };
  s/^LOCK TABLES.*//;
  s/^UNLOCK TABLES.*//; 
  print $_;
}; 
