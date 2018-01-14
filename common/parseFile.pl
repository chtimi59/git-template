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

my $MAGIC_REGEX = '\%\%([^\%]+)\%\%';
my $TRIM_REGEX = '^\s+|\s+$';
my $REPLACEMENT_SECTION = "replacement";
my $VARS_SECTION = "vars";
my $VARS_DEFAULT = ".DEFAULT";
my $VARS_PROMPT = ".PROMPT";
my $VARS_TEST = ".TEST";

# Config file
my %instanceData;
my $instanceConfigFilename = $ENV{'DEFINE_TEMPLATE_INSTANCE_CONFIG'};
if (! defined $instanceConfigFilename) {
    print STDERR "DEFINE_TEMPLATE_INSTANCE_CONFIG not set\n";
    exit 1;
}
if (! -e $instanceConfigFilename) {
    print STDERR "Config file '$instanceConfigFilename' not found\n";
    exit 1;
} else {
    %instanceData = SectionFile::read($instanceConfigFilename);
}

# Temporay Config file
my %temporayData;
my $temporayConfigFilename = $ENV{'DEFINE_TEMPLATE_TMP_CONFIG'};
if (! defined $temporayConfigFilename) {
    print STDERR "DEFINE_TEMPLATE_TMP_CONFIG not set\n";
    exit 1;
}
if (! -e $temporayConfigFilename) {
    print STDERR "Config file '$temporayConfigFilename' not found\n";
    exit 1;
} else {
    %temporayData = SectionFile::read($temporayConfigFilename);
}

# Template Config file
my %templateData;
my $templateConfigFilename = $ENV{'DEFINE_TEMPLATE_CONFIG'};
if (! defined $templateConfigFilename) {
    print STDERR "DEFINE_TEMPLATE_CONFIG not set\n";
    exit 1;
}
if (! -e $templateConfigFilename) {
    print STDERR "Config file '$templateConfigFilename' not found\n";
    exit 1;
} else {
    %templateData = SectionFile::read($templateConfigFilename);
}

# Input arguments
my ($inputFilename) = @ARGV;
if (not defined $inputFilename) {
    print STDERR "Missing input filename\n";
    exit 1;
}
if (! -e $inputFilename) {
    print STDERR "'$inputFilename' not found\n";
    exit 1;
}

# ---

sub getMissingRemplacementListFromFile {
    my($fileName) = (@_);
    my %foundkeysSet;
    open(my $fh, '<:encoding(UTF-8)', $fileName) 
        or die "Could not open '$fileName' $!";
    while ( my $line = <$fh> ) {
        my @keyReq = $line =~ m/$MAGIC_REGEX/;
        while (@keyReq) {
            $line =~ s/$MAGIC_REGEX//;
            my $key = $keyReq[0];
            $key =~ s/$TRIM_REGEX//g;
            $foundkeysSet{$key} = 1;
            @keyReq = $line =~ m/$MAGIC_REGEX/;
        }
    }
    my @out;
    foreach my $key (sort keys %foundkeysSet) {
        if (! exists $temporayData{$REPLACEMENT_SECTION}{$key}) {
            push @out, $key;
        }
    }
    return @out;
}

# Get list of missing definition
my @new = getMissingRemplacementListFromFile($inputFilename);
foreach my $key (@new) {
    my $prompt = $key;
    if (exists $templateData{"$VARS_SECTION"}{$key.$VARS_PROMPT}) {
        $prompt = $templateData{"$VARS_SECTION"}{$key.$VARS_PROMPT};
    }
    my $default;
    if (exists $templateData{"$VARS_SECTION"}{$key.$VARS_DEFAULT}) {
        $default = $templateData{"$VARS_SECTION"}{$key.$VARS_DEFAULT};
    }
    if (exists $temporayData{"$REPLACEMENT_SECTION"}{$key}) {
        $default = $temporayData{"$REPLACEMENT_SECTION"}{$key};
    }
    my $test='.+';
    if (exists $templateData{"$VARS_SECTION"}{$key.$VARS_TEST}) {
        $test = $templateData{"$VARS_SECTION"}{$key.$VARS_TEST};
    }
    my $value = Prompt::promptLine($prompt,$default,$test);
	print "$value\n";
    $temporayData{$REPLACEMENT_SECTION}{$key} = $value;
}
SectionFile::write($temporayConfigFilename, %temporayData);