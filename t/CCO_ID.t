# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl CCO_ID.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 5;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use CCO::Util::CCO_ID;
use strict;

my $my_id = CCO::Util::CCO_ID->new();
$my_id->idspace("CCO");
$my_id->subnamespace("P");
$my_id->number("3000001");
ok($my_id->id_as_string() eq "CCO:P3000001");

my $my_id2 = CCO::Util::CCO_ID->new();
$my_id2->idspace("CCO");
$my_id2->subnamespace("P");
$my_id2->number("3000001");

ok($my_id->equals($my_id2));
ok($my_id->next_id()->id_as_string() eq "CCO:P3000002");

ok($my_id->previous_id()->id_as_string() eq "CCO:P3000000");

ok(1);
