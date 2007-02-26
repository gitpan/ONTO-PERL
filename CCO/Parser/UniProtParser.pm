# $Id: UniProtParser.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : UniProtParser.pm
# Purpose : Parse UniProt files and add data to an ontology
# License : Copyright (c) 2006 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package CCO::Parser::UniProtParser;

use CCO::Parser::OBOParser;
use CCO::Core::Relationship;
use CCO::Core::Dbxref;
use CCO::Util::DbxrefSet;
use CCO::Core::Term;
use CCO::Util::Set;
use CCO::Util::CCO_ID_Term_Map; 
use SWISS::Entry;

use strict;
use warnings;
use Carp;

sub new {
	my $class                   = shift;
	my $self                    = {}; 
	
	bless ($self, $class);
	return $self;
}



=head2 work

  Usage    - $UniProtParser->work($ref_file_names, 'Arabidopsis thaliana organism')
  Returns  - updated CCO::Core::Ontology object 
  Args     - 1. reference to a list of filenames(input OBO file, output OBO file, UniProt file, CCO_id/protein_name map file one taxon only, CCO_id/protein_name map file all taxa), 2. taxon_name
  Function - parses a Uniprot file, adds relevant information to the input  ontology, writes OBO and map files 
  
=cut
sub work {
	my $self = shift;

	# Get the arguments
	my ($old_OBO_file, $new_OBO_file, $uniprot_file, $short_map_file, $long_map_file) = @{shift @_}; 
	my $taxon_name = shift; 
	# Initialize the OBO parser, load the OBO file, check the assumptions
	my $my_parser = CCO::Parser::OBOParser->new();
	my $ontology = $my_parser->work($old_OBO_file);
	my @rel_types = ('is_a', 'derives_from', 'encoded_by');
	foreach (@rel_types){
		die "Not a valid relationship type (valid values: ", @rel_types, ")" unless($ontology->{RELATIONSHIP_TYPES}->{$_});
	}
	my $taxon = $ontology->get_term_by_name($taxon_name) || die "No term for $taxon_name is defined in file '$old_OBO_file'";
	my $gene = $ontology->get_term_by_name('gene') || die "No term for 'gene' is defined in file '$old_OBO_file'";
	my @gene_dbs = ('EMBL','Ensemble','GeneDB_Spombe','HGNC','SGD','TAIR','UniGene');
	
	# Initialize CCO_ID_Map objects
	my $short_map = CCO::Util::CCO_ID_Term_Map->new($short_map_file); 
	my $long_map = CCO::Util::CCO_ID_Term_Map -> new ($long_map_file); # Set of [B]iomolecules IDs
	
	# parse the UniProt file
	open FH, $uniprot_file;
	local $/ = "\n//\n";
	while(<FH>){
		my $entry = SWISS::Entry->fromText($_);
		my $protein_name = $entry->ID; 
		my $accession = $entry->AC;
		my @descriptions = @{$entry->DEs->{list}};
		my $definition = ${shift @descriptions}{text}; #print "$def\n";
		# retrieve the corresponding protein object from ontology if exists
		my $protein = $ontology->get_term_by_name($protein_name) or die "The protein name $protein_name does not exist in file '$old_OBO_file':", $!; 
		
		# add protein definition 
		$protein->def_as_string($definition, "UniProt:$accession");
		
		
		# add DB cross references to the protein
		my $dbxrefs = $entry->DRs; # an object containing all DB cross-references
		my @pids = $dbxrefs->pids; #an array containing EMBL protein accessions
		foreach (@pids) {
			$protein->xref_set_as_string("[EMBL:$_]");
		}
		
		# add synonyms to the protein
		foreach (@descriptions) {
			$protein->synonym_as_string($_->{text}, "[UniProt:$accession]", 'EXACT');
		}		
		
		#create gene terms
		my @gene_groups = @{$entry->GNs->{list}};
		if (scalar @gene_groups == 1) {
			my $gene_group = shift @gene_groups;
			my $new_gene = &new_gene($gene_group,$short_map,$long_map,$accession,$definition);
			foreach my $db (@gene_dbs) {
				foreach my $xref (@{$dbxrefs->{list}}) {
					$new_gene->xref_set_as_string("[$db:${$xref}[1]]") if ${$xref}[0] eq $db;
				}
			}
			$ontology->add_term($new_gene);
			
			# add relationtionships 
			$ontology->create_rel($new_gene, 'is_a', $gene);
			$ontology->create_rel($protein, 'encoded_by', $new_gene);
			$ontology->create_rel($new_gene, 'derives_from', $taxon);		
			
		} elsif (scalar @gene_groups > 1) {
			foreach my $gene_group (@gene_groups) {
				my $new_gene = &new_gene($gene_group,$short_map,$long_map,$accession,$definition);				
				$ontology->add_term($new_gene);
				
				# add relationtionships 
				$ontology->create_rel($new_gene, 'is_a', $gene);
				$ontology->create_rel($protein, 'encoded_by', $new_gene);
				$ontology->create_rel($new_gene, 'derives_from', $taxon);
			}
		}
	}
	
	# Write the new ontology and map to disk
	open (FH, ">".$new_OBO_file) || die "Cannot write OBO file ($new_OBO_file): ", $!;
	$ontology->export(\*FH);
	close FH;
	$short_map -> write_map(); 
	$long_map -> write_map(); 
	return $ontology;
}

#############################################################################################################
#
# sub new_gene generates a new gene term with ID, name, definition, synonyms 
#
#############################################################################################################

sub new_gene {
	my ($gene_group,$short_map,$long_map,$accession,$definition) = @_;
	my $new_gene = CCO::Core::Term->new();
	my $new_gene_name;
	my $synonym_set = CCO::Util::SynonymSet->new();
	foreach ('Names', 'OLN', 'ORFNames') {		
		if (my @list = @{$gene_group->{$_}->{list}}) {
			if (!$new_gene_name) {
				my $gn = shift @list; 
				$new_gene_name = $gn->{text};
				$new_gene->name($new_gene_name); 			
				if ($short_map->contains_value($new_gene_name)){
					$new_gene->id($short_map->get_cco_id_by_term($new_gene_name));
				} elsif ($long_map->contains_value($new_gene_name)){
	               $new_gene->id($long_map->get_cco_id_by_term($new_gene_name));
	               $short_map->put($new_gene->id(), $new_gene_name);
				}else {
					my $new_gene_id = $long_map->get_new_cco_id("CCO", "B", $new_gene_name);
					$new_gene->id($new_gene_id);
					$short_map->put($new_gene_id, $new_gene_name); # TRICK to add the IDs in the other file
				}											
			}					
			if (@list) {						
				foreach (@list) {				
					$new_gene->synonym_as_string($_->{text}, "[UniProt:$accession]", 'EXACT');							
				}						
			}
		}				
	}
	
	# add gene definition
	$definition =~ /^(\w+.* gene) protein/ ? $new_gene->def_as_string($1, "UniProt:$accession") : $new_gene->def_as_string($definition.' gene', "UniProt:$accession");
	return $new_gene;
}

1;
	
=head1 NAME

    CCO::Parser::UniProtParser - A UniProt to OBO translator.

=head1 DESCRIPTION

Includes methods for adding information from UniProt files to ontologies

UniProt files can be obtained from ftp://ftp.expasy.org/databases/uniprot/knowledgebase/

The method 'work' incorporates relevant data from a UniProt file into the input ontology, writes the ontology into an OBO file, writes map files.
 
Assumptions: 

- the ontology contains already the term 'gene'

- the ontology already contains relevant protein terms. 

- the ontology already contains the NCBI taxonomy. 

- the ontology already contains the relationship types 'is_a', 'encoded_by', "derives_from"

- the input UniProt file contains entries for one species only and for protein terms present in the input ontology only

- all the entries in the species specific map file ($short_file_name) are present as well in the full map file ($long_file_name)

=head1 AUTHOR


Vladimir Mironov
vlmir@psb.ugent.be

=head1 COPYRIGHT AND LICENSE


Copyright (C) 2006 by Vladimir Mironov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
