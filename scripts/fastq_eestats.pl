#! /usr/bin/perl 
# Step2: inputs in data/paired/, outputs in data/pooled/:
# Usage: fastq_eestats.pl > logs/fastq_eestats.log 2>logs/fastq_eestats.err

# assumptions: $prj_dir, $prj_dir/data, $prj_dir/data/paired exist
# ARGUMENTS:
# aconst rg1 - path to your project_dir (with or without a trailing slash); optional if called from data/
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

my $pooled_file = "$out_dir/$prj_name.fq"; # used only for computing statistics
print "Writing to: $pooled_file\n";
my $cmd = "cat $in_dir/*.fq > $pooled_file";
system ( $cmd );
## computing Q (Phred) statistics
# $cmd = "usearch -fastq_stats $pooled_file -log $out_dir/fastq_stats.out";
# print "cmd: $cmd\n";
# system ( $cmd );
## computing expected error statistics
# $cmd = "usearch -fastq_eestats $pooled_file -output $log_dir/fastq_eestats.out > $log_dir/fastq_eestats.log 2>$log_dir/fastq_eestats.err";
$cmd = "usearch -fastq_eestats $pooled_file -output $out_dir/fastq_eestats.out";
print "cmd: $cmd\n";
system ( $cmd );

my $msg = "DONE $0 "; benchmark ( $start_time, $msg, 1 );
