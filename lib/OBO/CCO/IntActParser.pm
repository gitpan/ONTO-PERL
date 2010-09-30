# $Id: IntActParser.pm 2079 2010-09-29 Erick Antezana $
#
# Module  : IntActParser.pm
# Purpose : An IntAct Parser.
# License : Copyright (c) 2007, 2008 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package OBO::CCO::IntActParser;

=head1 NAME

OBO::CCO::IntActParser  - An IntAct to OBO parser/filter.
    
=head1 SYNOPSIS

use OBO::CCO::IntActParser;
use strict;

my $A_t_intact_files_dir = "/home/pik/Bioinformatics/Erick_two/IntactFiles/At/";
my @A_t_intact_files = @{&get_intact_files ($A_t_intact_files_dir)};

my $A_t_interactionmanager = InteractionManager->new;
$A_t_interactionmanager->work(
"pre_cco_A_thaliana.obo",
"cco_I_A_thaliana.obo",
"3702",
"cco_i_A_thaliana.ids",
"cco_b_A_thaliana.ids",
"cco_i.ids",
"cco_b.ids",
@A_t_intact_files 
);  


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

=head1 DESCRIPTION

A parser for IntAct to OBO conversion. The conversion is filtered according to the proteins already existing in the OBO file and the roles this proteins have in the interactions (prey, bait, neutral component). It deletes any interaction in OBO that it is not present in IntAct, for sync.

=head1 AUTHOR

Mikel Egana Aranguren, mikel.eganaaranguren@cs.man.ac.uk

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008 by Mikel Egana Aranguren

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use OBO::CCO::CCO_ID_Term_Map;
use OBO::CCO::XMLIntactParser;
use OBO::CCO::Interactor;
use OBO::CCO::Interaction;
use OBO::Parser::OBOParser;

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

  Usage    - IntActParser->work()
  Returns  - A new OBO ontology with new proteins and interactions from IntAct
  Args     - old OBO file, new OBO file, taxon (e.g. 3702), cco_i_taxon_ids file, cco_b_taxon_ids file, cco_i_ids file, cco_b_ids file, XML file 1, XML file 2, ...
  Function - Adds or deletes interactions to/from an OBO file, filtering the interactions from Intact XML files according to proteins already existing in CCO and their roles in IntAct (bait, prey, neutral component). It also includes any new proteins needed. It should be used for each taxon.
  
=cut
sub work {
	my ($self,
	$pre_cco_obo_file_name,
	$intact_cco_obo_file_name,
	$taxon,
	$cco_i_taxon_ids,
	$cco_b_taxon_ids,
	$cco_i_ids,
	$cco_b_ids,
	@intact_xml_files) = @_;

	# OPEN CCO ####################################################
	# Initialize the parser and load the OBO file
	my $my_parser = OBO::Parser::OBOParser->new;
	my $ontology = $my_parser->work($pre_cco_obo_file_name);

	# IDs MANAGEMENT ##############################################
	# Load the ids
	my $cco_i_taxon_ids_map = OBO::CCO::CCO_ID_Term_Map->new($cco_i_taxon_ids);
	my $cco_b_taxon_ids_map = OBO::CCO::CCO_ID_Term_Map->new($cco_b_taxon_ids);
	my $cco_i_ids_map = OBO::CCO::CCO_ID_Term_Map->new($cco_i_ids);
	my $cco_b_ids_map = OBO::CCO::CCO_ID_Term_Map->new($cco_b_ids);

	# STATISTICS #############################################
	# All the interaction ids of the XML files
	my @all_interactions_EBI_ids = ();

	# PARSING ################################################
	
	# Relationship types
	my $participates_in = ($ontology->get_relationship_type_by_name("participates_in"))->id;
	my $has_participant = ($ontology->get_relationship_type_by_name("has_participant"))->id;
	my $is_a = ($ontology->get_relationship_type_by_name("is_a"))->id;
	my $has_source = ($ontology->get_relationship_type_by_name("has_source"))->id;

	# Interactor roles
	my $neutral_component = "neutral component";
	my $bait = "bait";
	my $prey = "prey";
	
	# Get the CCO proteins for filtering once 
	my @cco_proteins = @{$ontology->get_descendent_terms($ontology->get_term_by_name("protein"))};

	# TODO: redundancy checking: the performance is a bit better ...

	# Work with each xml intact file
	for my $intact_xml_file(@intact_xml_files){
		my $XMLIntactParser = OBO::CCO::XMLIntactParser->new;
		$XMLIntactParser->work($intact_xml_file);
		my @xml_interactors = @{$XMLIntactParser->interactors()};
		my @xml_interactions = @{$XMLIntactParser->interactions()};

		# Get all the interactions for statistics and for checking that
		# we are in sync with IntAct
		for my $xml_interaction (@xml_interactions){
			push (@all_interactions_EBI_ids,$xml_interaction->primaryRef);
		}

		# For each interactor from intact, if it exists in CCO get the interactions 
		# and the rest of interactors, according to role (bait, ...)
		for my $xml_interactor (@xml_interactors){
			my $interactor_name = uc $xml_interactor->uniprot;
			
			for my $cco_protein (@cco_proteins){
				my $cco_protein_uniprot_id = &get_xref_acc("UniProt",$cco_protein);
				
				# IMPORTANT: 'modified protein' is also child of protein
				next if ($cco_protein->id eq "CCO:U0000010"); # skip the 'modified protein'
				# Interactor in CCO found: get interactions and other interactors
				confess "interactor_name note defined" if (!defined $interactor_name);
				confess "cco_protein_uniprot_id note defined for ", $cco_protein->id if (!defined $cco_protein_uniprot_id);
				if($interactor_name eq $cco_protein_uniprot_id){
					my @this_interactions = @{&retrieve_interactions($xml_interactor,\@xml_interactions)};
#					
					for my $interaction (@this_interactions){
						# Check taxon of interactors
						my $correct_taxon = 1; 
						my %interRefROLES = %{$interaction->interactorRefRoles};
						while (my ($key, $value) = each(%interRefROLES) ) {
							#Get the interactor object
							my $ebi_interactor = &get_interactor($key,\@xml_interactors);
							unless($ebi_interactor->ncbiTaxId eq $taxon){
								$correct_taxon = 0;
#								print $ebi_interactor->ncbiTaxId,$value,"\n";
							}
						}
						
						if($correct_taxon == 1){
						
						my $interaction_id=$interaction->primaryRef;
						my $good_interactor_id = $xml_interactor->id;
						my $role = &get_role ($good_interactor_id,$interaction);
						
						# If the main interactor is a neutral component, include all the neutral components
						if($role eq $neutral_component){
							my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $interaction->primaryRef);						
							if (!defined $obo_interaction_term){
								$obo_interaction_term = &add_interaction($interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map,$is_a);
								$ontology->create_rel($cco_protein, $participates_in, $obo_interaction_term);
								$ontology->create_rel($obo_interaction_term, $has_participant, $cco_protein);	
							} 	
							my %interRefROLES = %{$interaction->interactorRefRoles};
							while (my ($key, $value) = each(%interRefROLES) ) {
								if($value eq $neutral_component){
									#Get the interactor object
									my $ebi_interactor = &get_interactor($key,\@xml_interactors);
									if($ebi_interactor->ncbiTaxId eq $taxon){
										my $OBOed_EBI_interactor = $ontology->get_term_by_xref("UniProt", $ebi_interactor->uniprot);
										if (!defined $OBOed_EBI_interactor){
											$OBOed_EBI_interactor = &add_interactor($ebi_interactor,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map,$is_a,$has_source,$taxon);
										}
										$ontology->create_rel($OBOed_EBI_interactor, $participates_in, $obo_interaction_term);
										$ontology->create_rel($obo_interaction_term, $has_participant, $OBOed_EBI_interactor);
									}
								}
							}
						}
						# If the interactor is a bait, include all the preys
						elsif($role eq $bait){
							my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $interaction->primaryRef);						
							if (!defined $obo_interaction_term){
								$obo_interaction_term = &add_interaction($interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map,$is_a);
								$ontology->create_rel($cco_protein, $participates_in, $obo_interaction_term);
								$ontology->create_rel($obo_interaction_term, $has_participant, $cco_protein);	
							} 	
							my %interRefROLES = %{$interaction->interactorRefRoles};
							while (my ($key, $value) = each(%interRefROLES) ) {
								if($value eq $prey){
									#Get the interactor object
									my $ebi_interactor = &get_interactor($key,\@xml_interactors);
									if($ebi_interactor->ncbiTaxId eq $taxon){
										my $OBOed_EBI_interactor = $ontology->get_term_by_xref("UniProt", $ebi_interactor->uniprot);
										if (!defined $OBOed_EBI_interactor){
											$OBOed_EBI_interactor = &add_interactor($ebi_interactor,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map,$is_a,$has_source,$taxon);
										}
										$ontology->create_rel($OBOed_EBI_interactor, $participates_in, $obo_interaction_term);
										$ontology->create_rel($obo_interaction_term, $has_participant, $OBOed_EBI_interactor);
									}
								}
							}	
						}
# # 						# If the interactor is a prey, include only the bait 
						elsif($role eq $prey){
							my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $interaction->primaryRef);						
							if (!defined $obo_interaction_term){
								$obo_interaction_term = &add_interaction($interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map,$is_a);
								$ontology->create_rel($cco_protein, $participates_in, $obo_interaction_term);
								$ontology->create_rel($obo_interaction_term, $has_participant, $cco_protein);	
							} 	
							my %interRefROLES = %{$interaction->interactorRefRoles};
							while (my ($key, $value) = each(%interRefROLES) ) {
								if($value eq $bait){
									#Get the interactor object
									my $ebi_interactor = &get_interactor($key,\@xml_interactors);
									if($ebi_interactor->ncbiTaxId eq $taxon){
										my $OBOed_EBI_interactor = $ontology->get_term_by_xref("UniProt", $ebi_interactor->uniprot);
										if (!defined $OBOed_EBI_interactor){
											$OBOed_EBI_interactor = &add_interactor($ebi_interactor,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map,$is_a,$has_source,$taxon);
										}
										$ontology->create_rel($OBOed_EBI_interactor, $participates_in, $obo_interaction_term);
										$ontology->create_rel($obo_interaction_term, $has_participant, $OBOed_EBI_interactor);
									}
								}
							}	
						}
						}
					}
				}
			}
		}
	}

	# WRITE ID MAPS #############################################################
	$cco_i_taxon_ids_map->write_map();
	$cco_b_taxon_ids_map->write_map();
	$cco_i_ids_map->write_map(); 
	$cco_b_ids_map->write_map();

	# SYNC WITH INTACT###################################################################
	# Compare the interactions already in OBO with the ones in the XML files:
	# if there is an OBO interaction not present in XML file, delete it
	
	# For testing get rid of some interactions to simulate
	# that they are not in IntAct and hence should be deleted
	#print pop(@all_interactions_EBI_ids),"\n";
	#print pop(@all_interactions_EBI_ids),"\n";

	my @obo_interactions = @{$ontology->get_terms("CCO:I.*")};
	for my $obo_interaction (@obo_interactions){
		my $obo_interaction_EBI_id = &get_xref_acc("IntAct",$obo_interaction);
		if (defined $obo_interaction_EBI_id){
			if(!defined &lookup($obo_interaction_EBI_id,\@all_interactions_EBI_ids)){
				$ontology->delete_term($obo_interaction);
			}
		}
	}

	# WRITE NEW CCO ####################################################
	open (FH, ">".$intact_cco_obo_file_name) || die "Cannot write OBO file ", $!;
	$ontology->export(\*FH);
	close FH;

	return $ontology;
}

=head2 get_xref_acc

  Usage    - get_xref_acc($db, $term)
  Returns  - the name of the external database and the ID (strings)
  Args     - the database name and the term (OBO::Core::Term)
  Function - Given a term, get the xref of a given db. Otherwise, undef
  
=cut
sub get_xref_acc(){
	my ($db,$term)=@_; 
	my $result_acc = undef;
	my $dbxrefset = $term->xref_set;
	XREF: for my $xref ($dbxrefset->get_set){
		if($xref->db eq $db){
			$result_acc = $xref->acc;
			last XREF;		
		}
	}
	return $result_acc;
}

=head2 add_term

  Usage    - add_term ($term_name,$term_id,$ontology)
  Returns  - the added term object
  Args     - the term name, term name id, ontology
  Function - add a term to the ontology, with an ID and name
  
=cut

sub add_term (){
	my ($term_name,$term_id,$ontology)=@_;
	my $new_term=OBO::Core::Term->new();
	$new_term->id($term_id);
	$new_term->name($term_name);
	$ontology->add_term($new_term);
	return $new_term;
}

=head2 add_xref

  Usage    - add_xref ($term,$db,$acc)
  Returns  - the provided term object
  Args     - the term object, database name, accesion id
  Function - add an xref (database and accesion id) to a given term
  
=cut

sub add_xref (){
	my ($term,$db,$acc)=@_;
	$term->xref_set_as_string( "[".$db.":".$acc."]");
	return $term;
}

=head2 add_def

  Usage    - add_def ($term,$db,$acc,$def_text)
  Returns  - the provided term object
  Args     - the term object, database name, accesion id, definition text
  Function - add an definition (definition text, database and accesion id) to a given term
  
=cut

sub add_def (){
	my ($term,$db,$acc,$def_text)=@_;
	$def_text =~ s/\n+//g;
	$def_text =~ s/\t+//g;
	$def_text =~ s/\r+//g;
	$term->def_as_string($def_text, "[".$db.":".$acc."]");
	return $term; 
}

=head2 add_synonym

  Usage    - add_synonym ($term,$db,$acc,$syn_text)
  Returns  - the provided term object
  Args     - the term object, database name, accesion id, synonym text
  Function - add an exact synonym (synonym text, database and accesion id) to a given term
  
=cut

sub add_synonym (){
	my ($term,$db,$acc,$syn_text)=@_;
	$term->synonym_as_string($syn_text, "[".$db.":".$acc."]", "EXACT");
	return $term;  
}

=head2 add_comment

  Usage    - add_comment ($term,$text)
  Returns  - the provided term object
  Args     - the term object, comment text
  Function - add a comment to a given term
  
=cut

sub add_comment (){
	my ($term,$text)=@_;
	$text =~ s/\n+//g;
	$text =~ s/\t+//g;
	$text =~ s/\r+//g;
	$term->comment($text);
	return $term;  
}

=head2 retrieve_interactions

  Usage    - retrieve_interactions ($interactor,@interactions)
  Returns  - an array of interactions
  Args     - an interactor object and the array of interaction objects extracted from an IntAct XML file
  Function - given an interactor, retrieve all the interactions that have the interactor as participant
  
=cut

sub retrieve_interactions(){
	my ($interactor,$interactions)=@_;
	my @interactions=@{$interactions};
	my @resulting_interactions=();
	for my $interaction (@interactions){
		SYN: for my $syn (@{$interaction->interactorRef}){
			if($syn eq $interactor->id){
				push(@resulting_interactions,$interaction);
				last SYN;
			}
		}
	}
	return \@resulting_interactions;
}

=head2 get_role

  Usage    - get_role ($interactor_id,$interaction)
  Returns  - role (string)
  Args     - interactor id and interaction object
  Function - given and interactor id (e.g. 498), get its role in the interaction
  
=cut

sub get_role (){
	my ($interactor_id,$interaction)=@_;
	my %interRefROLES = %{$interaction->interactorRefRoles};
	my $role = undef;
	while ( my ($key, $value) = each(%interRefROLES) ) {
		if($key eq $interactor_id){
			$role=$value;
		}
    }
	return $role;
}

=head2 get_interactor

  Usage    - get_interactor ($interactor_id,@interactors)
  Returns  - interactor object
  Args     - interactor id and arrayc of interactors extracted from an IntAct XML file
  Function - given an interactor id get the interactor object
  
=cut

sub get_interactor {
	my ($interactor_id,$interactors)=@_;
	my $interactor_obj = undef;
	for my $interactor (@{$interactors}){
		if($interactor_id eq $interactor->id){
			$interactor_obj = $interactor;
		}
	}
	return $interactor_obj;
}

=head2 add_interaction

  Usage    - add_interaction ($interaction, $ontology, $cco_i_taxon_ids_map, $cco_i_ids_map,$is_a)
  Returns  - added interaction OBO term 
  Args     - interaction object, ontology, interaction id map (taxon), interaction id map (general), is_a relationship type id
  Function - add an interaction to CCO
  
=cut

sub add_interaction(){
	my ($good_interaction, $ontology, $cco_i_taxon_ids_map, $cco_i_ids_map,$is_a) = @_;
	my $interaction = $good_interaction->shortLabel." ".$good_interaction->interactionType;
	my $interaction_id = $cco_i_taxon_ids_map->get_id_by_term($interaction);
	if (!defined $interaction_id){
		$interaction_id = $cco_i_ids_map->get_new_id("CCO", "I", $interaction);
		$cco_i_taxon_ids_map->put($interaction_id, $interaction); # TRICK to add the IDs in the other file
	}
	my $OBOed_EBI_interaction = &add_term($interaction, $interaction_id, $ontology);
	my $primary_ref = $good_interaction->primaryRef();
	# Add xref
	&add_xref($OBOed_EBI_interaction,"IntAct", $primary_ref);
	# Add comment
	&add_comment($OBOed_EBI_interaction,$good_interaction->fullName) if(defined $good_interaction->fullName());
	# Add is_a interaction type
	
	my $CCO_interaction_type = $ontology->get_term_by_name_or_synonym($good_interaction->interactionType);

# 	my $CCO_interaction_type = $ontology->get_term_by_name($good_interaction->interactionType);
# 	unless (defined $CCO_interaction_type){
# 		$CCO_interaction_type = $ontology->get_term_by_name($good_interaction->interactionType." reaction");
# 	}
	$ontology->create_rel($OBOed_EBI_interaction, $is_a, $CCO_interaction_type);
	return $OBOed_EBI_interaction;
}

=head2 add_interactor

  Usage    - add_interactor ($interactor,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map,$is_a,$has_source,$taxon)
  Returns  - added interactor OBO term 
  Args     - interactor object, ontology, protein id map (taxon), protein id map (general), is_a relationship type id, has_source relationship type id, taxon id (e.g. 3702)
  Function - add an interactor to CCO
  
=cut

sub add_interactor(){
	my ($ebi_interactor_object,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map,$is_a,$has_source,$taxon) = @_;
	my $interactor_name = uc $ebi_interactor_object->shortLabel;
	my $interactor_cco_id = $cco_b_taxon_ids_map->get_id_by_term($interactor_name);
	if (!defined $interactor_cco_id){
		$interactor_cco_id = $cco_b_ids_map->get_new_id("CCO", "B", $interactor_name);
		$cco_b_taxon_ids_map->put($interactor_cco_id, $interactor_name); # TRICK to add the IDs in the other file
	}
	# Add term
	my $OBOed_EBI_interactor = &add_term($interactor_name, $interactor_cco_id, $ontology);
	# Add is_a protein
	my $cco_protein = $ontology->get_term_by_name("protein"); 	
	$ontology->create_rel($OBOed_EBI_interactor, $is_a, $cco_protein);
	# Add has_source taxon
	my $CCO_taxon = $ontology->get_term_by_xref('NCBI', $taxon);
	$ontology->create_rel($OBOed_EBI_interactor, $has_source, $CCO_taxon);
	# Add xref
	&add_xref($OBOed_EBI_interactor, "UniProt", $ebi_interactor_object->uniprot);
	# Add def
	my $ebi_interactor_object_ebi_id = $ebi_interactor_object->ebi_id();
	&add_def ($OBOed_EBI_interactor, "IntAct", $ebi_interactor_object_ebi_id, $ebi_interactor_object->fullName) if(defined $ebi_interactor_object->fullName);
	# Add syn
	for my $syn (@{$ebi_interactor_object->alias}){
		&add_synonym($OBOed_EBI_interactor, "IntAct", $ebi_interactor_object_ebi_id, $syn);
	}
	return $OBOed_EBI_interactor;
}

=head2 lookup

  Usage    - lookup ($item,@array)
  Returns  - found result or undefined if not found
  Args     - string to find, array
  Function - find and string in an array of strings
  
=cut

sub lookup (){
	my ($item,$array) = @_;
	my @results = grep(/^$item$/,@{$array});
	return $results[0];
}

1;