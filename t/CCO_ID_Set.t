# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl CCO_ID_Set.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 20;
}

#########################

use CCO::Util::CCO_ID_Set;

use CCO::Util::CCO_ID;

use strict;

my $my_set = CCO::Util::CCO_ID_Set->new();
ok(1);

my $id1 = CCO::Util::CCO_ID->new();

$id1->id_as_string("CCO:P0000001");

$my_set->add($id1);

ok($my_set->contains($id1));

my $id2 = CCO::Util::CCO_ID->new();

$id2->id_as_string("CCO:P0000002");

my $id3 = CCO::Util::CCO_ID->new();

$id3->id_as_string("CCO:P0000003");

my $id4 = CCO::Util::CCO_ID->new();

ok(!$my_set->contains($id4));

$id4->id_as_string("CCO:P0000004");

$my_set->add_all($id1, $id2, $id3, $id4);

ok($my_set->contains($id2) && $my_set->contains($id3) && $my_set->contains($id4));

my $id5_string = "CCO:P0000005";

my $id5 = $my_set->add_as_string($id5_string);

ok($my_set->contains($id5)); 

$my_set->add_as_string($id5_string);
$my_set->add_as_string($id5_string);
$my_set->add_as_string($id5_string);
$my_set->add_as_string($id5_string);

ok($my_set->size() == 5);

my $my_set2 = CCO::Util::CCO_ID_Set->new();

ok(1);

$my_set2->add_all_as_string("CCO:P0000001", "CCO:P0000002", "CCO:P0000003", "CCO:P0000004");

ok(!$my_set->equals($my_set2));

ok($my_set2->size() == 4);

my $id5_2 = $my_set2->add_as_string($id5_string);

ok($my_set2->size() == 5);

ok($my_set->contains($id5_2));

ok($my_set->equals($my_set2));

$my_set->remove($id3);

ok($my_set->contains($id2) && $my_set->contains($id1) && $my_set->contains($id4) && $my_set->contains($id5));

ok($my_set->size() == 4);

$my_set->remove($id5);

ok($my_set->contains($id2) && $my_set->contains($id1) && $my_set->contains($id4));

ok($my_set->size() == 3);

$my_set->clear();

ok(!$my_set->contains($id2) || !$my_set->contains($id1) || !$my_set->contains($id4));

ok($my_set->size() == 0);

ok($my_set->is_empty());

ok(1);
