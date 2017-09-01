#!/usr/bin/perl
$tablename='';
$has_constraints=0;
print "SET sql_log_bin=0;\n";

while(<>) {
  s/ENGINE=ROCKSDB/ENGINE=InnoDB/;
  print $_;
}; 
