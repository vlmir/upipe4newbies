#! /usr/bin/perl 
# Step7: inputs in data/final, outputs in data/final:
# Usage: makeudb_utax-utax.pl --1.0--2--3 0.80 ../taxref > logs/makeudb_utax-utax.log 2>logs/makeudb_utax-utax.err
# depricated in usearch10?


BEGIN {
	push @INC, '/work/upipe/scripts';
	push @INC, '/home/mironov/git/upipe/scripts';
}
print "STARTED $0\n"; my $start_time = time;
use Shared;

use Carp;
use strict;
use warnings;
my (
$prev_step_prms, # from cluster_otus
$conf_level,
$txn_dir,
$prj_dir,
) = @ARGV;
use Cwd;
$prj_dir ||= getcwd(); # full path no trailing slash, no \n
chomp $prj_dir;
chop $prj_dir if (substr ($prj_dir, -1, 1) eq '/');
my $data_dir = "$prj_dir/data";
my $out_dir = "$data_dir/final";
map { croak "Directory '$_' does not exist !" unless ( -e $_ ) } $prj_dir, $data_dir, $txn_dir, $out_dir; # $out_dir MUST be created at the previous step !!
my $log_dir = "$prj_dir/logs";
map { mkdir $_ unless ( -e $_ ); } $log_dir;
my $rex_bksl_tail = qr/\S*\/(\S+)/xmso;
my $prj_name = $prj_dir =~ $rex_bksl_tail ? $1 : $prj_dir;

my ( $q_file, $db_file, $cmd, $out_file );
my @prms = split /--/, $prev_step_prms;


### step 1
my $taxconfs_file = "$txn_dir/rdp_16s_trainset15/taxconfs/full_length.tc";
$db_file = "$txn_dir/rdp_16s_trainset15/fasta/refdb.fa";
my $db_path = "$txn_dir/utax.udb"; # used only in the next step
$cmd = "usearch -makeudb_utax $db_file -output $db_path -taxconfsin $taxconfs_file";
system ( $cmd );

### step 2
$q_file = "$out_dir/$prj_name$prev_step_prms.fac"; # sic!
$out_file = "$out_dir/$prj_name--$prms[1]--$conf_level.utax"; # terminal file
$cmd = "usearch -utax $q_file -db $db_path -utaxout $out_file -strand both -utax_cutoff $conf_level";
print "cmd: $cmd\n";
system ( $cmd );
print "Query: $q_file against db: $db_file produced result saved in: $out_file\n";

###############################################################################
my $msg = "DONE $0 "; benchmark ( $start_time, $msg, 1 );
