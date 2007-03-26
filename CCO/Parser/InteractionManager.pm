# $Id: InteractionManager.pm 1 2006-06-01 16:21:45Z erant $
#
# Module  : InteractionManager.pm
# Purpose : An interaction manager.
# License : Copyright (c) 2007 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package CCO::Parser::InteractionManager;

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

  Usage    - InteractionManager->work()
  Returns  - A new OBO ontology with new proteins and interactions from IntAct
  Args     - old OBO file, new OBO file, taxon (e.g. 3702), cco_i_taxon_ids file, cco_b_taxon_ids file, cco_i_ids file, cco_b_ids file, XML file 1, XML file 2, ...
  Function - Adds or deletes interactions to/from an OBO file, filtering the interactions from Intact XML files according to proteins already existing in CCO. It also includes any new proteins needed. It should be used for each taxa.
  
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

	# Interactors in Goa file
	my @cco_intact_interactors = ();

	# Initialize the parser and load the OBO file
	#&print_time;
# 	print $pre_cco_obo_file_name,"\n";
	my $my_parser = CCO::Parser::OBOParser->new;
	my $ontology = $my_parser->work($pre_cco_obo_file_name);
# 	#&print_time;

	# All the interaction ids of the XML files
	my @all_interactions_EBI_ids = ();
	
	# Interactions for cco
	my @interactions_for_cco = ();

	# For each XML file merge interactors in interactions and add the interaction objects
	# (with interactors within) to the @all_interactions array, if the interactor
	# is in CCOinteractors

	for my $intact_xml_file(@intact_xml_files){
		my $XMLIntactParser = CCO::Util::XMLIntactParser->new;
		#&print_time;
# 		print $intact_xml_file,"\n";
		$XMLIntactParser->work($intact_xml_file);
		my @xml_interactors = @{$XMLIntactParser->interactors()};
		my @xml_interactions = @{$XMLIntactParser->interactions()};
		for my $xml_interaction (@xml_interactions){
			push (@all_interactions_EBI_ids,$xml_interaction->primaryRef);
		}
		my @checked_interactors_ids = (); # Interactors are redundant
		my @checked_interactions_ids = (); # Interactions are redundant
		for my $xml_interactor (@xml_interactors){
			my $interactor_name = uc $xml_interactor->uniprot;
			if (!defined (&lookup($interactor_name,\@checked_interactors_ids))){
				push (@checked_interactors_ids,$interactor_name);
				if (defined $ontology->get_term_by_xref('UniProt', $interactor_name)){
# 					print "Interactor in OBO:",$interactor_name,"\n";
					my @this_interactions = @{&retrieve_interactions($xml_interactor,\@xml_interactions)};
					for my $this_interaction (@this_interactions){
						my $interaction_EBI_id = $this_interaction->primaryRef;
						if (!defined (&lookup($interaction_EBI_id,\@checked_interactions_ids))){
							my $interaction_for_cco = &merge_interactors($this_interaction,\@xml_interactors);
							push (@interactions_for_cco,$interaction_for_cco);
							push (@checked_interactions_ids,$interaction_EBI_id);
						}
					}
				}
			}			
		}
# 		#&print_time;
	}
	
	my $all_interactions_size = @all_interactions_EBI_ids;
	my $cco_interactions_size = @interactions_for_cco;
# 	print $all_interactions_size," total interactions: ",$cco_interactions_size," interactions chosen \n";

	
	# Load the ids
	my $cco_i_taxon_ids_map = CCO::Util::CCO_ID_Term_Map->new($cco_i_taxon_ids);
	my $cco_b_taxon_ids_map = CCO::Util::CCO_ID_Term_Map->new($cco_b_taxon_ids);
	my $cco_i_ids_map = CCO::Util::CCO_ID_Term_Map->new($cco_i_ids);
	my $cco_b_ids_map = CCO::Util::CCO_ID_Term_Map->new($cco_b_ids);

	# CHECK WHETHER THE INTERACTION IS ALREADY THERE
	# Include the interactions that have at least one interactor from 
	# goa file in OBO. Check if the interaction is 
	# already in the OBO file: if the interaction is in OBO (same xref), 
	# add the extras; if it isn't, add the interaction altogether with the extras

	#&print_time;
	my @oboed_interactions = ();
	my @original_obo_interactions = @{$ontology->get_terms("CCO:I.*")};
	for my $cco_intact_interaction (@interactions_for_cco){
# 		print $cco_intact_interaction->primaryRef,"\n";
# 		#&print_time;
		# does the interaction exist in OBO?
		#my $obo_interaction_term = &check_term_exists_by_xref_acc($cco_intact_interaction->primaryRef,@original_obo_interactions);
		my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $cco_intact_interaction->primaryRef);
		if (defined $obo_interaction_term){
			# TODO: check interactors and change them accordingly
# 			print "Interaction already in OBO: ",$cco_intact_interaction->primaryRef,"\n";
		}
		else{
# 			#&print_time;
			push(@oboed_interactions,$cco_intact_interaction);
# 			print "Adding interaction to OBO: ",$cco_intact_interaction->primaryRef,"\n";
# 			#&print_time;
			my $OBOed_EBI_interaction = &add_interaction($cco_intact_interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map);
# 			#&print_time;
			for my $ebi_interactor (@{$cco_intact_interaction->interactors}){
				if((defined $ebi_interactor->ncbiTaxId) and ($ebi_interactor->ncbiTaxId eq $taxon)){ 
					# Work only with interactors of the given taxon
					# TODO: this is wrong cause we will miss things like ATP, with no taxon cause it's in every taxon
					# although this is just in a few cases
# 					#&print_time;
					#my $obo_interactor_term = $ontology->get_term_by_name(uc $ebi_interactor->uniprot_secondary);
					my $obo_interactor_term = $ontology->get_term_by_xref('UniProt', $ebi_interactor->uniprot);
# 					#&print_time;
					if(defined $obo_interactor_term){
# 						#&print_time;
# 						print "Interactor already in OBO:",$ebi_interactor->uniprot_secondary,"\n";
						&add_rel("participates_in",$obo_interactor_term,$OBOed_EBI_interaction,$ontology);
						&add_rel("has_participant",$OBOed_EBI_interaction,$obo_interactor_term,$ontology);
# 						#&print_time;
					}
					else{
# 						#&print_time;
# 						print "Adding interactor to OBO:",$ebi_interactor->shortLabel,"\n";
						# Add the interactor term
						my $OBOed_EBI_interactor = &add_interactor($ebi_interactor,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map);
						# Add is_a
# 						#&print_time;
						&add_rel("participates_in",$OBOed_EBI_interactor,$OBOed_EBI_interaction,$ontology);	
						&add_rel("has_participant",$OBOed_EBI_interaction,$OBOed_EBI_interactor,$ontology);
# 						#&print_time;
					}
				}
			}
		}	
	}

	#
	# Write down the maps
	#
	$cco_i_taxon_ids_map->write_map();
	$cco_b_taxon_ids_map->write_map();
	$cco_i_ids_map->write_map(); 
	$cco_b_ids_map->write_map();
	
	#&print_time;
	my $oboed_interactions = @oboed_interactions;
# 	print $oboed_interactions," interactions added. \n";
 
	# Compare the interactions already in OBO with the ones in the XML files:
	# if there is an OBO interaction not present in XML file, delete it
# 	#&print_time;
# 	print pop(@all_interactions_EBI_ids),"\n";
# 	print pop(@all_interactions_EBI_ids),"\n";
	my @obo_interactions = @{$ontology->get_terms("CCO:I.*")};
	for my $obo_interaction (@obo_interactions){
		my $obo_interaction_EBI_id = &get_xref_acc("IntAct",$obo_interaction);
		if (defined $obo_interaction_EBI_id){
			if(!defined &lookup($obo_interaction_EBI_id,\@all_interactions_EBI_ids)){
				$ontology->delete_term($obo_interaction);
# 				print "Deleting interaction from ontology:",$obo_interaction->name,"\n";
			}
		}
	}
# 	#&print_time;
	
	# Write the new ontology to disk
	open (FH, ">".$intact_cco_obo_file_name) || die "Cannot write OBO file ", $!;
	$ontology->export(\*FH);
	close FH;
	#&print_time;
	return $ontology;
}

sub lookup (){
	my ($item,$array) = @_;
	my @results = grep(/^$item$/,@{$array});
	return $results[0];
}


sub add_interactor(){
	my ($ebi_interactor_object,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map) = @_;
	my $interactor_name = uc $ebi_interactor_object->shortLabel;
	my $interactor_cco_id = $cco_b_ids_map->get_new_cco_id("CCO", "B", $interactor_name);
	my $OBOed_EBI_interactor = &add_term($interactor_name,$interactor_cco_id,$ontology);
	$cco_b_taxon_ids_map->put($interactor_cco_id, $interactor_name); 
	my $cco_protein=$ontology->get_term_by_name("protein"); 
	#&print_time;
	&add_rel("is_a", $OBOed_EBI_interactor, $cco_protein, $ontology);	
	&add_xref($OBOed_EBI_interactor,"UniProt",$ebi_interactor_object->uniprot);
	# Add def
	if(defined $ebi_interactor_object->fullName){
		#&print_time;
		&add_def ($OBOed_EBI_interactor,"IntAct",$ebi_interactor_object->ebi_id,$ebi_interactor_object->fullName);
	}
	# Add syn
	for my $syn (@{$ebi_interactor_object->alias}){
		#&print_time;
		&add_synonym($OBOed_EBI_interactor,"IntAct",$ebi_interactor_object->ebi_id,$syn);
	}
	return $OBOed_EBI_interactor;
}

sub add_interaction(){
	my ($good_interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map) = @_;
	my $interaction_id = $cco_i_ids_map->get_new_cco_id("CCO", "I",$good_interaction->shortLabel." ".$good_interaction->interactionType);
	my $OBOed_EBI_interaction = &add_term($good_interaction->shortLabel." ".$good_interaction->interactionType,$interaction_id,$ontology);
	$cco_i_taxon_ids_map->put($interaction_id, $good_interaction->shortLabel." ".$good_interaction->interactionType); 
	# add is_a interaction
	my $cco_interaction=$ontology->get_term_by_name("interaction"); 
	#&print_time;
	&add_rel("is_a", $OBOed_EBI_interaction, $cco_interaction, $ontology);
	#&print_time;
	# Add xref
	&add_xref($OBOed_EBI_interaction,"IntAct",$good_interaction->primaryRef);
	# Add def
	if(defined $good_interaction->fullName){
		#&print_time;
		&add_def ($OBOed_EBI_interaction,"IntAct",$good_interaction->primaryRef,$good_interaction->fullName);
	}
	return $OBOed_EBI_interaction;
}

# Given an interactor, it retrieves all the interactions that have the interactor
# as participant
sub retrieve_interactions(){
	my ($interactor,$interactions)=@_;
	my @interactions=@{$interactions};
	my @resulting_interactions=();
	for my $interaction (@interactions){
# 		print "CANDIDATE:",$interaction,"\n";
		SYN: for my $syn (@{$interaction->interactorRef}){
# 			print "SYN:",$syn,"-----",$interactor->id,"!\n";
			if($syn eq $interactor->id){
# 				print "GOOD INTERACTOR FOUND!!!", $interactor->id,"\n";
				push(@resulting_interactions,$interaction);
				last SYN;
			}
		}
	}
	return \@resulting_interactions;
}


sub merge_interactors {
	my ($interaction,$interactors)=@_;
	my @interactors_to_merge = ();
	for my $intRef (@{$interaction->interactorRef}){
		for my $interactor (@{$interactors}){
			if($intRef eq $interactor->id){
				push(@interactors_to_merge,$interactor);
			}
		}
	}
	$interaction->interactors(\@interactors_to_merge);
	return $interaction;
}

sub print_time{
	my $now = localtime;
	print $now,"\n";
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
# 	my $xref = CCO::Core::Dbxref->new();
# 	$xref -> db($db);
# 	$xref -> acc($acc);
# 	my $xref_set = CCO::Util::DbxrefSet->new();
# 	$xref_set->add($xref);
# 	$term->xref_set($xref_set);
	return $term;
}

sub add_def (){
	my ($term,$db,$acc,$def_text)=@_;
	$term->def_as_string($def_text, "[".$db.":".$acc."]");
# 	my $def = CCO::Core::Def->new(); 
# 	$def->text($def_text); 
# 	my $dbxref_set = CCO::Util::DbxrefSet->new(); 
# 	my $dbxref = CCO::Core::Dbxref->new(); 
# 	$dbxref->db($db); 
# 	$dbxref->acc($acc); 
# 	$dbxref_set->add($dbxref); 
# 	$def->dbxref_set($dbxref_set); 
# 	$term -> def($def);
	return $term; 
}

sub add_synonym (){
	my ($term,$db,$acc,$syn_text)=@_;
	$term->synonym_as_string($syn_text, "[".$db.":".$acc."]", "EXACT");
	return $term;  
}

sub check_term_exists_by_xref_acc(){
	my ($unique_acc,@terms_to_check)=@_; 
	my $result_term = undef;
	for my $candidate_term (@terms_to_check){
		my $dbxrefset = $candidate_term->xref_set;
		XREF: for my $xref ($dbxrefset->get_set){
			if($xref->acc eq $unique_acc){
				$result_term = $candidate_term;
				last XREF;
			}
		}
	}
	return $result_term;
}

sub get_xref_acc(){
	my ($db,$term)=@_; 
	my $result_acc = undef;
	my $dbxrefset = $term->xref_set;
	for my $xref ($dbxrefset->get_set){
		if($xref->db eq $db){
# 			print $xref->db,$db,"\n";
			$result_acc = $xref->acc;		
		}
	}
	return $result_acc;
}

1;

=head1 NAME

    CCO::Core::InteractionManager  - An IntAct to OBO parser/filter.
    
=head1 SYNOPSIS

use CCO::Core::InteractionManager;
use strict;

my $A_t_intact_files_dir = "/home/pik/Bioinformatics/Erick_two/IntactFiles/At/";
my @A_t_intact_files = @{&get_intact_files ($A_t_intact_files_dir)};

my $A_t_interactionmanager = InteractionManager->new;
$A_t_interactionmanager->work(
"/home/pik/Bioinformatics/Erick_two/onto-perl-Intact-Optimized/DATA/pre_cco/pre_cco_A_thaliana.obo",
"/home/pik/Bioinformatics/Erick_two/onto-perl-Intact-Optimized/DATA/pre_cco/cco_I_A_thaliana.obo",
"3702",
"/home/pik/Bioinformatics/Erick_two/onto-perl-Intact-Optimized/DATA/cco_ids/cco_i_A_thaliana.ids",
"/home/pik/Bioinformatics/Erick_two/onto-perl-Intact-Optimized/DATA/cco_ids/cco_b_A_thaliana.ids",
"/home/pik/Bioinformatics/Erick_two/onto-perl-Intact-Optimized/DATA/cco_ids/cco_i.ids",
"/home/pik/Bioinformatics/Erick_two/onto-perl-Intact-Optimized/DATA/cco_ids/cco_b.ids",
@A_t_intact_files 
);  


sub get_intact_files{
	my $intact_files_dir = shift;
	my @intact_files = ();
	opendir(DIR, $intact_files_dir) || die "can't opendir $intact_files_dir: $!";
	my @files = readdir(DIR);
	for my $file (@files){
		if (!($file eq ".") and !($file eq "..")){
# 		print $intact_files_dir.$file,"\n";
		push (@intact_files,$intact_files_dir.$file);	
		}
	}
	closedir DIR;
	return \@intact_files;
}

=head1 DESCRIPTION

A parser for IntAct to OBO conversion. The conversion is filtered according to the proteins already existing in the OBO file.

=head1 AUTHOR

Mikel Egana Aranguren, mikel.eganaaranguren@cs.man.ac.uk

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Mikel Egana Aranguren

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

