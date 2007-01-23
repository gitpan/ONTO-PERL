package CCO::Parser::GoaParser;


use CCO::Parser::OBOParser;
use CCO::Core::Relationship;
use CCO::Core::Dbxref;
use CCO::Util::DbxrefSet;
use CCO::Core::Term;
use CCO::Core::GoaAssociation;
#use CCO::Util::GoaAssociationSet;


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

  Usage    - $GoaParser->work()
  Returns  - the new OBO ontology object 
  Args     - input OBO file, output OBO file, GOA associations file, list of NCBI taxon IDs
  Function - adds information from a GOA associations file to an existing ontology 
  
=cut


sub work {
	my $self = shift;
	

	# Get the arguments
	my ($old_OBOfileName, $new_OBOfileName, $goaAssocFileName, @taxon_ids) = @_; 
		
	# Initialize the OBO parser,load the OBO file
	my $my_parser = CCO::Parser::OBOParser->new();
	my $ontology = $my_parser->work($old_OBOfileName);
	
	# Open and parse the GOA associations file, add new terms to ontology
	open(FH, $goaAssocFileName) || die("can't open file: $!");
	#my $goaAssocSet = CCO::Util::GoaAssociationSet->new(); #TODO solve the problem
	my $count = 0;
	while(<FH>){
		chomp;
		my $record = $_;
		foreach (@taxon_ids){
			my $taxon_id = $_;
			$record =~ /^\w.*taxon:$taxon_id/ ? my $goaAssoc = CCO::Core::GoaAssociation->new() : next;
			@_ = split(/\t/, $record);
			foreach(@_){
				$_ =~ s/^\s+//; 
				$_ =~ s/\s+$//;
			}
			$goaAssoc->assc_id($.); #TODO proper ID
		    $goaAssoc->{OBJ_SRC}            = shift @_; 
	        $goaAssoc->{OBJ_ID}           	= shift @_; 
	        $goaAssoc->{OBJ_SYMB}			= shift @_; 
	        $goaAssoc->{QUALIFIER}			= shift @_; 
	        $goaAssoc->go_id(shift @_); 
	        $goaAssoc->{REFER}				= shift @_; 
	        $goaAssoc->{EVID_CODE}			= shift @_; 
	        $goaAssoc->{SUP_REF}			= shift @_; 
	        $goaAssoc->{ASPECT}				= shift @_; 
	        $goaAssoc->{DESCRIPTION}        = shift @_; 
	        $goaAssoc->{SYNONYM}			= shift @_;  
	        $goaAssoc->{TYPE}           	= shift @_; 
	        $goaAssoc->{TAXON}           	= shift @_; 
	        $goaAssoc->{DATE}           	= shift @_;  
	        $goaAssoc->{ANNOT_SRC}          = shift @_;
	        
	        
	        # check if the corresponding GO term id is present in the input ontology, if so then add the corresponding protein to CCO
	        
	        
	        if ($ontology->{TERMS_SET}->contains_id(&go2cco($goaAssoc))){
	        	$count++; 
	        	$ontology = &update_ontology($ontology, $goaAssoc); 
			}
	
		}
		
	}
	print "added $count annotations out of $.\n";
	close(FH);
	
	# Write the new ontology to disk
	open (FH, ">".$new_OBOfileName) || die "Cannot write OBO file ", $!;
	$ontology->export(\*FH);
	close FH;
	return $ontology; 

}
########################################################################
# Subroutines
########################################################################

# adds a protein term along with the relationships to the ontology 
# arguments: CCO::Core::Ontology object, CCO::Util::GoaAssociation object
sub update_ontology(){
	my($ontology, $goaAssoc) = @_;
	croak "Input must be a CCO::Core::Ontology object" unless (UNIVERSAL::isa($ontology, 'CCO::Core::Ontology'));
	croak "Input must be a CCO::Core::GoaAssociation object" unless (UNIVERSAL::isa($goaAssoc, 'CCO::Core::GoaAssociation'));
	
	my $protein ;
	
	# retrieve the protein object from ontology if exists
	if ($ontology->get_term_by_name($goaAssoc->obj_symb())) {
		$protein = $ontology->get_term_by_name($goaAssoc->obj_symb());
	}
	# otherwise create new protein term and relationships 
	else {
		$protein = CCO::Core::Term->new();
		$protein->id("CCO:".$goaAssoc->synonym()); #TODO replace dummy
		$protein->name($goaAssoc->obj_symb());
		
		my $xref = CCO::Core::Dbxref->new();
		$xref -> db($goaAssoc->obj_src());
		$xref -> acc($goaAssoc->obj_id());
		my $xref_set = CCO::Util::DbxrefSet->new();
		$xref_set->add($xref);
		$protein->xref_set($xref_set);
		
		my $def = &create_def($goaAssoc); 
		$protein -> def($def);  
		
		 
		my $synonym_set = CCO::Util::SynonymSet -> new(); 
		my $synonym = &create_synonym($goaAssoc); 
		#$synonym_set -> add($synonym); 
		$protein -> synonym_set($synonym); 
		
		
		$ontology->add_term($protein);
		
		# add "new protein is_a protein"
		my $cco_protein=$ontology->get_term_by_name("protein"); 
		$ontology = &add_rel($ontology, $protein, $cco_protein, "is_a");
		
		#add "new protein derives_from species"
		my $cco_taxon_term = $ontology->get_term_by_id(&ncbi2cco($goaAssoc));
		$ontology = &add_rel($ontology, $protein, $cco_taxon_term, "derives_from");
		
	
	}
	
	# add "new protein participates_in GO process"
	my $cco_go_term=$ontology->get_term_by_id(&go2cco($goaAssoc)); 
	$ontology = &add_rel($ontology, $protein, $cco_go_term, "participates_in");
	
	return $ontology; 
}

#create a new CCO::Core::Def object and fill in information from a CCO::Core::GoaAssociation object
sub create_def{
	my $goaAssoc = shift; 
	my $def = CCO::Core::Def->new(); 
	$def->text($goaAssoc->description()); 
	my $dbxref_set = CCO::Util::DbxrefSet->new(); 
	my $dbxref = CCO::Core::Dbxref->new(); 
	$dbxref->db('IPI'); 
	$dbxref->acc($goaAssoc->synonym()); 
	$dbxref_set ->add($dbxref); 
	$def -> dbxref_set($dbxref_set); 
	return $def; 
}

# create a new CCO::Core::Synonym object and fill in information from a CCO::Core::GoaAssociation object
sub create_synonym (){
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
# Convert a GO id to a CCO id (e.g. GO:0000027->CCO:P0000027)
sub go2cco (){
	
	my $goaAssoc = shift; 
	croak "Input must be a CCO::Core::GoaAssociation object" unless (UNIVERSAL::isa($goaAssoc, 'CCO::Core::GoaAssociation'));
	my $id = $goaAssoc->go_id();
	my $prefix = 'CCO:'.$goaAssoc->aspect(); 
	$id =~ s/GO:/$prefix/; 
	return $id;
}

# Convert an NCBI taxon id to a CCO id (e.g. taxon:27->CCO:T0000027)
# argument: a CCO::Util::GoaAssociation object
sub ncbi2cco (){
	my $goaAssoc = shift;
	croak "Input must be a CCO::Core::GoaAssociation object" unless (UNIVERSAL::isa($goaAssoc, 'CCO::Core::GoaAssociation'));
	my $id = $goaAssoc->taxon(); 
	$id =~ s/taxon://;
	my $prefix="CCO:T";
	for(my $i=0;$i<(7-length($id));$i++){
		$prefix=$prefix.'0';
	}
	return $prefix.$id;
}

#add a relationship to ontology
#arguments: ontology object, tail object, head object, relationship type (string)
sub add_rel (){
	my($ontology, $tail, $head, $type) = @_;
	croak "Ontology must be a CCO::Core::Ontology object" unless (UNIVERSAL::isa($ontology, 'CCO::Core::Ontology'));
	croak "Tail must be a CCO::Core::Term or CCO::Core::Relationship object" unless (UNIVERSAL::isa($tail, 'CCO::Core::Term') || UNIVERSAL::isa($tail, 'CCO::Core::Relationship'));
	croak "Head must be a CCO::Core::Term or CCO::Core::Relationship object" unless (UNIVERSAL::isa($head, 'CCO::Core::Term') || UNIVERSAL::isa($head, 'CCO::Core::Relationship'));
	croak "Not a valid relationship type" unless($ontology->{RELATIONSHIP_TYPES}->{$type});
	my $rel = CCO::Core::Relationship->new(); 
	$rel->type($type);
	$rel->CCO::Core::Relationship::link($tail,$head); 
	my $rel_id = $tail->id()."_".$type."_".$head->id(); 
	$rel->id($rel_id);
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
The function 'work' generates dummy protein IDs, will be fixed soon.
Synonyms will be eventually parsed out of the description. 

Assumptions: 
1. the ontology contains already the term 'protein'
2. there are yet no subclasses of it corresponding to individual proteins.
3. the ontology already contains all and only the necessary GO process terms. 
4. the ontology already contains the NCBI taxonomy. 
5. the ontology already contains the relationship types 'is_a', 'participates_in', "derives_from"


=head1 AUTHOR


Vladimir Mironov
vlmir@psb.ugent.be

=head1 COPYRIGHT AND LICENSE


Copyright (C) 2006 by Vladimir Mironov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
