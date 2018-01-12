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

#print "abcd\b\bXX\e[2J";
print "abcdXX";
print "\e[3D";
print "\e[0J";
print "\n";
#my $res = Prompt::promptLine('Enter your name4 ','arthur','^[^0-9]+$',('un','deux','trois'));
#print "$res\n";

#Prompt::test2();

#test("e",2);
#test("é",2);
#test("汉",2);
#test("𠜎",2);
#\xc3\xa9	

#printf "1\x65\bX\n"
#printf "1\xc3\xa9\bX\n"
#printf "1\xe0\xa4\x94\bX\n"
#printf "1\xef\xaa\x9a\bX\n"
#printf "1\xf0\xa0\x9c\x8e\bX\n"
#1 X