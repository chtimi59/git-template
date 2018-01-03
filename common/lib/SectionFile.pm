package SectionFile;
use strict;
use warnings;

# read(filename)
# return a hashtable
sub read {
    my($fileName) = @_;
    open(my $fh, '<:encoding(UTF-8)', $fileName) 
        or die "Could not open '$fileName' $!";
    my $sectionName = "";
    my %hash;
    while ( my $line = <$fh> ) {
        $line =~ s/^\s+|\s+$//g;
        if (! $line eq "") {
            #section regular expression:
            my @sectionReq = $line =~ m/^\[(.+)\]$/;
            #new section
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