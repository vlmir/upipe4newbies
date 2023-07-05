#! /usr/bin/perl
# Step1: inputs in reads/, outputs in data/paired/:
# Usage: fastq_mergepairs.pl 20 20 50 25 > logs/fastq_mergepairs.log 2>logs/fastq_mergepairs.err

# assumptions: $prj_dir, $prj_dir/data, $prj_dir/data/reads exit
# ARGUMENTS:
# arg1 - path to your project_dir (with or without a trailing slash); optional if called from the project_dir
# USAGE: perl [path_to]merge_pairs.pl [arg1]

BEGIN {
	push @INC, '/work/upipe/scripts';
	push @INC, '/home/mironov/git/upipe/scripts';
}
print "STARTED $0\n"; my $start_time = time;
use Shared;

use Carp;
use strict;
use warnings;
# use auxmod::SharedVars qw ( # other vars are well exported
# $rex_bksl
# );
my (
$fwd_prm_lng,
$rev_prm_lng,
$minmergelen,
$maxdiff, # max number of mismatches
$prj_dir, # full path, no trailing slash
) = @ARGV;
# $fwd_prm_lng ||= 0;
# $rev_prm_lng ||= 0;
use Cwd;
$prj_dir ||= getcwd(); print "prj_dir: $prj_dir\n"; # full path no trailing slash, no \n
chomp $prj_dir;
chop $prj_dir if (substr ($prj_dir, -1, 1) eq '/');
my $data_dir = "$prj_dir/data";
my $in_dir = "$prj_dir/reads";
map { croak "Directory '$_' does not exist !" unless ( -e $_ ) } $data_dir, $in_dir, $prj_dir;
my $out_dir = "$data_dir/paired";
my $log_dir = "$prj_dir/logs";
map { mkdir $_ unless ( -e $_ ); } $out_dir, $log_dir;
my $rex_bksl_tail = qr/\S*\/(\S+)/xmso;
# my $rex_bksl_tail = $rex_bksl; # TODO fix it
my $rex_base = qr/(.+)_L001_.+/xmso;
my $prj_name = $prj_dir =~ $rex_bksl_tail ? $1 : $prj_dir;

my @fwd_files = `ls $in_dir/*_R1_*`;
my @rev_files = `ls $in_dir/*_R2_*`;
# chomp @fwd_files, @rev_files;
my $last_index = @fwd_files == @rev_files ? $#fwd_files : croak "Unballanced forward and reverse reads in '$in_dir'";
foreach ( 0..$last_index ) {
	my $fwd_file = $1 if $fwd_files[$_] =~ $rex_bksl_tail;
	my $rev_file = $1 if $rev_files[$_] =~ $rex_bksl_tail;
	my $f_base = $1 if $fwd_file =~ $rex_base;
	my $r_base = $1 if $rev_file =~ $rex_base;
# 	croak "Unballanced file names: '$f_base'-'$r_base'" unless $f_base eq $r_base;
	my $base = $f_base eq $r_base ? $f_base : croak "Unballanced file names: '$f_base'-'$r_base'";
	my $out_file = "$out_dir/$base.fq";
# 	my $cmd = "usearch -fastq_mergepairs $in_dir/$fwd_file -reverse $in_dir/$rev_file -fastqout $out_file > $log_dir/fastq_mergepairs.log 2>$log_dir/fastq_mergepairs.err";
	#y $cmd = "usearch -fastq_mergepairs $in_dir/$fwd_file -reverse $in_dir/$rev_file -fastqout $out_file -report $out_dir/merge_pairs.report -fastq_minmergelen $minmergelen";
	## deleted -reverse - constructed by usearch 2017-05-28
	my $cmd = "usearch -fastq_mergepairs $in_dir/$fwd_file -fastqout $out_file -report $out_dir/merge_pairs.report -fastq_minmergelen $minmergelen, -fastq_maxdiffs $maxdiff";
	print "cmd: $cmd\n";
	system ( $cmd );
	
	## stripping the primers
	open my $FH, '<', $out_file or croak "File: cannot be opened!";
	my $buffer = '';
	my $count = 0;
	while ( <$FH> ) {
		$count ++;
		my $line = $_;
		my $first_char = substr ( $line, 0, 1 );
		if ( $count == 1 ) { $buffer .= $line; next; } 
		if ( $count == 3 ) { $buffer .= $line; next; }
		 
		my $offset = $fwd_prm_lng;
		$line = substr ( $line, $offset );
		$offset = 0 - $rev_prm_lng - 1;
		my $length = $rev_prm_lng + 1;
		substr ( $line,  $offset, $length, "\n" );
		$buffer .= $line;
		$count = 0 if $count == 4;
	}
	close $FH;
	open $FH, '>', $out_file;
	print $FH $buffer;
	close $FH;
	
}

my $msg = "DONE $0 "; benchmark ( $start_time, $msg, 1 );
