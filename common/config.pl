#!/bin/perl
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use SectionFile;
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);

# Options
my $optList;
my $optUnset;
GetOptions(
    'list|l' => \$optList,
    'unset|u' => \$optUnset,
) or exit 1;

# Config file
my $DEFINE_TEMPLATE_INSTANCE_CONFIG = $ENV{'DEFINE_TEMPLATE_INSTANCE_CONFIG'};
if (! defined $DEFINE_TEMPLATE_INSTANCE_CONFIG) {
    print STDERR "DEFINE_TEMPLATE_INSTANCE_CONFIG not set\n";
    exit 1;
}
if (! -e $DEFINE_TEMPLATE_INSTANCE_CONFIG) {
    print STDERR "Config file '$DEFINE_TEMPLATE_INSTANCE_CONFIG' not found\n";
    exit 1;
}

# Dump config hash table
my %data = SectionFile::read($DEFINE_TEMPLATE_INSTANCE_CONFIG);

# User just ask for the list ?
if ($optList) {
    foreach my $sectionName (sort keys %data) {
        foreach my $key (sort keys %{ $data{$sectionName} }) {
            my $value = $data{$sectionName}{$key};
            print STDOUT "$sectionName.$key=$value\n";
        }
    }
    exit 0;
}

# Input arguments
my ($input, $value) = @ARGV;
if (not defined $input) {
  print STDERR "Missing Key\n";
  exit 1; 
}

# Check if <sectionName>.<Key> is correct
my @r = $input =~ m/^([^\.]+)\.(.+)$/;
if (! @r) {
  print STDERR "Invalid Key: $input\n";
  exit 1; 
}
my $sectionName = $r[0];
my $key = $r[1];

if ($optUnset) {
    delete $data{$sectionName}{$key};
    SectionFile::write($DEFINE_TEMPLATE_INSTANCE_CONFIG, %data);
    exit 0;
}

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
    SectionFile::write($DEFINE_TEMPLATE_INSTANCE_CONFIG, %data);
}