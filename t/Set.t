# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Set.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 8;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use CCO::Util::Set;
use strict;

# new set
my $my_set = CCO::Util::Set->new();
ok(1);

$my_set->add("CCO:P0000001");
ok($my_set->contains("CCO:P0000001"));
$my_set->add_all("CCO:P0000002", "CCO:P0000003", "CCO:P0000004");
ok($my_set->contains("CCO:P0000002") && $my_set->contains("CCO:P0000003") && $my_set->contains("CCO:P0000004"));

foreach ($my_set->get_set()) {
	print $_, "\n";
}

print "\nContained!\n" if ($my_set->contains("CCO:P0000001"));

my $my_set2 = CCO::Util::Set->new();
ok(1);
$my_set2->add_all("CCO:P0000001", "CCO:P0000002", "CCO:P0000003", "CCO:P0000004");
ok($my_set2->contains("CCO:P0000002") && $my_set->contains("CCO:P0000003") && $my_set->contains("CCO:P0000004"));
ok($my_set->equals($my_set2));

ok($my_set2->size() == 4);

ok(1);
