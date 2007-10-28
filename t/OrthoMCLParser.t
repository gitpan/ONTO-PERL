# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl GoaParser.t'

#########################

BEGIN {
	eval { require Test; };
    use Test;    
    plan tests => 17;
}
#########################

use CCO::Parser::OrthoMCLParser;
use Carp;
use strict;
use warnings;
my %taxa = (
	'ath' => ['Arabidopsis thaliana organism', "./t/data/cco_b_ath.ids"],
	'hsa' => ['Homo sapiens organism', "./t/data/cco_b_hsa.ids"],
	'sce' => ['Saccharomyces cerevisiae organism', "./t/data/cco_b_sce.ids"],
#	'spo' => ['Schizosaccharomyces pombe organism', "./t/data/cco_b_spo.ids"],
	);
my @files = (
	"./t/data/out_omcl.obo",
	"./t/data/cco_u.ids",
	"./t/data/cco_t.ids",
	"./t/data/cco_o.ids",
	"./t/data/cco_b.ids",
);
			
my $my_parser = CCO::Parser::OrthoMCLParser->new();
ok(1);
my $omcl_data_file = "./t/data/test_orthomcl.dat";
ok(my $clusters = $my_parser->parse($omcl_data_file));


my $ontology = $my_parser->work($clusters, \@files, \%taxa);
ok(1);
ok($ontology->get_term_by_name("CCD51_ARATH"));
ok($ontology->get_term_by_name("RK20_ARATH"));
ok($ontology->get_term_by_name("Q6XJG8_ARATH"));
ok($ontology->get_term_by_name("Q84JF0_ARATH"));
ok($ontology->get_term_by_name("protein"));
ok(!$ontology->get_term_by_id("CCO:U0000002"));
ok($ontology->get_term_by_name("Orthology cluster10 protein"));
ok(!$ontology->get_term_by_id("CCO:O0000012"));
ok($ontology->get_term_by_name("Arabidopsis thaliana organism"));
ok($ontology->get_term_by_id("CCO:T0000004"));
ok(!$ontology->get_term_by_id("CCO:T0000009"));
ok($ontology->get_term_by_name("At5g39560"));
ok($ontology->get_term_by_id("CCO:B0000078"));
ok(!$ontology->get_term_by_id("CCO:B0000079"));
