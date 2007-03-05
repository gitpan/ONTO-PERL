# $Id: Ontology.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : Ontology.pm
# Purpose : OBO/OWL ontologies handling.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Core::Ontology;
use CCO::Util::TermSet;
use strict;
use warnings;
use Carp;
# TODO implement 'get_relationships_type_by_name()' in a similar way to 'get_terms_by_name' (using RelationshipSet)

sub new {
	my $class                     = shift;
	my $self                      = {};
        
	$self->{ID}                   = undef; # required, (1)
	$self->{NAME}                 = undef; # required, (1)
	$self->{NAMESPACE}            = undef; # required, (1)
	$self->{DATA_VERSION}         = undef; # string (0..1)
	$self->{DATE}				  = undef; # (1) The current date in dd:MM:yyyy HH:mm format
	$self->{SAVED_BY}             = undef; # string (0..1)
	$self->{REMARK}               = undef; # string (0..1)
        
	$self->{TERMS}                = {}; # map: term_id(string) vs. term(CCO::Core::Term)  (0..n)
	# TERMS_SET will be enabled once the Set is refactored
	#$self->{TERMS_SET}            = CCO::Util::TermSet->new(); # Terms (0..n)
	$self->{RELATIONSHIP_TYPES}   = {}; # map: relationship_type_id vs. relationship_type  (0..n)
	$self->{RELATIONSHIPS}        = {}; # (0..N) 
	# TODO implement RELATIONSHIP_SET
	$self->{TARGET_RELATIONSHIPS} = {}; # (0..N)
	$self->{SOURCE_RELATIONSHIPS} = {}; # (0..N)
        
	bless ($self, $class);
	return $self;
}

=head2 id

  Usage    - print $ontology->id()
  Returns  - the ontology ID (string)
  Args     - the ontology ID (string)
  Function - gets/sets the ontology ID
  
=cut
sub id {
	my $self = shift;
	if (@_) { $self->{ID} = shift }
	return $self->{ID};
}

=head2 name

  Usage    - print $ontology->name()
  Returns  - the name (string) of the ontology
  Args     - the name (string) of the ontology
  Function - gets/sets the name of the ontology
  
=cut
sub name {
	my $self = shift;
    if (@_) { $self->{NAME} = shift }
    return $self->{NAME};
}

=head2 date

  Usage    - print $ontology->date()
  Returns  - the current date (in dd:MM:yyyy HH:mm format) of the ontology
  Args     - the current date (in dd:MM:yyyy HH:mm format) of the ontology
  Function - gets/sets the date of the ontology
  
=cut
sub date {
	my $self = shift;
    if (@_) { $self->{DATE} = shift }
    return $self->{DATE};
}

=head2 namespace

  Usage    - print $ontology->namespace()
  Returns  - the namespace (string) of this ontology
  Args     - the namespace (string) of this ontology
  Function - gets/sets the namespace of this ontolog
  
=cut
sub namespace {
	my $self = shift;
    if (@_) { $self->{NAMESPACE} = uc(shift) }
    return $self->{NAMESPACE};
}

=head2 data_version

  Usage    - print $ontology->data_version()
  Returns  - the data version (string) of this ontology
  Args     - the data version (string) of this ontology
  Function - gets/sets the data version of this ontology
  
=cut
sub data_version {
	my $self = shift;
    if (@_) { $self->{DATA_VERSION} = shift }
    return $self->{DATA_VERSION};
}

=head2 saved_by

  Usage    - print $ontology->saved_by()
  Returns  - the username of the person (string) to last save this ontology
  Args     - the username of the person (string) to last save this ontology
  Function - gets/sets the username of the person to last save this ontology
  
=cut
sub saved_by {
	my $self = shift;
    if (@_) { $self->{SAVED_BY} = shift }
    return $self->{SAVED_BY};
}

=head2 remark

  Usage    - print $ontology->remark()
  Returns  - the remark (string) of this ontology
  Args     - the remark (string) of this ontology
  Function - gets/sets the remark of this ontology
  
=cut
sub remark {
	my $self = shift;
	if (@_) { $self->{REMARK} = shift }
	return $self->{REMARK};
}

=head2 add_term

  Usage    - $ontology->add_term($term)
  Returns  - the just added term (CCO::Core::Term)
  Args     - the term (CCO::Core::Term) to be added. The ID of the term to be added must have already been defined.
  Function - adds a term to this ontology
  
=cut
sub add_term {
	my ($self, $term) = @_;
	if ($term) {
		$self->{TERMS}->{$term->id()} = $term;
		#$self->{TERMS_SET}->add($term);
		return $term;
	}
}

=head2 add_term_as_string

  Usage    - $ontology->add_term_as_string($term_id, $term_name)
  Returns  - the just added term (CCO::Core::Term)
  Args     - the term id (string) and the term name (string) of term to be added
  Function - adds a term to this ontology
  
=cut
sub add_term_as_string {
    my $self = shift;
    if (@_) {
		my $term_id = shift;
		if (!$self->has_term_id($term_id)){
			my $term_name = shift;
	    
			$term_id || confess "A term to be added to this ontology must have an ID";
			$term_name || confess "A term to be added to this ontology must have a name";
	
			my $new_term = CCO::Core::Term->new();
			$new_term->id($term_id);
			$new_term->name($term_name);
			$self->add_term($new_term);
			return $new_term;
		}
    }
}

=head2 add_relationship_type

  Usage    - $ontology->add_relationship_type($relationship_type)
  Returns  - the just added relationship type (CCO::Core::RelationshipType)
  Args     - the relationship type to be added (CCO::Core::RelationshipType). The ID of the relationship type to be added must have already been defined.
  Function - adds a relationship type to this ontology
  
=cut
sub add_relationship_type {
    my ($self, $relationship_type) = @_;
    if ($relationship_type) {
		$self->{RELATIONSHIP_TYPES}->{$relationship_type->id()} = $relationship_type;
		return $relationship_type;
		
		# TODO Is necessary to implement a set of rel types? for get_relationship_types()?
		#$self->{RELATIONSHIP_TYPES_SET}->add($relationship_type);
    }
}

=head2 add_relationship_type_as_string

  Usage    - $ontology->add_relationship_type_as_string($relationship_type_id, $relationship_type_name)
  Returns  - the just added relationship type (CCO::Core::RelationshipType)
  Args     - the relationship type id (string) and the relationship type name (string) of the relationship type to be added
  Function - adds a relationship type to this ontology
  
=cut
sub add_relationship_type_as_string {
    my $self = shift;
    if (@_) {
		my $relationship_type_id = shift;
		if (!$self->has_relationship_type_id($relationship_type_id)){
			my $relationship_type_name = shift;
	    
			$relationship_type_id || confess "A relationship type to be added to this ontology must have an ID";
			$relationship_type_name || confess "A relationship type to be added to this ontology must have a name";
	
			my $new_relationship_type = CCO::Core::RelationshipType->new();
			$new_relationship_type->id($relationship_type_id);
			$new_relationship_type->name($relationship_type_name);
			$self->add_relationship_type($new_relationship_type);
			return $new_relationship_type;
		}
    }
}

=head2 delete_term

  Usage    - $ontology->delete_term($term)
  Returns  - none
  Args     - the term (CCO::Core::Term) to be deleted
  Function - deletes a term from this ontology
  
=cut
sub delete_term {
    my $self = shift;
    if (@_) {
		my $term = shift;
    
		$term->id || confess "The term to be deleted from this ontology does not have an ID";
    
		my $id = $term->id;
		if (defined($id) && defined($self->{TERMS}->{$id})) {
			delete $self->{TERMS}->{$id};
			#$self->{TERMS_SET}->remove($term);
		}
		
		# TODO delete the relationships: to its parents and children!
    }
}

=head2 has_term

  Usage    - print $ontology->has_term($term)
  Returns  - true or false
  Args     - the term (CCO::Core::Term) to be tested
  Function - checks if the given term belongs to this ontology
  
=cut
sub has_term {
	my ($self, $term) = @_;
	return (defined $term && defined($self->{TERMS}->{$term->id()}));
	# TODO Check the TERMS_SET
	#$result = 1 if (defined($id) && defined($self->{TERMS}->{$id}) && $self->{TERMS_SET}->contains($term));
}

=head2 has_term_id

  Usage    - print $ontology->has_term_id($term)
  Returns  - true or false
  Args     - the term id (string) to be tested
  Function - checks if the given term id corresponds to a term held by this ontology
  
=cut
sub has_term_id {
	my ($self, $term_id) = @_;
	return (defined $term_id && defined($self->{TERMS}->{$term_id}));
	# TODO Check the TERMS_SET
    	#return (defined $term_id && defined($self->{TERMS}->{$term_id}) && $self->{TERMS_SET}->contains($self->get_term_by_id($term_id)));
}

=head2 has_relationship_type

  Usage    - print $ontology->has_relationship_type($relationship_type)
  Returns  - true or false
  Args     - the relationship type (CCO::Core::RelationshipType) to be tested
  Function - checks if the given relationship type belongs to this ontology
  
=cut
sub has_relationship_type {
	my ($self, $relationship_type) = @_;    
	return (defined $relationship_type && defined($self->{RELATIONSHIP_TYPES}->{$relationship_type->id()}));
}

=head2 has_relationship_type_id

  Usage    - print $ontology->has_relationship_type_id($relationship_type_id)
  Returns  - true or false
  Args     - the relationship type id (string) to be tested
  Function - checks if the given relationship type id corresponds to a relationship type held by this ontology
  
=cut
sub has_relationship_type_id {
	my ($self, $relationship_type_id) = @_;
        return (defined $relationship_type_id && defined($self->{RELATIONSHIP_TYPES}->{$relationship_type_id}));
}

=head2 equals

  Usage    - print $ontology->equals($another_ontology)
  Returns  - either 1 (true) or 0 (false)
  Args     - the ontology (CCO::Core::Ontology) to compare with
  Function - tells whether this ontology is equal to the parameter
  
=cut
sub equals {
	my $self = shift;
	my $result =  0; 
	
	# TODO implement this method
	confess "Method: CCO::Core:Ontology::equals in not implemented yet";
	
	return $result;
}

=head2 get_terms

  Usage    - $ontology->get_terms() or $ontology->get_terms("CCO:I.*")
  Returns  - the terms held by this ontology as a reference to an array of CCO::Core::Term's
  Args     - none or the regular expression for filtering the terms by id's
  Function - returns the terms held by this ontology
  
=cut
sub get_terms {
    my $self = shift;
    my @terms;
    if (@_) {
		foreach my $term (values(%{$self->{TERMS}})) {
			push @terms, $term if ($term->id() =~ /$_[0]/);
		}
    } else {
		@terms = values(%{$self->{TERMS}});
		#@terms = $self->{TERMS_SET}->get_set(); # TODO this TERMS_SET is giving wrong results....
    }
    return \@terms;
}

=head2 get_terms_by_subnamespace

  Usage    - $ontology->get_terms_by_subnamespace() or $ontology->get_terms_by_subnamespace("P")
  Returns  - the terms held by this ontology corresponding to the requested subnamespace as a reference to an array of CCO::Core::Term's
  Args     - none or the subnamespace: 'P', 'I', and so on.
  Function - returns the terms held by this ontology corresponding to the requested subnamespace
  
=cut
sub get_terms_by_subnamespace {
    my $self = shift;
    my $terms;
    if (@_) {
		if (!defined $self->namespace()) {
			confess "The namespace is not defined for this ontology";
		} else {
			$terms = $self->get_terms($self->namespace().":".$_[0]);
		}
	}
	return $terms;
}

=head2 get_relationships

  Usage    - $ontology->get_relationships()
  Returns  - the relationships held by this ontology as a reference to an array of CCO::Core::Relationship's
  Args     - none
  Function - returns the relationships held by this ontology
  
=cut
sub get_relationships {
    my $self = shift;
    my @relationships = values(%{$self->{RELATIONSHIPS}});
    return \@relationships;
}

=head2 get_relationship_types

  Usage    - $ontology->get_relationship_types()
  Returns  - a reference to an array with the relationship types (CCO::Core::RelationshipType) held by this ontology
  Args     - none
  Function - returns the relationship types held by this ontology
  
=cut
sub get_relationship_types {
    my $self = shift;
    my @relationship_types = values(%{$self->{RELATIONSHIP_TYPES}});
    return \@relationship_types;
}

=head2 get_relationships_by_source_term

  Usage    - $ontology->get_relationships_by_source_term($source_term)
  Returns  - a reference to an array with the relationship (CCO::Core::Relationship) connecting this term to its children
  Args     - the term (CCO::Core::Term) for which its relationships will be found out
  Function - returns the relationships associated to the given source term
  
=cut
sub get_relationships_by_source_term {
	my $self = shift;
	my $result = CCO::Util::Set->new();
	if (@_) {
		my $term = shift;
		my @rels = values(%{$self->{SOURCE_RELATIONSHIPS}->{$term}});
		foreach my $rel (@rels) {
			$result->add($rel);
		}
	}
	my @arr = $result->get_set();
    return \@arr;
}

=head2 get_relationships_by_target_term

  Usage    - $ontology->get_relationships_by_target_term($target_term)
  Returns  - a reference to an array with the relationship (CCO::Core::Relationship) connecting this term to its parents
  Args     - the term (CCO::Core::Term) for which its relationships will be found out
  Function - returns the relationships associated to the given target term
  
=cut
sub get_relationships_by_target_term {
	my $self = shift;
	my $result = CCO::Util::Set->new();
	if (@_) {
		my $term = shift;
		my @rels = values(%{$self->{TARGET_RELATIONSHIPS}->{$term}});
		foreach my $rel (@rels) {
			$result->add($rel);
		}
	}
	my @arr = $result->get_set();
    return \@arr;
}

=head2 get_term_by_id

  Usage    - $ontology->get_term_by_id($id)
  Returns  - the term (CCO::Core::Term) associated to the given ID
  Args     - the term's ID (string)
  Function - returns the term associated to the given ID
  
=cut
sub get_term_by_id {
	my ($self, $id) = @_;
	return $self->{TERMS}->{$id};
}

=head2 set_term_id

  Usage    - $ontology->set_term_id($term, $new_id)
  Returns  - the term (CCO::Core::Term) with its new ID
  Args     - the term (CCO::Core::Term) and its new term's ID (string)
  Function - sets a new term ID for the given term 
  
=cut
sub set_term_id {
    my $self = shift;
    my $result;
    if (@_) {
    	my $term = shift;
    	if ($self->has_term($term)) {
			my $new_term_id = shift;
    		if (!$self->has_term_id($new_term_id)) {
				my $old_id = $term->id();
				$term->id($new_term_id);
				$self->{TERMS}->{$new_term_id} = $self->{TERMS}->{$old_id};
				delete $self->{TERMS}->{$old_id};
				# TODO adapt the relationship ids of this term: CCO:P0000001_is_a_CCO:P0000002  => CCO:P0000003_is_a_CCO:P0000002
			    return $self->{TERMS}->{$new_term_id};
    		} else {
    			confess "The given new ID is already used by: ", $self->get_term_by_id($new_term_id)->name();
    		}
    	} else {
    		confess "The term for which you want to modify its ID is not in the ontology";
    	}
    }
}

=head2 get_relationship_type_by_id

  Usage    - $ontology->get_relationship_type_by_id($id)
  Returns  - the relationship type (CCO::Core::RelationshipType) associated to the given id
  Args     - the relationship type's id (string)
  Function - returns the relationship type associated to the given id
  
=cut
sub get_relationship_type_by_id {
    my $self = shift;
    my $result;
    if (@_) {
		my $id = shift;
		$result = $self->{RELATIONSHIP_TYPES}->{$id};
    }
    return $result;
}

=head2 get_term_by_name

  Usage    - $ontology->get_term_by_name($name)
  Returns  - the term (CCO::Core::Term) associated to the given name
  Args     - the term's name (string)
  Function - returns the term associated to the given name
  
=cut
sub get_term_by_name {
	# TODO look also for the synonyms?
    my ($self, $name) = ($_[0], lc($_[1]));
    my $result;
    if ($name) {		
		foreach my $term (@{$self->get_terms()}) { # return the exact occurrence
			$result = $term, last if (defined ($term->name()) && (lc($term->name()) eq $name)); 
		}
    }
    return $result;
}

=head2 get_terms_by_name

  Usage    - $ontology->get_terms_by_name($name)
  Returns  - the term set (CCO::Util::TermSet) with all the terms (CCO::Core::Term) having $name in their names 
  Args     - the term's name (string)
  Function - returns the terms having $name in their names 
  
=cut
sub get_terms_by_name {
    my $self = shift;
    my $result;
    if (@_) {
		my $name = lc(shift);
		my @terms = @{$self->get_terms()};
		$result = CCO::Util::TermSet->new();
		
		# TODO the following two lines are equivalent to the 'for' loop
		#my @found_terms = grep {lc($_->name()) =~ /$name/} @terms;
		#$result->add_all(@found_terms);
		
		foreach my $term (@terms) { # return the all the occurrences
			$result->add($term) if (defined ($term->name()) && lc($term->name()) =~ /$name/); 
		}
    }
    return $result;
}

=head2 get_relationship_type_by_name

  Usage    - $ontology->get_relationship_type_by_name($name)
  Returns  - the relationship type (CCO::Core::RelationshipType) associated to the given name
  Args     - the relationship type's name (string)
  Function - returns the relationship type associated to the given name
  
=cut
sub get_relationship_type_by_name {
    my $self = shift;
    my $result;
    if (@_) {
		my $name = lc(shift);
		foreach my $rel_type (@{$self->get_relationship_types()}) { # return the exact occurrence
			$result = $rel_type, last if (defined ($rel_type->name()) && (lc($rel_type->name()) eq $name)); 
		}
    }
    return $result;
}

=head2 add_relationship

  Usage    - $ontology->add_relationship($relationship)
  Returns  - none
  Args     - the relationship (CCO::Core::Relationship) to be added between two existing terms or two relationship types
  Function - adds a relationship between either two terms or two relationship types. If the terms or relationship types bound by this relationship are not yet in the ontology, they will be added
  
=cut
sub add_relationship {
    my ($self, $relationship) = @_;
    
    my $id = $relationship->id();
    $id || confess "The relationship to be added to this ontology does not have an ID";
    $self->{RELATIONSHIPS}->{$id} = $relationship;
    
    #
    # Are the target and source elements (term or relationship type) connected by $relationship already in this ontology? if not, add them.
    #
    my $target_element = $self->{RELATIONSHIPS}->{$id}->head();
    my $source_element = $self->{RELATIONSHIPS}->{$id}->tail();
    if (UNIVERSAL::isa($target_element, "CCO::Core::Term") && UNIVERSAL::isa($source_element, "CCO::Core::Term")) {
	    $self->has_term($target_element) || $self->add_term($target_element);	
	    $self->has_term($source_element) || $self->add_term($source_element);	
    } elsif (UNIVERSAL::isa($target_element, "CCO::Core::RelationshipType") && UNIVERSAL::isa($source_element, "CCO::Core::RelationshipType")) {
    	$self->has_relationship_type($target_element) || $self->add_relationship_type($target_element);
    	$self->has_relationship_type($source_element) || $self->add_relationship_type($source_element);
    } else {
    	confess "An unrecognized object type (nor a Term, nor a RelationshipType) was found as part of the relationship with ID: '", $id, "'";
    }
    
    # for getting children and parents
    $self->{TARGET_RELATIONSHIPS}->{$relationship->head()}->{$relationship->tail()} = $relationship;
    $self->{SOURCE_RELATIONSHIPS}->{$relationship->tail()}->{$relationship->head()} = $relationship;
}

=head2 get_relationship_by_id

  Usage    - print $ontology->get_relationship_by_id()
  Returns  - the relationship (CCO::Core::Relationship) associated to the given id
  Args     - the relationship id (string)
  Function - returns the relationship associated to the given relationship id
  
=cut
sub get_relationship_by_id {
	my ($self, $id) = @_;
	return $self->{RELATIONSHIPS}->{$id};
}

=head2 get_child_terms

  Usage    - $ontology->get_child_terms($term)
  Returns  - a reference to an array with the child terms (CCO::Core::Term) of the given term
  Args     - the term (CCO::Core::Term) for which the children will be found
  Function - returns the child terms of the given term
  
=cut
sub get_child_terms {
	my $self = shift;
	my $result = CCO::Util::TermSet->new();
    if (@_) {
		my $term = shift;
		my @rels = values(%{$self->{TARGET_RELATIONSHIPS}->{$term}});
		foreach my $rel (@rels) {
			$result->add($rel->tail());
		}
    }
	my @arr = $result->get_set();
    return \@arr;
}

=head2 get_parent_terms

  Usage    - $ontology->get_parent_terms($term)
  Returns  - a reference to an array with the parent terms (CCO::Core::Term) of the given term
  Args     - the term (CCO::Core::Term) for which the parents will be found
  Function - returns the parent terms of the given term
  
=cut
sub get_parent_terms {
	my $self = shift;
	my $result = CCO::Util::TermSet->new();
    if (@_) {
		my $term = shift;
		my @rels = values(%{$self->{SOURCE_RELATIONSHIPS}->{$term}});
		foreach my $rel (@rels) {
			$result->add($rel->head());
		}
    }
    #return $result->get_set();
    my @arr = $result->get_set();
    return \@arr;
}

=head2 get_head_by_relationship_type

  Usage    - $ontology->get_head_by_relationship_type($term, $relationship_type) or $ontology->get_head_by_relationship_type($rel_type, $relationship_type)
  Returns  - a reference to an array of terms (CCO::Core::Term) or relationship types (CCO::Core::RelationshipType) pointed out by the relationship of the given type; otherwise undef
  Args     - the term (CCO::Core::Term) or relationship type (CCO::Core::RelationshipType) and the pointing relationship type (CCO::Core::RelationshipType)
  Function - returns the terms or relationship types pointed out by the relationship of the given type
  
=cut
sub get_head_by_relationship_type {
	my ($self, $element, $relationship_type) = @_;
	# <EASR> Performance improvement
	my @heads;
	if ($element && $relationship_type) {
		my @rels = values(%{$self->{SOURCE_RELATIONSHIPS}->{$element}});
		my $relationship_type_id = $relationship_type->id();
                foreach my $rel (@rels) {
			push @heads, $rel->head() if ($rel->type() eq $relationship_type_id);
                }
        }
	return \@heads;
	# </EASR>
#	my $result = CCO::Util::Set->new();
#	if ($element && $relationship_type) {
#		my @rels = values(%{$self->{SOURCE_RELATIONSHIPS}->{$element}});
#		foreach my $rel (@rels) {
#			 $result->add($rel->head()) if ($rel->type() eq $relationship_type->id());
#		}
#	}
#	my @arr = $result->get_set();
#	return \@arr;
}

=head2 get_tail_by_relationship_type

  Usage    - $ontology->get_tail_by_relationship_type($term, $relationship_type) or $ontology->get_tail_by_relationship_type($rel_type, $relationship_type)
  Returns  - a reference to an array of terms (CCO::Core::Term) or relationship types (CCO::Core::RelationshipType) pointing out the given term by means of the given relationship type; otherwise undef
  Args     - the term (CCO::Core::Term) or relationship type (CCO::Core::RelationshipType) and the relationship type (CCO::Core::RelationshipType)
  Function - returns the terms or relationship types pointing out the given term by means of the given relationship type
  
=cut
sub get_tail_by_relationship_type {
        # <EASR> Performance improvement
	my ($self, $element, $relationship_type) = @_;
        my @tails;
        if ($element && $relationship_type) {
                my @rels = values(%{$self->{TARGET_RELATIONSHIPS}->{$element}});
                my $relationship_type_id = $relationship_type->id();
                foreach my $rel (@rels) {
                        push @tails, $rel->tail() if ($rel->type() eq $relationship_type_id);
                }
        }
        return \@tails;
        # </EASR>
#	my $self = shift;
#	my $result = CCO::Util::Set->new();
#   if (@_) {
#		my $element = shift;
#		my $relationship_type = shift;
#		my @rels = values(%{$self->{TARGET_RELATIONSHIPS}->{$element}});
#		foreach my $rel (@rels) {
#			 $result->add($rel->tail()) if ($rel->type() eq $relationship_type->id());
#		}
#   }
#    my @arr = $result->get_set();
#    return \@arr;
}




=head2 get_number_of_terms

  Usage    - $ontology->get_number_of_terms()
  Returns  - the number of terms held by this ontology
  Args     - none
  Function - returns the number of terms held by this ontology
  
=cut
sub get_number_of_terms {
    my $self = shift;
    return scalar values(%{$self->{TERMS}});
}

=head2 get_number_of_relationships

  Usage    - $ontology->get_number_of_relationships()
  Returns  - the number of relationships held by this ontology
  Args     - none
  Function - returns the number of relationships held by this ontology
  
=cut
sub get_number_of_relationships {
    my $self = shift;
    return scalar values(%{$self->{RELATIONSHIPS}});
}

=head2 get_number_of_relationship_types

  Usage    - $ontology->get_number_of_relationship_types()
  Returns  - the number of relationship types held by this ontology
  Args     - none
  Function - returns the number of relationship types held by this ontology
  
=cut
sub get_number_of_relationship_types {
    my $self = shift;
    return scalar values(%{$self->{RELATIONSHIP_TYPES}});
}

=head2 export

  Usage    - $ontology->export($file_handle, $export_format)
  Returns  - exports this ontology
  Args     - the file handle (STDOUT, STDERR, ...) and the format: obo (by default), xml, owl, dot, gml, xgmml, sbml. Default file handle: STDOUT.
  Function - exports this ontology
  
=cut
sub export {
    my $self = shift;
    my $file_handle = shift || \*STDOUT;
    my $format = shift || "obo";
    
    my $possible_formats = CCO::Util::Set->new();
	$possible_formats->add_all('obo', 'xml', 'owl', 'dot', 'gml', 'xgmml', 'sbml');
	if (!$possible_formats->contains($format)) {
		confess "The format must be one of the following: 'obo', 'xml', 'owl', 'dot', 'gml', 'xgmml', 'sbml";
	}
    
    if ($format eq "obo") {
	    
		# preambule: OBO header tags
		print $file_handle "format-version: 1.2\n";
		chomp(my $local_date = `date '+%d:%m:%Y %H:%M'`);
		print $file_handle "date: ", (defined $self->date())?$self->date():$local_date, "\n";
		print $file_handle "auto-generated-by: onto-perl\n"; # TODO store this value?
		print $file_handle "default-namespace: ", $self->namespace(), "\n" if ($self->namespace());
		print $file_handle "remark: ", $self->remark(), "\n" if ($self->remark());
	
	    # terms
	    my @all_terms = values(%{$self->{TERMS}});
	    foreach my $term (sort {$a->id() cmp $b->id()} @all_terms) {
	    	#
	    	# [Term]
	    	#
	    	print $file_handle "\n[Term]";
	    	
	    	#
	    	# id:
	    	#
	    	print $file_handle "\nid: ", $term->id();
	    	
	    	#
	    	# name:
	    	#
	    	if (defined $term->name()) {
	    		print $file_handle "\nname: ", $term->name();
	    	} else {
	    		confess "The term with id: ", $term->id(), " has no name!" ;
	    	}
	    	
	    	#
			# alt_id:
			#
			foreach my $alt_id ($term->alt_id()->get_set()) {
				print $file_handle "\nalt_id: ", $alt_id;
			}
	    	
	    	#
	    	# builtin:
	    	#
	    	print $file_handle "\nbuiltin: true" if ($term->builtin() == 1);
	    	
	    	#
	    	# def:
	    	#
	    	print $file_handle "\ndef: ", $term->def_as_string() if (defined $term->def()->text());
	    	
	    	#
	    	# comment:
	    	#
	    	print $file_handle "\ncomment: ", $term->comment() if (defined $term->comment());

	    	#
	    	# synonym:
	    	#
	    	foreach my $synonym (sort {$a->def()->text() cmp $b->def()->text()} $term->synonym_set()) {
				print $file_handle "\nsynonym: \"", $synonym->def()->text(), "\" ", $synonym->type(), " ", $synonym->def()->dbxref_set_as_string();
	    	}
	    	
	    	#
	    	# xref:
	    	#
	    	foreach my $xref (sort {$a->as_string() cmp $b->as_string()} $term->xref_set_as_string()) {
	    		print $file_handle "\nxref: ", $xref->as_string();
	    	}
	    	
	    	#
	    	# is_a:
	    	#
	    	my $rt = $self->get_relationship_type_by_id("is_a");
	    	if (defined $rt)  {
		    	my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
		    	foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
		    		if (defined $head->name()) {
			    		print $file_handle "\nis_a: ", $head->id(), " ! ", $head->name();
			    	} else {
			    		confess "The term with id: ", $head->id(), " has no name!" ;
			    	}
		    	}
	    	}	    		    	
	    	
			#
			# disjoint_from:
			#
			foreach my $disjoint_term_id ($term->disjoint_from()) {
				print $file_handle "\ndisjoint_from: ", $disjoint_term_id;
			}
			
			#
	    	# relationship:
	    	#
	    	foreach $rt (@{$self->get_relationship_types()}) {
	    		if ($rt->id() ne "is_a") { # is_a is printed above
					my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
					foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
						print $file_handle "\nrelationship: ", $rt->id(), " ", $head->id(), " ! ", $head->name();
					}
	    		}
	    	}
	    	
	    	#
	    	# end
	    	#
	    	print $file_handle "\n";
	    }
	    # relationship types
	    my @all_relationship_types = values(%{$self->{RELATIONSHIP_TYPES}});
	    foreach my $relationship_type (sort {$a->id() cmp $b->id()} @all_relationship_types) {
			print $file_handle "\n[Typedef]";
	    	print $file_handle "\nid: ", $relationship_type->id();
	    	print $file_handle "\nname: ", $relationship_type->name();
	    	print $file_handle "\nbuiltin: true" if ($relationship_type->builtin() == 1);
	    	print $file_handle "\ndef: ", $relationship_type->def_as_string() if (defined $relationship_type->def()->text());
	    	print $file_handle "\ncomment: ", $relationship_type->comment() if (defined $relationship_type->comment());

	    	foreach my $synonym ($relationship_type->synonym_set()) {
	    		print $file_handle "\nsynonym: \"", $synonym->def()->text(), "\" ", $synonym->type(), " ", $synonym->def()->dbxref_set_as_string();
	    	}
	    	
	    	foreach my $xref (sort {$a cmp $b} $relationship_type->xref_set_as_string()) {
	    		print $file_handle "\nxref: ", $xref->as_string();
	    	}

	    	print $file_handle "\nis_anti_symmetric: true" if ($relationship_type->is_anti_symmetric() == 1);
	    	print $file_handle "\nis_cyclic: true" if ($relationship_type->is_cyclic() == 1);
	    	print $file_handle "\nis_reflexive: true" if ($relationship_type->is_reflexive() == 1);
	    	print $file_handle "\nis_symmetric: true" if ($relationship_type->is_symmetric() == 1);
	    	print $file_handle "\nis_transitive: true" if ($relationship_type->is_transitive() == 1);
	    	
	    	#
	    	# is_a: TODO missing function to retieve the rel types 
	    	#
	    	my $rt = $self->get_relationship_type_by_name("is_a");
	    	if (defined $rt)  {
		    	my @heads = @{$self->get_head_by_relationship_type($relationship_type, $rt)};
		    	foreach my $head (@heads) {
		    		if (defined $head->name()) {
			    		print $file_handle "\nis_a: ", $head->id(), " ! ", $head->name();
			    	} else {
			    		confess "The relationship type with id: ", $head->id(), " has no name!" ;
					}
		    	}
	    	}
	    	
	    	print $file_handle "\nis_metadata_tag: true" if ($relationship_type->is_metadata_tag() == 1);
	    	
	    	print $file_handle "\n";
	    }
    } elsif ($format eq "xml") {
		# terms
	    my @all_terms = values(%{$self->{TERMS}});
	    
		# preambule: OBO header tags
		print $file_handle "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n";
		print $file_handle "<cco>\n";
		
		print $file_handle "\t<header>\n";
		print $file_handle "\t\t<format-version>1.2</format-version>\n";
		chomp(my $date = (defined $self->date())?$self->date():`date '+%d:%m:%Y %H:%M'`);
		print $file_handle "\t\t<hasDate>", $date, "</hasDate>\n";
		print $file_handle "\t\t<savedBy>", $self->saved_by(), "</savedBy>\n" if ($self->saved_by());
		print $file_handle "\t\t<default-namespace>", $self->namespace(), "</default-namespace>\n" if ($self->namespace());
		print $file_handle "\t\t<autoGeneratedBy>", $0, "</autoGeneratedBy>\n";
		print $file_handle "\t\t<remark>", $self->remark(), "</remark>\n" if ($self->remark());
		print $file_handle "\t</header>\n\n";
		
		foreach my $term (sort {$a->id() cmp $b->id()} @all_terms) {
			#
	    	# [Term]
	    	#
	    	print $file_handle "\t<term>\n";
	    	
	    	#
	    	# id:
	    	#
	    	print $file_handle "\t\t<id>", $term->id(), "</id>\n";
	    	
	    	#
	    	# name:
	    	#
	    	if (defined $term->name()) {
	    		print $file_handle "\t\t<name>", $term->name(), "</name>\n";
	    	} else {
	    		confess "The term with id: ", $term->id(), " has no name!" ;
	    	}
	    	
	    	#
			# alt_id:
			#
			foreach my $alt_id ($term->alt_id()->get_set()) {
				print $file_handle "\t\t<hasAlternativeId>", $alt_id, "</hasAlternativeId>\n";
			}

			#
			# comment
			#
			print $file_handle "\t<comment>", $term->comment(), "</comment>\n" if ($term->comment());
			
	    	#
	    	# def:
	    	#
	    	if (defined $term->def()->text()) {
				print $file_handle "\t\t<Definition label=\"", $term->def()->text(), "\">\n";				
				for my $ref ($term->def()->dbxref_set()->get_set()) {
			        print $file_handle "\t\t\t<DbXref xref=\"", $ref->name(), "\">\n";
			        print $file_handle "\t\t\t\t<acc>", $ref->acc(),"</acc>\n";
			        print $file_handle "\t\t\t\t<dbname>", $ref->db(),"</dbname>\n";
			        print $file_handle "\t\t\t</DbXref>\n";
				}
				print $file_handle "\t\t</Definition>\n";
			}

			#
			# disjoint_from:
			#
			foreach my $disjoint_term_id ($term->disjoint_from()) {
				print $file_handle "\t\t<disjoint_from>", $disjoint_term_id, "</disjoint_from>\n";
			}
			
	    	#
	    	# is_a:
	    	#
	    	my $rt = $self->get_relationship_type_by_name("is_a");
	    	if (defined $rt)  {
		    	my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
		    	foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
		    		if (defined $head->name()) {
			    		print $file_handle "\t\t<is_a id=\"", $head->id(), "\">", $head->name(), "</is_a>\n";
			    	} else {
			    		confess "The term with id: ", $head->id(), " has no name!" ;
			    	}
		    	}
	    	}
			
			#
			# relationship:
			#
	    	foreach $rt (@{$self->get_relationship_types()}) {
	    		if ($rt->name() ne "is_a") { # is_a is printed above
					my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
					foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
						print $file_handle "\t\t<relationship>\n";
						print $file_handle "\t\t\t<type>", $rt->name(), "</type>\n";
						print $file_handle "\t\t\t<target id=\"", $head->id(), "\">", $head->name(),"</target>\n";
						print $file_handle "\t\t</relationship>\n";
					}
	    		}
	    	}
	    	#
	    	# synonym:
	    	#
	    	foreach my $synonym ($term->synonym_set()) {
	    		print $file_handle "\t\t<synonym scope=\"", $synonym->type(), "\">", $synonym->def_as_string(), "</synonym>\n";
	    	}
	    	
	    	#
	    	# comment:
	    	#
	    	print $file_handle "\t\t<comment>", $term->comment(), "</comment>\n" if (defined $term->comment());
	    	
	    	#
	    	# xref:
	    	#
	    	foreach my $xref (sort {$a cmp $b} $term->xref_set_as_string()) {
	    		print $file_handle "\t\t<xref>", $xref->as_string(), "</xref>\n";
	    	}
	    	
	    	#
	    	# builtin:
	    	#
	    	print $file_handle "\t\t<builtin>true</builtin>" if ($term->builtin() == 1);
	    	
	    	#
	    	# end
	    	#
	    	print $file_handle "\t</term>\n\n";
	    }
		
		# relationship types
	    my @all_relationship_types = values(%{$self->{RELATIONSHIP_TYPES}});
	    foreach my $relationship_type (sort {$a->id() cmp $b->id()} @all_relationship_types) {
		   	print $file_handle "\t<typedef>\n";
	    	print $file_handle "\t\t<id>", $relationship_type->id(), "</id>\n";
	    	print $file_handle "\t\t<name>", $relationship_type->name(), "</name>\n";
	    	print $file_handle "\t\t<builtin>true</builtin>" if ($relationship_type->builtin() == 1);
	    	print $file_handle "\t\t<def>", $relationship_type->def_as_string(), "</def>\n" if (defined $relationship_type->def()->text());
	    	foreach my $rt_synonym ($relationship_type->synonym_set()) {
				print $file_handle "\t\t<synonym scope=\"", $rt_synonym->type(), "\">", $rt_synonym->def()->text(), "</synonym>\n";
			}
	    	print $file_handle "\t\t<comment>", $relationship_type->comment(), "</comment>\n" if (defined $relationship_type->comment());
	    	print $file_handle "\t\t<is_cyclic>true</is_cyclic>" if ($relationship_type->is_cyclic() == 1);
	    	print $file_handle "\t\t<is_reflexive>true</is_reflexive>" if ($relationship_type->is_reflexive() == 1);
	    	print $file_handle "\t\t<is_symmetric>true</is_symmetric>" if ($relationship_type->is_symmetric() == 1);
	    	print $file_handle "\t\t<is_anti_symmetric>true</is_anti_symmetric>" if ($relationship_type->is_anti_symmetric() == 1);
	    	print $file_handle "\t\t<is_transitive>true</is_transitive>" if ($relationship_type->is_transitive() == 1);
	    	print $file_handle "\t\t<is_metadata_tag>true</is_metadata_tag>" if ($relationship_type->is_metadata_tag() == 1);
	    	foreach my $xref (sort {$a cmp $b} $relationship_type->xref_set_as_string()) {
	    		print $file_handle "\t\t<xref>", $xref->as_string(), "</xref>\n";
	    	}
	    	
	    	print $file_handle "\t</typedef>\n\n";
	    }
	    
	    print $file_handle "</cco>\n";
    } elsif ($format eq "owl") {
                #
                # preambule
                #
                print $file_handle "<?xml version=\"1.0\"?>\n";
                print $file_handle "<rdf:RDF\n";
                print $file_handle "\txmlns=\"http://www.cellcycleontology.org/obo/owl/\"\n";
                print $file_handle "\txml:base=\"http://www.cellcycleontology.org/owl/\"\n";
                print $file_handle "\txmlns:p1=\"http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl#\"\n";
                print $file_handle "\txmlns:dcterms=\"http://purl.org/dc/terms/\"\n";
                print $file_handle "\txmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"\n";
                print $file_handle "\txmlns:xsp=\"http://www.owl-ontologies.com/2005/08/07/xsp.owl#\"\n";
                print $file_handle "\txmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n";
                print $file_handle "\txmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n";
                print $file_handle "\txmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n";
                print $file_handle "\txmlns:owl=\"http://www.w3.org/2002/07/owl#\"\n";
                print $file_handle "\txmlns:oboInOwl=\"http://www.cellcycleontology.org/formats/oboInOwl#\"\n";
                print $file_handle "\txmlns:oboContent=\"http://www.cellcycleontology.org/obo/owl/\"\n";
                print $file_handle ">\n";

                #
                # meta-data: oboInOwl elements
                #
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasAlternativeId\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasDate\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasVersion\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasDbXref\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasDefaultNamespace\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasNamespace\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasDefinition\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasExactSynonym\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasNarrowSynonym\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasBroadSynonym\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasRelatedSynonym\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasSynonymType\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#hasSubset\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#inSubset\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#savedBy\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#replacedBy\"/>\n";
                print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#consider\"/>\n";
                print $file_handle "<owl:Class rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#DbXref\"/>\n";
                print $file_handle "<owl:Class rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#Definition\"/>\n";
                print $file_handle "<owl:Class rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#Subset\"/>\n";
                print $file_handle "<owl:Class rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#Synonym\"/>\n";
                print $file_handle "<owl:Class rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#SynonymType\"/>\n";
                print $file_handle "<owl:Class rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#ObsoleteClass\"/>\n";
                print $file_handle "<owl:ObjectProperty rdf:about=\"http://www.cellcycleontology.org/formats/oboInOwl#ObsoleteProperty\"/>\n";

		#
		# header: http://oe0.spreadsheets.google.com/ccc?id=o06770842196506107736.4732937099693365844.03735622766900057712.3276521997699206495#
		#
		print $file_handle "<owl:Ontology rdf:about=\"\">\n";
		print $file_handle "\t<owl:versionInfo rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $self->data_version(), "</owl:versionInfo>\n" if ($self->data_version());;
		print $file_handle "\t<oboInOwl:hasDate rdf:datatype=\"http://www.w3.org/2001/XMLSchema#dateTime\">", $self->date(), "</oboInOwl:hasDate>\n" if ($self->date());
		print $file_handle "\t<oboInOwl:savedBy rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $self->saved_by(), "</oboInOwl:savedBy>\n" if ($self->saved_by());
		# autoGeneratedBy is not supported by oboInOwl
		print $file_handle "\t<autoGeneratedBy rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $0, "</autoGeneratedBy>\n" if ($0);
		print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $self->remark(), "</rdfs:comment>\n" if ($self->remark());
		print $file_handle "\t<owl:imports rdf:resource=\"http://purl.org/dc/elements/1.1/\"/>\n";
		# TODO Consider subsets like:
		#    <oboInOwl:hasSubset>
		#	   <oboInOwl:Subset rdf:about="http://purl.org/obo/owl/gosubset_prok">
		#        <rdfs:comment rdf:datatype="http://www.w3.org/2001/XMLSchema#string">Prokaryotic GO subset</rdfs:comment>
		#      </oboInOwl:Subset>
		#    </oboInOwl:hasSubset>
		print $file_handle "</owl:Ontology>\n\n";
		
		#
		# OLD: oboInOwl elements
		#
#		print $file_handle "<owl:DatatypeProperty rdf:about=\"http://www.cellcycleontology.org/oboInOwl#dbname\">\n";
#		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#FunctionalProperty\"/>\n";
#		print $file_handle "\t<rdfs:range rdf:resource=\"http://www.w3.org/2001/XMLSchema#string\"/>\n";
#		print $file_handle "</owl:DatatypeProperty>\n";
		
#		print $file_handle "<owl:DatatypeProperty rdf:about=\"http://www.cellcycleontology.org/oboInOwl#acc\">\n";
#		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#FunctionalProperty\"/>\n";
#		print $file_handle "\t<rdfs:range rdf:resource=\"http://www.w3.org/2001/XMLSchema#string\"/>\n";
#		print $file_handle "</owl:DatatypeProperty>\n";
		
#		print $file_handle "<owl:ObjectProperty rdf:about=\"http://www.cellcycleontology.org/oboInOwl#has_dbxref\"/>\n";
		
#		print $file_handle "<owl:Class rdf:about=\"http://www.cellcycleontology.org/oboInOwl#DbXref\">\n";
#		print $file_handle "\t<owl:intersectionOf rdf:parseType=\"Collection\">\n";
#		print $file_handle "\t<owl:Restriction>\n";
#		print $file_handle "\t\t<owl:cardinality rdf:datatype=\"http://www.w3.org/2001/XMLSchema#nonNegativeInteger\">1</owl:cardinality>\n";
#		print $file_handle "\t\t<owl:onProperty rdf:resource=\"http://www.cellcycleontology.org/oboInOwl#dbname\"/>\n";
#		print $file_handle "\t</owl:Restriction>\n";
#		print $file_handle "\t<owl:Restriction>\n";
#		print $file_handle "\t\t<owl:cardinality rdf:datatype=\"http://www.w3.org/2001/XMLSchema#nonNegativeInteger\">1</owl:cardinality>\n";
#		print $file_handle "\t\t<owl:onProperty rdf:resource=\"http://www.cellcycleontology.org/oboInOwl#acc\"/>\n";
#		print $file_handle "\t</owl:Restriction>\n";
#		print $file_handle "\t</owl:intersectionOf>\n";
#		print $file_handle "</owl:Class>\n";
   
#		print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/oboInOwl#has_definition\"/>\n";
#		print $file_handle "<owl:AnnotationProperty rdf:about=\"http://www.cellcycleontology.org/oboInOwl#has_synonym\"/>\n";
		
		#
		# term
		#
		my @all_terms = values(%{$self->{TERMS}});
		# visit the terms
		foreach my $term (sort {$a->id() cmp $b->id()} @all_terms){
			#
			# Class name
			#
			#print $file_handle "<owl:Class rdf:ID=\"", obo_id2owl_id($term->id()), "\">\n";
			print $file_handle "<owl:Class rdf:about=\"", obo_id2owl_id($term->id()), "\">\n";
			
			#
			# label name = class name
			#
			print $file_handle "\t<rdfs:label xml:lang=\"en\">", $term->name(), "</rdfs:label>\n";
			
			#
			# alt_id:
			#
			foreach my $alt_id ($term->alt_id()->get_set()) {
				print $file_handle "\t<hasAlternativeId rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $alt_id, "</hasAlternativeId>\n";
			}
			
			#
			# comment
			#
			print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $term->comment(), "</rdfs:comment>\n" if ($term->comment());
			
			#
			# xref's
			#
			foreach my $xref ($term->xref_set_as_string()) {
				print $file_handle "\t<xref rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $xref->as_string(), "</xref>\n";
			}
			
			#
			# Def
			#      
			if (defined $term->def()->text()) {
				print $file_handle "\t<oboInOwl:hasDefinition>\n";
				print $file_handle "\t\t<oboInOwl:Definition>\n";
				print $file_handle "\t\t\t<rdfs:label xml:lang=\"en\">", $term->def()->text(), "</rdfs:label>\n";
				
				for my $ref ($term->def()->dbxref_set()->get_set()) {
					print $file_handle "\t\t\t<oboInOwl:hasDbXref>\n";
			       		print $file_handle "\t\t\t<oboInOwl:DbXref rdf:about=\"/", $ref->db(), "#", $ref->acc(),"\">\n";
			        #	print $file_handle "\t\t\t\t<oboInOwl:acc>", $ref->acc(),"</oboInOwl:acc>\n";
			        #	print $file_handle "\t\t\t\t<oboInOwl:dbname>", $ref->db(),"</oboInOwl:dbname>\n";
			        	print $file_handle "\t\t\t</oboInOwl:DbXref>\n";
			        	print $file_handle "\t\t\t</oboInOwl:hasDbXref>\n";
				}
		        	
				print $file_handle "\t\t</oboInOwl:Definition>\n";
				print $file_handle "\t</oboInOwl:hasDefinition>\n";
			}
			
			#
			# dbxref: todo: put them inside the definition
			#
#			foreach my $dbxref (@{$_->definition_dbxref_list || []}) {
#				my $comment = $dbxref->xref_key;
#				#print STDERR "comment: ", $comment, "\t";
#				my $xrf_id = $cco_id_i_map->get_cco_id_by_term ($comment);
#				if (!defined $xrf_id) { # Does this term have an associated ID?
#					$xrf_id = $cco_id_i_map->get_new_cco_id("CCO", "I", $comment);
#				}
#				#print STDERR "xrf_id: ",$xrf_id, "\n";
#				my $xrf_type = $cco_id_r_map->get_cco_id_by_term($dbxref->xref_dbname);
#				die "The term (", $dbxref->xref_dbname, ") has not been defined in the references file." if (!defined $xrf_type);
#				$xrf_type = obo_id2owl_id($xrf_type);
#				
#				if ($dbxref->xref_dbname eq "http"){ # 'http' considered as a DB ;-)
#					$comment = "http:".$comment;
#				}
#				
#				my $instance_id = obo_id2owl_id($xrf_id);
#				$instances_buffer = "<".$xrf_type." rdf:ID=\"".$instance_id."\">\n"; # ID based on $comment
#				#print STDERR $dbxref->xref_dbname.":".$comment, "\n";
#				$instances_buffer .= TB."<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">".$comment."</rdfs:comment>\n";
#				if ($dbxref->xref_desc) { 
#					print STDERR "dbxref description: ".$dbxref->xref_desc; # <dbxref description>
#					exit 1;
#				}
#				$instances_buffer .= "</".$xrf_type.">\n";
#				
#				# has_reference related to dbxref
#				$has_ref{$instance_id} = $instances_buffer;
#				print "\t<has_reference rdf:resource=\"#", $instance_id, "\"/>\n";
#			}
			
		#
		# synonym:
		#
	    	foreach my $synonym ($term->synonym_set()) {
			my $synonym_type;
			if ($synonym->type() eq "EXACT") {
				$synonym_type = "hasExactSynonym";
			} elsif ($synonym->type() eq "BROAD") {
                                $synonym_type = "hasExactSynonym";
			} elsif ($synonym->type() eq "NARROW") {
                                $synonym_type = "hasNarrowSynonym";
			} elsif ($synonym->type() eq "RELATED") {
                                $synonym_type = "hasRelatedSynonym";
			} else {
				confess "A non-valid synonym type has been found ($synonym). Valid types: EXACT, BROAD, NARROW, RELATED";
			}
			print $file_handle "\t<oboInOwl:", $synonym_type, ">\n";
			print $file_handle "\t\t<oboInOwl:Synonym>\n";
			print $file_handle "\t\t\t<rdfs:label xml:lang=\"en\">", $synonym->def()->text(), "</rdfs:label>\n";
			print $file_handle "\t\t</oboInOwl:Synonym>\n";
			print $file_handle "\t</oboInOwl:", $synonym_type, ">\n";
	    	}
	    	
		#
		# disjoint_from:
		#
		foreach my $disjoint_term_id ($term->disjoint_from()) {
			print $file_handle "\t<owl:disjointWith rdf:resource=\"#", obo_id2owl_id($disjoint_term_id), "\"/>\n";
		}
		
	    	#
	    	# is_a:
	    	#
#			my @disjoint_term = (); # for collecting the disjoint terms of the running term
	    	my $rt = $self->get_relationship_type_by_name("is_a");
	    	if (defined $rt)  {
		    	my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
		    	foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
		    		print $file_handle "\t<rdfs:subClassOf rdf:resource=\"#", obo_id2owl_id($head->id()), "\"/>\n"; # head->name() not used
		    		
#					#
#					# Gathering for the Disjointness (see below, after the bucle)
#					#
#		#			my $child_rels = $graph->get_child_relationships($rel->object_acc);
#		#			foreach my $r (@{$child_rels}){
#		#				if ($r->type eq "is_a") { # Only consider the children playing a role in the is_a realtionship
#		#					my $already_in_array = grep /$r->subject_acc/, @disjoint_term;
#		#					push @disjoint_term, $r->subject_acc if (!$already_in_array && $r->subject_acc ne $rel->subject_acc());
#		#				}
#		#			}

		    	}
#				#
#				# Disjointness (array filled up while treating the is_a relation)
#				#
#				#	foreach my $disjoint (@disjoint_term){
#				#		$disjoint =~ s/:/_/;
#				#		print $file_handle "\t<owl:disjointWith rdf:resource=\"#", $disjoint, "\"/>\n";
#				#	}
	    	}
		
		#	
		# relationships:
		#
	    	foreach $rt (@{$self->get_relationship_types()}) {
	    		if ($rt->name() ne "is_a") { # is_a is printed above
					my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
					foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
						print $file_handle "\t<rdfs:subClassOf>\n";
						print $file_handle "\t\t<owl:Restriction>\n";
						print $file_handle "\t\t\t<owl:onProperty rdf:resource=\"#", $rt->name(), "\"/>\n";
						print $file_handle "\t\t\t<owl:someValuesFrom rdf:resource=\"#", obo_id2owl_id($head->id()), "\"/>\n"; # head->name() not used
						print $file_handle "\t\t</owl:Restriction>\n";
						print $file_handle "\t</rdfs:subClassOf>\n";
					}
	    		}
	    	}
	    	#
	    	# builtin:
	    	#
	    	#### Not used in OWL.####
	    	
   			# End of the term
			print $file_handle "</owl:Class>\n\n";
		}
		
		#
		# Print associated 'has_reference' instances with the hash filled up in 'dbxref'
		#
#		foreach my $ref (keys %has_ref) {
#			print $file_handle $has_ref{$ref}, NL;
#		}

		#
		# relationship types: properties
		#
	    my @all_relationship_types = values(%{$self->{RELATIONSHIP_TYPES}});
	    foreach my $relationship_type (sort {$a->id() cmp $b->id()} @all_relationship_types) {
			# Object property
			print $file_handle "<owl:ObjectProperty rdf:ID=\"", $relationship_type->id(), "\">\n";
			print $file_handle "\t<rdfs:label rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $relationship_type->name(), "</rdfs:label>\n" if ($relationship_type->name());
			print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $relationship_type->def_as_string(), "</rdfs:comment>\n" if (defined $relationship_type->def()->text());
			foreach my $rt_synonym ($relationship_type->synonym_set()) {
				print $file_handle "\t<synonym rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string scope=\">", $rt_synonym->def()->text(), "</synonym>\n";
				#print $file_handle "\t<synonym rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string scope=\"", $rt_synonym->type(), "\">", $rt_synonym->def()->text(), "</synonym>\n";
			}
			print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#TransitiveProperty\"/>\n" if ($relationship_type->is_transitive());
			print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#SymmetricProperty\"/>\n" if ($relationship_type->is_symmetric()); # No cases so far
			
			print $file_handle "\t<is_reflexive rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">true</is_reflexive>\n" if ($relationship_type->is_reflexive());
			print $file_handle "\t<is_anti_symmetric rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">true</is_anti_symmetric>\n" if ($relationship_type->is_anti_symmetric()); # anti-symmetric <> not symmetric
			foreach my $xref ($relationship_type->xref_set_as_string()) {
	    		print $file_handle "\t<xref rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $xref->as_string(), "</xref>\n";
	    	}
			## There is no way to code these rel's in OBO
			##print $file_handle "\t<rdf:type rdf:resource=\"&owl;FunctionalProperty\"/>\n" if (${$relationship{$_}}{"TODO"});
			##print $file_handle "\t<rdf:type rdf:resource=\"&owl;InverseFunctionalProperty\"/>\n" if (${$relationship{$_}}{"TODO"});
			##print $file_handle "\t<owl:inverseOf rdf:resource=\"#has_authors\"/>\n" if (${$relationship{$_}}{"TODO"});
			print $file_handle "</owl:ObjectProperty>\n\n";
	    }
				
		#
		# Datatype annotation properties: todo: AnnotationProperty or not?
		#
		
		# has_reference
		print $file_handle "<owl:ObjectProperty rdf:ID=\"has_reference\">\n";
		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
		print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">Describes the reference of the term definition.</rdfs:comment>\n";
		print $file_handle "</owl:ObjectProperty>\n\n";
		
		# alt_id
		print $file_handle "<owl:DatatypeProperty rdf:ID=\"hasAlternativeId\">\n";
		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
		print $file_handle "\t<rdfs:range rdf:resource=\"http://www.w3.org/2001/XMLSchema#string\"/>\n";
		print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", "Defines an alternate id for a term. A term may have any number of alternate ids", "</rdfs:comment>\n";
		print $file_handle "</owl:DatatypeProperty>\n\n";
		
		# xref
		print $file_handle "<owl:DatatypeProperty rdf:ID=\"xref\">\n";
		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
		print $file_handle "\t<rdfs:range rdf:resource=\"http://www.w3.org/2001/XMLSchema#string\"/>\n";
		print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", "Describes an analogous term in another vocabulary. A term may have any number of xref's.", "</rdfs:comment>\n";
		print $file_handle "</owl:DatatypeProperty>\n\n";
		
		# autoGeneratedBy
		print $file_handle "<owl:DatatypeProperty rdf:ID=\"autoGeneratedBy\">\n";
		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
		print $file_handle "\t<rdfs:range rdf:resource=\"http://www.w3.org/2001/XMLSchema#string\"/>\n";
		print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", "The program that generated this ontology.", "</rdfs:comment>\n";
		print $file_handle "</owl:DatatypeProperty>\n\n";
		
		# is_anti_symmetric
		print $file_handle "<owl:DatatypeProperty rdf:ID=\"is_anti_symmetric\">\n";
		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
		print $file_handle "</owl:DatatypeProperty>\n\n";
		
		# is_reflexive
		print $file_handle "<owl:DatatypeProperty rdf:ID=\"is_reflexive\">\n";
		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
		print $file_handle "</owl:DatatypeProperty>\n\n";
		
		#
		# EOF:
		#
		print $file_handle "</rdf:RDF>\n\n";
		print $file_handle "<!--\nGenerated with onto-perl: ".$0.", ".`date`."-->";
		
    } elsif ($format eq "dot") {
    	#
    	# begin DOT format
    	#
    	print $file_handle "digraph Ontology {";
    	print $file_handle "\n\tpage=\"11,17\";";
		#print $file_handle "\n\tratio=auto;";
    	
    	# terms
	    my @all_terms = values(%{$self->{TERMS}});
	    print $file_handle "\n\tedge [label=\"is a\"];";
	    foreach my $term (sort {$a->id() cmp $b->id()} @all_terms) {
	    	
	    	#
	    	# is_a: term1 -> term2
	    	#
	    	my $rt = $self->get_relationship_type_by_name("is_a");
	    	if (defined $rt)  {
		    	my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
		    	foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
		    		if (!defined $term->name()) {
			    		confess "The term with id: ", $term->id(), " has no name!" ;
			    	} elsif (!defined $head->name()) {
			    		confess "The term with id: ", $head->id(), " has no name!" ;
			    	} else {
			    		# todo write down the name() instead of the id()
		    			print $file_handle "\n\t", obo_id2owl_id($term->id()), " -> ", obo_id2owl_id($head->id()), ";";
		    		}
		    	}
	    	}
	    	
	    	#
	    	# relationships: terms1 -> term2
	    	#
	    	foreach $rt (@{$self->get_relationship_types()}) {
	    		if ($rt->name() ne "is_a") { # is_a is printed above
					my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
					print $file_handle "\n\tedge [label=\"", $rt->name(), "\"];" if (@heads);
					foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
						if (!defined $term->name()) {
				    		confess "The term with id: ", $term->id(), " has no name!" ;
				    	} elsif (!defined $head->name()) {
				    		confess "The term with id: ", $head->id(), " has no name!" ;
				    	} else {	
							print $file_handle "\n\t", obo_id2owl_id($term->id()), " -> ", obo_id2owl_id($head->id()), ";";
						}
					}
	    		}
	    	}
	    }
	    
	    #
		# end DOT format
		#
    	print $file_handle "\n}";
    } elsif ($format eq "gml") {
    	#
    	# begin GML format
    	#
    	print $file_handle "Creator \"onto-perl\"\n";
    	print $file_handle "Version	1.0\n";
    	print $file_handle "graph [\n";
    	#print $file_handle "\tVendor \"onto-perl\"\n";
    	#print $file_handle "\tdirected 1\n";
    	#print $file_handle "\tcomment 1"
    	#print $file_handle "\tlabel 1"
    	
    	my %id = ('C'=>1, 'P'=>2, 'F'=>3, 'R'=>4, 'T'=>5, 'I'=>6, 'B'=>7, 'U'=>8, 'X'=>9);
    	my %color_id = ('C'=>'fff5f5', 'P'=>'b7ffd4', 'F'=>'d7ffe7', 'R'=>'ceffe1', 'T'=>'ffeaea', 'I'=>'f4fff8', 'B'=>'f0fff6', 'U'=>'e0ffec', 'X'=>'ffcccc', 'Y'=>'fecccc');
    	my %gml_id;
    	# terms
	    my @all_terms = values(%{$self->{TERMS}});
	    foreach my $term (sort {$a->id() cmp $b->id()} @all_terms) {
	    	#
			# Class name
			#
			print $file_handle "\tnode [\n";
			my $term_sns = $term->subnamespace();
			my $id = $id{$term_sns};
			$gml_id{$term->id()} = 100000000 * (defined($id)?$id:1) + $term->code();
			#$id{$term->id()} = $gml_id;
			print $file_handle "\t\troot_index	-", $gml_id{$term->id()}, "\n";
			print $file_handle "\t\tid			-", $gml_id{$term->id()}, "\n";
			print $file_handle "\t\tgraphics	[\n";
			#print $file_handle "\t\t\tx	1656.0\n";
			#print $file_handle "\t\t\ty	255.0\n";
			print $file_handle "\t\t\tw	40.0\n";
			print $file_handle "\t\t\th	40.0\n";
			print $file_handle "\t\t\tfill	\"#".$color_id{$term_sns}."\"\n";
			print $file_handle "\t\t\toutline	\"#000000\"\n";
			print $file_handle "\t\t\toutline_width	1.0\n";
			print $file_handle "\t\t]\n";
			print $file_handle "\t\tlabel		\"", $term->id(), "\"\n";
			print $file_handle "\t\tname		\"", $term->name(), "\"\n";
			print $file_handle "\t\tcomment		\"", $term->def()->text(), "\"\n" if (defined $term->def()->text());
			print $file_handle "\t]\n";
			
	    	#
	    	# relationships: terms1 -> term2
	    	#
	    	foreach my $rt (@{$self->get_relationship_types()}) {
				my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
				foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
					if (!defined $term->name()) {
				   		confess "The term with id: ", $term->id(), " has no name!" ;
				   	} elsif (!defined $head->name()) {
				   		confess "The term with id: ", $head->id(), " has no name!" ;
				   	} else {
			    		print $file_handle "\tedge [\n";
			    		print $file_handle "\t\troot_index	-", $gml_id{$term->id()}, "\n";
		    			print $file_handle "\t\tsource		-", $gml_id{$term->id()}, "\n";
		    			$gml_id{$head->id()} = 100000000 * (defined($id{$head->subnamespace()})?$id{$head->subnamespace()}:1) + $head->code();
		    			print $file_handle "\t\ttarget		-", $gml_id{$head->id()}, "\n";
		    			print $file_handle "\t\tlabel		\"", $rt->name(),"\"\n";
		    			print $file_handle "\t]\n";
					}
				}
	    	}
	    }
	    
	    #
		# end GML format
		#
    	print $file_handle "\n]";
	} elsif ($format eq "xgmml") {
		warn "Not implemented yet";
	} elsif ($format eq "sbml") {
		warn "Not implemented yet";
    }
    
    return 0;
}

=head2 subontology_by_terms

  Usage    - $ontology->subontology_by_terms($term_set)
  Returns  - a subontology with the given terms from this ontology 
  Args     - the terms (CCO::Util::TermSet) that will be included in the subontology
  Function - creates a subontology based on the given terms from this ontology
  
=cut

sub subontology_by_terms {
	my $self = shift;
	my $term_set = shift;
    
	# TODO improve this algorithm
	my $result = CCO::Core::Ontology->new();
	foreach my $term ($term_set->get_set()) {
		$result->has_term($term) || $result->add_term($term);
		my @descendent = @{$self->get_descendent_terms($term)};
		foreach my $rel (@{$self->get_relationships_by_target_term($term)}){
			$result->add_relationship($rel);
			my $rel_type = $self->get_relationship_type_by_id($rel->type());
			$result->has_relationship_type($rel_type) || $result->add_relationship_type($rel_type);
		}
		foreach my $descendent (@descendent) {
			$result->has_term($descendent) || $result->add_term($descendent);
		}
	}
	return $result;
}

=head2 obo_id2owl_id

  Usage    - $ontology->obo_id2owl_id($term)
  Returns  - the ID for OWL representation.
  Args     - the OBO-type ID.
  Function - Transform an OBO-type ID into an OWL-type one. E.g. CCO:I1234567 -> CCO_I1234567
  
=cut

sub obo_id2owl_id {
	$_[0] =~ s/:/_/;
	return $_[0];
}

=head2 get_descendent_terms

  Usage    - $ontology->get_descendent_terms($term)
  Returns  - a set with the descendent terms (CCO::Core::Term) of the given term
  Args     - the term (CCO::Core::Term) for which all the descendent will be found
  Function - returns recursively all the child terms of the given term
  
=cut
sub get_descendent_terms {
	# TODO implement another method: get_descendent_terms(string)
	my $self = shift;
	my $result = CCO::Util::TermSet->new();
    if (@_) {
    	my $term = shift;
    	
    	my @queue = @{$self->get_child_terms($term)}; 
    	while (scalar(@queue) > 0) {
    		my $unqueued = shift @queue;
    		$result->add($unqueued); 
    		my @children = @{$self->get_child_terms($unqueued)}; 
    		@queue = (@queue, @children);
    		
    	}
    }
	my @arr = $result->get_set();
	return \@arr;
}

=head2 get_ancestor_terms

  Usage    - $ontology->get_ancestor_terms($term)
  Returns  - a set with the ancestor terms (CCO::Core::Term) of the given term
  Args     - the term (CCO::Core::Term) for which all the ancestors will be found
  Function - returns recursively all the parent terms of the given term
  
=cut
sub get_ancestor_terms {
	
	my $self = shift;
	my $result = CCO::Util::TermSet->new();
    if (@_) {
    	my $term = shift;
    	my @queue = @{$self->get_parent_terms($term)};
    	while (scalar(@queue) > 0) {
    		my $unqueued = shift @queue;
    		$result->add($unqueued);
    		my @parents = @{$self->get_parent_terms($unqueued)};
    		@queue = (@queue, @parents);
    		
    	}
    }
	my @arr = $result->get_set();
	return \@arr;
}

=head2 get_descendent_terms_by_subnamespace

  Usage    - $ontology->get_descendent_terms_by_subnamespace($term, subnamespace)
  Returns  - a set with the descendent terms (CCO::Core::Term) of the given subnamespace 
  Args     - the term (CCO::Core::Term), the subnamespace (string, e.g. 'P', 'R' etc)
  Function - returns recursively the given term's children of the given subnamespace
  
=cut
sub get_descendent_terms_by_subnamespace {
	
	my $self = shift;
	my $result = CCO::Util::TermSet->new();
    if (@_) {
    	my ($term, $subnamespace) = @_;
    	my @queue = @{$self->get_child_terms($term)};
    	while (scalar(@queue) > 0) {
    		my $unqueued = shift @queue;
    		$result->add($unqueued) if substr($unqueued->id(), 4, length($subnamespace)) eq $subnamespace;
    		my @children = @{$self->get_child_terms($unqueued)};
    		@queue = (@queue, @children);
    	}
    }
	my @arr = $result->get_set();
	return \@arr;
    
}

=head2 get_ancestor_terms_by_subnamespace

  Usage    - $ontology->get_ancestor_terms_by_subnamespace($term, subnamespace)
  Returns  - a set with the ancestor terms (CCO::Core::Term) of the given subnamespace 
  Args     - the term (CCO::Core::Term), the subnamespace (string, e.g. 'P', 'R' etc)
  Function - returns recursively the given term's parents of the given subnamespace
  
=cut
sub get_ancestor_terms_by_subnamespace {
	
	my $self = shift;
	my $result = CCO::Util::TermSet->new();
    if (@_) {
    	my ($term, $subnamespace) = @_;
    	my @queue = @{$self->get_parent_terms($term)};
    	while (scalar(@queue) > 0) {
    		my $unqueued = shift @queue;
    		$result->add($unqueued) if substr($unqueued->id(), 4, length($subnamespace)) eq $subnamespace;
    		my @parents = @{$self->get_parent_terms($unqueued)};
    		@queue = (@queue, @parents);
    	}
    }
	my @arr = $result->get_set();
	return \@arr;
    
}

=head2 get_descendent_terms_by_relationship_type

  Usage    - $ontology->get_descendent_terms_by_relationship_type($term, $rel_type)
  Returns  - a set with the descendent terms (CCO::Core::Term) of the given term linked by the given relationship type
  Args     - CCO::Core::Term object, CCO::Core::RelationshipType object
  Function - returns recursively all the child terms of the given term linked by the given relationship type
  
=cut
sub get_descendent_terms_by_relationship_type {
	
	my $self = shift;
	my $result = CCO::Util::TermSet->new();
    if (@_) {
    	my ($term, $type) = @_;
    	my @queue = @{$self->get_tail_by_relationship_type($term, $type)};
    	while (scalar(@queue) > 0) {
    		my $unqueued = shift @queue;
    		$result->add($unqueued);
    		my @children = @{$self->get_tail_by_relationship_type($unqueued, $type)}; 
    		@queue = (@queue, @children);
    	}
    }
	my @arr = $result->get_set();
	return \@arr;
}

=head2 get_ancestor_terms_by_relationship_type

  Usage    - $ontology->get_ancestor_terms_by_relationship_type($term, $rel_type)
  Returns  - a set with the ancestor terms (CCO::Core::Term) of the given term linked by the given relationship type
  Args     - CCO::Core::Term object, CCO::Core::RelationshipType object
  Function - returns recursively the parent terms of the given term linked by the given relationship type
  
=cut
sub get_ancestor_terms_by_relationship_type {
	
	my $self = shift;
	my $result = CCO::Util::TermSet->new();
    if (@_) {
    	my ($term, $type) = @_;
    	my @queue = @{$self->get_head_by_relationship_type($term, $type)};
    	while (scalar(@queue) > 0) {
    		my $unqueued = shift @queue;
    		$result->add($unqueued);
    		my @parents = @{$self->get_head_by_relationship_type($unqueued, $type)};
    		@queue = (@queue, @parents);
    	}
    }
	my @arr = $result->get_set();
	return \@arr;
}


=head2 create_rel

  Usage    - $ontology->create_rel->($tail, $head, $type)
  Returns  - CCO::Core::Ontology object
  Args     - CCO::Core::(Term|Relationship) object, CCO::Core::(Term|Relationship) object, relationship type string
  Function - creates and adds to the ontology a new relationship
  
=cut
sub create_rel (){
	my $self = shift;
	my($tail, $type, $head) = @_;
	confess "Not a valid relationship type" unless($self->{RELATIONSHIP_TYPES}->{$type});
	my $rel = CCO::Core::Relationship->new(); 
	$rel->type($type);
	$rel->link($tail,$head);
	$rel->id($tail->id()."_".$type."_".$head->id());
	$self->add_relationship($rel);
	return $self;
}

1;

=head1 NAME

    CCO::Core::Ontology  - an ontology 
    
=head1 SYNOPSIS

use CCO::Core::Ontology;

use CCO::Core::Term;

use CCO::Core::Relationship;

use CCO::Core::RelationshipType;

use strict;


# three new terms

my $n1 = CCO::Core::Term->new();

my $n2 = CCO::Core::Term->new();

my $n3 = CCO::Core::Term->new();


# new ontology

my $onto = CCO::Core::Ontology->new;


$n1->id("CCO:P0000001");

$n2->id("CCO:P0000002");

$n3->id("CCO:P0000003");


$n1->name("One");

$n2->name("Two");

$n3->name("Three");


my $def1 = CCO::Core::Def->new();

$def1->text("Definition of One");

my $def2 = CCO::Core::Def->new();

$def2->text("Definition of Two");

my $def3 = CCO::Core::Def->new();

$def3->text("Definition of Three");


$n1->def($def1);

$n2->def($def2);

$n3->def($def3);


$onto->add_term($n1);

$onto->add_term($n2);

$onto->add_term($n3);


$onto->delete_term($n1);


$onto->add_term($n1);

# new term

my $n4 = CCO::Core::Term->new();

$n4->id("CCO:P0000004");

$n4->name("Four");

my $def4 = CCO::Core::Def->new();

$def4->text("Definition of Four");

$n4->def($def4);

$onto->delete_term($n4);

$onto->add_term($n4);


# add term as string

my $new_term = $onto->add_term_as_string("CCO:P0000005", "Five");

$new_term->def_as_string("This is a dummy definition", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]");

my $n5 = $new_term; 


# five new relationships

my $r12 = CCO::Core::Relationship->new();

my $r23 = CCO::Core::Relationship->new();

my $r13 = CCO::Core::Relationship->new();

my $r14 = CCO::Core::Relationship->new();

my $r35 = CCO::Core::Relationship->new();


$r12->id("CCO:P0000001_is_a_CCO:P0000002");

$r23->id("CCO:P0000002_part_of_CCO:P0000003");

$r13->id("CCO:P0000001_participates_in_CCO:P0000003");

$r14->id("CCO:P0000001_participates_in_CCO:P0000004");

$r35->id("CCO:P0000003_part_of_CCO:P0000005");


$r12->type("is_a");

$r23->type("part_of");

$r13->type("participates_in");

$r14->type("participates_in");

$r35->type("part_of");


$r12->link($n1, $n2); 

$r23->link($n2, $n3);

$r13->link($n1, $n3);

$r14->link($n1, $n4);

$r35->link($n3, $n5);


# get all terms

my $c = 0;

my %h;

foreach my $t (@{$onto->get_terms()}) {
	
	$h{$t->id()} = $t;
	
	$c++;
	
}


# get terms with argument

my @processes = sort {$a->id() cmp $b->id()} @{$onto->get_terms("CCO:P.*")};

my @odd_processes = sort {$a->id() cmp $b->id()} @{$onto->get_terms("CCO:P000000[35]")};

$onto->namespace("CCO");

my @same_processes = @{$onto->get_terms_by_subnamespace("P")};

my @no_processes = @{$onto->get_terms_by_subnamespace("p")};


# add relationships

$onto->add_relationship($r12);

$onto->add_relationship($r23);

$onto->add_relationship($r13);

$onto->add_relationship($r14);

$onto->add_relationship($r35);



# add relationships and terms linked by this relationship

my $n11 = CCO::Core::Term->new();

my $n21 = CCO::Core::Term->new();

$n11->id("CCO:P0000011"); $n11->name("One one"); $n11->def_as_string("Definition One one", "");

$n21->id("CCO:P0000021"); $n21->name("Two one"); $n21->def_as_string("Definition Two one", "");

my $r11_21 = CCO::Core::Relationship->new();

$r11_21->id("CCO:R0001121"); $r11_21->type("r11-21");

$r11_21->link($n11, $n21);

$onto->add_relationship($r11_21); # adds to the ontology the terms linked by this relationship


# get all relationships

my %hr;

foreach my $r (@{$onto->get_relationships()}) {
	
	$hr{$r->id()} = $r;
	
}

# get children

my @children = @{$onto->get_child_terms($n1)}; 

@children = @{$onto->get_child_terms($n3)}; 

my %ct;

foreach my $child (@children) {
	
	$ct{$child->id()} = $child;
	
} 


@children = @{$onto->get_child_terms($n2)};


# get parents

my @parents = @{$onto->get_parent_terms($n3)};

@parents = @{$onto->get_parent_terms($n1)};

@parents = @{$onto->get_parent_terms($n2)};


# get all descendents

my @descendents1 = @{$onto->get_descendent_terms($n1)};

my @descendents2 = @{$onto->get_descendent_terms($n2)};

my @descendents3 = @{$onto->get_descendent_terms($n3)};

my @descendents5 = @{$onto->get_descendent_terms($n5)};


# get all ancestors

my @ancestors1 = @{$onto->get_ancestor_terms($n1)};

my @ancestors2 = @{$onto->get_ancestor_terms($n2)};

my @ancestors3 = @{$onto->get_ancestor_terms($n3)};


# get descendents by term subnamespace

my @descendents4 = @{$onto->get_descendent_terms_by_subnamespace($n1, 'P')};

my @descendents5 = @{$onto->get_descendent_terms_by_subnamespace($n2, 'P')}; 

my @descendents6 = @{$onto->get_descendent_terms_by_subnamespace($n3, 'P')};

my @descendents6 = @{$onto->get_descendent_terms_by_subnamespace($n3, 'R')};


# get ancestors by term subnamespace

my @ancestors4 = @{$onto->get_ancestor_terms_by_subnamespace($n1, 'P')};

my @ancestors5 = @{$onto->get_ancestor_terms_by_subnamespace($n2, 'P')}; 

my @ancestors6 = @{$onto->get_ancestor_terms_by_subnamespace($n3, 'P')};

my @ancestors6 = @{$onto->get_ancestor_terms_by_subnamespace($n3, 'R')};



# three new relationships types

my $r1 = CCO::Core::RelationshipType->new();

my $r2 = CCO::Core::RelationshipType->new();

my $r3 = CCO::Core::RelationshipType->new();


$r1->id("CCO:R0000001");

$r2->id("CCO:R0000002");

$r3->id("CCO:R0000003");


$r1->name("is_a");

$r2->name("part_of");

$r3->name("participates_in");


# add relationship types

$onto->add_relationship_type($r1);

$onto->add_relationship_type($r2);

$onto->add_relationship_type($r3);


# get descendents or ancestors linked by a particular relationship type 

my $rel_type1 = $onto->get_relationship_type_by_name("is_a");

my $rel_type2 = $onto->get_relationship_type_by_name("part_of");

my $rel_type3 = $onto->get_relationship_type_by_name("participates_in");


my @descendents7 = @{$onto->get_descendent_terms_by_relationship_type($n5, $rel_type1)};

@descendents7 = @{$onto->get_descendent_terms_by_relationship_type($n5, $rel_type2)};

@descendents7 = @{$onto->get_descendent_terms_by_relationship_type($n2, $rel_type1)};

@descendents7 = @{$onto->get_descendent_terms_by_relationship_type($n3, $rel_type3)};


my @ancestors7 = @{$onto->get_ancestor_terms_by_relationship_type($n1, $rel_type1)};

@ancestors7 = @{$onto->get_ancestor_terms_by_relationship_type($n1, $rel_type2)};

@ancestors7 = @{$onto->get_ancestor_terms_by_relationship_type($n1, $rel_type3)};

@ancestors7 = @{$onto->get_ancestor_terms_by_relationship_type($n2, $rel_type2)};



# add relationship type as string

my $relationship_type = $onto->add_relationship_type_as_string("CCO:R0000004", "has_participant");


# get relationship types

my @rt = @{$onto->get_relationship_types()};

my %rrt;

foreach my $relt (@rt) {
	
	$rrt{$relt->name()} = $relt;
	
}



my @rtbt = @{$onto->get_relationship_types_by_term($n1)};


my %rtbth;

foreach my $relt (@rtbt) {
	
	$rtbth{$relt} = $relt;
	
}


# get_head_by_relationship_type

my @heads_n1 = @{$onto->get_head_by_relationship_type($n1, $onto->get_relationship_type_by_name("participates_in"))};

my %hbrt;

foreach my $head (@heads_n1) {
	
	$hbrt{$head->id()} = $head;
	
}


=head1 DESCRIPTION

This module has several methods to work with Ontologies in OBO and OWL formats, 
such as the Cell Cycle Ontology (http://www.cellcycleontology.org). Basically, 
it is a directed acyclic graph (DAG) holding the terms (CCO::Core::Term) which 
in turn are linked by relationships (CCO::Core::Relationship). These relationships 
have an associated relationship type (CCO::Core::RelationshipType).

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    
