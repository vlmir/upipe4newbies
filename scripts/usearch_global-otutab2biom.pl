#! /usr/bin/perl 
# Step6: inputs in data/final, outputs in data/final:
# Usage: usearch_global-otutab2biom.pl --1.0--2--3 0.97 ../mytaxref > logs/usearch_global-otutab2biom.log 2>logs/usearch_global-otutab2biom.err

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
$id,
$conf_level,
$prj_dir,
) = @ARGV;
use Cwd;
$prj_dir ||= getcwd(); # full path no trailing slash, no \n
chomp $prj_dir;
chop $prj_dir if (substr ($prj_dir, -1, 1) eq '/');
my $data_dir = "$prj_dir/data";
my $in_dir = "$data_dir/pooled";
my $out_dir = "$data_dir/final";
map { croak "Directory '$_' does not exist !" unless ( -e $_ ) } $prj_dir, $data_dir, $in_dir, $out_dir; # $out_dir MUST be created at the previous step !!
my $log_dir = "$prj_dir/logs";
map { mkdir $_ unless ( -e $_ ); } $log_dir;
my $rex_bksl_tail = qr/\S*\/(\S+)/xmso;
my $prj_name = $prj_dir =~ $rex_bksl_tail ? $1 : $prj_dir;

my ( $q_file, $db_file, $cmd, $out_file, $biom_file );
my @prms = split /--/, $prev_step_prms;

### step 1
$q_file = "$in_dir/$prj_name--$prms[1].fa"; # swapped these two files according to the manual
$db_file = "$out_dir/$prj_name$prev_step_prms.fac"; # swapped these two files according to the manual
$out_file = "$out_dir/$prj_name$prev_step_prms--$id.otu-tab"; # terminal file
$biom_file = "$out_dir/$prj_name$prev_step_prms--$id.biom"; # terminal file
# $cmd = "usearch -usearch_global $q_file -db $db_file -strand plus -id $id -uc $out_file"; # as used before
$cmd = "usearch -usearch_global $q_file -db $db_file -strand plus -id $id -otutabout $out_file -biomout $biom_file ";
print "cmd: $cmd\n";
system ( $cmd );
print "Query: $q_file against db: $db_file produced result saved in: $out_file\n";

### step 2
#my $in_file = $out_file;
#$out_file = "$out_dir/$prj_name$prev_step_prms--$id.2biom";
#$cmd = "usearch -otutab2biom $in_file -output $out_file";
#system ( $cmd );
#print "Converted: $in_file into: $out_file";

###############################################################################
my $msg = "DONE $0 "; benchmark ( $start_time, $msg, 1 );
