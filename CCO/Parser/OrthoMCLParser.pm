# $Id: OrthoMCLParser.pm 1702 2007-12-06 17:01:36Z erant $
#
# Module  : OrthoMCLParser.pm
# Purpose : Parse OrthoMCL files and add data to an ontology
# License : Copyright (c) 2006 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#

package CCO::Parser::OrthoMCLParser;

=head1 NAME

CCO::Parser::OrthoMCLParser - An orthoMCL data to OBO translator

=head1 DESCRIPTION

Includes methods for adding information from orthoMCL data files to ontologies

orthoMCL can be obtained from http://orthomcl.cbil.upenn.edu/cgi-bin/OrthoMclWeb.cgi

The method 'parse()' parses an orthoMCL output data file  into a data structure (hash of arrays)
The method 'work()' incorporates data from an orthoMCL data file into an ontology, writes the ontology into an OBO file, writes map files.

=head1 AUTHOR

Vladimir Mironov
vlmir@psb.ugent.be

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Vladimir Mironov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use CCO::Core::RelationshipType;
use CCO::Core::Relationship;
use CCO::Core::Term;
use CCO::Util::CCO_ID_Term_Map;
use CCO::Core::Ontology;

use strict;
use warnings;
use Carp;

sub new {
    my $class = $_[0];
    my $self  = {};

    bless( $self, $class );
    return $self;
}

=head2 parse

  Usage    - $OrthoMCLParser->parse()
  Returns  - A a reference to a data structure (hash of hases) containing orthoMCL output data
  Args     - orthoMCL output data file
  Function - parses an orthoMCL output data file  into a data structure
  
=cut

sub parse {
	my $self = shift;
	#get orthoMCL data file
	my $omclDataFile = shift;	
	open(my $FH, '<', $omclDataFile) || die("Cannot open file '$omclDataFile': $!");
	
	#parse orthoMCL output
	my %clusters;# %clusters{protein_name}{taxon_label}
	while(<$FH>){
		my ($cluster, $proteins) = split /:\s+/xms;
		my $cluster_num = $.-1;
		$cluster = "cluster$cluster_num";
		my @proteins = split /\s/xms, $proteins;
		foreach ( @proteins) {
			$_ =~/\A(\w+?)\((\w+?)\)/xms;# $1 is protein name, $2 is taxon label (e.g Hsa)
			$clusters{$cluster}->{$1} =  $2;			
		}
	}		
	close $FH;
	return \%clusters;
}

=head2 work

  Usage    - $OrthoMCLParser->work($omcl_data_ref, $file_names_ref, $taxa_ref)
  Returns  - CCO::Core::Ontology object 
  Args     - 1. reference to an orthoMCL data structure (output of parse()), 2. reference to a list of filenames (output OBO file, 4 map files (U,T,O,B, see the test file), 3. reference to a with taxons and taxon specific maps (see the test file)
  Function - converts orthoMCL data into an ontology, writes OBO and map files 
  
=cut

sub work {
	my ($self, $clust, $files,  $tax) = @_;
	my %clusters = %{$clust};
	my %taxa = %{$tax};
	# input/output files
	my ($new_OBO_file, $u_map_file, $t_map_file, $o_map_file, $b_map_file) = @{$files}; 
	
	
	
	# Initialize  maps (CCO::Util::CCO_ID_Term_Map objects)
	my $u_map = CCO::Util::CCO_ID_Term_Map->new($u_map_file); #map for Upper Level Ontology terms
	my $t_map  = CCO::Util::CCO_ID_Term_Map->new($t_map_file); # map for taxonomy terms
	my $o_map  = CCO::Util::CCO_ID_Term_Map->new($o_map_file); #map for orthologous groups terms
	my $b_map  = CCO::Util::CCO_ID_Term_Map->new($b_map_file); #map for biomolecule terms
	# taxon specific maps for biolmolecule terms
	foreach (keys %taxa) {
		push @{$taxa{$_}}, CCO::Util::CCO_ID_Term_Map->new($taxa{$_}->[1]);
	}
	# @{$taxa{taxon_label}} contains now taxon name, taxon specific map file, taxon specific map object
	
	my $ontology = CCO::Core::Ontology->new();
	
	# populate ontology
	$ontology->add_relationship_type_as_string('is_a', 'is_a');
	$ontology->add_relationship_type_as_string('belongs_to', 'belongs_to');
	
	my $protein = CCO::Core::Term->new();# upper level ontology term
	$protein->name('protein');
	$protein->id(assign_term_id($u_map, 'U', 'protein'));
	if ($u_map->contains_value('protein')) {
		$protein->id($u_map->get_cco_id_by_term('protein'));
	}else{
		$protein->id(assign_term_id($u_map, 'U', 'protein'));
	}
	$ontology->add_term($protein);
	
	foreach (keys %taxa) {
		my $taxon = CCO::Core::Term->new();
		my $taxon_lab = $_;
		my $tax_name = $taxa{$taxon_lab}->[0];
		$taxon->name($tax_name);
		$taxon->id(assign_term_id($t_map, 'T', $tax_name));
		$ontology->add_term($taxon);
		push @{$taxa{$taxon_lab}}, $taxon;
		#@{$taxa{$taxon_lab}} contains now taxon name, taxon specific map file, taxon specific map object, taxon term object
	}
	
	foreach (keys %clusters) {
		my $cluster = CCO::Core::Term->new();
		my $clust_num = $_;
		my $clust_name = "Orthology $_ protein";
		$cluster->name($clust_name);
		$cluster->id(assign_term_id($o_map, 'O', $clust_name));
		$cluster->def_as_string("A protein belonging to the orthology $_ produced by orthoMCL", "[CCO:vm]");
		$ontology->create_rel($cluster, 'is_a', $protein);
		foreach (keys %{$clusters{$clust_num}}) {# for each protein in the cluster
			my $prot_name = $_;
			my $taxon_lab = $clusters{$clust_num}{$prot_name};
			my $clust_protein = CCO::Core::Term->new();
			$clust_protein->name($prot_name);
			$clust_protein->id(assign_biomol_id($taxa{$taxon_lab}[2], $b_map, $prot_name));
			my $short_map = $taxa{$taxon_lab}[2];
			if ($short_map->contains_value($prot_name)) {
				$clust_protein->id($short_map->get_cco_id_by_term($prot_name));
			} else {
				$clust_protein->id(assign_biomol_id($short_map, $b_map, $prot_name));
			}
			$ontology->add_term($clust_protein);
			$ontology->create_rel($clust_protein, 'is_a', $cluster);
			$ontology->create_rel($clust_protein, 'belongs_to', $taxa{$taxon_lab}->[3]);
		}
	}
	

	
	# Write the new ontology and maps to disk
	open (my $FH, ">".$new_OBO_file) || die "Cannot write OBO file: ", $!;
	$ontology->export(\*$FH);
	close $FH;
	foreach ((keys %taxa)) {
		$taxa{$_}[2] -> write_map();
	}
	$b_map -> write_map();
	$o_map -> write_map();
	$t_map -> write_map();
	$u_map -> write_map();
	return $ontology;
}

#############################################################################################################
#
# sub assign_biomol_id
#
#############################################################################################################
sub assign_biomol_id {
	#used to obtain IDs for biomolecule terms 
	# arguments: taxon specific map (CCO::Util::CCO_ID_Term_Map object), cumulative map for all taxa, protein name
	my ($short_map, $long_map, $term_name) = @_;
	my $term_id;
	if ($short_map->contains_value($term_name)) {#look up first in the species specific map
		$term_id = $short_map->get_cco_id_by_term($term_name);
		return $term_id;
	} else {
		$term_id = $long_map->get_new_cco_id( "CCO", "B", $term_name );
		$short_map->put( $term_id, $term_name );#updates the species specific maps
		return  $term_id;
	}
}

#############################################################################################################
#
# sub assign_term_id
#
#############################################################################################################
sub assign_term_id {
	#used to obtain IDs for terms other than biomolecules
	#arguments: map (CCO::Util::CCO_ID_Term_Map object), subdomain (a single character [BOTU]), term name
	my ($map, $subdomain, $term_name) = @_;
	my $term_id;
	if ($map->contains_value($term_name)) {
		$term_id = $map->get_cco_id_by_term($term_name);
		return $term_id;
	}
	else {
		$term_id = $map->get_new_cco_id( "CCO", $subdomain, $term_name );
	}
}

1;