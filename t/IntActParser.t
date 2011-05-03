# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl IntActParser.t'

#########################

use Test::More tests => 7;

#########################

use Carp;
use strict;
use warnings;

SKIP:
{	
	eval 'use XML::XPath';
	skip ('because XML::XPath is required for testing the IntAct parser', 7) if $@;
	
	use OBO::Parser::OBOParser;	
	require OBO::CCO::IntActParser;
	
	my $obo_parser    = OBO::Parser::OBOParser->new();	
	my $intact_parser = OBO::CCO::IntActParser->new();
	ok ($intact_parser);
	
	my $global_label = 'human';
	my $data_dir     = "./t/data";
	my $file_prefix  = "$data_dir/$global_label";
	# 1st arg
	my $in_obo_path  = $file_prefix.".0.obo";
	my $onto         = $obo_parser->work( $in_obo_path );
	ok ( ! $onto->get_term_by_name ( 'DDB2_HUMAN' ));
	# 2nd arg
	my $intact_file = $file_prefix."_small-41.xml";
	my $data        = $intact_parser->parse($intact_file);
	ok ( $data );
	# 3rd arg
	my $up_map_path = $file_prefix.".map";
	# 4th arg
	my $up_core_map_path  = $file_prefix.".1.map";
	# 5th arg
	my $up_map_added_path = $file_prefix.".2.map"; # for writing	
	open my $FH, '>', $up_map_added_path or croak "Can't open file $up_map_added_path: $!";
	my $parent_protein_name = 'gene regulation protein';
	my $global_taxon_id  = '9606';
	my @adding_new_terms = (
		$FH,
		$parent_protein_name,
		$global_taxon_id,
		);
	# work()		
	$intact_parser->work(
		$onto, 
		$data, 
		read_map($up_map_path), 
		read_map($up_core_map_path), 
		\@adding_new_terms
		);
	ok ( 1 );
	close $FH;
	# terms
	ok ( my $protein  = $onto->get_term_by_name ( 'DDB2_HUMAN' ));
	# relations
	my @heads_pi = @{$onto->get_head_by_relationship_type( $protein, $onto->get_relationship_type_by_name("participates in"))};
	ok ( @heads_pi == 1 );
	my @heads_hs = @{$onto->get_head_by_relationship_type( $protein, $onto->get_relationship_type_by_name("has source"))};
	ok ( @heads_hs == 1 );
}

sub read_map {
	my $map_file = shift or croak "No map file provided!\n";
	my %map;
	open my $FH, '<', $map_file or croak "Can't open file '$map_file': $!";
	while (<$FH>) {
		chomp;
		my ( $key, $value ) = split;
		$map{$key} = $value;
	}
	close $FH;
	return \%map;
}