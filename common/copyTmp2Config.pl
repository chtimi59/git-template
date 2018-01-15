#!/bin/perl
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use SectionFile;
use Prompt;
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use Data::Dumper qw(Dumper);

# Input arguments
my ($fileSrc, $fileDst, $sectionKey) = @ARGV;

# source
my %source;
if (not defined $fileSrc) {
    print STDERR "Missing source file\n";
    exit 1;
}
if (-e "$fileSrc") {
    %source = SectionFile::read($fileSrc);
}

# destination
my %destination;
if (not defined $fileDst) {
    print STDERR "Missing destination file\n";
    exit 1;
}
if (-e "$fileDst") {
    %destination = SectionFile::read($fileDst);
}

# sectionKey
my $sectionName;
my $key;
if (not defined $sectionKey) {
    print STDERR "Missing section name\n";
    exit 1;
}
my @r = $sectionKey =~ m/^([^\.]+)\.*(.*)$/;
if (! @r) {
  print STDERR "Invalid Key: $sectionKey\n";
  exit 1; 
}
$sectionName = $r[0];
$key = $r[1];

# get keys
if ($key eq "") {
    if (exists $source{$sectionName}) {
        $destination{$sectionName} = $source{$sectionName};
    }
} else {
    if (exists $source{$sectionName}{$key}) {
        $destination{$sectionName}{$key} = $source{$sectionName}{$key};
    }
}

#print Dumper \%destination;
SectionFile::write($fileDst, %destination);