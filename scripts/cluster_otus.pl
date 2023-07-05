#! /usr/bin/perl 
# Step5: inputs in data/pooled/, outputs in data/final:
# Usage: cluster_otus.pl --1.0--2 3 > logs/cluster_otus.log 2>logs/cluster_otus.err

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
$otu_radius_pct,
$prj_dir,
) = @ARGV;
use Cwd;

$prj_dir ||= getcwd(); # full path no trailing slash, no \n
chomp $prj_dir;
chop $prj_dir if (substr ($prj_dir, -1, 1) eq '/');
my $data_dir = "$prj_dir/data";
my $in_dir = "$data_dir/pooled";
map { croak "Directory '$_' does not exist !" unless ( -e $_ ) } $prj_dir, $data_dir, $in_dir;
my $out_dir = "$data_dir/final";
my $log_dir = "$prj_dir/logs";
map { mkdir $_ unless ( -e $_ ); } $out_dir, $log_dir;
my $rex_bksl_tail = qr/\S*\/(\S+)/xmso;
my $prj_name = $prj_dir =~ $rex_bksl_tail ? $1 : $prj_dir;

my $in_file = "$in_dir/$prj_name$prev_step_prms.fas";
my $centroids_file = "$out_dir/$prj_name$prev_step_prms--$otu_radius_pct.fac";
# my $idscores_file = "$out_dir/$prj_name$prev_step_prms--$otu_radius_pct.uc";
my $idscores_file = "$out_dir/$prj_name$prev_step_prms--$otu_radius_pct.scores";
# usearch9: -sizein/out not supported
# userch10: -otu_radius_pct depricated; the default 3% used
my $cmd = "usearch -cluster_otus $in_file -otus $centroids_file -uparseout $idscores_file -relabel OTU_ ";
print "cmd: $cmd\n";
system ( $cmd );
print "Saved centroids in: $centroids_file and identity scores in: $idscores_file\n";

my $msg = "DONE $0 "; benchmark ( $start_time, $msg, 1 );
