# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl NCBIParser.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 3;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use CCO::Parser::NCBIParser;
use strict;

my $my_parser = CCO::Parser::NCBIParser->new();
ok(1);

my $taxa_ontology = $my_parser->work("./t/data/pre_cco.obo", "./t/data/pre_cco_taxa.obo", "./t/data/cco_t.ids", "./t/data/nodes_dummy.dmp", "./t/data/names_dummy.dmp", "3702", "9606");
ok($taxa_ontology->has_term($taxa_ontology->get_term_by_name("Mikel organism")));
ok(1);


