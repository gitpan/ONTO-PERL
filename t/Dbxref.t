# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Dbxref.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 18;
}

#########################

use OBO::Core::Dbxref;
use strict;

# three new dbxref's
my $ref1 = OBO::Core::Dbxref->new();
my $ref2 = OBO::Core::Dbxref->new();
my $ref3 = OBO::Core::Dbxref->new();

$ref1->name("CCO:vm");
$ref1->description("this is a description");
$ref1->modifier("{opt=123}");
ok($ref1->name() eq "CCO:vm");
$ref2->name("CCO:ls");
ok($ref2->name() eq "CCO:ls");
$ref3->db("CCO");
$ref3->acc("ea");
ok($ref3->name() eq "CCO:ea");
ok($ref3->db() eq "CCO");
ok($ref3->acc() eq "ea");

ok(!$ref2->equals($ref3));
ok(!$ref1->equals($ref3));
ok(!$ref1->equals($ref2));
ok($ref1->equals($ref1));
ok($ref2->equals($ref2));
ok($ref3->equals($ref3));

my $ref4 = $ref3;
ok($ref4->name() eq $ref3->name() && $ref4->description() eq $ref3->description() && $ref4->modifier() eq $ref3->modifier());

my $ref5 = OBO::Core::Dbxref->new();
$ref5->name("CCO:vm");
$ref5->description("this is a description");
$ref5->modifier("{opt=123}");
ok($ref5->name() eq "CCO:vm");

ok($ref1->equals($ref5));

ok($ref1->as_string() eq "CCO:vm \"this is a description\" {opt=123}");

my $ref6 = OBO::Core::Dbxref->new();
$ref6->name("IUPAC:1");
ok($ref6->name() eq "IUPAC:1");

my $ref7 = OBO::Core::Dbxref->new();
$ref7->name("NIST_Chemistry_WebBook:1");
ok($ref7->name() eq "NIST_Chemistry_WebBook:1");

ok(1);