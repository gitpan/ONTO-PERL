# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl SwissProtToRDF.t'

#########################

BEGIN {
	eval { require Test; };
	use Test;    
	plan tests => 2;
}
#########################

use Carp;
use strict;
use warnings;

use OBO::APO::SwissProtToRDF;

my $goa2rdf = OBO::APO::SwissProtToRDF->new();
ok(1);
my $file = './t/data/up.dat';
open (FH, '>./t/data/test_uo.rdf') || die $!;

my $file_handle = \*FH;
my $base        = 'http://www.semantic-systems-biology.org/';
my $ns          = 'SSB';
$file_handle    = $goa2rdf->work($file, $file_handle, $base, $ns);

ok(1);
close $file_handle;