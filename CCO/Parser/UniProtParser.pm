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
	my $class                   = $_[0];
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
	my $self = $_[0];

	# Get the arguments
	my ($old_OBO_file, $new_OBO_file, $uniprot_file, $short_map_file, $long_map_file) = @{$_[1]}; 
	my $taxon_name = $_[2]; 
	# Initialize the OBO parser, load the OBO file, check the assumptions
	my $my_parser = CCO::Parser::OBOParser->new();
	my $ontology = $my_parser->work($old_OBO_file);
	my @rel_types = ('is_a', 'derives_from', 'encoded_by');
	foreach (@rel_types){
		die "Not a valid relationship type (valid values: ", @rel_types, ")" unless($ontology->{RELATIONSHIP_TYPES}->{$_});
	}
	my $taxon = $ontology->get_term_by_name($taxon_name) || die "No term for $taxon_name is defined in file '$old_OBO_file'";
	my $onto_gene = $ontology->get_term_by_name('gene') || die "No term for 'gene' is defined in file '$old_OBO_file'";
	my @gene_dbs = ('EMBL','Ensemble','GeneDB_Spombe','HGNC','SGD','TAIR','UniGene');
	
	# Initialize CCO_ID_Map objects
	my $short_map = CCO::Util::CCO_ID_Term_Map->new($short_map_file); 
	my $long_map = CCO::Util::CCO_ID_Term_Map -> new ($long_map_file); # Set of [B]iomolecules IDs
	
	# parse the UniProt file
	open FH, $uniprot_file;
	local $/ = "\n//\n";
	while(<FH>){
		my $entry = SWISS::Entry->fromText($_);
		my ($accession, @accs) = @{$entry->ACs->{list}};
		my ($def, @syns) = @{$entry->DEs->{list}};
		my $definition = $def->{text};
		# retrieve the corresponding protein object from ontology if exists
		my $protein = $ontology->get_term_by_xref('UniProt', $accession) or die "UniProt accession $accession not found in file '$old_OBO_file':", $!; 
		$protein->name($entry->ID);
		# add protein definition 
		$protein->def_as_string($definition, "UniProt:$accession");
		
		# add secondary accessions
		if (@accs) {
			foreach (@accs) {
				$protein->xref_set_as_string("[UniProt:$_]");
			}
		}
		# add DB cross references to the protein
		my $dbxrefs = $entry->DRs; # an object containing all DB cross-references
		my @pids = $dbxrefs->pids; #an array containing EMBL protein accessions
		foreach (@pids) {
			$protein->xref_set_as_string("[EMBL:$_]");
		}
		
		# add synonyms to the protein
		foreach (@syns) {
			$protein->synonym_as_string($_->{text}, "[UniProt:$accession]", 'EXACT');
		}		
		
		#create or retrieve gene terms
		my @gene_groups = @{$entry->GNs->{list}};
		if (scalar @gene_groups == 1) { # there is only one gene associated with the protein
			my $gene_group = $gene_groups[0];
			my $gene_name;
			($gene_name = ${$gene_group->{Names}->{list}}[0]->{text}) || ($gene_name = ${$gene_group->{OLN}->{list}}[0]->{text}) || ($gene_name = ${$gene_group->{ORFNames}->{list}}[0]->{text});
			my $gene;
			($gene = $ontology->get_term_by_name($gene_name)) || ($gene = &new_gene($gene_group,$short_map,$long_map,$accession,$definition));
			
			foreach my $db (@gene_dbs) {
				foreach my $xref (@{$dbxrefs->{list}}) {
					$gene->xref_set_as_string("[$db:${$xref}[1]]") if ${$xref}[0] eq $db;
				}
			}
			$ontology->add_term($gene);
			
			# add relationtionships 
			$ontology->create_rel($gene, 'is_a', $onto_gene);
			$ontology->create_rel($protein, 'encoded_by', $gene);
			$ontology->create_rel($gene, 'derives_from', $taxon);		
			
		} elsif (scalar @gene_groups > 1) { # multiple genes associated with the protein
			foreach my $gene_group (@gene_groups) {
				my $gene_name;
				($gene_name = ${$gene_group->{Names}->{list}}[0]->{text}) || ($gene_name = ${$gene_group->{OLN}->{list}}[0]->{text}) || ($gene_name = ${$gene_group->{ORFNames}->{list}}[0]->{text});
				my $gene;
				($gene = $ontology->get_term_by_name($gene_name)) || ($gene = &new_gene($gene_group,$short_map,$long_map,$accession,$definition));
				
				$ontology->add_term($gene);
				
				# add relationtionships 
				$ontology->create_rel($gene, 'is_a', $onto_gene);
				$ontology->create_rel($protein, 'encoded_by', $gene);
				$ontology->create_rel($gene, 'derives_from', $taxon);
			}
		}
	}
	
	# Write the new ontology and maps to disk
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
	my $gene = CCO::Core::Term->new();
	my $gene_name;
	foreach ('Names', 'OLN', 'ORFNames') {# gene group object must contain at least one of the three types of names	
		if (my ($name, @names) = @{$gene_group->{$_}->{list}}) {# list of gene name objects of one particular type
			if (!$gene_name) { # this is the first existing name type to process
				$gene_name = $name->{text} || next;#a bug in Swissnife - an empty hash is returned instead of an empty array if the field 'Names' is empty
				$gene->name($gene_name); 
				
				#get CCO id for the gene			
				if ($short_map->contains_value($gene_name)){
					$gene->id($short_map->get_cco_id_by_term($gene_name));
				}else {
					my $gene_id = $long_map->get_new_cco_id("CCO", "B", $gene_name);
					$gene->id($gene_id);
					$short_map->put($gene_id, $gene_name); # TRICK to add the IDs in the other file
					
				}
				if (@names) { # if there are other names of this type						
					foreach (@names) {				
						$gene->synonym_as_string($_->{text}, "[UniProt:$accession]", 'EXACT');							
					}						
				}
			} else { # the name has already been assigned from another name type
				foreach ($name, @names) {				
					$gene->synonym_as_string($_->{text}, "[UniProt:$accession]", 'EXACT');							
				}
			}			
		}
	}	
	# add gene definition
	#TODO take gene definitions from the original gene databases
	#if the gene is associated with multiple proteins the definition is derived from the first one 
	$definition =~ /^(\w+.* gene) protein/ ? $gene->def_as_string($1, "UniProt:$accession") : $gene->def_as_string($definition.' gene', "UniProt:$accession");
	return $gene;
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
