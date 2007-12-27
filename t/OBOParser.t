# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl OBOParser.t'

#########################

BEGIN {
    eval { require Test; };
    use Test;    
    plan tests => 19;
}

#########################

use OBO::Parser::OBOParser;
use strict;

my $my_parser = OBO::Parser::OBOParser->new();
ok(1);

my $mini_onto = $my_parser->work("./t/data/header.obo");
ok(($mini_onto->imports()->get_set())[0] eq 'ulo.obo');
ok(scalar $mini_onto->subsets()->get_set() == 7);
ok(scalar $mini_onto->synonym_type_def_set()->get_set() == 5);
# export to OBO
#$ontology->export(\*STDERR);
open (FH, ">./t/data/test0.obo") || die "Run as root the tests: ", $!;
$mini_onto->export(\*FH);
close FH;

my $ontology = $my_parser->work("./t/data/fake_ulo_cco.obo");

ok($ontology->has_term($ontology->get_term_by_id("CCO:B9999993")));
ok($ontology->get_terms_by_name("small molecule")->size() == 1);
ok($ontology->has_term(($ontology->get_terms_by_name("small molecule")->get_set())[0]));
ok($ontology->get_relationship_by_id("CCO:B9999998_is_a_CCO:B0000000")->type() eq "is_a");
ok($ontology->get_relationship_by_id("CCO:B9999996_part_of_CCO:B9999992")->type() eq "part_of");

# export to OBO
#$ontology->export(\*STDERR);
open (FH, ">./t/data/test1.obo") || die "Run as root the tests: ", $!;
$ontology->export(\*FH);
close FH;

# export to RDF

# for RDF get the whole ontology, as we need interactions, processes ...
my $rdf_ontology = $my_parser->work("./t/data/out_I_A_thaliana.obo");
open (FH, ">./t/data/test1.rdf") || die "Run as root the tests: ", $!;
$rdf_ontology->export(\*FH, 'rdf');
close FH;

# export to RDF (generic)

my $rdf_ontology_gen = $my_parser->work("./t/data/cell.obo");
open (FH, ">./t/data/test2.rdf") || die "Run as root the tests: ", $!;
$rdf_ontology_gen->export(\*FH, 'rdf');
close FH;

# export to XML 1
open (FH, ">./t/data/test1.xml") || die "Run as root the tests: ", $!;
$ontology->export(\*FH, 'xml');
close FH;

my $ontology2 = $my_parser->work("./t/data/pre_cco.obo");
#warn "number of terms: ", $ontology2->get_number_of_terms();

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

# Internal parsing tests with huge OBO ontologies
#my $ontologia = $my_parser->work("./t/data/mammalian_phenotype.obo");
#$ontologia = $my_parser->work("./t/data/environment_ontology.obo");
#my $ontologia = $my_parser->work("./t/data/gene_ontology_edit.obo");
#$ontologia = $my_parser->work("./t/data/MPheno_OBO.ontology");
#$ontologia = $my_parser->work("./t/data/PSI-MOD.obo");
#$ontologia = $my_parser->work("./t/data/fma_obo.obo");
#$ontologia = $my_parser->work("./t/data/psi-mod.obo");
#$ontologia = $my_parser->work("./t/data/zea_mays_anatomy.obo");
#open (FH, ">./t/data/MPheno_OBO.ontology2") || die "Run as root the tests: ", $!;
#$ontologia->export(\*FH, 'obo');
#close FH;

ok(1);