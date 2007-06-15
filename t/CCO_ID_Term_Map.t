# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl CCO_ID_Term_Map.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 1;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use CCO::Util::CCO_ID_Term_Map;
use strict;

my $my_set = CCO::Util::CCO_ID_Term_Map->new("cco_dummy.ids");
ok(1);
