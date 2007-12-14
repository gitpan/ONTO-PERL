# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl NewIntActParser.t'

#########################

use Test::More tests => 8;

#########################

use Carp;
use strict;
use warnings;

BEGIN {
	push @INC, '..';
}

SKIP:
{
	my %taxa = (
		'4896' => 'Schizosaccharomyces pombe organism',
		'4932' => 'Saccharomyces cerevisiae organism',
		'3702' => 'Arabidopsis thaliana organism',
		'9606' => 'Homo sapiens organism'
	);
	my @files = (
		"./t/data/out_cco.obo", 
		"./t/data/out_int_cco.obo",		
		"./t/data/cco_b_ath.ids",
		"./t/data/cco_b.ids",
		"./t/data/cco_i_At.ids",
		"./t/data/cco_i.ids",
		"./t/data/Ath_cc_up.map",
		"./t/data/Ath_up.map",
		"./t/data/arath_small-07.xml",
	);
	require OBO::CCO::NewIntActParser;
	my $my_parser = OBO::CCO::NewIntActParser->new();
	ok(1);

	eval 'use XML::XPath';
	skip ('because XML::XPath is required for testing the new IntAct parser', 7) if $@;
		
	#my $start    = time;
	my $ontology = $my_parser->work( \@files, $taxa{'3702'} );
	#my $end      = time;
	
	#print "Processed in ", $end - $start, " seconds\n";
	ok(1);
	ok( !$ontology->get_term_by_name("Q6NMC8_ARATH") );
	ok( $ontology->get_term_by_name("CCD51_ARATH") ); 
	ok( $ontology->get_term_by_name("RK20_ARATH") );
	ok( $ontology->get_term_by_name("Q6XJG8_ARATH") );
	ok( $ontology->get_term_by_name("Q84JF0_ARATH") );
	ok( !$ontology->get_term_by_name("Q65967_9LUTE") );
}