# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl NCBIToRDF.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 2;
}

#########################

use OBO::CCO::NCBIToRDF;
use Carp;
use strict;
use warnings;

my $ncbi2rdf = OBO::CCO::NCBIToRDF->new();
ok(1);

open (FH, ">./t/data/ncbi.rdf") || die $!;
my $file_handle = \*FH;
$file_handle = $ncbi2rdf->work("./t/data/nodes_dummy.dmp","./t/data/names_dummy.dmp",$file_handle);
close $file_handle;
ok(1);