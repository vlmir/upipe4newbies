package Shared;

use Carp;
use strict;
use warnings;
use Exporter;
#use Data::Dumper; # cannot be conditioned !
my $Verbose = 0;
$Carp::Verbose = 1 if $Verbose;

our @ISA = qw(Exporter);
our @EXPORT = qw(
$usearch
benchmark
__date
extract_map
open_read
open_write
);
print Dumper(\@EXPORT) if $Verbose;
#our $usearch = '~/git/upipe/bin/usearch9.2.64_i86linux64';
#our $usearch = 'usearch';

sub benchmark {
	my ( 
	$start_time, 
	$message, 
	$date, # boolean
	) = @_;
	my $elapsed_time = (time - $start_time)/60;
	$message = "$message in ";
	$date ? 
	print $message, sprintf("%.2f", $elapsed_time), " min ", __date(), "\n" : 
	print $message, sprintf("%.2f", $elapsed_time), " min\n";
}

sub __date {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	 # e.g. 2008:05:11 12:52
	my $result = sprintf "%4d:%02d:%02d %02d:%02d", $year+1900,$mon+1,$mday,$hour,$min;
}

sub extract_map {
	my ( 
	$in_file, 
	$key_ind, # indexing starts at '0'
	$val_ind # optional
	) = @_;
# 	open my $FH, '<', $in_file or croak "Cannot open file '$in_file': $!";
	my $FH = open_read ( $in_file );
	my %map;
	while (<$FH>) {
		next if substr ( $_, 0, 1) eq "\n";
		next if substr ( $_, 0, 1) eq "#";
		next if substr ( $_, 0, 1) eq "!";
		chomp;
		my ( @fields ) = split /\t/;
		my $key = $fields[$key_ind];
		next unless $key;
		if ( ! $val_ind ) {
			$map{$key}++; # counting the number of lines with $key
		}
		else {
			my $val = $fields[$val_ind];
			if ($map{$key}) {
				carp "Already exits: '$key-$map{$key}', ignored: '$key-$val'";
				next; # only the first occurence is retained
			}
			$map{$key} = $val if $val;
		}
	}
	close $FH;
	my @keys = keys %map;
	return \%map; # should be this way, no conditionals
}

sub open_read {
	my ($file) = @_;
	open my $FH, '<', $file or croak "File: $file cannot be opened!";
	return $FH;
}

sub open_write {
	my ( $file, $mode ) = @_;
	$mode ||= '>';
	my $FH;
	open $FH, $mode, $file; # TODO test it
	
# 	$mode eq '-a' ?
# 	open $FH, '>>', $file :
# 	open $FH, '>', $file;
	croak "File: $file cannot be opened!" unless $FH;
	return $FH;
}

1;
