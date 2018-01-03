#!/bin/perl
use strict;
use warnings;
use Data::Dumper qw(Dumper);

sub readConfigFile {
    my $fileName = $ENV{'DEFINE_TEMPLATE_CONFIG'};
    open(my $fh, '<:encoding(UTF-8)', $fileName) 
        or die "Could not open '$fileName' $!";
    my $sectionName = "";
    my %configData;
    while ( my $line = <$fh> ) {
        $line =~ s/^\s+|\s+$//g;
        if (! $line eq "") {
            my @sectionReq = $line =~ m/^\[(.+)\]$/;
            if (@sectionReq) {
                $sectionName = $sectionReq[0];
                $sectionName =~ s/^\s+|\s+$//g;
            } else {
                (! $sectionName eq "") or die "Missing section in '$fileName'";
                my @keyValueReq = $line =~ m/^([^\=]+)\=([^\=]+)$/;
                (@keyValueReq) or die "Invalid entry in '$fileName'";
                if (@keyValueReq) {
                    my $key = $keyValueReq[0];
                    $key =~ s/^\s+|\s+$//g;
                    my $value = $keyValueReq[1];
                    $value =~ s/^\s+|\s+$//g;
                    $configData{$sectionName}{$key} = $value;
                }
            }
        }
    }
    return %configData;
}

sub writeConfigFile {
    my(%configData) = @_;
    my $fileName = $ENV{'DEFINE_TEMPLATE_CONFIG'};
    open(my $fh, '>', $fileName) 
        or die "Could not open '$fileName' $!";
    foreach my $sectionName (sort keys %configData) {
        print $fh "[$sectionName]\n";
        foreach my $key (sort keys %{ $configData{$sectionName} }) {
            my $value = $configData{$sectionName}{$key};
            print $fh "\t$key = $value\n";
        }
    }
}

sub getMissingRemplacementListFromFile {
    my($fileName, %configData) = (@_);
    my %missingSet;
    open(my $fh, '<:encoding(UTF-8)', $fileName) 
        or die "Could not open '$fileName' $!";
    while ( my $line = <$fh> ) {
        my @keyReq = $line =~ m/\%\%([^\%]+)\%\%/;
        while (@keyReq) {
            $line =~ s/\%\%([^\%]+)\%\%/--/;
            my $key = $keyReq[0];
            $key =~ s/^\s+|\s+$//g;
            $missingSet{$key} = 1;
            @keyReq = $line =~ m/\%\%([^\%]+)\%\%/;
        }
    }
    my @out;
    foreach my $key (sort keys %missingSet) {
        if (! exists$configData{"replacement"}{$key}) {
            push @out, $key;
        }
    }
    return @out;
}

#my %configData;
#$configData{"replacement"}{"sdf"} = "world";
#$configData{"replacement"}{"mainfile"} = "main";

my %configData = readConfigFile();
my @new = getMissingRemplacementListFromFile($ENV{'DEFINE_TEMPLATE_PARSEFILE_SRC'}, %configData);
foreach my $key (@new) {
    print "$key\n"
}
writeConfigFile(%configData)
