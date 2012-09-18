#!/usr/bin/perl

use strict;
use XML::XPath;

my $file = 'test.xml';

my $xp = XML::XPath->new(filename=>$file);

foreach my $oe ($xp->find('//OntologyEntry')->get_nodelist){
    print "OntologyEntry:"; 
    print $oe->find('@category');
    print "--"; 
    print $oe->find('@value');
    print "\n";
}

foreach my $oe ($xp->find('//Protocol')->get_nodelist){
    print "Protocol Text:"; 
    print $oe->find('@text');
    print "\n";
}

