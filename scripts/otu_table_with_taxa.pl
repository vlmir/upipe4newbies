#! /usr/bin/perl 
# Step8: optional, dependent on step 6
# Usage: otu_table_with_taxa.pl test--1.0--2--3--0.97.otu-tab test--1.0--0.80.utax > data/final/test--1.0--2--3--0.97.otutx-tab

BEGIN {
	push @INC, '/work/upipe/scripts';
	push @INC, '/home/mironov/git/upipe/scripts';
}
# print "STARTED $0\n"; my $start_time = time;
use Shared;

use Carp;
use strict;
use warnings;
#use Data::Dumper;

my (
$otu_tab,
$taxa,
$prj_dir,
) = @ARGV;
use Cwd;
$prj_dir ||= getcwd(); # full path no trailing slash, no \n
chomp $prj_dir;
chop $prj_dir if (substr ($prj_dir, -1, 1) eq '/');
my $data_dir = "$prj_dir/data";
my $in_dir = "$data_dir/final";
my $out_dir = "$data_dir/final";
map { croak "Directory '$_' does not exist !" unless ( -e $_ ) } $prj_dir, $data_dir, $in_dir, $out_dir; # $out_dir MUST be created at the previous step !!
my $log_dir = "$prj_dir/logs";
map { mkdir $_ unless ( -e $_ ); } $log_dir;
my $rex_bksl_tail = qr/\S*\/(\S+)/xmso;
my $prj_name = $prj_dir =~ $rex_bksl_tail ? $1 : $prj_dir;

my $otu2tax; # = extract_map ( "$in_dir/$taxa", 0, 1 ); # 
my $map_fh = open_read ( "$in_dir/$taxa" );

while ( <$map_fh> ) {
	my $line = $_;
	chomp $line;
	my @line = split /\t/, $line;
	my ($id, $size) = split /;/, $line[0];
	$otu2tax->{$id} = $line[1];
}#print Dumper($otu2tax);
close $map_fh;
my $ifh = open_read ( "$in_dir/$otu_tab" );

while ( <$ifh> ) {
	my $line = $_;
	chomp $line;
	my @line = split /\t/, $line;
	my $id = $line[0];
	my $tax = $otu2tax-> {$id};
# 	print "id: $id, tax: $otu2tax-> {$id}\n" if $otu2tax-> {$id};
$tax ? print "$line\t$tax\n" : print "$line\tTaxonomy\n";
}
