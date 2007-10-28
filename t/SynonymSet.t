# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl SynonymSet.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 33;
}

#########################

use CCO::Util::SynonymSet;
use CCO::Core::Synonym;

# new set
my $my_set = CCO::Util::SynonymSet->new();
ok(1);
ok($my_set->is_empty() == 1);

my @arr = $my_set->get_set();
ok($#{@arr} == -1);

# three new synonyms
my $sn1 = CCO::Core::Synonym->new();
my $sn2 = CCO::Core::Synonym->new();
my $sn3 = CCO::Core::Synonym->new();

# type and def
$sn1->type('EXACT');
$sn2->type('EXACT');
$sn3->type('EXACT');

$sn1->def_as_string("This is a dummy synonym1", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]");
$sn2->def_as_string("This is a dummy synonym2", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]");
$sn3->def_as_string("This is a dummy synonym3", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]");

# tests with empty set
$my_set->remove($sn1);
ok($my_set->size() == 0);
ok(!$my_set->contains($sn1));
$my_set->add($sn1);
ok($my_set->contains($sn1));
$my_set->remove($sn1);
ok($my_set->size() == 0);
ok(!$my_set->contains($sn1));

# add's
$my_set->add($sn1);
ok($my_set->contains($sn1));
$my_set->add($sn2);
ok($my_set->contains($sn2));
$my_set->add($sn3);
ok($my_set->contains($sn3));

my $sn4 = CCO::Core::Synonym->new();
my $sn5 = CCO::Core::Synonym->new();
my $sn6 = CCO::Core::Synonym->new();

# type and def
$sn4->type('EXACT');
$sn5->type('EXACT');
$sn6->type('EXACT');

$sn4->def_as_string("This is a dummy synonym4", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]");
$sn5->def_as_string("This is a dummy synonym5", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]");
$sn6->def_as_string("This is a dummy synonym1", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]"); # repeated !!!

$my_set->add_all($sn4, $sn5);
my $false = $my_set->add($sn6);
ok($false == 0);
ok($my_set->contains($sn4) && $my_set->contains($sn5) && $my_set->contains($sn6));

### get versions ###
#foreach ($my_set->get_set()) {
#	print $_, "\n";
#}

$my_set->add_all($sn4, $sn5, $sn6);
ok($my_set->size() == 5);

# remove from my_set
$my_set->remove($sn4);
ok($my_set->size() == 4);
ok(!$my_set->contains($sn4));

my $sn7 = $sn4;
my $sn8 = $sn5;
my $sn9 = $sn6;

# a second set
my $my_set2 = CCO::Util::SynonymSet->new();
ok(1);

ok($my_set2->is_empty());
ok(!$my_set->equals($my_set2));

my $add_all_check = $my_set->add_all($sn4, $sn5, $sn6);
ok($add_all_check == 0);
$add_all_check = $my_set2->add_all($sn7, $sn8, $sn9, $sn1, $sn2, $sn3);
ok($add_all_check == 0);
ok(!$my_set2->is_empty());
ok($my_set->contains($sn7) && $my_set->contains($sn8) && $my_set->contains($sn9));
# todo check the next test:
#ok($my_set->equals($my_set2));

ok($my_set2->size() == 5);

$my_set2->clear();
ok($my_set2->is_empty());
ok($my_set2->size() == 0);

#
# more tests
#
my $snA = CCO::Core::Synonym->new();
my $snB = CCO::Core::Synonym->new();

$snA->type('EXACT');
$snB->type('EXACT');

$snA->def_as_string("This is a very dummy synonym", "[]");
$snB->def_as_string("This is a very dummy synonym", "[]");
$my_set2->clear();
$my_set2->add_all($snA, $snB);
ok($my_set2->size() == 1);
ok($my_set2->contains($snB));
ok($my_set2->contains($snA));

#
# one more
#
my $snC = CCO::Core::Synonym->new();
$snC->type('EXACT');
$snC->def_as_string("SPCC645.04", "[]");
$my_set2->clear();
$my_set2->add($snC);
ok($my_set2->size() == 1);
ok($my_set2->contains($snC));
ok(($my_set2->get_set())[0]->def()->text() eq "SPCC645.04");

ok(1);
