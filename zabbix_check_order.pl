#!/usr/bin/perl
$tablename='';
$has_constraints=0;
$create_statement=0;
@fields=();
print "SET sql_log_bin=0;\n";
while(<>) {
  s/CHARACTER SET latin1//;
  if(/CREATE TABLE `(.*)`/) {
    $tablename=$1;
    $has_constraints=0;
    $has_primary_key='';
    $create_statement=1;
    @fields=();
  };
  if(/CONSTRAINT/) {
    $has_constraints=1;
  };
  if(/PRIMARY KEY \(`(\S+)`\),/) {
    $has_primary_key=$1;
  };

  if(/ENGINE=InnoDB/ and $has_constraints==0) {
     s/ENGINE=InnoDB/ENGINE=ROCKSDB/;
     s/CHARSET=([^ ^;]+)/CHARSET=$1 COLLATE=$1_bin/;
     $create_statement=0;
  };
  if($create_statement == 1) {
     if(/^  `([^`]+)`/) {
        push @fields,$1;
     };
  };
  if(/^INSERT/ and $has_constraints==0) {
     $prikey_pos=-1;
     for($i=0;$i<=$#fields;$i++ ){
       if($fields[$i] eq $has_primary_key) {
          $prikey_pos=$i;
       };
     };
## See http://perldoc.perl.org/perlfaq6.html#Can-I-use-Perl-regular-expressions-to-match-balanced-text%3f
     @inserts= $_=~m/(\((?:[^()]++|(?1))*\))/xg;
     $prev_key=undef;
     $order=undef;
     foreach my $insert (@inserts) {
        @values = $insert=~m/(\d+|'(?:[^']|\\')+')/;
        if(defined($prev_key)) {
          if(defined($order)) {
            if($order== 1) {
              if($values[$prikey_pos] < $prev_key) {
                print STDERR "Error on table $tablename\n primary key=$has_primary_key v=".$values[$prikey_pos]."<$prev_key";
                exit(1);
              };
            } else {
              if($values[$prikey_pos] > $prev_key) {
                print STDERR "Error on table $tablename\n primary key=$has_primary_key v=".$values[$prikey_pos].">$prev_key";
                exit(1);
              };
            };
          } else {
            if($values[$prikey_pos] > $prev_key) { $order = 1; };
            if($values[$prikey_pos] < $prev_key) { $order = -1; };
          };
        };
     };
  };


  s/^LOCK TABLES.*//;
  s/^UNLOCK TABLES.*//; 

  print $_;
}; 
