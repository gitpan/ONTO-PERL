# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl GoaParser.t'

#########################

use Test::More tests => 12;

#########################

use Carp;
use strict;
use warnings;

SKIP:
{
	eval 'use SWISS::Entry';
	skip ('because SWISS::Entry is required for testing the UniProt parser', 12) if $@;
	ok(1);
	
	my %taxa = (
		'4896' => 'Schizosaccharomyces pombe organism',
		'4932' => 'Saccharomyces cerevisiae organism', 
		'3702' => 'Arabidopsis thaliana organism',
		'9606' => 'Homo sapiens organism'
		);
	my @files = ("./t/data/out_cco.obo",
				"./t/data/out_cco_up.obo",
				"./t/data/up_test.txt", 
				"./t/data/cco_b_ath.ids",
				"./t/data/cco_b.ids",
				"./t/data/cco_g_dummy.ids",
				"./t/data/cco_g.ids"
				);
				
	require OBO::CCO::UniProtParser;
	my $my_parser = OBO::CCO::UniProtParser->new();
	ok(1);
	
	my $start = time;
	my $ontology = $my_parser->work(\@files, $taxa{'3702'});
	my $end = time;
	#print "Processed in ", $end - $start, " seconds\n"; 
	ok(1);
	ok($ontology->get_term_by_name("rpl20_arath")); 
	ok($ontology->get_term_by_name("At5g67520_arath"));
	ok($ontology->get_term_by_name("RPN1b_arath"));
	ok(!$ontology->get_term_by_name("At4g37630"));
	ok($ontology->get_term_by_name("RK20_ARATH"));
	ok(!$ontology->get_term_by_id('CCO:B0000045'));
	ok($ontology->get_term_by_name("Q6XJG8_ARATH-Phosphoserine351"));
	ok($ontology->get_term_by_name("Q6XJG8_ARATH-Phosphoserine418"));
	ok($ontology->get_term_by_name("Q6XJG8_ARATH-Phosphoserine421"));
}