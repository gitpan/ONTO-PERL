# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl OBOParser.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 15;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use CCO::Parser::OBOParser;
use strict;

my $my_parser = CCO::Parser::OBOParser->new;
ok(1);

my $ontology = $my_parser->work("./t/data/fake_ulo_cco.obo");

ok($ontology->has_term($ontology->get_term_by_id("CCO:B9999993")));
ok($ontology->has_term($ontology->get_term_by_name("small molecule")));
ok($ontology->get_relationship_by_id("CCO:B9999998_is_a_CCO:B0000000")->type() eq "is_a");
ok($ontology->get_relationship_by_id("CCO:B9999996_part_of_CCO:B9999992")->type() eq "part_of");

# export to OBO
#$ontology->export(\*STDERR);
open (FH, ">./t/data/test1.obo") || die "Run as root the tests: ", $!;
$ontology->export(\*FH);
close FH;

# export to XML 1
open (FH, ">./t/data/test1.xml") || die "Run as root the tests: ", $!;
$ontology->export(\*FH, 'xml');
close FH;

my $ontology2 = $my_parser->work("./t/data/pre_cco.obo");
warn "number of terms: ", $ontology2->get_number_of_terms();

# export to XML 2
open (FH, ">./t/data/test2.xml") || die "Run as root the tests: ", $!;
$ontology2->export(\*FH, 'xml');
close FH;

# export to OWL 2
open (FH, ">./t/data/test2.owl") || die "Run as root the tests: ", $!;
$ontology2->export(\*FH, 'owl');
close FH;

# export to DOT 2
open (FH, ">./t/data/test2.dot") || die "Run as root the tests: ", $!;
$ontology2->export(\*FH, 'dot');
close FH;

# export back to obo
open (FH, ">./t/data/test2.obo") || die "Run as root the tests: ", $!;
ok($ontology2->has_term($ontology2->get_term_by_id("CCO:P0000205")));
ok($ontology2->has_term($ontology2->get_term_by_name("gene")));
$ontology2->export(\*FH);
close FH;

# some tests
ok($ontology2->has_term($ontology2->get_term_by_id("CCO:U0000009")));
ok($ontology2->has_term($ontology2->get_term_by_name("cell cycle")));
ok($ontology2->get_relationship_by_id("CCO:P0000274_is_a_CCO:P0000262")->type() eq "is_a");
ok($ontology2->get_relationship_by_id("CCO:P0000274_part_of_CCO:P0000272")->type() eq "part_of"); 

#
# a third ontology
# 
my $ontology3 = $my_parser->work("./t/data/ulo_cco.obo");
ok($ontology3->get_number_of_terms() == 11);
ok($ontology3->has_term($ontology3->get_term_by_id("CCO:U0000009")));
ok($ontology3->has_term($ontology3->get_term_by_id("CCO:U0000001")));

# export to OWL ULO
open (FH, ">./t/data/test_ulo_cco.owl") || die "Run as root the tests: ", $!;
$ontology3->export(\*FH, 'owl');
close FH;

# export to DOT ULO
open (FH, ">./t/data/test_ulo_cco.dot") || die "Run as root the tests: ", $!;
$ontology3->export(\*FH, 'dot');
close FH;

ok(1);