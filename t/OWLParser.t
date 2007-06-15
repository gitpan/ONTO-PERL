# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl OWLParser.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 4;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use CCO::Parser::OWLParser;
use strict;

my $my_parser = CCO::Parser::OWLParser->new();

my $owl_test_file = "./t/data/test_ulo_cco2.owl";

my $onto = $my_parser->work($owl_test_file);
ok($onto->get_number_of_terms() == 11);
ok($onto->has_term($onto->get_term_by_id("CCO:U0000009")));
ok($onto->has_term($onto->get_term_by_id("CCO:U0000001")));

# export to OBO
open (FH, ">./t/data/test_ulo_cco2.obo") || die "Run as root the tests: ", $!;
$onto->export(\*FH, 'obo');
close FH;
                     
ok(1);
