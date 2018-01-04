#!/bin/perl
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(abs_path $0) . '/lib';
use SectionFile;
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use Data::Dumper qw(Dumper);
#use Term::ReadLine;

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
        if (! exists $instanceData{$REPLACEMENT_SECTION}{$key}) {
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
        $prompt = "$prompt ($default)";
    }
    my $test='.+';
    if (exists $templateData{"$VARS_SECTION"}{$key.$VARS_TEST}) {
        $test = $templateData{"$VARS_SECTION"}{$key.$VARS_TEST};
    }
    my $ok = 0;
    my $value = "";
    while (! $ok) {
        $ok = 0;
        print "$prompt: ";
        $value = <STDIN>;
        chomp $value;
        if (($value eq "") && (defined $default)) {
            $value = $default;
        };
        if ($value =~ /$test/) {
            $ok = 1;
        } else {
            print STDERR "invalid input\n"; 
        };
    }
    $instanceData{$REPLACEMENT_SECTION}{$key} = $value;
}
#SectionFile::write($filename, %data);