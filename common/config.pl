#!/bin/perl
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use SectionFile;

# Config file
my $filename = $ENV{'DEFINE_TEMPLATE_CONFIG'};
if (! -e $filename) {
    print STDERR "Config file '$filename' not found\n";
    exit 1;
}

# Dump config hash table
my %data = SectionFile::read($filename);

# Arguments
my ($input, $value) = @ARGV;
if (not defined $input) {
  print STDERR "Missing Key\n";
  exit 1; 
}

# Just the list ?
if ($input eq "list") {
    foreach my $sectionName (sort keys %data) {
        foreach my $key (sort keys %{ $data{$sectionName} }) {
            my $value = $data{$sectionName}{$key};
            print STDOUT "$sectionName.$key=$value\n";
        }
    }
    exit 0;
}

# Check if <sectionName>.<Key> is correct
my @r = $input =~ m/^([^\.]+)\.(.+)$/;
if (! @r) {
  print STDERR "Invalid Key: $input\n";
  exit 1; 
}
my $sectionName = $r[0];
my $key = $r[1];

# Only Reading key ?
if (not defined $value) {
    if (! exists $data{$sectionName}{$key}) {
        exit 0;
    }
    print STDOUT "$data{$sectionName}{$key}\n";
    exit 0;
} else {
    # Write Key then
    $data{$sectionName}{$key} = $value;
    SectionFile::write($filename, %data);
}