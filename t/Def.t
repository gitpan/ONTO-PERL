# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Def.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 15;
}

#########################

use OBO::Core::Def;
use OBO::Core::Dbxref;
use strict;

# three new def's
my $def1 = OBO::Core::Def->new();
my $def2 = OBO::Core::Def->new();
my $def3 = OBO::Core::Def->new();

ok($def2->dbxref_set_as_string() eq "[]");

$def1->text("CCO:vm text");
ok($def1->text() eq "CCO:vm text");
$def2->text("CCO:ls text");
ok($def2->text() eq "CCO:ls text");
$def3->text("CCO:ea text");
ok($def3->text() eq "CCO:ea text");

my $ref1 = OBO::Core::Dbxref->new();
my $ref2 = OBO::Core::Dbxref->new();
my $ref3 = OBO::Core::Dbxref->new();

$ref1->name("CCO:vm");
$ref2->name("CCO:ls");
$ref3->name("CCO:ea");

ok($ref3->db() eq "CCO");
ok($ref3->acc() eq "ea");

my $dbxref_set1 = OBO::Util::DbxrefSet->new();
$dbxref_set1->add($ref1);

my $dbxref_set2 = OBO::Util::DbxrefSet->new();
$dbxref_set2->add($ref2);

my $dbxref_set3 = OBO::Util::DbxrefSet->new();
$dbxref_set3->add($ref3);

$def1->dbxref_set($dbxref_set1);
$def2->dbxref_set($dbxref_set2);
$def3->dbxref_set($dbxref_set3);

ok(!$def3->equals($def2));
ok($def3->equals($def3));

# dbxref_set_as_string
ok($def2->dbxref_set_as_string() eq "[CCO:ls]");
$def2->dbxref_set_as_string('[CCO:vm, CCO:ls, CCO:ea "Erick Antezana" {opt=first}]');
my @refs_def2 = $def2->dbxref_set()->get_set();
my %r_def2;
foreach my $ref_def2 (@refs_def2) {
	$r_def2{$ref_def2->name()} = $ref_def2->name();
}
ok($r_def2{"CCO:vm"} eq "CCO:vm");
ok($r_def2{"CCO:ls"} eq "CCO:ls");
ok($r_def2{"CCO:ea"} eq "CCO:ea");
ok($def2->dbxref_set_as_string() eq '[CCO:ea "Erick Antezana" {opt=first}, CCO:ls, CCO:vm]');

$def2->dbxref_set_as_string('[http://mydomain.com/key1=value1&key2=value2]');
ok($def2->dbxref_set_as_string() eq '[CCO:ea "Erick Antezana" {opt=first}, CCO:ls, CCO:vm, http://mydomain.com/key1=value1&key2=value2]');

ok(1);
