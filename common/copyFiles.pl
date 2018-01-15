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

my $TRIM_REGEX = '^\s+|\s+$';
my $MAGIC_REGEX = '\%\%([^\%]+)\%\%';
my $REPLACEMENT_SECTION = "replacement";
my $DEFINE_TEMPLATE_CONTENT = $ENV{'DEFINE_TEMPLATE_CONTENT'};
if (! defined $DEFINE_TEMPLATE_CONTENT) {
    print STDERR "DEFINE_TEMPLATE_CONTENT not set\n";
    exit 1;
}

# Input arguments
my ($fileList, $configFile, $destPath) = @ARGV;
if (not defined $fileList) {
    print STDERR "Missing input file List\n";
    exit 1;
}
if (! -e $fileList) {
    print STDERR "'$fileList' not found\n";
    exit 1;
}
if (not defined $configFile) {
    print STDERR "Missing input config File\n";
    exit 1;
}
if (! -e $configFile) {
    print STDERR "'$configFile' not found\n";
    exit 1;
}
if (not defined $destPath) {
    print STDERR "Missing output path\n";
    exit 1;
}
if (! -e $destPath) {
    print STDERR "'$destPath' not found\n";
    exit 1;
}

sub copyFile {
    my ($in, $out, $isSimpleCpy) = @_;
    if ($isSimpleCpy) {
        print "copy $in $out\n";
    } else {
        print "change $in $out\n";
    }
}

my %config = SectionFile::read($configFile);
open(my $fh, '<:encoding(UTF-8)', $fileList) or die "Could not open '$fileList' $!";
while ( my $line = <$fh> ) {
    chomp $line;
    $line =~ s/$TRIM_REGEX//g;
    my $in = $line;
    my @keyReq = $line =~ m/$MAGIC_REGEX/;
    while (@keyReq) {
        my $key = $keyReq[0];
        my $regex = "\\%\\%".$key."\\%\\%";
        if (exists $config{$REPLACEMENT_SECTION}{$key}) {
            my $v = $config{$REPLACEMENT_SECTION}{$key};
            $line =~ s/$regex/$v/;
        } else {
            $line =~ s/$regex/xxx/;
        }
        @keyReq = $line =~ m/$MAGIC_REGEX/;
    }
    my $len = length($DEFINE_TEMPLATE_CONTENT."/");
    my $content = substr($line,$len,length($line)-$len);
    if ($content) {
        my $isSimpleCpy=0;
        if ($content =~ m/\.template$/) {
            $content =~ s/\.template$//;
            $isSimpleCpy=1;
        }
        my $out = "$destPath/$content";
        copyFile($in, $out, $isSimpleCpy);
    }
}