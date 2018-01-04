package SectionFile;
use strict;
use warnings;

my $TRIM_REGEX = '^\s+|\s+$';
my $SECTION_REGEX = '^\[(.+)\]$';
my $ENTRY_REGEX = '^([^\=]+)\=([^\=]+)$';

# read(filename)
# return a hashtable
sub read {
    my($fileName) = @_;
    open(my $fh, '<:encoding(UTF-8)', $fileName) 
        or die "Could not open '$fileName' $!";
    my $sectionName = "";
    my %hash;
    while ( my $line = <$fh> ) {
        $line =~ s/$TRIM_REGEX//g;
        if (! $line eq "") {
            #section regular expression:
            my @sectionReq = $line =~ m/$SECTION_REGEX/;
            #new section
            if (@sectionReq) {
                $sectionName = $sectionReq[0];
                $sectionName =~ s/$TRIM_REGEX//g;
            } else {
                (! $sectionName eq "") or die "Missing section in '$fileName'";
                my @keyValueReq = $line =~ m/$ENTRY_REGEX/;
                (@keyValueReq) or die "Invalid entry in '$fileName'";
                if (@keyValueReq) {
                    my $key = $keyValueReq[0];
                    $key =~ s/$TRIM_REGEX//g;
                    my $value = $keyValueReq[1];
                    $value =~ s/$TRIM_REGEX//g;
                    $hash{$sectionName}{$key} = $value;
                }
            }
        }
    }
    return %hash;
}

# write(filename, hashtable)
# write hashtable into a text file
sub write {
    my($fileName, %hash) = @_;
    open(my $fh, '>', $fileName) 
        or die "Could not open '$fileName' $!";
    foreach my $sectionName (sort keys %hash) {
        print $fh "[$sectionName]\n";
        foreach my $key (sort keys %{ $hash{$sectionName} }) {
            my $value = $hash{$sectionName}{$key};
            print $fh "\t$key = $value\n";
        }
    }
}

1;