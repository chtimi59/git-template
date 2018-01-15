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

# Options
my $optContent;
GetOptions(
    'content|c' => \$optContent,
) or exit 1;

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

# --

my $MAGIC_REGEX = '\%\%([^\%]+)\%\%';
my $TRIM_REGEX = '^\s+|\s+$';
my $REPLACEMENT_SECTION = "replacement";
my $VARS_SECTION = "vars";
my $VARS_DEFAULT = ".DEFAULT";
my $VARS_PROMPT = ".PROMPT";
my $VARS_TEST = ".TEST";
my $DEFINE_TEMPLATE_INSTANCE_CONFIG = $ENV{'DEFINE_TEMPLATE_INSTANCE_CONFIG'};
if (! defined $DEFINE_TEMPLATE_INSTANCE_CONFIG) {
    print STDERR "DEFINE_TEMPLATE_INSTANCE_CONFIG not set\n";
    exit 1;
}
my $DEFINE_TEMPLATE_TMP_CONFIG = $ENV{'DEFINE_TEMPLATE_TMP_CONFIG'};
if (! defined $DEFINE_TEMPLATE_TMP_CONFIG) {
    print STDERR "DEFINE_TEMPLATE_TMP_CONFIG not set\n";
    exit 1;
}
my $DEFINE_TEMPLATE_CONFIG = $ENV{'DEFINE_TEMPLATE_CONFIG'};
if (! defined $DEFINE_TEMPLATE_CONFIG) {
    print STDERR "DEFINE_TEMPLATE_CONFIG not set\n";
    exit 1;
}

# Config file
my %instanceData;
if (! -e $DEFINE_TEMPLATE_INSTANCE_CONFIG) {
    print STDERR "Config file '$DEFINE_TEMPLATE_INSTANCE_CONFIG' not found\n";
    exit 1;
} else {
    %instanceData = SectionFile::read($DEFINE_TEMPLATE_INSTANCE_CONFIG);
}
# Temporary Config file
my %temporaryData;
if (! -e $DEFINE_TEMPLATE_TMP_CONFIG) {
    print STDERR "Config file '$DEFINE_TEMPLATE_TMP_CONFIG' not found\n";
    exit 1;
} else {
    %temporaryData = SectionFile::read($DEFINE_TEMPLATE_TMP_CONFIG);
}
# Template Config file
my %templateData;
if (! -e $DEFINE_TEMPLATE_CONFIG) {
    print STDERR "Config file '$DEFINE_TEMPLATE_CONFIG' not found\n";
    exit 1;
} else {
    %templateData = SectionFile::read($DEFINE_TEMPLATE_CONFIG);
}

# ---

sub parseFile {
    my($fileName) = (@_);
    
    my @newKeys;
    
    # Get Found Keys
    my %foundkeysSet;
    open(my $fh, '<:encoding(UTF-8)', $fileName) 
        or die "Could not open '$fileName' $!";
    while ( my $line = <$fh> ) {
        my @keyReq = $line =~ m/$MAGIC_REGEX/;
        while (@keyReq) {
            my $key = $keyReq[0];
            my $regex = "\\%\\%".$key."\\%\\%";
            $line=~ s/$regex//;
            $key =~ s/$TRIM_REGEX//g;
            $foundkeysSet{$key} = 1;
            @keyReq = $line =~ m/$MAGIC_REGEX/;
        }
    }

    # Get missing keys from temporary dictionnary
    foreach my $key (sort keys %foundkeysSet) {
        if (! exists $temporaryData{$REPLACEMENT_SECTION}{$key}) {
            push @newKeys, $key;
        }
    }

    # Prompt for each missing keys
    foreach my $key (@newKeys) {
        my ($prompt, $default, $test, @hist);
        $prompt = $key;
        $test='.+';
        @hist = ();

        if (exists $templateData{"$VARS_SECTION"}{$key.$VARS_PROMPT}) {
            $prompt = $templateData{"$VARS_SECTION"}{$key.$VARS_PROMPT};
        }
        if (exists $templateData{"$VARS_SECTION"}{$key.$VARS_DEFAULT}) {
            $default = $templateData{"$VARS_SECTION"}{$key.$VARS_DEFAULT};
            push(@hist, $default);
        }
        if (exists $instanceData{"$REPLACEMENT_SECTION"}{$key}) {
            $default = $instanceData{"$REPLACEMENT_SECTION"}{$key};
            push(@hist, $default);
        }
        if (exists $temporaryData{"$REPLACEMENT_SECTION"}{$key}) {
            $default = $temporaryData{"$REPLACEMENT_SECTION"}{$key};
            push(@hist, $default);
        }
        if (exists $templateData{"$VARS_SECTION"}{$key.$VARS_TEST}) {
            $test = $templateData{"$VARS_SECTION"}{$key.$VARS_TEST};
        }
        
        my $value = Prompt::promptLine("$prompt ",$default,$test,\@hist);
        $temporaryData{$REPLACEMENT_SECTION}{$key} = $value;
    }
    SectionFile::write($DEFINE_TEMPLATE_TMP_CONFIG, %temporaryData);
}

if ($optContent) {
    open(my $fh, '<:encoding(UTF-8)', $inputFilename) or die "Could not open '$inputFilename' $!";
    while ( my $line = <$fh> ) {
        chomp($line);
        $line =~ s/$TRIM_REGEX//g;
        parseFile($line) if ($line =~ /\.template$/);
    }
    exit 0
}

parseFile($inputFilename)