# $Id: Ontolome.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : Ontolome.pm
# Purpose : A Set of ontologies.
# License : Copyright (c) 2007 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Util::Ontolome;

=head1 NAME

CCO::Util::Ontolome  - A set of ontologies
    
=head1 SYNOPSIS

use CCO::Util::Set;

use strict;

my $o1 = CCO::Core::Ontology->new();

my $o2 = CCO::Core::Ontology->new();

my $o3 = CCO::Core::Ontology->new();


my $ome1 = CCO::Util::Ontolome->new();

$ome1->add($o1);

$ome1->add_all($o2, $o3);


my $ome2 = CCO::Util::Ontolome->new();

$ome2->add_all($o1, $o2, $o3);


=head1 DESCRIPTION

A collection that contains no duplicate ontology elements. More formally, an
ontolome contains no pair of ontologies $e1 and $e2 such that $e1->equals($e2). 
As implied by its name, this package models the set of ontologies.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

our @ISA = qw(CCO::Util::ObjectSet);
use CCO::Util::ObjectSet;

use strict;
use warnings;
use Carp;

=head2 union

  Usage    - $ome->union($o1, $o2, ...)
  Returns  - an ontology (CCO::Core::Ontology) being the union of the parameters (ontologies)
  Args     - the ontologies (CCO::Core::Ontology) to be united
  Function - creates an ontology having the union of terms and relationships from the given ontologies
  Remark1  - we are assuming: same IDSPACE among the ontologies and for merging terms, they must have the same name and ID
  Remark2  - the union is made on the basis of the IDs
  
=cut

sub union () {
	my ($self, @ontos) = @_;
	my $result = CCO::Core::Ontology->new();
	$result->idspace_as_string("CCO", "http://www.cellcycle.org/ontology/CCO");
	$result->default_namespace("cellcycle_ontology");
	$result->remark("Merged ontology");
	
	foreach my $ontology (@ontos) {
		$result->idspace($ontology->idspace()); # assuming the same idspace
		$result->subsets($ontology->subsets()->get_set()); # add all subsets by default
	
		my @terms = @{$ontology->get_terms()};
		foreach my $term (@terms){
			my $current_term =  $result->get_term_by_id($term->id()); # could also be $result->get_term_by_name_or_synonym()
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
	}
	return $result;
}

=head2 intersection

  Usage    - $ome->intersection($o1, $o2)
  Return   - an ontology (CCO::Core::Ontology) holding the 'intersection' of $o1 and $o2
  Args     - the two ontologies (CCO::Core::Ontology) to be intersected 
  Function - finds the intersection ontology from $o1 and $o2. All the common terms by ID 
             are added to the resulting ontology. This method provides a way of comparing two
             ontologies. The resulting ontology gives hints about the missing and identical
             terms (comparison done by term ID). A closer analysis should be done to identify
             the differences.
  Remark   - Performance issues with huge ontologies.
  
=cut

sub intersection () {
	my ($self, $onto1, $onto2) = @_;
	my $result = CCO::Core::Ontology->new();
	$result->idspace_as_string("CCO", "http://www.cellcycle.org/ontology/CCO"); # adapt it for other ontologies
	$result->default_namespace("cellcycle_ontology"); # adapt it for other ontologies
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
	
	
	# path of references
	my @pr1;
	my @pr2;
	
	# link the common terms
	foreach my $term (@{$result->get_terms()}) {
		my $term_id         = $term->id();

		my $stop  = CCO::Util::Set->new();
		map {$stop->add($_->id())} @{$result->get_terms()};

		# path of references:
		
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
	
		my $V= CCO::Util::Set->new();
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

1;
