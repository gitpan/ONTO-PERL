# $Id: InteractionManager.pm 1702 2007-12-06 17:01:36Z erant $
#
# Module  : InteractionManager.pm
# Purpose : An interaction manager.
# License : Copyright (c) 2007 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package OBO::CCO::InteractionManager;

=head1 NAME

OBO::CCO::InteractionManager  - An IntAct to OBO parser/filter manager.
    
=head1 SYNOPSIS

use OBO::CCO::InteractionManager;
use strict;

my $A_t_intact_files_dir = "/IntactFiles/At/";
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
		if (!($file eq ".") and !($file eq "..")) {
		push (@intact_files,$intact_files_dir.$file);	
		}
	}
	closedir DIR;
	return \@intact_files;
}

=head1 DESCRIPTION

A parser for IntAct to OBO conversion. The conversion is filtered 
according to the proteins already existing in the OBO file.

=head1 AUTHOR

Mikel Egana Aranguren, mikel.eganaaranguren@cs.man.ac.uk

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Mikel Egana Aranguren

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
	my $my_parser = OBO::Parser::OBOParser->new;
	my $ontology = $my_parser->work($pre_cco_obo_file_name);

	# All the interaction ids of the XML files
	my @all_interactions_EBI_ids = ();
	
	# Interactions for cco
	my @interactions_for_cco = ();

	# For each XML file merge interactors in interactions and add the interaction objects
	# (with interactors within) to the @all_interactions array, if the interactor
	# is in CCOinteractors

	for my $intact_xml_file(@intact_xml_files){
		my $XMLIntactParser = OBO::CCO::XMLIntactParser->new;
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
					my @this_interactions = @{&retrieve_interactions($xml_interactor,\@xml_interactions)};
					for my $this_interaction (@this_interactions){
						my $interaction_EBI_id = $this_interaction->primaryRef;
						if (!defined (&lookup($interaction_EBI_id,\@checked_interactions_ids))){
							my $interaction_for_cco = &merge_interactors($this_interaction,\@xml_interactors);
							$this_interaction->goodInteractorID($xml_interactor->id);
							push (@interactions_for_cco,$interaction_for_cco);
							push (@checked_interactions_ids,$interaction_EBI_id);
						}
					}
				}
			}			
		}
	}
	
	my $all_interactions_size = @all_interactions_EBI_ids;
	my $cco_interactions_size = @interactions_for_cco;
# 	print $all_interactions_size," total interactions: ",$cco_interactions_size," interactions chosen \n";

	# Load the ids
	my $cco_i_taxon_ids_map = OBO::CCO::CCO_ID_Term_Map->new($cco_i_taxon_ids);
	my $cco_b_taxon_ids_map = OBO::CCO::CCO_ID_Term_Map->new($cco_b_taxon_ids);
	my $cco_i_ids_map = OBO::CCO::CCO_ID_Term_Map->new($cco_i_ids);
	my $cco_b_ids_map = OBO::CCO::CCO_ID_Term_Map->new($cco_b_ids);

	# CHECK WHETHER THE INTERACTION IS ALREADY THERE
	# Include the interactions that have at least one interactor from 
	# goa file in OBO. Check if the interaction is 
	# already in the OBO file: if the interaction is in OBO (same xref), 
	# add the extras; if it isn't, add the interaction altogether with the extras
	
	# Generate the ids for interaction types
	my %cco_y_ids = %{&generate_cco_y_ids()};
# 	print "========>",$cco_y_ids{'physical interaction'},"\n";

	my @oboed_interactions = ();
	my @original_obo_interactions = @{$ontology->get_terms("CCO:I.*")};
	for my $cco_intact_interaction (@interactions_for_cco){
		# does the interaction exist in OBO?
		my $obo_interaction_term = $ontology->get_term_by_xref('IntAct', $cco_intact_interaction->primaryRef);
		if (defined $obo_interaction_term){
			# TODO: check interactors and change them accordingly
		}
		else{
			push(@oboed_interactions,$cco_intact_interaction);
			my $OBOed_EBI_interaction = &add_interaction($cco_intact_interaction,$ontology,$cco_i_taxon_ids_map,$cco_i_ids_map);
			# Add interaction type
			my $interaction_type = $cco_intact_interaction->interactionType;
			my $CCO_interaction_type = $ontology->get_term_by_name_or_synonym($interaction_type);			
			if (defined $CCO_interaction_type){
				&add_rel("is_a", $OBOed_EBI_interaction, $CCO_interaction_type, $ontology);
			}
			else{
				print $interaction_type, " -> NO INTERACTION TYPE FOUND IN CCO!!!\n";
			}
			# Add interactors
			
			my $good_interactor_is_bait=0;
			# Get the good interactor and check whether is bait or prey
			for my $ebi_interactor (@{$cco_intact_interaction->interactors}){
				if($ebi_interactor->id eq $cco_intact_interaction->goodInteractorID){
					my $role = &get_role ($ebi_interactor->id,$cco_intact_interaction);
					if($role eq "bait"){
						$good_interactor_is_bait=1;
					}
					if($role eq "prey"){
						$good_interactor_is_bait=0;
					}
				}
			}
			

			for my $ebi_interactor (@{$cco_intact_interaction->interactors}){
				if((defined $ebi_interactor->ncbiTaxId) and ($ebi_interactor->ncbiTaxId eq $taxon)){ 
					# Work only with interactors of the given taxon
					# TODO: this is wrong cause we will miss things like ATP, 
					#with no taxon cause it's in every taxon
					# although this is just in a few cases
					my $obo_interactor_term = $ontology->get_term_by_xref('UniProt', $ebi_interactor->uniprot);
					if(defined $obo_interactor_term){
						&add_rel("participates_in",$obo_interactor_term,$OBOed_EBI_interaction,$ontology);
						&add_rel("has_participant",$OBOed_EBI_interaction,$obo_interactor_term,$ontology);
					}
					else{
						my $role = &get_role ($ebi_interactor->id,$cco_intact_interaction);
						# If good interactor is bait, include all the preys
						if($good_interactor_is_bait==1 && $role eq "prey"){
							# Add the interactor term
							my $OBOed_EBI_interactor = &add_interactor($ebi_interactor,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map);
							# Add is_a
							&add_rel("participates_in",$OBOed_EBI_interactor,$OBOed_EBI_interaction,$ontology);	
							&add_rel("has_participant",$OBOed_EBI_interaction,$OBOed_EBI_interactor,$ontology);
						}
						# If good interactor is prey, include only the bait
						if($good_interactor_is_bait==0 && $role eq "bait"){
							# Add the interactor term
							my $OBOed_EBI_interactor = &add_interactor($ebi_interactor,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map);
							# Add is_a
							&add_rel("participates_in",$OBOed_EBI_interactor,$OBOed_EBI_interaction,$ontology);	
							&add_rel("has_participant",$OBOed_EBI_interaction,$OBOed_EBI_interactor,$ontology);
						}
						if($role eq "neutral component"){
							my $OBOed_EBI_interactor = &add_interactor($ebi_interactor,$ontology,$cco_b_taxon_ids_map,$cco_b_ids_map);
							# Add is_a
							&add_rel("participates_in",$OBOed_EBI_interactor,$OBOed_EBI_interaction,$ontology);	
							&add_rel("has_participant",$OBOed_EBI_interaction,$OBOed_EBI_interactor,$ontology);
						}					
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
	
	my $oboed_interactions = @oboed_interactions;
 
	# Compare the interactions already in OBO with the ones in the XML files:
	# if there is an OBO interaction not present in XML file, delete it
	
	# FAKE FOR TESTING 
	#print pop(@all_interactions_EBI_ids),"\n";
	#print pop(@all_interactions_EBI_ids),"\n";
	# END FAKE FOR TESTING
	my @obo_interactions = @{$ontology->get_terms("CCO:I.*")};
	for my $obo_interaction (@obo_interactions){
		my $obo_interaction_EBI_id = &get_xref_acc("IntAct",$obo_interaction);
		if (defined $obo_interaction_EBI_id){
			if(!defined &lookup($obo_interaction_EBI_id,\@all_interactions_EBI_ids)){
				$ontology->delete_term($obo_interaction);
			}
		}
	}
	
	# Write the new ontology to disk
	open (FH, ">".$intact_cco_obo_file_name) || die "Cannot write OBO file ", $!;
	$ontology->export(\*FH);
	close FH;

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
	#
	# Add def
	#
	&add_def ($OBOed_EBI_interactor, "IntAct", $ebi_interactor_object_ebi_id, $ebi_interactor_object->fullName) if(defined $ebi_interactor_object->fullName);
	#
	# Add syn
	#
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
	#
	# Add is_a interaction
	#
# 	my $cco_interaction = $ontology->get_term_by_name("interaction"); 
# 	&add_rel("is_a", $OBOed_EBI_interaction, $cco_interaction, $ontology);
	
	my $primary_ref = $good_interaction->primaryRef();
	#
	# Add xref
	#
	&add_xref($OBOed_EBI_interaction,"IntAct", $primary_ref);
	#
	# Add comment
	#
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
	my $new_term=OBO::Core::Term->new();
	$new_term->id($term_id);
	$new_term->name($term_name);
	$ontology->add_term($new_term);
	return $new_term;
}

sub add_rel (){
	my ($rel_name,$source_term,$target_term,$ontology)=@_;
	my $rel = OBO::Core::Relationship->new();
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
	my ($term, $text)=@_;
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

sub generate_cco_y_ids(){
	my %cco_y = (
		'interaction type' => 'CCO:Y0000001',
		'acetylation reaction'=> 'CCO:Y0000002',
		'amidation reaction' => 'CCO:Y0000003',
		'cleavage reaction' => 'CCO:Y0000004',	
		'covalent binding' => 'CCO:Y0000005',	
		'deacetylation reaction' => 'CCO:Y0000006',	
		'defarnesylation reaction' => 'CCO:Y0000007',	
		'deformylation reaction' => 'CCO:Y0000008',	
		'degeranylation reaction' => 'CCO:Y0000009',	
		'demyristoylation reaction' => 'CCO:Y0000010',	
		'depalmitoylation reaction' => 'CCO:Y0000011',	
		'dephosphorylation reaction' => 'CCO:Y0000012',	
		'deubiquitination reaction' => 'CCO:Y0000013',	
		'farnesylation reaction' => 'CCO:Y0000014',
		'formylation reaction' => 'CCO:Y0000015',	
		'genetic interaction' => 'CCO:Y0000016',
		'geranylgeranylation reaction' => 'CCO:Y0000017',	
		'hydroxylation reaction' => 'CCO:Y0000018',	
		'lipid addition' => 'CCO:Y0000019',	
		'lipid cleavage' => 'CCO:Y0000020',	
		'methylation reaction' => 'CCO:Y0000021',	
		'myristoylation reaction' => 'CCO:Y0000022',	
		'palmitoylation reaction' => 'CCO:Y0000023',	
		'phosphorylation reaction' => 'CCO:Y0000024',	
		'physical interaction' => 'CCO:Y0000025',
		'ubiquitination reaction' => 'CCO:Y0000026',	
		'colocalization' => 'CCO:Y0000027',	
		'direct interaction' => 'CCO:Y0000028',	
		'disulfide bond' => 'CCO:Y0000029',	
		'enzymatic reaction' => 'CCO:Y0000030',	
		'transglutamination reaction' => 'CCO:Y0000031',	
		'adp ribosylation reaction' => 'CCO:Y0000032',	
		'deglycosylationreaction' => 'reaction CCO:Y0000033',	
		'glycosylation reaction' => 'CCO:Y0000034',	
		'sumoylation reaction' => 'CCO:Y0000035',	
		'neddylation reaction' => 'CCO:Y0000036',	
		'desumoylation reaction' => 'CCO:Y0000037',	
		'deneddylation reaction' => 'CCO:Y0000038',	
		'protein cleavage' => 'CCO:Y0000039',	
		'mrna cleavage' => 'CCO:Y0000040',
		'dna cleavage' => 'CCO:Y0000041',	
		'dna strand elongation' => 'CCO:Y0000042',	
		'synthetic interaction' => 'CCO:Y0000043',	
		'asynthetic interaction' => 'CCO:Y0000044',	
		'suppressive interaction' => 'CCO:Y0000045',	
		'epistatic interaction' => 'CCO:Y0000046',	
		'conditional interaction' => 'CCO:Y0000047',	
		'additive interaction' => 'CCO:Y0000048',	
		'single nonmonotonic interaction' => 'CCO:Y0000049',	
		'double nonmonotonic' => 'interaction CCO:Y0000050',
		'enhancement interaction' => 'CCO:Y0000051',	
		'phosphotransfer reaction' => 'CCO:Y0000052'		
	);
	return \%cco_y;
}

1;

