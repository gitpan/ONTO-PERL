# $Id: GoaParser.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : GoaParser.pm
# Purpose : Parse GOA files
# License : Copyright (c) 2006 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package CCO::Parser::GoaParser;

use CCO::Parser::OBOParser;

use CCO::Core::Relationship;
use CCO::Core::Dbxref;
use CCO::Core::Term;
use CCO::Core::GoaAssociation;

use CCO::Util::CCO_ID_Term_Map;
use CCO::Util::DbxrefSet;
use CCO::Util::GoaAssociationSet;
use CCO::Util::Set;

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

  Usage    - $GoaParser->parse()
  Returns  - An CCO::Util::GoaAssociationSet object
  Args     - GOA associations file
  Function - converts a GOA associations file into a CCO::Util::GoaAssociationSet object
  
=cut

# TODO make faster, currently very slow. The major culprit is the method CCO::Core::GoaAssociation::equals
sub parse {
	my $self = shift;

	# Get the arguments
	my $goaAssocFileName = shift;
	
	my $goaAssocSet = CCO::Util::GoaAssociationSet->new();
	
	# Open the assoc file
	open(FH, $goaAssocFileName) || die("Cannot open file '$goaAssocFileName': $!");
	
	# Populate the CCO::Util::GoaAssociationSet object
	while(<FH>){
		chomp;
		$_ =~ /^\w/ ? my $goaAssoc = CCO::Core::GoaAssociation->new() : next;	
		@_ = split(/\t/);
		foreach(@_){
			$_ =~ s/^\s+//; 
			$_ =~ s/\s+$//;
		}
		$goaAssoc->assc_id($.);
		$goaAssoc->obj_src(shift @_);
        $goaAssoc->obj_id(shift @_);
        $goaAssoc->obj_symb(shift @_);
        $goaAssoc->qualifier(shift @_);
        $goaAssoc->go_id(shift @_); 
        $goaAssoc->refer(shift @_);
        $goaAssoc->evid_code(shift @_);
        $goaAssoc->sup_ref(shift @_);
        $goaAssoc->aspect(shift @_);
        $goaAssoc->description(shift @_);
        $goaAssoc->synonym(shift @_);
        $goaAssoc->type(shift @_);
        $goaAssoc->taxon(shift @_);
        $goaAssoc->date(shift @_);
        $goaAssoc->annot_src(shift @_);
		
		$goaAssocSet ->add($goaAssoc);
	}
	close FH;
	return $goaAssocSet;
}

=head2 work

  Usage    - $GoaParser->work($ref_file_names, 'Arabidopsis thaliana organism')
  Returns  - updated CCO::Core::Ontology object 
  Args     - 1. reference to a list of filenames(input OBO file, output OBO file, GOA associations file, CCO_id/Uniprot_id map file one taxon only, CCO_id/Uniprot_id map file all taxa), 2. taxon_name
  Function - parses a GOA associations file, adds relevant information to the input  ontology, writes OBO and map files 
  
=cut
sub work {
	my $self = shift;

	# Get the arguments
	my ($old_OBO_file, $new_OBO_file, $goa_assoc_file, $short_map_file, $long_map_file) = @{shift @_}; 
	my $taxon = shift;
	
	# Initialize the OBO parser, load the OBO file, check the assumptions
	my $my_parser = CCO::Parser::OBOParser->new();
	my $ontology = $my_parser->work($old_OBO_file);
	die "the term 'protein' is not defined" unless (defined $ontology->get_term_by_name('protein')) ;
	my @rel_types = ('is_a', 'participates_in', 'derives_from');
	foreach (@rel_types){
		die "Not a valid relationship type" unless($ontology->{RELATIONSHIP_TYPES}->{$_});
	}
	die "the term $taxon is not defined" unless (defined $ontology->get_term_by_name($taxon)) ;
	
	# Initialize CCO_ID_Map objects
	my $short_map = CCO::Util::CCO_ID_Term_Map->new($short_map_file); 
	my $long_map  = CCO::Util::CCO_ID_Term_Map->new($long_map_file); # Set of [B]iomolecules IDs
	
	# parse the GOA associations file
	my $goa_parser = CCO::Parser::GoaParser->new();
	my $goa_assoc_set = $goa_parser->parse($goa_assoc_file); 
	foreach my $goaAssoc (@{$goa_assoc_set->{SET}}){
		
		# retrieve the protein object from ontology if exists
		my $protein_name = $goaAssoc->obj_symb();
		my $protein = $ontology->get_term_by_name($protein_name); 
		if (!defined $protein) {
			# create new protein term and relationships 
			$protein = CCO::Core::Term->new(); 
			$protein->name($protein_name); 
			
			if ($short_map->contains_value($protein_name)){
				$protein->id($short_map->get_cco_id_by_term($protein_name));
			} elsif ($long_map->contains_value($protein_name)){
               $protein->id($long_map->get_cco_id_by_term($protein_name));
               $short_map->put($protein->id(), $protein_name);
			}else {
				my $new_protein_id = $long_map->get_new_cco_id("CCO", "B", $protein_name);
				$protein->id($new_protein_id);
				$short_map->put($new_protein_id, $protein_name); # TRICK to add the IDs in the other file
			}
			# create xref's
			my $xref_set = CCO::Util::DbxrefSet->new();
			# create xref to UniProt
			my $xref1 = CCO::Core::Dbxref->new();
			$xref1->db($goaAssoc->obj_src());
			$xref1->acc($goaAssoc->obj_id());
			$xref_set->add($xref1);
			
			# create xref to IPI (taken from the field SYNONYM)
			my $xref2 = CCO::Core::Dbxref->new();
			if ($xref2->acc($goaAssoc->synonym())) {
				$xref2->db('IPI');		
				$xref_set->add($xref2);						
			}
			$protein->xref_set($xref_set);
			
			# create definition
			my $def = CCO::Core::Def->new(); 
			my @desc = split ': ', $goaAssoc->description();
			$def->text(pop @desc); 
			my $dbxref_set = CCO::Util::DbxrefSet->new(); 
			my $dbxref = CCO::Core::Dbxref->new(); 
			$dbxref->db($goaAssoc->obj_src()); 
			$dbxref->acc($goaAssoc->obj_id()); 
			$dbxref_set ->add($dbxref); 
			$def->dbxref_set($dbxref_set); 
			$protein->def($def); 
			
			$ontology->add_term($protein);
			
			# add "new protein is_a protein"
			#$ontology = &add_rel($ontology, $protein, $ontology->get_term_by_name("protein"), "is_a");
			my $rel1 = CCO::Core::Relationship->new(); 
			my($head, $type) = ($ontology->get_term_by_name("protein"), "is_a");
			$rel1->type($type);
			$rel1->link($protein,$head);
			$rel1->id($protein->id()."_".$type."_".$head->id());
			$ontology->add_relationship($rel1);		
			
			# add "new protein derives_from species" 
			(my $cco_taxon_term = $ontology->get_term_by_name($taxon)) || die ("taxon mame: ",$taxon," doesn't exist");
			#$ontology = &add_rel($ontology, $protein, $cco_taxon_term, "derives_from");
			my $rel2 = CCO::Core::Relationship->new(); 
			($head, $type) = ($cco_taxon_term, "derives_from");
			$rel2->type($type);
			$rel2->link($protein,$head);
			$rel2->id($protein->id()."_".$type."_".$head->id());
			$ontology->add_relationship($rel2);
		}
		
		# add "new protein participates_in GO process"
		my $rel3 = CCO::Core::Relationship->new(); 
		my $id = $goaAssoc->go_id();
		my $prefix = 'CCO:'.$goaAssoc->aspect(); 
		$id =~ s/GO:/$prefix/; 
		my $cco_go_term=$ontology->get_term_by_id($id); 
		#$ontology = &add_rel($ontology, $protein, $cco_go_term, "participates_in");
		my ($head, $type) = ($cco_go_term, "participates_in");
		$rel3->type($type);
		$rel3->link($protein,$head);
		$rel3->id($protein->id()."_".$type."_".$head->id());
		$ontology->add_relationship($rel3);	
		
	}
	
	# Write the new ontology and map to disk
	open (FH, ">".$new_OBO_file) || die "Cannot write OBO file: ", $!;
	$ontology->export(\*FH);
	close FH;
	$short_map -> write_map($short_map_file); 
	$long_map -> write_map($long_map_file); 
	return $ontology;
}
################################################################################
#
# Subroutines
#
################################################################################
#
# create a new CCO::Core::Synonym object and fill in information from a CCO::Core::GoaAssociation object
# argument: a CCO::Util::GoaAssociation object
#
################################################################################
# TODO erase this method and move the code up
# Synonym is either the IPI id or none
#sub create_synonym (){
#	if (@_) {
#		my $goaAssoc = shift; 
#		my $synonym = CCO::Core::Synonym->new(); 
#		$synonym ->type('EXACT'); 
#		my $def = CCO::Core::Def->new(); 
#		$def->text($goaAssoc->synonym()); 
#		my $dbxref_set = CCO::Util::DbxrefSet->new(); 
#		my $dbxref = CCO::Core::Dbxref->new(); 
#		$dbxref->db('IPI'); 
#		$dbxref->acc($goaAssoc->synonym()); 
#		$dbxref_set ->add($dbxref); 
#		$def -> dbxref_set($dbxref_set); 
#		$synonym -> def($def); 
#		return $synonym;
#	} 
#}
################################################################################
#
# Add a relationship to ontology
# Arguments: ontology object, tail object, head object, relationship type (string)
#
################################################################################
#sub add_rel (){
#	my($ontology, $tail, $head, $type) = @_;
#	die "Ontology must be a CCO::Core::Ontology object" unless (UNIVERSAL::isa($ontology, 'CCO::Core::Ontology'));
#	die "Tail must be a CCO::Core::Term or CCO::Core::Relationship object" unless (UNIVERSAL::isa($tail, 'CCO::Core::Term') || UNIVERSAL::isa($tail, 'CCO::Core::Relationship'));
#	die "Head must be a CCO::Core::Term or CCO::Core::Relationship object" unless (UNIVERSAL::isa($head, 'CCO::Core::Term') || UNIVERSAL::isa($head, 'CCO::Core::Relationship'));
#	die "Not a valid relationship type" unless($ontology->{RELATIONSHIP_TYPES}->{$type});
#	my $rel = CCO::Core::Relationship->new(); 
#	$rel->type($type);
#	$rel->link($tail,$head);
#	$rel->id($tail->id()."_".$type."_".$head->id());
#	$ontology->add_relationship($rel);
#	return $ontology;
#}

1;

	
=head1 NAME

    CCO::Parser::GoaParser - A GOA associations to OBO translator.

=head1 DESCRIPTION

Includes methods for adding information from GOA association files to ontologies
GOA associations files can be obtained from http://www.ebi.ac.uk/GOA/proteomes.html

The method 'parse' parses the GOA association file and returns a CCO::Util::GoaAssociationSet object

The method 'work' incorporates OBJ_SRC, OBJ_ID, OBJ_SYMB, SYNONYM, DESCRIPTION into the input ontology, writes the ontology into an OBO file, writes map files.
 
Assumptions: 
1. the ontology contains already the term 'protein'
2. the ontology already contains all and only the necessary GO terms. 
3. the ontology already contains the NCBI taxonomy. 
4. the ontology already contains the relationship types 'is_a', 'participates_in', "derives_from"
5. the input GOA association file contains entries for one species only and for GO terms present in the input ontology only


=head1 AUTHOR


Vladimir Mironov
vlmir@psb.ugent.be

=head1 COPYRIGHT AND LICENSE


Copyright (C) 2006 by Vladimir Mironov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
