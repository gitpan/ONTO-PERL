# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl GoaParser.t'

#########################

BEGIN {
	eval { require Test; };
    use Test;    
    plan tests => 7;
}
#########################

use OBO::CCO::GoaParser;
use Carp;
use strict;
use warnings;

my %taxa = (
	'4896' => 'Schizosaccharomyces pombe organism',
	'4932' => 'Saccharomyces cerevisiae organism', 
	'3702' => 'Arabidopsis thaliana organism',
	'9606' => 'Homo sapiens organism'
	);
my @files = ("./t/data/pre_cco_core.obo",
			"./t/data/out_cco.obo",
			"./t/data/goa_assoc_filt.txt", 
			"./t/data/cco_b_ath.ids",
			"./t/data/cco_b.ids",
			"./t/data/Ath_cc_up.map",
			);
my $my_parser = OBO::CCO::GoaParser->new();
ok(1);
my $goaAssocSet = $my_parser->parse("./t/data/goa_assoc_filt.txt");
#my $start = time;
my $ontology = $my_parser->work(\@files);
#my $end = time;
#print "Processed in ", $end - $start, " seconds\n"; 
ok(1);
ok(!$ontology->get_term_by_name("Q6NMC8_ARATH")); #this entry has no synonyms (i.e. no IPI id) and was renamed in UniProt
ok($ontology->get_term_by_name("RK20_ARATH"));
ok($ontology->get_term_by_name("Q6XJG8_ARATH"));
ok($ontology->get_term_by_name("Q84JF0_ARATH"));

@files = (
"./t/data/add_goa_assocs.obo",
"./t/data/add_goa_assocs.out",
"./t/data/add_goa_assocs.goa",
"./t/data/add_goa_assocs_up.map",
"./t/data/add_goa_assocs_goa.map",
);

$ontology = $my_parser->add_go_assocs(\@files);
ok(1);