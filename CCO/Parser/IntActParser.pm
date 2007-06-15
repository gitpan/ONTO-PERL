# $Id: IntActParser.pm 1 2006-06-01 16:21:45Z erant $
#
# Module  : IntActParser.pm
# Purpose : An IntAct Parser.
# License : Copyright (c) 2007 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package CCO::Parser::IntActParser;

use CCO::Util::CCO_ID_Term_Map;
use CCO::Util::XMLIntactParser;
use CCO::Core::Interactor;
use CCO::Core::Interaction;
use CCO::Parser::OBOParser;

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
	my $my_parser = CCO::Parser::OBOParser->new;
	my $ontology = $my_parser->work($pre_cco_obo_file_name);

	# IDs MANAGEMENT ##############################################
	# Load the ids
	my $cco_i_taxon_ids_map = CCO::Util::CCO_ID_Term_Map->new($cco_i_taxon_ids);
	my $cco_b_taxon_ids_map = CCO::Util::CCO_ID_Term_Map->new($cco_b_taxon_ids);
	my $cco_i_ids_map = CCO::Util::CCO_ID_Term_Map->new($cco_i_ids);
	my $cco_b_ids_map = CCO::Util::CCO_ID_Term_Map->new($cco_b_ids);

	# STATISTICS #############################################
	# All the interaction ids of the XML files
	my @all_interactions_EBI_ids = ();

	# PARSING ################################################
	


	my @cco_proteins = @{$ontology->get_descendent_terms($ontology->get_term_by_name("protein"))};


	for my $intact_xml_file(@intact_xml_files){
		my $XMLIntactParser = CCO::Util::XMLIntactParser->new;
		$XMLIntactParser->work($intact_xml_file);
		my @xml_interactors = @{$XMLIntactParser->interactors()};
		my @xml_interactions = @{$XMLIntactParser->interactions()};
		# Get all the interactions for statistics and for checking that
		# we are in sync with IntAct
		for my $xml_interaction (@xml_interactions){
			push (@all_interactions_EBI_ids,$xml_interaction->primaryRef);
		}
		my @checked_interactions = ();
		for my $xml_interactor (@xml_interactors){
			my $interactor_name = uc $xml_interactor->uniprot;
			for my $cco_protein (@cco_proteins){
				my $cco_protein_uniprot_id = &get_xref_acc("UniProt",$cco_protein);
				if($interactor_name eq $cco_protein_uniprot_id){
# 					print "INTERACTOR FOUND: ",$interactor_name,"--",$cco_protein->id,"\n";
					my @this_interactions = @{&retrieve_interactions($xml_interactor,\@xml_interactions)};
					for my $interaction (@this_interactions){
						my $interaction_id=$interaction->primaryRef;
						if(!defined (&lookup($interaction_id,\@checked_interactions))){
							push(@checked_interactions,$interaction_id);
# 							print $interaction->primaryRef,"\n";	
							my $good_interactor_id = $xml_interactor->id;
							my $role = &get_role ($good_interactor_id,$interaction);
							my $neutral_component = "neutral component";
							my $bait = "bait";
							my $prey = "prey";
							if($role eq $neutral_component){
# 								print "      GOOD INTERACTOR ROLE:",$neutral_component,"\n";
								my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $interaction->primaryRef);						
								if (!defined $obo_interaction_term){
									$obo_interaction_term = &add_interaction($interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map);
									my $CCO_interaction_type = $ontology->get_term_by_name_or_synonym($interaction->interactionType);
									&add_rel("is_a", $obo_interaction_term, $CCO_interaction_type, $ontology);
									&add_rel("participates_in",$cco_protein,$obo_interaction_term,$ontology);	
									&add_rel("has_participant",$obo_interaction_term,$cco_protein,$ontology);
								} 	
								&conditional_add_interactor ($interaction,$good_interactor_id,\@xml_interactors,$obo_interaction_term,$ontology,$neutral_component,$taxon,$cco_b_taxon_ids_map,$cco_b_ids_map);
							}
							# If the interactor is a bait, include all the preys
							elsif($role eq $bait){
# 								print "      GOOD INTERACTOR ROLE:",$bait,"\n";
								my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $interaction->primaryRef);						
								if (!defined $obo_interaction_term){
									$obo_interaction_term = &add_interaction($interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map);
									my $CCO_interaction_type = $ontology->get_term_by_name_or_synonym($interaction->interactionType);
									&add_rel("is_a", $obo_interaction_term, $CCO_interaction_type, $ontology);
									&add_rel("participates_in",$cco_protein,$obo_interaction_term,$ontology);	
									&add_rel("has_participant",$obo_interaction_term,$cco_protein,$ontology);
								} 	
								&conditional_add_interactor ($interaction,$good_interactor_id,\@xml_interactors,$obo_interaction_term,$ontology,$prey,$taxon,$cco_b_taxon_ids_map,$cco_b_ids_map);
							}
# # 
# # 							# If the interactor is a prey, include only the bait 
							elsif($role eq $prey){
# 								print "      GOOD INTERACTOR ROLE:",$prey,"\n";
								my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $interaction->primaryRef);						
								if (!defined $obo_interaction_term){
									$obo_interaction_term = &add_interaction($interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map);
									my $CCO_interaction_type = $ontology->get_term_by_name_or_synonym($interaction->interactionType);
									&add_rel("is_a", $obo_interaction_term, $CCO_interaction_type, $ontology);
									&add_rel("participates_in",$cco_protein,$obo_interaction_term,$ontology);	
									&add_rel("has_participant",$obo_interaction_term,$cco_protein,$ontology);
								} 	
								&conditional_add_interactor ($interaction,$good_interactor_id,\@xml_interactors,$obo_interaction_term,$ontology,$bait,$taxon,$cco_b_taxon_ids_map,$cco_b_ids_map);
							}
						}
					}
				}
			}
		}
	}

		


# 		foreach my $cco_protein_term (@{$ontology->get_descendent_terms($ontology->get_term_by_name("protein"))}){ 
# 			my $uniprot_id = &get_xref_acc("UniProt",$cco_protein_term);
# 			
# 
# 
# 
# 			
# 			if(defined $uniprot_id){
# 				for my $xml_interactor (@xml_interactors){
# 					my $interactor_name = uc $xml_interactor->uniprot;
# 					if($interactor_name eq $uniprot_id){
# 						print $interactor_name,"--",$uniprot_id,"\n";
# 						my @this_interactions = @{&retrieve_interactions($xml_interactor,\@xml_interactions)};
# 						for my $interaction (@this_interactions){
# 							my $interaction_id=$interaction->primaryRef;
# 							if(!defined (&lookup($interaction_id,\@checked_interactions))){
# 								push(@checked_interactions,$interaction_id);
# 								print $interaction->primaryRef,"\n";
# 							
# 								
# 								my $good_interactor_id = $xml_interactor->id;
# 								my $role = &get_role ($good_interactor_id,$interaction);
# 								my $neutral_component = "neutral component";
# 								my $bait = "bait";
# 								my $prey = "prey";
# 								if($role eq $neutral_component){
# 									print "      GOOD INTERACTOR ROLE:",$neutral_component,"\n";
# 									my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $interaction->primaryRef);
# 		# 							
# 									if (!defined $obo_interaction_term){
# 										$obo_interaction_term = &add_interaction($interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map);
# 										my $CCO_interaction_type = $ontology->get_term_by_name_or_synonym($interaction->interactionType);
# 										&add_rel("is_a", $obo_interaction_term, $CCO_interaction_type, $ontology);
# 										print &add_rel("participates_in",$cco_protein_term,$obo_interaction_term,$ontology),"\n";	
# 										print &add_rel("has_participant",$obo_interaction_term,$cco_protein_term,$ontology),"\n";
# 									} 	
# 									&conditional_add_interactor ($interaction,$good_interactor_id,\@xml_interactors,$obo_interaction_term,$ontology,$neutral_component,$taxon,$cco_b_taxon_ids_map,$cco_b_ids_map);
# 								}
# 							}
# 						}
# 					}
# 				}
# 			}
# 		}
		


###########################################################################################
	
# 		my @checked_interactors_ids = (); # Interactors are redundant 
# 		my @checked_interactions_ids = (); # Interactions are redundant 
# 		for my $xml_interactor (@xml_interactors){
# 			my $interactor_name = uc $xml_interactor->uniprot;
# 			print "--------------------------------\n";
# 			print "INTERACTOR TO CHECK:",$interactor_name,"\n";
# 			# Make sure we haven't checked this interactor before
# 			if (!defined (&lookup($interactor_name,\@checked_interactors_ids))){ 
# 				push (@checked_interactors_ids,$interactor_name);
# 				print " NON REDUNDANT INTERACTOR :",$interactor_name,"\n";
# 				# The interactor is present in CCO?
# # 				my $CCO_interactor = $ontology->get_term_by_xref('UniProt', $interactor_name);
# 				
# 				if (defined (&lookup($interactor_name,\@cco_uniprot_ids))){
# # 				if (defined $CCO_interactor){
# 
# 					my $CCO_interactor = $ontology->get_term_by_xref('UniProt', $interactor_name);
# 					print "  INTERACTOR IN CCO:xml interactor:",$interactor_name," CCO interactor:",$CCO_interactor->id,"\n";
# 
# 					# Get the interactions where this interactor participates
# 					my @this_interactions = @{&retrieve_interactions($xml_interactor,\@xml_interactions)};
# 					for my $interaction (@this_interactions){
# 						my $interaction_EBI_id = $interaction->primaryRef;
# 						print "   OBTAINED INTERACTION:",$interaction_EBI_id,"\n";
# 						# Make sure we haven't checked this interaction before
# 						if (!defined (&lookup($interaction_EBI_id,\@checked_interactions_ids))){
# 							print "    NON REDUNDANT INTERACTION:",$interaction_EBI_id,"\n";
# 							push (@checked_interactions_ids,$interaction_EBI_id);
# 
# 							my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $interaction->primaryRef);
# 							
# 							if (!defined $obo_interaction_term){
# 								$obo_interaction_term = &add_interaction($interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map);
# 								my $interaction_type = $interaction->interactionType;
# 								my $CCO_interaction_type = $ontology->get_term_by_name_or_synonym($interaction_type);
# 								&add_rel("is_a", $obo_interaction_term, $CCO_interaction_type, $ontology);
# 								
# 							}
# 							
# 							# Add participates_in and has_participant with good interactor
# 							print &add_rel("participates_in",$CCO_interactor,$obo_interaction_term,$ontology),"\n";	
# 							print &add_rel("has_participant",$obo_interaction_term,$CCO_interactor,$ontology),"\n";
# 							
# 							
# 							# Get the role of the interactor
# 							my $good_interactor_id = $xml_interactor->id;
# 							my $role = &get_role ($good_interactor_id,$interaction);
# 							
# 							my $neutral_component = "neutral component";
# 							my $bait = "bait";
# 							my $prey = "prey";
# # 
# # # 							# If the interactor is a neutral component, include all the neutral components
# 							if($role eq $neutral_component){
# 								print "      GOOD INTERACTOR ROLE:",$neutral_component,"\n";	
# 								&conditional_add_interactor ($interaction,$good_interactor_id,\@xml_interactors,$obo_interaction_term,$ontology,$neutral_component,$taxon,$cco_b_taxon_ids_map,$cco_b_ids_map);
# 							}
# # # 						
# # # 							# If the interactor is a bait, include all the preys
# 							elsif($role eq $bait){
# 								print "      GOOD INTERACTOR ROLE:",$bait,"\n";
# 								&conditional_add_interactor ($interaction,$good_interactor_id,\@xml_interactors,$obo_interaction_term,$ontology,$prey,$taxon,$cco_b_taxon_ids_map,$cco_b_ids_map);
# 							}
# # # 
# # # 							# If the interactor is a prey, include only the bait 
# 							elsif($role eq $prey){
# 								print "      GOOD INTERACTOR ROLE:",$prey,"\n";
# 								&conditional_add_interactor ($interaction,$good_interactor_id,\@xml_interactors,$obo_interaction_term,$ontology,$bait,$taxon,$cco_b_taxon_ids_map,$cco_b_ids_map);
# 							}
# 						}	
# 					}
# 				}
# 			}
# 		}
	

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

# Find and element in an array
sub lookup (){
	my ($item,$array) = @_;
	my @results = grep(/^$item$/,@{$array});
	return $results[0];
}


sub add_interactor(){
	my ($ebi_interactor_object,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map) = @_;
	my $interactor_name = uc $ebi_interactor_object->shortLabel;
	my $interactor_cco_id = $cco_b_taxon_ids_map->get_cco_id_by_term($interactor_name);
	if (!defined $interactor_cco_id){
		$interactor_cco_id = $cco_b_ids_map->get_new_cco_id("CCO", "B", $interactor_name);
		$cco_b_taxon_ids_map->put($interactor_cco_id, $interactor_name); # TRICK to add the IDs in the other file
	}
	
	my $OBOed_EBI_interactor = &add_term($interactor_name, $interactor_cco_id, $ontology);
	my $cco_protein = $ontology->get_term_by_name("protein"); 

	&add_rel("is_a", $OBOed_EBI_interactor, $cco_protein, $ontology);	
	&add_xref($OBOed_EBI_interactor, "UniProt", $ebi_interactor_object->uniprot);
	
	my $ebi_interactor_object_ebi_id = $ebi_interactor_object->ebi_id();
	# Add def
	&add_def ($OBOed_EBI_interactor, "IntAct", $ebi_interactor_object_ebi_id, $ebi_interactor_object->fullName) if(defined $ebi_interactor_object->fullName);
	# Add syn
	for my $syn (@{$ebi_interactor_object->alias}){
		&add_synonym($OBOed_EBI_interactor, "IntAct", $ebi_interactor_object_ebi_id, $syn);
	}
	return $OBOed_EBI_interactor;
}

sub add_interaction(){
	my ($good_interaction, $ontology, $cco_i_taxon_ids_map, $cco_i_ids_map) = @_;
	my $interaction = $good_interaction->shortLabel." ".$good_interaction->interactionType;
	my $interaction_id = $cco_i_taxon_ids_map->get_cco_id_by_term($interaction);
	if (!defined $interaction_id){
		$interaction_id = $cco_i_ids_map->get_new_cco_id("CCO", "I", $interaction);
		$cco_i_taxon_ids_map->put($interaction_id, $interaction); # TRICK to add the IDs in the other file
	}
	
	my $OBOed_EBI_interaction = &add_term($interaction, $interaction_id, $ontology);
	my $primary_ref = $good_interaction->primaryRef();
	# Add xref
	&add_xref($OBOed_EBI_interaction,"IntAct", $primary_ref);
	# Add comment
	&add_comment($OBOed_EBI_interaction,$good_interaction->fullName) if(defined $good_interaction->fullName());
	return $OBOed_EBI_interaction;
}

# Given an interactor, retrieve all the interactions that have the interactor
# as participant
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

# Given an interactor id get the interactor object
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

# Add an interactor depending on its role
sub conditional_add_interactor (){
	my ($interaction,$good_interactor_id,$xml_interactors,$obo_interaction_term,$ontology,$condition,$taxon_id,$cco_b_taxon_ids_map,$cco_b_ids_map)=@_;
# 	print "          CONDITION FOR BEING ADDED: ",$condition,"\n";
	my %interRefROLES = %{$interaction->interactorRefRoles};
	while (my ($key, $value) = each(%interRefROLES) ) {
		unless($key eq $good_interactor_id){
			if($value eq $condition){
				# Get the interactor object
				my $ebi_interactor = &get_interactor($key,\@{$xml_interactors});
# 				print "           TAXON:",$ebi_interactor->ncbiTaxId,"\n";
				if($ebi_interactor->ncbiTaxId eq $taxon_id){
# 					print "           TAXON:",$taxon_id,"=============",$ebi_interactor->ncbiTaxId,"\n";
					# Add the interactor term
# 					print "          INTERACTOR ADDED: ",$ebi_interactor->uniprot," CONDITION ",$value,"\n";
				
					my $OBOed_EBI_interactor = &add_interactor($ebi_interactor,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map);
					

					&add_rel("participates_in",$OBOed_EBI_interactor,$obo_interaction_term,$ontology);	
					&add_rel("has_participant",$obo_interaction_term,$OBOed_EBI_interactor,$ontology);
					# Get CCO taxon term
					my $CCO_taxon = $ontology->get_term_by_xref('NCBI', $taxon_id);
					&add_rel("derives_from",$OBOed_EBI_interactor,$CCO_taxon,$ontology);	
				}
			}
		}
	}
}

# Given and interactor id (e.g 498), get its role in the interaction
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

sub add_term (){
	my ($term_name,$term_id,$ontology)=@_;
	my $new_term=CCO::Core::Term->new();
	$new_term->id($term_id);
	$new_term->name($term_name);
	$ontology->add_term($new_term);
	return $new_term;
}

sub add_rel (){
	my ($rel_name,$source_term,$target_term,$ontology)=@_;
	my $rel = CCO::Core::Relationship->new();
	$rel->type($rel_name);
	$rel->link($source_term, $target_term);
	my $rel_id = $source_term->id()."_".$rel_name."_".$target_term->id();
	$rel->id($rel_id);
	$ontology->add_relationship($rel);
	return $rel_id;
}

sub add_xref (){
	my ($term,$db,$acc)=@_;
	$term->xref_set_as_string( "[".$db.":".$acc."]");
	return $term;
}

sub add_def (){
	my ($term,$db,$acc,$def_text)=@_;
	$def_text =~ s/\n+//g;
	$def_text =~ s/\t+//g;
	$def_text =~ s/\r+//g;
	$term->def_as_string($def_text, "[".$db.":".$acc."]");
	return $term; 
}

sub add_synonym (){
	my ($term,$db,$acc,$syn_text)=@_;
	$term->synonym_as_string($syn_text, "[".$db.":".$acc."]", "EXACT");
	return $term;  
}

sub add_comment (){
	my ($term,$text)=@_;
	$text =~ s/\n+//g;
	$text =~ s/\t+//g;
	$text =~ s/\r+//g;
	$term->comment($text);
	return $term;  
}

# Given a term, get the xref of a given db
sub get_xref_acc(){
	my ($db,$term)=@_; 
	my $result_acc = undef;
	my $dbxrefset = $term->xref_set;
	for my $xref ($dbxrefset->get_set){
		if($xref->db eq $db){
			$result_acc = $xref->acc;		
		}
	}
	return $result_acc;
}


# Fake term to add to out_cco.obo in tests
# [Term]
# id: CCO:B0000005
# name: rbx1a_arath
# xref: UniProt:Q940X7
# is_a: CCO:U0000005 ! protein
# relationship: derives_from CCO:T0000033 ! Arabidopsis thaliana organism
# relationship: participates_in CCO:P0000103 ! meiosis

1;

=head1 NAME

    CCO::Parser::IntActParser  - An IntAct to OBO parser/filter.
    
=head1 SYNOPSIS

use CCO::Parser::IntActParser;
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

Copyright (C) 2007 by Mikel Egana Aranguren

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
