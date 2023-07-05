#! /usr/bin/perl 
# Step4: inputs in data/paired/, outputs in data/pooled/: 
# Usage: derep_fulllength-sortbysize.pl --1.0 2 > logs/derep_fulllength-sortbysize.log 2>logs/derep_fulllength-sortbysize.err

# assumptions: $prj_dir, $prj_dir/data, $prj_dir/data/paired exist
# ARGUMENTS:
# arg1 - path to your project_dir (with or without a trailing slash); optional if called from data/
# USAGE: perl [path_to]assess_quality.pl [arg1]

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
$prev_step_prms,
$minsize,
$prj_dir,
) = @ARGV;
use Cwd;
$prj_dir ||= getcwd(); # full path no trailing slash, no \n
chomp $prj_dir;
chop $prj_dir if (substr ($prj_dir, -1, 1) eq '/');
my $data_dir = "$prj_dir/data";
my $in_dir = "$data_dir/paired";
map { croak "Directory '$_' does not exist !" unless ( -e $_ ) } $prj_dir, $data_dir, $in_dir;
my $out_dir = "$data_dir/pooled";
my $log_dir = "$prj_dir/logs";
map { mkdir $_ unless ( -e $_ ); } $out_dir, $log_dir;
my $rex_bksl_tail = qr/\S*\/(\S+)/xmso;
my $prj_name = $prj_dir =~ $rex_bksl_tail ? $1 : $prj_dir;

my $pooled_file = "$out_dir/$prj_name$prev_step_prms.fa";
my $cmd = "cat $in_dir/*$prev_step_prms.fasta > $pooled_file";
print "cmd: $cmd\n";
system ( $cmd );
print "Pooled file saved to: $pooled_file\n";

my $derep_file =  $pooled_file.'d';
$cmd = "usearch -derep_fulllength $pooled_file -fastaout $derep_file -sizeout";
print "cmd: $cmd\n";
system ( $cmd );
print "Dereplicated file saved to: $derep_file\n";

my $sort_file = "$out_dir/$prj_name$prev_step_prms--$minsize.fas";
$cmd = "usearch -sortbysize $derep_file -fastaout $sort_file -minsize $minsize";
print "cmd: $cmd\n";
system ( $cmd );
print "Sorted file saved to: $sort_file\n";

my $msg = "DONE $0 "; benchmark ( $start_time, $msg, 1 );
