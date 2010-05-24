# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Synonym.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 35;
}

#########################

use OBO::Core::Synonym;
use OBO::Core::Dbxref;

my $syn1 = OBO::Core::Synonym->new();
my $syn2 = OBO::Core::Synonym->new();
my $syn3 = OBO::Core::Synonym->new();
my $syn4 = OBO::Core::Synonym->new();

# type
ok(!defined $syn1->type());
$syn1->type('EXACT');
$syn2->type('BROAD');
$syn3->type('NARROW');
$syn4->type('NARROW');

# def
my $def1 = OBO::Core::Def->new();
my $def2 = OBO::Core::Def->new();
my $def3 = OBO::Core::Def->new();
my $def4 = OBO::Core::Def->new();

$def1->text("Hola mundo1");
$def2->text("Hola mundo2");
$def3->text("Hola mundo3");
$def4->text("Hola mundo3");

my $ref1 = OBO::Core::Dbxref->new();
my $ref2 = OBO::Core::Dbxref->new();
my $ref3 = OBO::Core::Dbxref->new();
my $ref4 = OBO::Core::Dbxref->new();

$ref1->name("CCO:vm");
$ref2->name("CCO:ls");
$ref3->name("CCO:ea");
$ref4->name("CCO:ea");

my $refs_set1 = OBO::Util::DbxrefSet->new();
$refs_set1->add_all($ref1,$ref2,$ref3,$ref4);
$def1->dbxref_set($refs_set1);
$syn1->def($def1);
ok($syn1->def()->text() eq "Hola mundo1");
ok($syn1->def()->dbxref_set()->size == 3);

my $refs_set2 = OBO::Util::DbxrefSet->new();
ok($syn1->def()->dbxref_set()->size == 3);
ok($syn2->def()->dbxref_set()->size == 0);
$refs_set2->add($ref2);
$def2->dbxref_set($refs_set2);
$syn2->def($def2);
ok($syn2->def()->text() eq "Hola mundo2");
ok($syn2->def()->dbxref_set()->size == 1);
ok(($syn2->def()->dbxref_set()->get_set())[0]->equals($ref2));

my $refs_set3 = OBO::Util::DbxrefSet->new();
ok($syn1->def()->dbxref_set()->size == 3);
ok($syn2->def()->dbxref_set()->size == 1);
ok($syn3->def()->dbxref_set()->size == 0);
$refs_set3->add($ref3);
$def3->dbxref_set($refs_set3);
$syn3->def($def3);
ok($syn3->def()->text() eq "Hola mundo3");
ok($syn3->def()->dbxref_set()->size == 1);
ok(($syn3->def()->dbxref_set()->get_set())[0]->name() eq "CCO:ea");

my $refs_set4 = OBO::Util::DbxrefSet->new();
ok($syn1->def()->dbxref_set()->size == 3);
ok($syn2->def()->dbxref_set()->size == 1);
ok($syn3->def()->dbxref_set()->size == 1);
ok($syn4->def()->dbxref_set()->size == 0);
$refs_set4->add($ref4);
$def4->dbxref_set($refs_set4);
$syn4->def($def4);
ok($syn4->def()->text() eq "Hola mundo3");
ok($syn4->def()->dbxref_set()->size == 1);
ok(($syn4->def()->dbxref_set()->get_set())[0]->name() eq "CCO:ea");

# syn3 and syn4 are equal
ok($syn3->equals($syn4));
ok($syn3->type() eq $syn4->type());
ok($syn3->def()->equals($syn4->def()));
ok($syn3->def()->text() eq $syn4->def()->text());
ok(($syn3->def()->dbxref_set())->equals($syn4->def()->dbxref_set()));

# def as string
ok($syn3->def_as_string() eq "\"Hola mundo3\" [CCO:ea]");
$syn3->def_as_string("This is a dummy synonym", "[CCO:ls, CCO:ea \"Erick Antezana\", CCO:vm, http://mydomain.com/key1=value1&key2=value2]");
ok($syn3->def()->text() eq "This is a dummy synonym");
my @refs_syn3 = $syn3->def()->dbxref_set()->get_set();
my %r_syn3;
foreach my $ref_syn3 (@refs_syn3) {
	$r_syn3{$ref_syn3->name()} = $ref_syn3->name();
}
ok($syn3->def()->dbxref_set()->size == 4);
ok($r_syn3{"CCO:vm"} eq "CCO:vm");
ok($r_syn3{"CCO:ls"} eq "CCO:ls");
ok($r_syn3{"CCO:ea"} eq "CCO:ea");
ok($r_syn3{"http://mydomain.com/key1=value1&key2=value2"} eq "http://mydomain.com/key1=value1&key2=value2");
ok($syn3->def_as_string() eq "\"This is a dummy synonym\" [CCO:ea \"Erick Antezana\", CCO:ls, CCO:vm, http://mydomain.com/key1=value1&key2=value2]");

ok(1);
