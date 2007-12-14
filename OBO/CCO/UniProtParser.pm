# $Id: UniProtParser.pm 1678 2007-12-03 12:51:11Z erant $
#
# Module  : UniProtParser.pm
# Purpose : Parse UniProt files and add data to an ontology
# License : Copyright (c) 2006 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#

package OBO::CCO::UniProtParser;

=head1 NAME

OBO::CCO::UniProtParser - A UniProt to OBO translator.

=head1 DESCRIPTION

Includes methods for adding information from UniProt files to ontologies

UniProt files can be obtained from ftp://ftp.expasy.org/databases/uniprot/knowledgebase/

The method 'work' incorporates relevant data from a UniProt file into the input ontology, writes the ontology into an OBO file, writes map files.
 
This method assumes: 

- the input ontology contains already the term 'gene', 'protein', 'modified protein'

- the input ontology already contains relevant protein terms. 

- the input ontology already contains the NCBI taxonomy. 

- the input ontology already contains the relationship types 'is_a', 'encoded_by', "belongs_to", "tranformation_of"

- the input UniProt file contains entries for one species only and for protein terms present in the input ontology only

- the full map file ($long_file_name, the UNION of the species specific map files ($short_file_name)) contains all the proteins to be processed by the UniProtParser 

=head1 AUTHOR


Vladimir Mironov
vlmir@psb.ugent.be

=head1 COPYRIGHT AND LICENSE


Copyright (C) 2006 by Vladimir Mironov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut

use OBO::Parser::OBOParser;
use OBO::Core::Relationship;
use OBO::Core::Dbxref;
use OBO::Util::DbxrefSet;
use OBO::Core::Term;
use OBO::Util::Set;
use OBO::CCO::CCO_ID_Term_Map;
use SWISS::Entry;

use strict;
use warnings;
use Carp;

sub new {
    my $class = $_[0];
    my $self  = {};

    bless( $self, $class );
    return $self;
}

=head2 work

  Usage    - $UniProtParser->work($ref_file_names, 'Arabidopsis thaliana organism')
  Returns  - updated OBO::Core::Ontology object 
  Args     - 1. reference to a list of filenames(input OBO file, output OBO file, UniProt file, CCO_id/protein_name map file one taxon only, CCO_id/protein_name map file all taxa), 2. taxon_name
  Function - parses a Uniprot file, adds relevant information to the input  ontology, writes OBO and map files 
  
=cut

sub work {
	my $self = $_[0];

	# Get the arguments
	my ( $old_OBO_file,   $new_OBO_file, $uniprot_file, $short_map_file, $long_map_file, $short_map_g_file, $long_map_g_file) = @{ $_[1] };
	my $taxon_name = $_[2];
    
	my %gene_name_sufix_by_taxon_name = (
		'Schizosaccharomyces pombe organism' => '_schpo',
		'Saccharomyces cerevisiae organism'  => '_yeast',
		'Arabidopsis thaliana organism'      => '_arath',
		'Homo sapiens organism'              => '_human' 
	);
	
	my $current_sufix = $gene_name_sufix_by_taxon_name{$taxon_name};

	# Initialize the OBO parser, load the OBO file, check the assumptions
	my $my_parser = OBO::Parser::OBOParser->new();
	my $ontology  = $my_parser->work($old_OBO_file);
	
	my @rel_types = ( 'is_a', 'belongs_to', 'encoded_by' );
	foreach (@rel_types) {
		confess "Not a valid relationship type (valid values: ", @rel_types, ")" unless ( $ontology->{RELATIONSHIP_TYPES}->{$_} );
	}
	
	my $taxon = $ontology->get_term_by_name($taxon_name) || die "No term for $taxon_name is defined in file '$old_OBO_file'";
	# TODO Connect the core cell cycle genes to 'core cell cycle gene'
	my $onto_gene = $ontology->get_term_by_name('cell cycle gene')  || die "No term for 'cell cycle gene' is defined in file '$old_OBO_file'";
	my @gene_dbs = ( 'EMBL', 'Ensemble', 'GeneDB_Spombe', 'HGNC', 'SGD', 'TAIR', 'UniGene' );

	# Initialize CCO_ID_Term_Map objects
	my $short_map = OBO::CCO::CCO_ID_Term_Map->new($short_map_file);
	my $long_map  = OBO::CCO::CCO_ID_Term_Map->new($long_map_file);        # Set of [B]iomolecules IDs

	my $short_map_g = OBO::CCO::CCO_ID_Term_Map->new($short_map_g_file);
	my $long_map_g  = OBO::CCO::CCO_ID_Term_Map->new($long_map_g_file);    # Set of Gene IDs
	
	# Parse the UniProt file
	open FH, $uniprot_file;
	local $/ = "\n//\n";
	while (<FH>) {    
		my $entry = SWISS::Entry->fromText($_);
		my ( $accession, @accs ) = @{ $entry->ACs->{list} };
		my ( $def,       @syns ) = @{ $entry->DEs->{list} };
		my $definition = $def->{text};

		#<<EASR
        # retrieve by the accession number the corresponding protein object from ontology if exists
        my $protein;
		my @all_acs = ( $accession, @accs );
		foreach my $ac (@all_acs) {
			$protein = $ontology->get_term_by_xref('UniProt', $ac);
			last if (defined $protein);
		}
		warn "None of the UniProt AC's (", join(", ", @all_acs),") were found in file '$old_OBO_file': ", $! if (!defined $protein);
		next if (!defined $protein);
		# Question: do we keep the $accession as the primary AC in our entries? (it is used many times below...)
		# NB: all the AC's should go to the xref field (see below)
		#>>EASR
          
		my $protein_name = $entry->ID;
        

		# add protein definition
		$protein->def_as_string( $definition, "UniProt:$accession" );

		# add secondary accessions
		foreach (@all_acs) {
			$protein->xref_set_as_string("[UniProt:$_]");
		}

		# add DB cross references to the protein
		my $dbxrefs = $entry->DRs;    # an object containing all DB cross-references
		my @pids = $dbxrefs->pids;  #an array containing EMBL protein accessions
		foreach (@pids) {
			$protein->xref_set_as_string("[EMBL:$_]");
		}

		# add synonyms to the protein
		foreach (@syns) {
			$protein->synonym_as_string( $_->{text}, "[UniProt:$accession]", 'EXACT' );
		}
		
		# <<EASR: add the is_a missing link for the proteins but core cycle ones
		my @heads = @{$ontology->get_head_by_relationship_type($protein, $ontology->get_relationship_type_by_name('is_a'))};
		my $link_found = 0;
		foreach my $head (@heads) {
			if ($head->name() eq 'core cell cycle protein') {
				$link_found = 1;
				last;
			}
		}
		if (!$link_found) { # assuming the term 'cell cycle protein' exists in the ontology
			my $cell_cycle_protein_term = $ontology->get_term_by_name("cell cycle protein"); # CCO:U0000007
			$ontology->create_rel( $protein, 'is_a', $cell_cycle_protein_term);
		}
		# >>EASR
		
		$ontology->create_rel( $protein, 'belongs_to', $taxon );

		# add post-translationally modified derivatives of the protein
		if(my @fts = @{$entry->FTs->{list}}){#an array of references to arrays corresponding to individual FT lines 
			foreach my $ft (@fts){
				# select only lines for modified residues
				$ft->[0] eq 'MOD_RES' ? 
				my ($feature_key, $from_position, $to_position, $description, $qualifier, $FTId, $evidence_tag) = @{$ft}:next; # go to the next FT line
				next unless $from_position eq $to_position; #this feature concerns only a single residue
				my ($mod_prot_name, $mod_prot_comment, $mod_prot_def);
				if ($description =~ /(\S+);\s*?(\S+.*)/) {#description contains the name of the modified residue separated by a colon from the rest
					my ($mod_residue, $comment) = ($1, $2);
					$mod_prot_name = $protein_name.'-'.$mod_residue.$from_position;
					$mod_prot_def = "Protein $protein_name with the residue $from_position substituted with $mod_residue";
					$mod_prot_comment = "$comment; $qualifier";
				} else {# $description contains only the name of the modified residue
					$mod_prot_name = $protein_name.'-'.$description.$from_position;
					$mod_prot_def = "Protein $protein_name with the residue $from_position substituted with $description";
					$mod_prot_comment = $qualifier if $qualifier;
        		}

				# assign modified protein ID
				my $mod_prot_id;
				if ( $short_map->contains_value($mod_prot_name) ) {
					$mod_prot_id = $short_map->get_cco_id_by_term($mod_prot_name);
				} else {
					$mod_prot_id = $long_map->get_new_cco_id( "CCO", "B", $mod_prot_name );
					$short_map->put( $mod_prot_id, $mod_prot_name ); #updates the species specific maps
				}       		

				# create protein terms for modified proteins and add to ontology
				my $mod_prot_obj = OBO::Core::Term->new();
				$mod_prot_obj->name($mod_prot_name);
				$mod_prot_obj->id($mod_prot_id);
				$mod_prot_obj->def_as_string($mod_prot_def, "[UniProt:$accession]");
				$mod_prot_obj->xref_set_as_string("[UniProt:$accession]");
				$mod_prot_obj->comment($mod_prot_comment);                
				$ontology->add_term($mod_prot_obj);

				$ontology->create_rel( $mod_prot_obj,    'belongs_to', $taxon );
				$ontology->create_rel( $mod_prot_obj,    'transformation_of', $protein );
				$ontology->create_rel( $mod_prot_obj,    'is_a', $ontology->get_term_by_name('modified protein') );	
			}
		}
        
		#create or retrieve gene terms
		my @gene_groups = @{ $entry->GNs->{list} };
		if ( scalar @gene_groups == 1 ) {      # there is only one gene associated with the protein
			my $gene_group = $gene_groups[0];
			my $gene_name;
			( $gene_name = ${ $gene_group->{Names}->{list} }[0]->{text} )
				|| ( $gene_name = ${ $gene_group->{OLN}->{list} }[0]->{text} )
				|| ( $gene_name = ${ $gene_group->{ORFNames}->{list} }[0]->{text} );
	
			$gene_name .= $current_sufix;
	
			my $gene;
			( $gene = $ontology->get_term_by_name($gene_name) )
				|| ( $gene = &new_gene( $gene_group, $short_map_g, $long_map_g, $accession, $definition, $current_sufix) );
	
			foreach my $db (@gene_dbs) {
				foreach my $xref ( @{ $dbxrefs->{list} } ) {
					$gene->xref_set_as_string("[$db:${$xref}[1]]") if ${$xref}[0] eq $db;
				}
			}
			$ontology->add_term($gene);
	
			# add relationtionships
			$ontology->create_rel( $gene,    'is_a',         $onto_gene );
			$ontology->create_rel( $protein, 'encoded_by',   $gene );
			$ontology->create_rel( $gene,    'belongs_to', $taxon );
		} elsif ( scalar @gene_groups > 1 ) {    # multiple genes associated with the protein
			foreach my $gene_group (@gene_groups) {
				my $gene_name;
				( $gene_name = ${ $gene_group->{Names}->{list} }[0]->{text} )
					|| ( $gene_name = ${ $gene_group->{OLN}->{list} }[0]->{text} )
					|| ( $gene_name = ${ $gene_group->{ORFNames}->{list} }[0]->{text} );

				$gene_name .= $current_sufix;

				my $gene;
				($gene = $ontology->get_term_by_name($gene_name))
					|| 
				($gene = &new_gene($gene_group, $short_map_g, $long_map_g, $accession,  $definition, $current_sufix));

				$ontology->add_term($gene);

				# add relationtionships
				$ontology->create_rel( $gene,    'is_a',         $onto_gene );
				$ontology->create_rel( $protein, 'encoded_by',   $gene );
				$ontology->create_rel( $gene,    'belongs_to', $taxon );
			}
		}
	}

	# Write the new ontology and maps to disk
	open( FH, ">" . $new_OBO_file ) || die "Cannot write OBO file ($new_OBO_file): ", $!;
	$ontology->export( \*FH );
	close FH;
    
	$short_map->write_map();
	$long_map->write_map();
	$short_map_g->write_map();
	$long_map_g->write_map();

	return $ontology;
}
#############################################################################################################
#
# sub new_gene generates a new gene term with ID, name, definition, synonyms
#
#############################################################################################################
sub new_gene {
	my ( $gene_group, $short_map, $long_map, $accession, $definition, $current_sufix ) = @_;
	my $gene = OBO::Core::Term->new();
	my $gene_name;
	foreach ( 'Names', 'OLN', 'ORFNames' ) {  # gene group object must contain at least one of the three types of names
		if ( my ( $name, @names ) = @{ $gene_group->{$_}->{list} } ) {    # list of gene name objects of one particular type
			# a bug in Swissknife (which version? 1.65?) - a list with a reference to an empty hash is returned instead of an empty array if the field 'Names' is empty
			if ( !$gene_name ) {    # this is the first existing name type to process
				$gene_name = $name->{text} || next;

				$gene_name .= $current_sufix;

				$gene->name($gene_name);

				# get CCO id for the gene
				if ( $short_map->contains_value($gene_name) ) {
					$gene->id( $short_map->get_cco_id_by_term($gene_name) );
				} else {
					my $gene_id = $long_map->get_new_cco_id( "CCO", "G", $gene_name );
					$gene->id($gene_id);
					$short_map->put( $gene_id, $gene_name );
				}
                
				if (@names) {    # if there are other names of this type
					foreach (@names) {
						$gene->synonym_as_string( $_->{text}, "[UniProt:$accession]", 'EXACT' );
					}
				}
			} else {   # the name has already been assigned from another name type
				foreach ( $name, @names ) {
					$gene->synonym_as_string( $_->{text}, "[UniProt:$accession]", 'EXACT' );
				}
			}
		}
	}

	# Add gene definition
	# Remark: if the gene is associated with multiple proteins the definition is derived from the first one
	# TODO take gene definitions from the original gene databases
	$definition =~ /^(\w+.* gene) protein/
		? $gene->def_as_string( $1,                  "UniProt:$accession" )
		: $gene->def_as_string( $definition.' gene', "UniProt:$accession" );

	return $gene;
}
1;