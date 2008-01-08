# $Id: GoaParser.pm 1844 2008-01-08 12:30:37Z erant $
#
# Module  : GoaParser.pm
# Purpose : Parse GOA files
# License : Copyright (c) 2006, 2007, 2008 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#

package OBO::CCO::GoaParser;

=head1 NAME

OBO::CCO::GoaParser - A GOA associations to OBO translator.

=head1 DESCRIPTION

Includes methods for adding information from GOA association files to ontologies
GOA associations files can be obtained from http://www.ebi.ac.uk/GOA/proteomes.html

The method 'parse' parses the GOA association file and returns a OBO::CCO::GoaAssociationSet object

The method 'work' incorporates OBJ_SRC, OBJ_ID, OBJ_SYMB, SYNONYM, DESCRIPTION into the input ontology, writes the ontology into an OBO file, writes map files.
This method assumes: 
1. the ontology contains already the term 'protein'
2. the ontology already contains all and only the necessary GO terms. 
3. the ontology already contains the relationship types 'is_a', 'participates_in', 'has_participant'
4. the input GOA association file contains entries for one species only and for GO terms present in the input ontology only

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
use OBO::Core::Term;
use OBO::Core::GoaAssociation;
use OBO::CCO::CCO_ID_Term_Map;
use OBO::Util::DbxrefSet;
use OBO::CCO::GoaAssociationSet;
use OBO::Util::Set;
use Data::Dumper;
use strict;
use warnings;
use Carp;

sub new {
	my $class                   = shift;
	my $self                    = {}; 
	
	bless ($self, $class);
	return $self;
}

=head2 parse

  Usage    - $GoaParser->parse(GOA_association_file)
  Returns  - An OBO::CCO::GoaAssociationSet object
  Args     - GOA associations file
  Function - converts a GOA associations file into a OBO::CCO::GoaAssociationSet object
  
=cut

sub parse {
	my $self = shift;

	# Get the argument
	my $goaAssocFileName = shift;	
	
	my $goaAssocSet = OBO::CCO::GoaAssociationSet->new();
	
	# Open the assoc file
	open(FH, $goaAssocFileName) || die("Cannot open file '$goaAssocFileName': $!");
	
	# Populate the OBO::CCO::GoaAssociationSet class with objects
	while(<FH>){
		chomp;
		$_ =~ /^\w/ ? my $goaAssoc = OBO::Core::GoaAssociation->new() : next;	
		@_ = split(/\t/);
		foreach(@_){
			$_ =~ s/^\s+//; 
			$_ =~ s/\s+$//;
		}
		$goaAssoc->assc_id($.);
		$goaAssoc->obj_src($_[0]);
        $goaAssoc->obj_id($_[1]);
        $goaAssoc->obj_symb($_[2]);
        $goaAssoc->qualifier($_[3]);
        $goaAssoc->go_id($_[4]); 
        $goaAssoc->refer($_[5]);
        $goaAssoc->evid_code($_[6]);
        $goaAssoc->sup_ref($_[7]);
        $goaAssoc->aspect($_[8]);
        $goaAssoc->description($_[9]);
        $goaAssoc->synonym($_[10]);
        $goaAssoc->type($_[11]);
        $goaAssoc->taxon($_[12]);
        $goaAssoc->date($_[13]);
        $goaAssoc->annot_src($_[14]);
		
		$goaAssocSet ->add($goaAssoc);
	}
	close FH;
	return $goaAssocSet;
}

=head2 work

  Usage    - $GoaParser->work($ref_file_names)
  Returns  - updated OBO::Core::Ontology object 
  Args     - reference to a list of filenames(input OBO file, output OBO file, GOA associations file, CCO_id/Uniprot_id map file one taxon only, CCO_id/Uniprot_id map file all taxa)
  Function - parses a GOA associations file, adds relevant information to the input  ontology, writes OBO and map files 
  
=cut

sub work {
	my $self = shift;

	# Get the arguments
	my ($old_OBO_file, $new_OBO_file, $goa_assoc_file, $short_map_file, $long_map_file, $up_map_file) = @{shift @_}; 
	
	# Initialize the OBO parser, load the OBO file, check the assumptions
	my $my_parser = OBO::Parser::OBOParser->new();
	my $ontology = $my_parser->work($old_OBO_file);
	
	# rels
	my $is_a            = 'is_a';
	
	my $participates_in = 'participates_in';
	my $has_participant = 'has_participant';
	
	my $located_in      = 'located_in';
	my $location_of     = 'location_of';
	
	# rel existency check
	foreach (($is_a, $participates_in, $has_participant, $located_in, $location_of)){
		die "Not a valid relationship type" unless($ontology->{RELATIONSHIP_TYPES}->{$_});
	}
	
#	my $taxon = $ontology->get_term_by_name($taxon_name) || die "the term $taxon_name is not defined", $!;
	my $name_of_parent_of_the_new_proteins = 'core cell cycle protein';
	my $onto_protein = $ontology->get_term_by_name($name_of_parent_of_the_new_proteins) || confess "The term '", $name_of_parent_of_the_new_proteins, "' is not defined", $!;
	
	# Initialize CCO_ID_Map objects
	my $short_map = OBO::CCO::CCO_ID_Term_Map->new($short_map_file); 
	my $long_map  = OBO::CCO::CCO_ID_Term_Map->new($long_map_file); # Set of Protein IDs	
	
	# Read UniProt map file (keys - accession numbers, values - protein IDs)
	open my $fh, '<', $up_map_file
	  or croak "Can't open file '$up_map_file' : $!";
	my %up_map;
	while (<$fh>) {
		my ( $acc, $name ) = split( /\t/, $_ );
		chomp $acc;
		chomp $name;
		$up_map{$acc} = $name;
	}
	close $fh;
	
	
	# parse the GOA associations file
	my $goa_parser = OBO::CCO::GoaParser->new();
	my $goa_assoc_set = $goa_parser->parse($goa_assoc_file); 
	foreach my $goaAssoc (@{$goa_assoc_set->{SET}}){
		my $db = $goaAssoc->obj_src();
		my $acc = $goaAssoc->obj_id();
		my $protein_name = $goaAssoc->obj_symb();
		my $up_prot_name = $up_map{$acc}; 
		my $protein = $ontology->get_term_by_xref($db, $acc);
		
		# updata protein name if necessary
		my $depric_prot_name;
		if (( $up_prot_name) && ($protein_name ne $up_prot_name)) {
			$depric_prot_name = $protein_name;
			$protein_name = $up_prot_name ;
			my $cco_id = $short_map->get_cco_id_by_term($depric_prot_name);
#			my $cco_id = $protein->id();
			$short_map->put( $cco_id, $up_prot_name );
			$long_map->put( $cco_id, $up_prot_name  );
			
		}
#		defined $up_prot_name ? $protein_name = $up_prot_name : warn "the accession $acc not found in the UniProt map file $up_map_file\n";
		
		# create  a  new protein object
		if (!defined $protein) {
			# create new protein term 
			$protein = OBO::Core::Term->new(); 
			$protein->name($protein_name); 
			# create xref's
			$protein->xref_set_as_string("[$db:$acc]"); # cross-reference to UniProt
			# assign a CCO protein id
			if ($short_map->contains_value($protein_name)){
				$protein->id($short_map->get_cco_id_by_term($protein_name));
			} else {
				my $new_protein_id = $long_map->get_new_cco_id("CCO", "B", $protein_name);
				$protein->id($new_protein_id);
				$short_map->put($new_protein_id, $protein_name); # TRICK to add the IDs in the other file
			}
			
			$ontology->add_term($protein);
			
			# add "new protein is_a protein"
			confess "The following protein is missing: '", $name_of_parent_of_the_new_proteins, "'" if (!defined $onto_protein);
			$ontology->create_rel($protein, $is_a, $onto_protein);
			
		}
		
		# add relatioships with GO terms 
		my $id = $goaAssoc->go_id();
		my $aspect = $goaAssoc->aspect();
		my $prefix = 'CCO:'.$aspect; 
		$id =~ s/GO:/$prefix/;
		my $cco_go_term = $ontology->get_term_by_id($id);
		
		if (!defined $cco_go_term){
			warn "The following term is missing: '", $id, "'";
			next;
		}
		
		if ($aspect eq 'P') {
			$ontology->create_rel($protein,     $participates_in, $cco_go_term);
			$ontology->create_rel($cco_go_term, $has_participant, $protein); # inverse of 'participates_in'			
		} elsif ($aspect eq 'C') {
			$ontology->create_rel($protein,     $located_in,  $cco_go_term);
			$ontology->create_rel($cco_go_term, $location_of, $protein); # inverse of 'located_in'
		} elsif ($aspect eq 'F') {
			# TODO add the 'F' data
			#$ontology->create_rel($protein, $acts_in, $cco_go_term);
		}
	}
	
	# Write the new ontology and map to disk
	open (FH, ">".$new_OBO_file) || die "Cannot write OBO file: ", $!;
	$ontology->export(\*FH);
	close FH;
	$short_map -> write_map(); 
	$long_map -> write_map(); 
	return $ontology;
}
1;