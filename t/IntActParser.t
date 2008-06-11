# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl IntActParser.t'

#########################

use Test::More tests => 7;

#########################

use OBO::Parser::OBOParser;

use strict;

SKIP:
{
	# How many proteins have we got for filtering?
	my $my_parser = OBO::Parser::OBOParser->new;
	my $ontology = $my_parser->work("./t/data/out_cco.obo");
	my @gene_names_goa_file = @{$ontology->get_terms("CCO:B.*")};
	my $goa_size = @gene_names_goa_file;
	ok ($goa_size > 0);
	
	eval 'use XML::Simple';
	skip ('because XML::Simple is required for testing the IntAct parser', 6) if $@;
	
	eval 'use XML::SAX';
	skip ('because XML::SAX is required for testing the IntAct parser', 6) if $@;
	
	require OBO::CCO::XMLIntactParser;
	require OBO::CCO::IntActParser;
	
	# TEST THE PARSER FROM INSIDE ###############################
	
	# Does the XML parser work?
	my $xmlintactparser = OBO::CCO::XMLIntactParser->new();
	$xmlintactparser->work("./t/data/arath_small-05.xml");
	ok (1);
	
	# Get interactors
	my @interactors = @{$xmlintactparser->interactors()};
	my $interactors = @interactors;
	ok ($interactors > 0);
	
	# Get interactions
	my @interactions = @{$xmlintactparser->interactions()};
	my $interactions = @interactions;
	ok ($interactions > 0);
	
	# TEST THE PARSER FROM OUTSIDE ###############################
	# my $A_t_intact_files_dir = "/home/pik/Bioinformatics/Erick_two/IntactFiles/At";
	# my @A_t_intact_files = @{&get_intact_files ($A_t_intact_files_dir)};
	
	my @A_t_intact_files = ("./t/data/arath_small-05.xml");
	
	my $A_t_interactionmanager = OBO::CCO::IntActParser->new;
	my $new_ontology = $A_t_interactionmanager->work(
		"./t/data/out_cco.obo.old",
		"./t/data/out_I_A_thaliana.obo",
		"3702",
		"./t/data/cco_i_At.ids",
		"./t/data/cco_b_ath.ids",
		"./t/data/cco_i.ids",
		"./t/data/cco_b.ids",
		@A_t_intact_files 
	);
	ok (1);
	
	# How many new interactions?
	my @new_interactions = @{$new_ontology->get_terms("CCO:I.*")};
	my $new_interactions_size = @new_interactions;
	ok ($new_interactions_size > 0);
	
	# How many new interactors?
	my @new_interactors = @{$new_ontology->get_terms("CCO:B.*")};
	my $new_interactors_size = @new_interactors;
	ok ($new_interactors_size > $goa_size);
}
sub get_intact_files{
	my $intact_files_dir = shift;
	my @intact_files = ();
	opendir(DIR, $intact_files_dir) || die "can't opendir $intact_files_dir: $!";
	my @files = readdir(DIR);
	for my $file (@files){
		if (!($file eq ".") and !($file eq "..")){
		push (@intact_files,$intact_files_dir.$file);	
		}
	}
	closedir DIR;
	return \@intact_files;
}
