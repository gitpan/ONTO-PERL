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
#
# TODO update the sub's documentation
#
BEGIN{
	push @INC, '../cco/scripts/pipeline'; 
}
use CCO::Parser::OBOParser;
use CCO::Core::Relationship;
use CCO::Core::Dbxref;
use CCO::Util::DbxrefSet;
use CCO::Core::Term;
use CCO::Core::GoaAssociation;
use CCO::Util::GoaAssociationSet;
use CCO::Util::Set;
use CCO_ID_Term_Map; 

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

# TODO make faster, currently very slow
sub parse {
	my $self = shift;

	# Get the arguments
	my $goaAssocFileName = shift;
	
	my $goaAssocSet = CCO::Util::GoaAssociationSet->new();
	
	# Open the assoc file
	open(FH, $goaAssocFileName) || die("can't open file: $!");
	
	# Populate the CCO::Util::GoaAssociationSet object
	while(<FH>){
		chomp;
		$_ =~ /^\w/ ? my $goaAssoc = CCO::Core::GoaAssociation->new() : next;	
		@_ = split(/\t/);
		foreach(@_){
			$_ =~ s/^\s+//; 
			$_ =~ s/\s+$//;
		}
		$goaAssoc->assc_id($.); # TODO proper ID
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

  Usage    - $GoaParser->work($ref_file_names, $ref_taxa)
  Returns  - updated OBO ontology object 
  Args     - reference to a list of filenames(input OBO file, output OBO file, GOA associations file, input CCO_id/Uniprot_id map file), referece to a hash NCBI_id =>taxon_name
  Function - filters GOA associations file by TAXON and GO_ID, adds relevant information to the input  ontology 
  
=cut
sub work {
	my $self = shift;
	

	# Get the arguments
	my ($old_OBOfileName, $new_OBOfileName, $goaAssocFileName, $cco_uniprot_map_file_name) = @{shift @_}; 
	my %taxa = %{shift @_};
	
	# Initialize the OBO parser,load the OBO file, check the assumptions
	my $my_parser = CCO::Parser::OBOParser->new();
	my $ontology = $my_parser->work($old_OBOfileName);
	die "the term 'protein' is not defiined" unless (defined $ontology->get_term_by_name('protein')) ;
	my @rel_types = ('is_a', 'participates_in', 'derives_from');
	foreach (@rel_types){
		die "Not a valid relationship type" unless($ontology->{RELATIONSHIP_TYPES}->{$_});
	}
	foreach (values %taxa) {
		die "the taxon name: $_ doesn't exist" unless (defined $ontology->get_term_by_name($_)) ;
	}
	
	# Initialize CCO_ID_Map object
	my $map = CCO_ID_Term_Map->new($cco_uniprot_map_file_name); 
	
	# Open and parse the GOA associations file, add new terms to ontology
	open(FH, $goaAssocFileName) || die("can't open file: $!");
	#my $count = 0;
	while(<FH>){
		chomp;
		my $record = $_;
		my $goaAssoc; 
		foreach (keys %taxa){
			$record =~ /\staxon:$_\s/ ?  $goaAssoc = CCO::Core::GoaAssociation->new() : next;
			@_ = split(/\t/, $record);
			foreach(@_){
				$_ =~ s/^\s+//; 
				$_ =~ s/\s+$//;
			}
			$goaAssoc->assc_id($.); # TODO proper ID
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
	        
	        # check if the corresponding GO term id is present in the input ontology, if so then add the corresponding protein to CCO
	        
	        if ($ontology->{TERMS_SET}->contains_id(&go2cco($goaAssoc))){
	        	#$count++; 
	        	($ontology, $map) = &update_ontology($ontology, $goaAssoc, $map, \%taxa); 
			}
			last;
		}
	}
	#print "added $count annotations out of $.\n"; 
	close(FH);
	
	# Write the new ontology and map to disk
	open (FH, ">".$new_OBOfileName) || die "Cannot write OBO file ", $!;
	$ontology->export(\*FH);
	close FH;
	$map -> write_map($cco_uniprot_map_file_name); 
	
	return $ontology;
}
################################################################################
#
# Subroutines
#
################################################################################
# adds a protein term along with the relationships to the ontology 
# arguments: CCO::Core::Ontology object, CCO::Util::GoaAssociation object, CCO_ID_Map object, reference to a hash NCBI_id => taxon_name
#
# TODO erase this method and move the code up
sub update_ontology(){
	my($ontology, $goaAssoc, $map, $tax) = @_;
	die "Input must be a CCO::Core::Ontology object" unless (UNIVERSAL::isa($ontology, 'CCO::Core::Ontology'));
	die "Input must be a CCO::Core::GoaAssociation object" unless (UNIVERSAL::isa($goaAssoc, 'CCO::Core::GoaAssociation'));
	die "Input must be a CCO_ID_Map object" unless (UNIVERSAL::isa($map, 'CCO_ID_Term_Map')); 
	die "The hash of taxa: %$tax should contain  at least one species\n" unless (%$tax);
	my $protein; 
	
	# retrieve the protein object from ontology if exists
	$protein = $ontology->get_term_by_name($goaAssoc->obj_symb()); 
	if (!defined $protein) {
		# create new protein term and relationships 
		$protein = CCO::Core::Term->new(); 
		$protein->name($goaAssoc->obj_symb()); 
		
		my $protein_name = $protein->name();
		if ($map->contains_value($protein_name)){
			$protein->id($map->get_cco_id_by_term($protein_name)); 
		}
		else { 			
			$protein->id($map->get_new_cco_id('CCO','B', $protein_name)); 
			
		}
		
		my $xref = CCO::Core::Dbxref->new();
		$xref -> db($goaAssoc->obj_src());
		$xref -> acc($goaAssoc->obj_id());
		my $xref_set = CCO::Util::DbxrefSet->new();
		$xref_set->add($xref);
		$protein->xref_set($xref_set);
		
		my $def = &create_def($goaAssoc); 
		$protein->def($def);  

		$protein->synonym_set(&create_synonym($goaAssoc)) if ($goaAssoc->synonym()); 
		
		$ontology->add_term($protein);
		
		# add "new protein is_a protein"
		$ontology = &add_rel($ontology, $protein, $ontology->get_term_by_name("protein"), "is_a");
		
		# add "new protein derives_from species" 
		my $tax_name = $tax->{substr($goaAssoc->taxon(), 6)}; 
		(my $cco_taxon_term = $ontology->get_term_by_name($tax_name)) || die ("taxon mame: ",$tax_name," doesn't exist");
		$ontology = &add_rel($ontology, $protein, $cco_taxon_term, "derives_from");
	}
	
	# add "new protein participates_in GO process"
	my $cco_go_term=$ontology->get_term_by_id(&go2cco($goaAssoc)); 
	$ontology = &add_rel($ontology, $protein, $cco_go_term, "participates_in");
	return ($ontology, $map); 
}
################################################################################
#
# Create a new CCO::Core::Def object and fill in information from a CCO::Core::GoaAssociation object
#
################################################################################
# TODO erase this method and move the code up
sub create_def{
	if (@_) {
		my $goaAssoc = shift; 
		my $def = CCO::Core::Def->new(); 
		$def->text($goaAssoc->description()); 
		my $dbxref_set = CCO::Util::DbxrefSet->new(); 
		my $dbxref = CCO::Core::Dbxref->new(); 
		$dbxref->db('IPI'); 
		$dbxref->acc($goaAssoc->synonym()); 
		$dbxref_set ->add($dbxref); 
		$def->dbxref_set($dbxref_set); 
		return $def;
	} 
}
################################################################################
#
# create a new CCO::Core::Synonym object and fill in information from a CCO::Core::GoaAssociation object
# argument: a CCO::Util::GoaAssociation object
#
################################################################################
# TODO erase this method and move the code up
sub create_synonym (){
	if (@_) {
		my $goaAssoc = shift; 
		my $synonym = CCO::Core::Synonym->new(); 
		$synonym ->type('EXACT'); 
		my $def = CCO::Core::Def->new(); 
		$def->text($goaAssoc->synonym()); 
		my $dbxref_set = CCO::Util::DbxrefSet->new(); 
		my $dbxref = CCO::Core::Dbxref->new(); 
		$dbxref->db('IPI'); 
		$dbxref->acc($goaAssoc->synonym()); 
		$dbxref_set ->add($dbxref); 
		$def -> dbxref_set($dbxref_set); 
		$synonym -> def($def); 
		return $synonym;
	} 
}
################################################################################
#
# Convert a GO id to a CCO id (e.g. GO:0000027->CCO:P0000027)
# argument: a CCO::Util::GoaAssociation object
#
################################################################################
sub go2cco (){
	if (@_) {
		my $goaAssoc = shift; 
		die "Input must be a CCO::Core::GoaAssociation object" unless (UNIVERSAL::isa($goaAssoc, 'CCO::Core::GoaAssociation'));
		my $id = $goaAssoc->go_id();
		my $prefix = 'CCO:'.$goaAssoc->aspect(); 
		$id =~ s/GO:/$prefix/; 
		return $id;
	}
}
################################################################################
#
# Add a relationship to ontology
# Arguments: ontology object, tail object, head object, relationship type (string)
#
################################################################################
sub add_rel (){
	my($ontology, $tail, $head, $type) = @_;
	die "Ontology must be a CCO::Core::Ontology object" unless (UNIVERSAL::isa($ontology, 'CCO::Core::Ontology'));
	die "Tail must be a CCO::Core::Term or CCO::Core::Relationship object" unless (UNIVERSAL::isa($tail, 'CCO::Core::Term') || UNIVERSAL::isa($tail, 'CCO::Core::Relationship'));
	die "Head must be a CCO::Core::Term or CCO::Core::Relationship object" unless (UNIVERSAL::isa($head, 'CCO::Core::Term') || UNIVERSAL::isa($head, 'CCO::Core::Relationship'));
	die "Not a valid relationship type" unless($ontology->{RELATIONSHIP_TYPES}->{$type});
	my $rel = CCO::Core::Relationship->new(); 
	$rel->type($type);
	$rel->link($tail,$head);
	$rel->id($tail->id()."_".$type."_".$head->id());
	$ontology->add_relationship($rel);
	return $ontology;
}
1;

	
=head1 NAME


    CCO::Parser::GoaParser - A GOA associations to OBO translator.


=head1 DESCRIPTION


The function 'work' converts selected parts of  GOA associations into an OBO file. 
GOA assiciations files can be obtained from http://www.ebi.ac.uk/GOA/proteomes.html

Comments:
Currently only OBJ_SRC, OBJ_ID, OBJ_SYMB, SYNONYM, DESCRIPTION are transfered into ontology. 
Synonyms will be eventually parsed out of the description. 

Assumptions: 
1. the ontology contains already the term 'protein'
2. the ontology already contains all and only the necessary GO process terms. 
3. the ontology already contains the NCBI taxonomy. 
4. the ontology already contains the relationship types 'is_a', 'participates_in', "derives_from"


=head1 AUTHOR


Vladimir Mironov
vlmir@psb.ugent.be

=head1 COPYRIGHT AND LICENSE


Copyright (C) 2006 by Vladimir Mironov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
