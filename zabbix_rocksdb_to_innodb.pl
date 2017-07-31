#!/usr/bin/perl
$tablename='';
$has_constraints=0;

while(<>) {
  s/ENGINE=ROCKSDB/ENGINE=InnoDB/;
  print $_;
}; 
