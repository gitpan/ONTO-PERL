# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl GoaToRDF.t'

#########################

BEGIN {
	eval { require Test; };
	use Test;    
	plan tests => 2;
}
#########################

use OBO::CCO::GoaToRDF;
use Carp;
use strict;
use warnings;

my $goa2rdf = OBO::CCO::GoaToRDF->new();
ok(1);

open (FH, ">./t/data/goa.rdf") || die $!;
my $file_handle = \*FH;
$file_handle = $goa2rdf->work($file_handle,"./t/data/goa_assoc_filt.txt");
ok(1);

close $file_handle;
