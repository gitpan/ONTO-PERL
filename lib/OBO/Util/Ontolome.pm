# $Id: Ontolome.pm 2132 2008-05-26 11:13:15Z Erick Antezana $
#
# Module  : Ontolome.pm
# Purpose : A Set of ontologies.
# License : Copyright (c) 2007, 2008 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana@gmail.com>
#
package OBO::Util::Ontolome;

=head1 NAME

OBO::Util::Ontolome  - A set of ontologies.
    
=head1 SYNOPSIS

use OBO::Util::Set;

use strict;

my $o1 = OBO::Core::Ontology->new();

my $o2 = OBO::Core::Ontology->new();

my $o3 = OBO::Core::Ontology->new();


my $ome1 = OBO::Util::Ontolome->new();

$ome1->add($o1);

$ome1->add_all($o2, $o3);


my $ome2 = OBO::Util::Ontolome->new();

$ome2->add_all($o1, $o2, $o3);


=head1 DESCRIPTION

A collection that contains no duplicate ontology elements. More formally, an
ontolome contains no pair of ontologies $e1 and $e2 such that $e1->equals($e2). 
As implied by its name, this package models the set of ontologies.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

our @ISA = qw(OBO::Util::ObjectSet);
use OBO::Util::ObjectSet;

use strict;
use warnings;
use Carp;

=head2 union

  Usage    - $ome->union($o1, $o2, ...)
  Returns  - an ontology (OBO::Core::Ontology) being the union of the parameters (ontologies)
  Args     - the ontologies (OBO::Core::Ontology) to be united
  Function - creates an ontology having the union of terms and relationships from the given ontologies
  Remark1  - we are assuming: same IDSPACE among the ontologies and for merging terms, they must have the same name and ID
  Remark2  - the union is made on the basis of the IDs
  
=cut

sub union () {
	my ($self, @ontos) = @_;
	my $result = OBO::Core::Ontology->new();
	$result->idspace_as_string("CCO", "http://www.cellcycleontology.org/ontology/obo/"); # adapt it to your needs
	$result->default_namespace("cellcycle_ontology"); # adapt it to your needs
	$result->remark("Merged ontology");
	
	foreach my $ontology (@ontos) {
		$result->idspace($ontology->idspace()); # assuming the same idspace
		$result->subsets($ontology->subsets()->get_set()); # add all subsets by default
		$result->synonym_type_def_set($ontology->synonym_type_def_set()->get_set()); # add all synonym_type_def_set by default

		my @terms = @{$ontology->get_terms()};
		foreach my $term (@terms){
			my $term_id = $term->id();
			my $current_term = $result->get_term_by_id($term_id); # could also be $result->get_term_by_name_or_synonym()
			if ($current_term) { # TODO && $current_term is in $term->namespace()  i.e. check if they belong to an identical namespace
				$current_term->is_anonymous("true") if (!defined $current_term->is_anonymous() && $term->is_anonymous());
				foreach ($term->alt_id()->get_set()) {
					$current_term->alt_id($_);
				}
				$current_term->def($term->def()) if (!defined $current_term->def()->text() && $term->def()->text()); # TODO implement the case where the def xref's are not balanced!
				foreach ($term->namespace()) {
					$current_term->namespace($_);
				}
				$current_term->comment($term->comment()) if (!defined $current_term->comment() && $term->comment());
				foreach ($term->subset()) { 
					$current_term->subset($_);
				}
				foreach ($term->synonym_set()) {
					$current_term->synonym_set($_);
				}
				foreach ($term->xref_set()->get_set()) {
					$current_term->xref_set()->add($_);
				}
				foreach ($term->intersection_of()) {
					$current_term->intersection_of($_);
				}
				foreach ($term->union_of()) {
					$current_term->union_of($_);
				}
				foreach ($term->disjoint_from()) {
					$current_term->disjoint_from($_);
				}
				$current_term->is_obsolete("true") if (!defined $current_term->is_obsolete() && $term->is_obsolete());
				foreach ($term->replaced_by()->get_set()) {
					$current_term->replaced_by($_);
				}
				foreach ($term->consider()->get_set()) {
					$current_term->consider($_);
				}
				$current_term->builtin("true") if (!defined $current_term->builtin() && $term->builtin());
				
				# fix the rel's
				my @rels = @{$ontology->get_relationships_by_target_term($term)}; 
				foreach my $r (@rels) {
					my $cola    = $r->tail();
					my $tail_id = $cola->id();
					
					#confess "There is no ID for the tail term linked to: ", $term->id() if (!$tail_id);
					
					my $tail = $result->get_term_by_id($tail_id); # Is $cola already present in the growing ontology?					
					if (!defined $tail) {
						my $new_term = OBO::Core::Term->new();
						$new_term->id($tail_id);
						$new_term->name($cola->name());
						$result->add_term($new_term);			# add $cola if it is not present yet!
						$tail = $result->get_term_by_id($tail_id);
					}
					my $r_type = $r->type(); # e.g. is_a
					my $rel_type = $ontology->get_relationship_type_by_id($r_type);
					$result->has_relationship_type($rel_type) || $result->add_relationship_type_as_string($rel_type->id(), $r_type);
					
					$result->create_rel($tail, $r_type, $current_term);
				}
			} else {
				my $new_term = OBO::Core::Term->new();
				$new_term->id($term_id);
				$new_term->name($term->name());
				$result->add_term($new_term);
				push @terms, $term; # trick to visit again the just added term which wasn't treated yet
			}
		}
		
		#
		# Add relationships
		#
		foreach my $rela (@{$ontology->get_relationships()}){
			my $rel_type_name = $rela->type();
			my $onto_rela_type = $ontology->get_relationship_type_by_id($rel_type_name);
			my $rel_type = $result->get_relationship_type_by_id($rel_type_name);
			if (!$result->has_relationship_type($rel_type)) {
				$result->add_relationship_type($rel_type); # add rel types between rel's (typical is_a, part_of)
				$rel_type = $result->get_relationship_type_by_id($rel_type_name);
			}
			
			foreach ($onto_rela_type->alt_id()->get_set()) {
					$rel_type->alt_id($_);
			}
			$rel_type->def($onto_rela_type->def()) if (!defined $rel_type->def()->text() && $onto_rela_type->def()->text()); # TODO implement the case where the def xref's are not balanced!
			foreach ($onto_rela_type->namespace()) {
				$rel_type->namespace($_);
			}
			$rel_type->comment($onto_rela_type->comment()) if (!defined $rel_type->comment() && $onto_rela_type->comment());
			foreach ($onto_rela_type->subset()) { 
				$rel_type->subset($_);
			}
			foreach ($onto_rela_type->synonym_set()) {
				$rel_type->synonym_set($_);
			}
			foreach ($onto_rela_type->xref_set()->get_set()) {
				$rel_type->xref_set()->add($_);
			}
			$rel_type->is_cyclic("true") if (!defined $rel_type->is_cyclic() && $onto_rela_type->is_cyclic());
			$rel_type->is_reflexive("true") if (!defined $rel_type->is_reflexive() && $onto_rela_type->is_reflexive());
			$rel_type->is_symmetric("true") if (!defined $rel_type->is_symmetric() && $onto_rela_type->is_symmetric());
			$rel_type->is_anti_symmetric("true") if (!defined $rel_type->is_anti_symmetric() && $onto_rela_type->is_anti_symmetric());
			$rel_type->is_transitive("true") if (!defined $rel_type->is_transitive() && $onto_rela_type->is_transitive());
			$rel_type->is_metadata_tag("true") if (!defined $rel_type->is_metadata_tag() && $onto_rela_type->is_metadata_tag());
			
			$rel_type->is_obsolete("true") if (!defined $rel_type->is_obsolete() && $onto_rela_type->is_obsolete());
			foreach ($onto_rela_type->replaced_by()->get_set()) {
				$rel_type->replaced_by($_);
			}
			foreach ($onto_rela_type->consider()->get_set()) {
				$rel_type->consider($_);
			}
			$rel_type->builtin("true") if (!defined $rel_type->builtin() && $onto_rela_type->builtin());
			
			#
			# link the rels:
			#
			my $rel_id = $rela->id();
			if (! $result->has_relationship_id($rel_id)) {
				$result->add_relationship($rela); # add rel's between rel's
			}
		}
	}
	return $result;
}

=head2 intersection

  Usage    - $ome->intersection($o1, $o2)
  Return   - an ontology (OBO::Core::Ontology) holding the 'intersection' of $o1 and $o2
  Args     - the two ontologies (OBO::Core::Ontology) to be intersected 
  Function - finds the intersection ontology from $o1 and $o2. All the common terms by ID 
             are added to the resulting ontology. This method provides a way of comparing two
             ontologies. The resulting ontology gives hints about the missing and identical
             terms (comparison done by term ID). A closer analysis should be done to identify
             the differences.
  Remark   - Performance issues with huge ontologies.
  
=cut

sub intersection () {
	my ($self, $onto1, $onto2) = @_;
	my $result = OBO::Core::Ontology->new();
	$result->idspace_as_string("CCO", "http://www.cellcycleontology.org/ontology/obo"); # adapt it to your needs
	$result->default_namespace("cellcycle_ontology"); # adapt it to your needs
	$result->remark("Intersected ontology");
	
	$result->idspace($onto1->idspace()); # assuming the same idspace
	$result->subsets($onto1->subsets()->get_set()); # add all subsets by default

	foreach my $term (@{$onto1->get_terms()}){
		my $current_term = $onto2->get_term_by_id($term->id()); ### could also be $result->get_term_by_name_or_synonym()
		if (defined $current_term) { # term intersection
			$result->add_term($term); # added the term from onto2
		}
	}
	my $onto1_number_relationships  = $onto1->get_number_of_relationships();
	my $onto2_number_relationships  = $onto2->get_number_of_relationships();
	my $min_number_rels_onto1_onto2 = ($onto1_number_relationships < $onto2_number_relationships)?$onto1_number_relationships:$onto2_number_relationships;
	
	my @terms = @{$result->get_terms()};
	
	my $stop  = OBO::Util::Set->new();
	map {$stop->add($_->id())} @terms;
	
	# path of references
	my @pr1;
	my @pr2;
	
	# link the common terms
	foreach my $term (@terms) {
		my $term_id = $term->id();
		
		#
		# path of references: onto1 and onto2
		#
		
		# onto1
		my @pref1 = $onto1->get_paths_term_terms($term_id, $stop);
		push @pr1, [@pref1];
		
		# onto2
		my @pref2 = $onto2->get_paths_term_terms($term_id, $stop);
		push @pr2, [@pref2];
	}	
	
	my %cand;
	
	# pr1
	foreach my $pref (@pr1) {
		foreach my $ref (@$pref) {
			my $type = @$ref[0]->type(); # first type
			my $invalid = 0;
			my $r_type;
			foreach my $tt (@$ref) {
				$r_type = $tt->type();
				if ($type ne $r_type) {
					$invalid = 1;
					last; # no more walking
				}
			}
			if (!$invalid) {
				my $f = @$ref[0]->tail()->id();
				my $l = @$ref[$#$ref]->head()->id();
				$cand{$f.'->'.$r_type.'->'.$l} = 1; # there could be more than 1 path
				$invalid = 0;
			}
		}
	}
	my %r_cand;
	# pr2
	foreach my $pref (@pr2) {
		foreach my $ref (@$pref) {
			my $type = @$ref[0]->type(); # first type
			my $invalid = 0;
			my $r_type;
			foreach my $tt (@$ref) {
				$r_type = $tt->type();
				if ($type ne $r_type) { # ONLY identical rel types in the path are admitted!!!
					#warn "INVALID REL: ", $tt->id();
					$invalid = 1;
					last; # no more walking
				}
			}
			if (!$invalid) {
				my $f = @$ref[0]->tail()->id();
				my $l = @$ref[$#$ref]->head()->id();
				$cand{$f.'->'.$r_type.'->'.$l}++;
				$r_cand{$f.'->'.$l} = $r_type;
				$invalid = 0;
			}
		}
	}
	
	# cleaning candidates
	foreach (keys (%cand)) {
		delete $cand{$_} if ($cand{$_} < 2);
	}
	
	# candidatos simplificado	
	my %cola;
	foreach (keys (%cand)) {
		my $f = $1, my $r = $2, my $l = $3 if ($_ =~ /(.*)->(.*)->(.*)/);
		$cola{$f} .= $l." ";  # hold the candidates
	}	
	
	# transistive reduction
	while ( my ($k, $v) = each(%cola)) {
	
		my $V= OBO::Util::Set->new();
		$V->add($v);
		
		my @T = split (/ /, $v);
		
		my %target = ();
		my $r_type = $r_cand{$k.'->'.$T[$#T]}; # check
		
		while ($#T > -1) {
			my $n = pop @T;
			$target{$r_type.'->'.$n}++;
			if (!$V->contains($n)) {
				$V->add($n);				
				push @T, split(/ /, $cola{$n}) if ($cola{$n});
			}
		}
		
		while (my ($t, $veces) = each(%target)) {
			if ($veces > 1) { # if so, the delete $k->$t
				delete $cand{$k."->".$t};
			}
		}
	}
	
	# after "transitive reduction" we have
	while (my ($k, $v) = each(%cand)) {
		my $s = $1, my $r_type = $2, my $t = $3 if ($k =~ /(.*)->(.*)->(.*)/);
		my $source    = $result->get_term_by_id($s);
		my $target    = $result->get_term_by_id($t);
		
		if (!($result->has_relationship_type_id($r_type))) {
			$result->add_relationship_type_as_string($r_type, $r_type); # ID = NAME
		}		
		$result->create_rel($source, $r_type, $target);
	}
	return $result;
}

=head2 transitive_closure

  Usage    - $ome->transitive_closure($o)
  Return   - an ontology (OBO::Core::Ontology) with the transitive closure
  Args     - an ontology (OBO::Core::Ontology) to be expanded
  Function - expands all the transitive relationships (e.g. is_a, part_of) along the
  			 hierarchy and generates a new ontology holding all possible paths.
  Remark   - Performance issues with huge ontologies.
  
=cut

sub transitive_closure () {
my ($self, $ontology) = @_;
	my $result = OBO::Core::Ontology->new();
	$result->idspace_as_string("CCO", "http://www.cellcycleontology.org/ontology/obo/"); # adapt it to your needs
	$result->default_namespace("cellcycle_ontology"); # adapt it to your needs
	$result->remark("Ontology with transitive closure");
	
	$result->idspace($ontology->idspace()); # assuming the same idspace
	$result->subsets($ontology->subsets()->get_set()); # add all subsets by default
	$result->synonym_type_def_set($ontology->synonym_type_def_set()->get_set()); # add all synonym_type_def_set by default
	
	my @terms = @{$ontology->get_terms()};
	foreach my $term (@terms){
		my $current_term =  $result->get_term_by_id($term->id());
		if (defined $current_term) { # TODO && $current_term is in $term->namespace()  i.e. check if they belong to an identical namespace
			$current_term->is_anonymous("true") if (!defined $current_term->is_anonymous() && $term->is_anonymous());
			foreach ($term->alt_id()->get_set()) {
				$current_term->alt_id($_);
			}
			$current_term->def($term->def()) if (!defined $current_term->def()->text() && $term->def()->text()); # TODO implement the case where the def xref's are not balanced!
			foreach ($term->namespace()) {
				$current_term->namespace($_);
			}
			$current_term->comment($term->comment()) if (!defined $current_term->comment() && $term->comment());
			foreach ($term->subset()) { 
				$current_term->subset($_);
			}
			foreach ($term->synonym_set()) {
				$current_term->synonym_set($_);
			}
			foreach ($term->xref_set()->get_set()) {
				$current_term->xref_set()->add($_);
			}
			foreach ($term->intersection_of()) {
				$current_term->intersection_of($_);
			}
			foreach ($term->union_of()) {
				$current_term->union_of($_);
			}
			foreach ($term->disjoint_from()) {
				$current_term->disjoint_from($_);
			}
			$current_term->is_obsolete("true") if (!defined $current_term->is_obsolete() && $term->is_obsolete());
			foreach ($term->replaced_by()->get_set()) {
				$current_term->replaced_by($_);
			}
			foreach ($term->consider()->get_set()) {
				$current_term->consider($_);
			}
			$current_term->builtin("true") if (!defined $current_term->builtin() && $term->builtin());
			
			# fix the rel's
			my @rels = @{$ontology->get_relationships_by_target_term($term)}; 
			foreach my $r (@rels) {
				my $cola    = $r->tail();
				my $tail_id = $cola->id();
				
				#confess "There is no ID for the tail term linked to: ", $term->id() if (!$tail_id);
				
				my $tail = $result->get_term_by_id($tail_id); # Is $cola already present in the growing ontology?					
				if (!defined $tail) {
					$result->add_term($cola);            # add $cola if it is not present!
					$tail = $result->get_term_by_id($tail_id);
					
					my @more_rels = @{$ontology->get_relationships_by_target_term($cola)};
					@rels = (@rels, @more_rels); # trick to "recursively" visit the just added rel
				}
				my $r_type = $r->type();
				$r->id($tail_id."_".$r_type."_".$current_term->id());
				$r->link($tail, $current_term);
				
				$result->add_relationship($r);
				
				#
				# relationship type
				#
				my $rel_type = $ontology->get_relationship_type_by_id($r_type);
				$result->has_relationship_type($rel_type) || $result->add_relationship_type($rel_type);
			}
		} else {
			$result->add_term($term);
			push @terms, $term; # trick to "recursively" visit the just added term
		}
	}
	foreach my $rel (@{$ontology->get_relationships()}){
		if (! $result->has_relationship_id($rel->id())) {
			$result->add_relationship($rel);
			my $rel_type = $ontology->get_relationship_type_by_id($rel->type());
			$result->has_relationship_type($rel_type) || $result->add_relationship_type($rel_type);
		}
	}
	@terms = @{$result->get_terms()}; # set 'terms' (avoding the pushed ones)
	
	my $stop  = OBO::Util::Set->new();
	map {$stop->add($_->id())} @terms;

	# link the common terms
	foreach my $term (@terms) {
		my $term_id = $term->id();
		# path of references:
		foreach my $type_of_rel ("is_a", "part_of") {
			#$result->create_rel($term, $type_of_rel, $term); # reflexive one (not working line since ONTO-PERL does not allow more that one relflexive relationship)
	
			# take the paths from the original ontology
			my @ref_paths = $ontology->get_paths_term_terms_same_rel($term_id, $stop, $type_of_rel);

			foreach my $ref_path (@ref_paths) {
				#foreach my $tt (@$ref_path) {
				#	warn $tt->id();
				#}
				#warn "\n";
				my $f = @$ref_path[0]->tail();
				my $l = @$ref_path[$#$ref_path]->head();
				$result->create_rel($f, $type_of_rel, $l);
			}
		}	
	}
	return $result;
}

1;
