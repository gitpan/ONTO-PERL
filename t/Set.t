# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Set.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 15;
}

#########################

use OBO::Util::Set;
use strict;

my $my_set = OBO::Util::Set->new();
ok(1);

$my_set->add("CCO:P0000001");

ok($my_set->contains("CCO:P0000001"));

$my_set->add_all("CCO:P0000002", "CCO:P0000003", "CCO:P0000004");

ok($my_set->contains("CCO:P0000002") && $my_set->contains("CCO:P0000003") && $my_set->contains("CCO:P0000004"));

my $my_set2 = OBO::Util::Set->new();

ok(1);

$my_set2->add_all("CCO:P0000001", "CCO:P0000002", "CCO:P0000003", "CCO:P0000004");

ok($my_set2->contains("CCO:P0000002") && $my_set->contains("CCO:P0000003") && $my_set->contains("CCO:P0000004"));

ok($my_set->equals($my_set2));

ok($my_set2->size() == 4);

$my_set2->remove("CCO:P0000003");

ok($my_set2->contains("CCO:P0000001") && $my_set->contains("CCO:P0000002") && $my_set->contains("CCO:P0000004"));

ok($my_set2->size() == 3);


$my_set2->remove("CCO:P0000005");

ok($my_set2->contains("CCO:P0000001") && $my_set->contains("CCO:P0000002") && $my_set->contains("CCO:P0000004"));

ok($my_set2->size() == 3);

$my_set2->clear();

ok(!$my_set2->contains("CCO:P0000001") || !$my_set->contains("CCO:P0000002") || !$my_set->contains("CCO:P0000004"));

ok($my_set2->size() == 0);

ok($my_set2->is_empty());

ok(1);
