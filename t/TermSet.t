# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl TermSet.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 25;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use CCO::Core::TermSet;
use CCO::Core::Term;
use strict;

# new set
my $my_set = CCO::Core::TermSet->new();
ok(1);
ok($my_set->is_empty() == 1);

my @arr = $my_set->get_set();
ok($#{@arr} == -1);

# three new terms
my $n1 = CCO::Core::Term->new();
my $n2 = CCO::Core::Term->new();
my $n3 = CCO::Core::Term->new();

$n1->id("CCO:P0000001");
$n2->id("CCO:P0000002");
$n3->id("CCO:P0000003");

$n1->name("One");
$n2->name("Two");
$n3->name("Three");

# remove from my_set
$my_set->remove($n1);
ok($my_set->size() == 0);
ok(!$my_set->contains($n1));
$my_set->add($n1);
ok($my_set->contains($n1));
$my_set->remove($n1);
ok($my_set->size() == 0);
ok(!$my_set->contains($n1));

$my_set->add($n1);
ok($my_set->contains($n1));
$my_set->add($n2);
ok($my_set->contains($n2));
$my_set->add($n3);
ok($my_set->contains($n3));

my $n4 = CCO::Core::Term->new();
my $n5 = CCO::Core::Term->new();
my $n6 = CCO::Core::Term->new();

$n4->id("CCO:P0000004");
$n5->id("CCO:P0000005");
$n6->id("CCO:P0000006");

$n4->name("Four");
$n5->name("Five");
$n6->name("Six");

$my_set->add_all($n4, $n5, $n6);
ok($my_set->contains($n4) && $my_set->contains($n5) && $my_set->contains($n6));

### get versions ###
#foreach ($my_set->get_set()) {
#	print $_, "\n";
#}

$my_set->add_all($n4, $n5, $n6);
ok($my_set->size() == 6);

# remove from my_set
$my_set->remove($n4);
ok($my_set->size() == 5);
ok(!$my_set->contains($n4));

my $n7 = $n4;
my $n8 = $n5;
my $n9 = $n6;

my $my_set2 = CCO::Core::TermSet->new();
ok(1);

ok($my_set2->is_empty());
ok(!$my_set->equals($my_set2));

$my_set->add_all($n4, $n5, $n6);
$my_set2->add_all($n7, $n8, $n9, $n1, $n2, $n3);
ok(!$my_set2->is_empty());
ok($my_set->contains($n7) && $my_set->contains($n8) && $my_set->contains($n9));
ok($my_set->equals($my_set2));

ok($my_set2->size() == 6);

$my_set2->clear();
ok($my_set2->is_empty());
ok($my_set2->size() == 0);

ok(1);
