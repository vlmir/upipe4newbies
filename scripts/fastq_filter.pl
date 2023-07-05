#! /usr/bin/perl 
# Step3: inputs in data/paired/, outputs in data/paired/:
# Usage: fastq_filter.pl 1.0 > logs/fastq_filter.log 2>logs/fastq_filter.err

# assumptions: $prj_dir, $prj_dir/data, $prj_dir/data/paired exist
# ARGUMENTS:
# arg1 - 'fastq_maxee' parameter for 'usearch -fastq_filter', a numeric value for filtering (typically in the range 0.25-1.0)
# arg2 - path to your project_dir (with or without a trailing slash); optional if called from the project_dir
# USAGE: perl [path_to]assess_quality.pl arg1 [arg2]

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
$fastq_maxee,
$prj_dir, # optinal
) = @ARGV;
use Cwd;
$prj_dir ||= getcwd(); # full path no trailing slash, no \n
chomp $prj_dir;
chop $prj_dir if (substr ($prj_dir, -1, 1) eq '/');
my $data_dir = "$prj_dir/data";
my $in_dir = "$data_dir/paired";
map { croak "Directory '$_' does not exist !" unless ( -e $_ ) } $prj_dir, $data_dir, $in_dir;
my $out_dir = "$data_dir/paired";
my $log_dir = "$prj_dir/logs";
map { mkdir $_ unless ( -e $_ ); } $out_dir, $log_dir;
my $rex_bksl_tail = qr/\S*\/(\S+)/xmso;
my $prj_name = $prj_dir =~ $rex_bksl_tail ? $1 : $prj_dir;
my $rex_fa_head = qr/^>(.+)/xmso;
my @files = `ls $in_dir/*.fq`;
	foreach my $in_file ( @files ) {
	chomp $in_file;
	my $out_file = "$in_file";
	substr ( $out_file, -3 ) = "--$fastq_maxee.fasta"; # arguably a better way to replace a string at the end
	my $cmd = "usearch -fastq_filter $in_file -fastq_maxee $fastq_maxee -fastaout $out_file";
	print "cmd: $cmd\n";
	system ( $cmd );

## adding labels
# sed "-es/^>\(.*\)/>\1;barcodelabel=Nordgard-16s-A-MIXInfluentPB_S117;/" < Nordgard-16s-A-MIXInfluentPB_S117.fa > Nordgard-16s-A-MIXInfluentPB_S117.fal
	my @chunks = split /--/, $out_file;
	my $base = $chunks[0] =~ $rex_bksl_tail ? $1 : $chunks[0];
	my $buffer = '';
	open my $IN, '<', $out_file or croak "File: '$out_file' cannot be opened!";
	while ( <$IN> ) { 
		my $line = $_;
		chomp $line;
		if ( substr ( $line, 0, 1) eq '>' ) {
			$buffer .= "$line;barcodelabel=$base;\n";
		} else {
			$buffer .= $line."\n";
		}
# 		substr ( $line, 0, 1) eq '>' ? $buffer .= $line.$base."\n" : $buffer .= $line."\n"; # did not work
	}
	open my $OUT, '>', $out_file or croak "File: '$out_file' cannot be opened!";
	print $OUT $buffer;
	print "barcode labelled fasta headers in $out_file\n";
}

my $msg = "DONE $0 "; benchmark ( $start_time, $msg, 1 );
