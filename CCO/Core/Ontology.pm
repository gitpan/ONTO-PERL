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

use CCO::Core::IDspace;
use CCO::Util::SynonymTypeDefSet;
use CCO::Util::TermSet;

use strict;
use warnings;
use Carp;

# TODO implement 'get_relationships_type_by_name()' in a similar way to 'get_terms_by_name' (using RelationshipSet)

sub new {
	my $class                      = shift;
	my $self                       = {};
        
	$self->{ID}                    = undef; # required, (1)
	$self->{NAME}                  = undef; # required, (1)
	$self->{IMPORTS}               = CCO::Util::Set->new(); # set (0..N)
	$self->{IDSPACE}               = CCO::Core::IDspace->new(); # required, (1)
	$self->{DEFAULT_NAMESPACE}     = undef; # string (0..1)
	$self->{DATA_VERSION}          = undef; # string (0..1)
	$self->{DATE}                  = undef; # (1) The current date in dd:MM:yyyy HH:mm format
	$self->{SAVED_BY}              = undef; # string (0..1)
	$self->{REMARK}                = undef; # string (0..1)
	$self->{SUBSETS_SET}           = CCO::Util::Set->new(); # set (0..N); A subset is a view over an ontology
	$self->{SYNONYM_TYPE_DEF_SET}  = CCO::Util::SynonymTypeDefSet->new(); # set (0..N); A description of a user-defined synonym type
        
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

  Usage    - print $ontology->id() or $ontology->id($id)
  Returns  - the ontology ID (string)
  Args     - the ontology ID (string)
  Function - gets/sets the ontology ID
  
=cut
sub id {
	my ($self, $id) = @_;
	if ($id) { $self->{ID} = $id }
	return $self->{ID};
}

=head2 name

  Usage    - print $ontology->name() or $ontology->name($name)
  Returns  - the name (string) of the ontology
  Args     - the name (string) of the ontology
  Function - gets/sets the name of the ontology
  
=cut
sub name {
	my ($self, $name) = @_;
    if ($name) { $self->{NAME} = $name }
    return $self->{NAME};
}

=head2 imports

  Usage    - $onto->imports() or $onto->imports($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the imported id ontologies
  Args     - the ontology id(s) (string) 
  Function - gets/sets the id(s) of the ontologies that are imported by this one
  
=cut
sub imports {
	my $self = shift;
	if (scalar(@_) > 1) {
		$self->{IMPORTS}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{IMPORTS}->add($_[0]);
	}
	return $self->{IMPORTS};
}

=head2 date

  Usage    - print $ontology->date()
  Returns  - the current date (in dd:MM:yyyy HH:mm format) of the ontology
  Args     - the current date (in dd:MM:yyyy HH:mm format) of the ontology
  Function - gets/sets the date of the ontology
  
=cut
sub date {
	my ($self, $d) = @_;
	if ($d) { $self->{DATE} = $d }
	return $self->{DATE};
}

=head2 default_namespace

  Usage    - print $ontology->default_namespace() or $ontology->default_namespace("cellcycle_ontology")
  Returns  - the default namespace (string) of this ontology
  Args     - the default namespace (string) of this ontology
  Function - gets/sets the default namespace of this ontology
  
=cut
sub default_namespace {
	my ($self, $dns) = @_;
	if ($dns) { $self->{DEFAULT_NAMESPACE} = $dns }
	return $self->{DEFAULT_NAMESPACE};
}

=head2 idspace

  Usage    - print $ontology->idspace() or $ontology->idspace("CCO http://www.cellcycleontology.org/ontology/owl#")
  Returns  - the id space (CCO::Core::IDspace) of this ontology
  Args     - the id space (CCO::Core::IDspace) of this ontology
  Function - gets/sets the idspace of this ontology
  
=cut
sub idspace {
	my ($self, $is) = @_;
	if ($is) { $self->{IDSPACE} = $is }
	return $self->{IDSPACE};
} 

=head2 idspace_as_string

  Usage    - $ontology->idspace_as_string($local_id, $uri, $description)
  Returns  - the idspace as string (string)
  Args     - the local idspace (string), the uri (string) and the description (string)
  Function - sets the idspace of this ontology
  
=cut
sub idspace_as_string {
	my ($self, $local_id, $uri, $description) = @_;
	if ($local_id && $uri) {
		my $new_idspace = CCO::Core::IDspace->new();
		$new_idspace->local_idspace($local_id);
		$new_idspace->uri($uri);
		$new_idspace->description($description);
		$self->idspace($new_idspace);
		return $new_idspace;
	}
	return $self->{IDSPACE}->as_string();
}

=head2 data_version

  Usage    - print $ontology->data_version()
  Returns  - the data version (string) of this ontology
  Args     - the data version (string) of this ontology
  Function - gets/sets the data version of this ontology
  
=cut
sub data_version {
	my ($self, $dv) = @_;
	if ($dv) { $self->{DATA_VERSION} = $dv }
	return $self->{DATA_VERSION};
}

=head2 saved_by

  Usage    - print $ontology->saved_by()
  Returns  - the username of the person (string) to last save this ontology
  Args     - the username of the person (string) to last save this ontology
  Function - gets/sets the username of the person to last save this ontology
  
=cut
sub saved_by {
	my ($self, $sb) = @_;
    if ($sb) { $self->{SAVED_BY} = $sb }
    return $self->{SAVED_BY};
}

=head2 remark

  Usage    - print $ontology->remark()
  Returns  - the remark (string) of this ontology
  Args     - the remark (string) of this ontology
  Function - gets/sets the remark of this ontology
  
=cut
sub remark {
	my ($self, $r) = @_;
	if ($r) { $self->{REMARK} = $r }
	return $self->{REMARK};
}

=head2 subsets

  Usage    - $onto->subsets() or $onto->subsets($ss1, $ss2, $ss3, ...)
  Returns  - a set (CCO::Util::Set) with the subsets used in this ontology. A subset is a view over an ontology
  Args     - the subset(s) (string) used in this ontology 
  Function - gets/sets the subset(s) of this ontology
        
=cut    
sub subsets {
	my $self = shift;             
	if (scalar(@_) > 1) {         
		$self->{SUBSETS_SET}->add_all(@_);
	} elsif (scalar(@_) == 1) {   
		$self->{SUBSETS_SET}->add($_[0]);
	}
	return $self->{SUBSETS_SET};      
}

=head2 synonym_type_def_set

  Usage    - $onto->synonym_type_def_set() or $onto->synonym_type_def_set($st1, $st2, $st3, ...)
  Returns  - a set (CCO::Util::SynonymTypeDefSet) with the synonym type defintions used in this ontology. A synonym type is a description of a user-defined synonym type 
  Args     - the synonym type defintion(s) (CCO::Core::SynonymTypeDef) used in this ontology 
  Function - gets/sets the synonym type definitions (s) of this ontology
        
=cut
sub synonym_type_def_set {
	my $self = shift;
	if (scalar(@_) > 1) {
		$self->{SYNONYM_TYPE_DEF_SET}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{SYNONYM_TYPE_DEF_SET}->add($_[0]);
	}
	return $self->{SYNONYM_TYPE_DEF_SET};
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
    my ($self, $term) = @_;
    if ($term) {    
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
	# This will be part of the Ontolome packages
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
		my $is = $self->idspace()->local_idspace();
		if (!defined $is) {
			confess "The idspace is not defined for this ontology";
		} else {
			$terms = $self->get_terms($is.":".$_[0]);
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
	my ($self, $term) = @_;
	my $result = CCO::Util::Set->new();
	if ($term) {
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
	my ($self, $term) = @_;
	my $result = CCO::Util::Set->new();
	if ($term) {
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
    my ($self, $term, $new_term_id) = @_;
    if ($term && $new_term_id) {
    	if ($self->has_term($term)) {
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
	my ($self, $id) = @_;
	return $self->{RELATIONSHIP_TYPES}->{$id} if ($id);
}

=head2 get_term_by_name

  Usage    - $ontology->get_term_by_name($name)
  Returns  - the term (CCO::Core::Term) associated to the given name
  Args     - the term's name (string)
  Function - returns the term associated to the given name
  
=cut
sub get_term_by_name {
    my ($self, $name) = ($_[0], lc($_[1]));
    my $result;
    if ($name) {		
		foreach my $term (@{$self->get_terms()}) { # return the exact occurrence
			$result = $term, last if (defined ($term->name()) && (lc($term->name()) eq $name)); 
		}
    }
    return $result;
}

=head2 get_term_by_name_or_synonym

  Usage    - $ontology->get_term_by_name_or_synonym($name)
  Returns  - the term (CCO::Core::Term) associated to the given name or *EXACT* synonym
  Args     - the term's name or synonym (string)
  Function - returns the term associated to the given name or *EXACT* synonym
  Remark   - this function should be carefully used since among ontologies there may be homonyms at the level of the synonyms (e.g. genes)
  
=cut
sub get_term_by_name_or_synonym {
    my ($self, $name_or_synonym) = ($_[0], lc($_[1]));
    my $result;
    if ($name_or_synonym) {		
		foreach my $term (@{$self->get_terms()}) { # return the exact occurrence
			return $term if (defined ($term->name()) && (lc($term->name()) eq $name_or_synonym));
			# Check its synonyms
			foreach my $syn ($term->synonym_set()){
				return $term if ($syn->type() eq "EXACT" && lc($syn->def()->text()) eq $name_or_synonym);
			}
		}
    }
}

=head2 get_terms_by_name

  Usage    - $ontology->get_terms_by_name($name)
  Returns  - the term set (CCO::Util::TermSet) with all the terms (CCO::Core::Term) having $name in their names 
  Args     - the term's name (string)
  Function - returns the terms having $name in their names 
  
=cut
sub get_terms_by_name {
    my ($self, $name) = ($_[0], lc($_[1]));
    my $result;
    if ($name) {
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
    my ($self, $name) = ($_[0], lc($_[1]));;
    my $result;
    if ($name) {
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
	my ($self, $term) = @_;
	my $result = CCO::Util::TermSet->new();
	if ($term) {
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
	my ($self, $term) = @_;
	my $result = CCO::Util::TermSet->new();
    if ($term) {
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
		
		# import
		foreach my $import ($self->imports()->get_set()) {
			print $file_handle "import: ", $import, "\n";
		}
		
		# subsetdef
		foreach my $subset ($self->subsets()->get_set()) {
			print $file_handle "subsetdef: ", $subset, "\n";
		}
		
		# synonyntypedef
		foreach my $st ($self->synonym_type_def_set()->get_set()) {
			print $file_handle "synonymtypedef: ", $st->synonym_type_def_as_string(), "\n";
		}

		print $file_handle "idspace: ", $self->idspace_as_string() , "\n" if (defined $self->idspace_as_string());
		print $file_handle "default-namespace: ", $self->default_namespace(), "\n" if (defined $self->default_namespace());
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
			# is_anonymous:
			#
			print $file_handle "\nis_anonymous: true" if ($term->is_anonymous());

	    	#
	    	# name:
	    	#
	    	if (defined $term->name()) {
	    		print $file_handle "\nname: ", $term->name();
	    	} else {
	    		confess "The term with id: ", $term->id(), " has no name!" ;
	    	}

			#
			# namespace
			#
			foreach my $ns ($term->namespace()) {
				print $file_handle "\nnamespace: ", $ns;
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
	    	print $file_handle "\nbuiltin: true" if ($term->builtin());
	    	
			#
			# def:
			#
			# QUICK FIX due to IntAct data... TODO
			if (defined $term->def()->text()) {
				my $def_as_string = $term->def_as_string();
				$def_as_string =~ s/\n+//g;
				$def_as_string =~ s/\r+//g;
				$def_as_string =~ s/\t+//g;
				print $file_handle "\ndef: ", $def_as_string;
			}
	    	
			#
			# comment:
			#
			print $file_handle "\ncomment: ", $term->comment() if (defined $term->comment());
		
			#
			# subset
			#
			foreach my $sset ($term->subset()) {
				print $file_handle "\nsubset: ", $sset;
			}

			#
			# synonym:
			#
			foreach my $synonym (sort {$a->def()->text() cmp $b->def()->text()} $term->synonym_set()) {
				my $stn = $synonym->synonym_type_name();
				if (defined $stn) {
					print $file_handle "\nsynonym: \"", $synonym->def()->text(), "\" ", $synonym->type(), " ", $stn, " ", $synonym->def()->dbxref_set_as_string();
				} else {
					print $file_handle "\nsynonym: \"", $synonym->def()->text(), "\" ", $synonym->type(), " ", $synonym->def()->dbxref_set_as_string();
				}
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
			# intersection_of (at least 2 entries)
			#
			foreach my $tr ($term->intersection_of()) {
				print $file_handle "\nintersection_of: ", $tr;
			}

			#
			# union_of (at least 2 entries)
			#
			foreach my $tr ($term->union_of()) {
				print $file_handle "\nunion_of: ", $tr;
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
			# is_obsolete
			#
			print $file_handle "\nis_obsolete: true" if ($term->is_obsolete());

			#
			# replaced_by
			#
			foreach my $replaced_by ($term->replaced_by()->get_set()) {
				print $file_handle "\nreplaced_by: ", $replaced_by;
			}
			
			#
			# consider
	    	#
			foreach my $consider ($term->consider()->get_set()) {
				print $file_handle "\nconsider: ", $consider;
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
	    	
	    	foreach my $xref (sort {$a->as_string() cmp $b->as_string()} $relationship_type->xref_set_as_string()) {
	    		print $file_handle "\nxref: ", $xref->as_string();
	    	}

			#
			# domain
			#
			foreach my $domain ($relationship_type->domain()->get_set()) {
				print $file_handle "\ndomain: ", $domain;
			}
			
			#
			# range
			#
			foreach my $range ($relationship_type->range()->get_set()) {
				print $file_handle "\nrange: ", $range;
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
			    		confess "The relationship type with id: '", $head->id(), "' has no name!" ;
					}
		    	}
	    	}
	    	
	    	print $file_handle "\nis_metadata_tag: true" if ($relationship_type->is_metadata_tag() == 1);
	    	
	    	#
			# transitive_over
			#
			foreach my $transitive_over ($relationship_type->transitive_over()->get_set()) {
				print $file_handle "\ntransitive_over: ", $transitive_over;
			}
			
	    	#
			# is_obsolete
			#
			print $file_handle "\nis_obsolete: true" if ($relationship_type->is_obsolete());
			
	    	#
			# replaced_by
			#
			foreach my $replaced_by ($relationship_type->replaced_by()->get_set()) {
				print $file_handle "\nreplaced_by: ", $replaced_by;
			}
			
			#
			# consider
	    	#
			foreach my $consider ($relationship_type->consider()->get_set()) {
				print $file_handle "\nconsider: ", $consider;
			}
			
			#
			# the end...
			#
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
		print $file_handle "\t\t<default-namespace>", $self->default_namespace(), "</default-namespace>\n" if ($self->default_namespace());
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

		my $oboContentUrl = "http://www.cellcycleontology.org/obo/owl/"; # "http://purl.org/obo/owl/"; #
		my $oboInOwlUrl = "http://www.cellcycleontology.org/formats/oboInOwl#"; # "http://www.geneontology.org/formats/oboInOwl#"; #
		#
		# preambule
		#
		print $file_handle "<?xml version=\"1.0\"?>\n";
		print $file_handle "<rdf:RDF\n";
		print $file_handle "\txmlns=\"".$oboContentUrl."\"\n";
		print $file_handle "\txmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n";
		print $file_handle "\txmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n";
		print $file_handle "\txmlns:owl=\"http://www.w3.org/2002/07/owl#\"\n";
		print $file_handle "\txmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"\n";
		print $file_handle "\txmlns:oboInOwl=\"".$oboInOwlUrl."\"\n";
		print $file_handle "\txmlns:oboContent=\"".$oboContentUrl."\"\n";
		print $file_handle "\txml:base=\"".$oboContentUrl."\"\n";

		#print $file_handle "\txmlns:p1=\"http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl#\"\n";
		#print $file_handle "\txmlns:dcterms=\"http://purl.org/dc/terms/\"\n";
		#print $file_handle "\txmlns:xsp=\"http://www.owl-ontologies.com/2005/08/07/xsp.owl#\"\n";
		#print $file_handle "\txmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n";
		print $file_handle ">\n";

		#
		# meta-data: oboInOwl elements
		#
		foreach my $ap ("hasURI", "hasAlternativeId", "hasDate", "hasVersion", "hasDbXref", "hasDefaultNamespace", "hasNamespace", "hasDefinition", "hasExactSynonym", "hasNarrowSynonym", "hasBroadSynonym", "hasRelatedSynonym", "hasSynonymType", "hasSubset", "inSubset", "savedBy", "replacedBy", "consider") {
			print $file_handle "<owl:AnnotationProperty rdf:about=\"".$oboInOwlUrl.$ap."\"/>\n";
		}
		foreach my $c ("DbXref", "Definition", "Subset", "Synonym", "SynonymType", "ObsoleteClass") {
			print $file_handle "<owl:Class rdf:about=\"".$oboInOwlUrl.$c."\"/>\n";
		}
		print $file_handle "<owl:ObjectProperty rdf:about=\"".$oboInOwlUrl."ObsoleteProperty\"/>\n";
		print $file_handle "\n";

		#
		# header: http://oe0.spreadsheets.google.com/ccc?id=o06770842196506107736.4732937099693365844.03735622766900057712.3276521997699206495#
		#
		print $file_handle "<owl:Ontology rdf:about=\"\">\n";
		foreach my $import_obo ($self->imports()->get_set()) {
			# As Ontology.pm is independant of the format (OBO, OWL) it will import the ID of the ontology
			(my $import_owl = $import_obo) =~ s/\.obo/\.owl/;
			print $file_handle "\t<owl:imports rdf:resource=\"", $import_owl, "\"/>\n";
		}
		# format-version is not treated
		print $file_handle "\t<oboInOwl:hasDate>", $self->date(), "</oboInOwl:hasDate>\n" if ($self->date());
		print $file_handle "\t<oboInOwl:hasDate>", $self->data_version(), "</oboInOwl:hasDate>\n" if ($self->data_version());
		print $file_handle "\t<oboInOwl:savedBy>", $self->saved_by(), "</oboInOwl:savedBy>\n" if ($self->saved_by());
		#print $file_handle "\t<rdfs:comment>autogenerated-by: ", $0, "</rdfs:comment>\n";
		print $file_handle "\t<oboInOwl:hasDefaultNamespace>", $self->default_namespace(), "</oboInOwl:hasDefaultNamespace>\n" if ($self->default_namespace());
		print $file_handle "\t<rdfs:comment>", $self->remark(), "</rdfs:comment>\n" if ($self->remark());
		
		# subsetdef
		foreach my $subset ($self->subsets()->get_set()) {
			my ($t, @desc) = split(/\s+/, $subset);
			print $file_handle "\t<oboInOwl:hasSubset>\n";
			print $file_handle "\t\t<oboInOwl:Subset rdf:about=\"", $oboContentUrl, $t, "\">\n";
			print $file_handle "\t\t\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", join(' ', @desc), "</rdfs:comment>\n";
			print $file_handle "\t\t</oboInOwl:Subset>\n";
			print $file_handle "\t</oboInOwl:hasSubset>\n";
		}
 
		# synonyntypedef
		foreach my $st ($self->synonym_type_def_set()->get_set()) {
			print $file_handle "\t<oboInOwl:hasSynonymType>\n";
			print $file_handle "\t\t<oboInOwl:SynonymType rdf:about=\"", $oboContentUrl, $st->synonym_type_name(), "\">\n";
			print $file_handle "\t\t\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $st->description(), "</rdfs:comment>\n";
			my $scope = $st->scope();
			print $file_handle "\t\t\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $scope, "</rdfs:comment>\n" if (defined $scope);
			print $file_handle "\t\t</oboInOwl:SynonymType>\n";
			print $file_handle "\t</oboInOwl:hasSynonymType>\n";
		}
		
		# idspace
		my $local_idspace = $self->idspace()->local_idspace(); 
		if ($local_idspace) {
			print $file_handle "\t<oboInOwl:IDSpace>\n";
			print $file_handle "\t\t<oboInOwl:local>\n";
			print $file_handle "\t\t\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $local_idspace, "</rdfs:comment>\n";
			print $file_handle "\t\t</oboInOwl:local>\n";
			print $file_handle "\t\t<oboInOwl:global>\n";
			print $file_handle "\t\t\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $self->idspace()->uri(), "</rdfs:comment>\n";
			print $file_handle "\t\t</oboInOwl:global>\n";
			my $desc = $self->idspace()->description();
			print $file_handle "\t\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $desc, "</rdfs:comment>\n";
			print $file_handle "\t</oboInOwl:IDSpace>\n";
		}
		print $file_handle "</owl:Ontology>\n\n";
		
		#
		# term
		#
		my @all_terms = values(%{$self->{TERMS}});
		# visit the terms
		foreach my $term (sort {$a->id() cmp $b->id()} @all_terms){
			
			# for the URLs
			my $term_id = $term->id();
			$local_idspace = $local_idspace || (split(/:/, $term_id))[0]; # the idspace or the space from the term itself. e.g. CCO
		
			#
			# Class name
			#
			print $file_handle "<owl:Class rdf:about=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($term_id), "\">\n";
			
			#
			# label name = class name
			#
			print $file_handle "\t<rdfs:label xml:lang=\"en\">", $term->name(), "</rdfs:label>\n";
			
			#
			# comment
			#
			print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $term->comment(), "</rdfs:comment>\n" if ($term->comment());
			
			#
			# subset
			#
			foreach my $sset ($term->subset()) {
				print $file_handle "\t<oboInOwl:inSubset rdf:resource=\"", $oboContentUrl, $sset, "\"/>\n";
			}
			
			#
			# Def
			#      
			if (defined $term->def()->text()) {
				print $file_handle "\t<oboInOwl:hasDefinition>\n";
				print $file_handle "\t\t<oboInOwl:Definition>\n";
				print $file_handle "\t\t\t<rdfs:label xml:lang=\"en\">", char_hex_http($term->def()->text()), "</rdfs:label>\n";
				
				print_hasDbXref_for_owl($file_handle, $term->def()->dbxref_set(), $oboContentUrl, 3);
				
				print $file_handle "\t\t</oboInOwl:Definition>\n";
				print $file_handle "\t</oboInOwl:hasDefinition>\n";
			}
			
			#
			# synonym:
			#
			foreach my $synonym ($term->synonym_set()) {
				my $st = $synonym->type();
				my $synonym_type;
				if ($st eq "EXACT") {
					$synonym_type = "hasExactSynonym";
				} elsif ($st eq "BROAD") {
					$synonym_type = "hasBroadSynonym";
				} elsif ($st eq "NARROW") {
					$synonym_type = "hasNarrowSynonym";
				} elsif ($st eq "RELATED") {
					$synonym_type = "hasRelatedSynonym";
				} else {
					# todo consider the synonym types defined in the header: 'synonymtypedef' tag
					confess "A non-valid synonym type has been found ($synonym). Valid types: EXACT, BROAD, NARROW, RELATED";
				}
				print $file_handle "\t<oboInOwl:", $synonym_type, ">\n";
				print $file_handle "\t\t<oboInOwl:Synonym>\n";
				print $file_handle "\t\t\t<rdfs:label xml:lang=\"en\">", $synonym->def()->text(), "</rdfs:label>\n";
				
				print_hasDbXref_for_owl($file_handle, $synonym->def()->dbxref_set(), $oboContentUrl, 3);
				
				print $file_handle "\t\t</oboInOwl:Synonym>\n";
				print $file_handle "\t</oboInOwl:", $synonym_type, ">\n";
			}
			
			#
			# namespace
			#
			foreach my $ns ($term->namespace()) {
				print $file_handle "\t<oboInOwl:hasNamespace>", $ns, "</oboInOwl:hasNamespace>\n";
			}

			#
			# alt_id:
			#
			foreach my $alt_id ($term->alt_id()->get_set()) {
				print $file_handle "\t<oboInOwl:hasAlternativeId>", $alt_id, "</oboInOwl:hasAlternativeId>\n";
			}

			#
			# xref's
			#
			print_hasDbXref_for_owl($file_handle, $term->xref_set(), $oboContentUrl, 1);
	    	
			#
			# is_a:
			#
#			my @disjoint_term = (); # for collecting the disjoint terms of the running term
			my $rt = $self->get_relationship_type_by_name("is_a");
			if (defined $rt)  {
		    		my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
		    		foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
						print $file_handle "\t<rdfs:subClassOf rdf:resource=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($head->id()), "\"/>\n"; # head->name() not used
		    		
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
						print $file_handle "\t\t\t<owl:onProperty>\n"; 
						print $file_handle "\t\t\t\t<owl:ObjectProperty rdf:about=\"", $oboContentUrl, $local_idspace, "#", $rt->name(), "\"/>\n";
						print $file_handle "\t\t\t</owl:onProperty>\n";
						print $file_handle "\t\t\t<owl:someValuesFrom rdf:resource=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($head->id()), "\"/>\n"; # head->name() not used
						print $file_handle "\t\t</owl:Restriction>\n";
						print $file_handle "\t</rdfs:subClassOf>\n";
					}
				}
			}

			#
			# disjoint_from:
			#
			foreach my $disjoint_term_id ($term->disjoint_from()) {
				print $file_handle "\t<owl:disjointWith rdf:resource=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($disjoint_term_id), "\"/>\n";
			}

			#
			# obsolete
			#
			print $file_handle "\t<rdfs:subClassOf rdf:resource=\"", $oboInOwlUrl, "ObsoleteClass\"/>\n" if ($term->is_obsolete());

			#
			# intersection_of
			#
			my @intersection_of = $term->intersection_of();
			if (@intersection_of) {
				print $file_handle "\t<owl:equivalentClass>\n";
				print $file_handle "\t\t<owl:Class>\n";
				print $file_handle "\t\t\t<owl:intersectionOf rdf:parseType=\"Collection\">\n";
				foreach my $tr (@intersection_of) {
					# TODO improve the parsing of the 'interection_of' elements
					my @inter = split(/\s+/, $tr);
					# TODO check the idspace of the terms in the set 'intersection_of' and optimize the code: only one call to $self->idspace()->local_idspace()
					my $idspace = ($tr =~ /([A-Z]+):/)?$1:$local_idspace;      
					if (scalar @inter == 1) {
						my $idspace = ($tr =~ /([A-Z]+):/)?$1:$local_idspace;
						print $file_handle "\t\t\t<owl:Class rdf:about=\"", $oboContentUrl, $idspace, "/", obo_id2owl_id($tr), "\"/>\n";
					} elsif (scalar @inter == 2) { # restriction
						print $file_handle "\t\t<owl:Restriction>\n";
						print $file_handle "\t\t\t<owl:onProperty>\n";
						print $file_handle "\t\t\t\t<owl:ObjectProperty rdf:about=\"", $oboContentUrl, $local_idspace, "#", $inter[0], "\"/>\n";
						print $file_handle "\t\t\t</owl:onProperty>\n";
						print $file_handle "\t\t\t<owl:someValuesFrom rdf:resource=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($inter[1]), "\"/>\n";
						print $file_handle "\t\t</owl:Restriction>\n";
					} else {
						confess "Parsing error: 'intersection_of' tag has an unknown argument";
					}
				}
				print $file_handle "\t\t\t</owl:intersectionOf>\n";
				print $file_handle "\t\t</owl:Class>\n";
				print $file_handle "\t</owl:equivalentClass>\n";
			}

			#
			# union_of
			#
			my @union_of = $term->union_of();
			if (@union_of) {
				print $file_handle "\t<owl:equivalentClass>\n";
				print $file_handle "\t\t<owl:Class>\n";
				print $file_handle "\t\t\t<owl:unionOf rdf:parseType=\"Collection\">\n";
				foreach my $tr (@union_of) {
					# TODO check the idspace of the terms in the set 'union_of'
					my $idspace = ($tr =~ /([A-Z]+):/)?$1:$local_idspace; 
					print $file_handle "\t\t\t<owl:Class rdf:about=\"", $oboContentUrl, $idspace, "/", obo_id2owl_id($tr), "\"/>\n";
				}
				print $file_handle "\t\t\t</owl:unionOf>\n";
				print $file_handle "\t\t</owl:Class>\n";
				print $file_handle "\t</owl:equivalentClass>\n";
			}
			
			#
			# builtin:
			#
			#### Not used in OWL.####
			
			#
			# replaced_by
			#
			foreach my $replaced_by ($term->replaced_by()->get_set()) {
				print $file_handle "\t<oboInOwl:replacedBy rdf:resource=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($replaced_by), "\"/>\n";
			}
			
			#
			# consider
			#
			foreach my $consider ($term->consider()->get_set()) {
				print $file_handle "\t<oboInOwl:consider rdf:resource=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($consider), "\"/>\n";
			}

	    	#
   			# End of the term
   			#
			print $file_handle "</owl:Class>\n\n";
		}
		
		#
		# relationship types: properties
		#
		# TODO
#		print $file_handle "<owl:TransitiveProperty rdf:about=\"", $oboContentUrl, "part_of\">\n";
# 		print $file_handle "\t<rdfs:label xml:lang=\"en\">part of</rdfs:label>\n";
#		print $file_handle "\t<oboInOwl:hasNamespace>", $self->default_namespace(), "</oboInOwl:hasNamespace>\n" if ($self->default_namespace());
#		print $file_handle "</owl:TransitiveProperty>\n";
		
	    my @all_relationship_types = values(%{$self->{RELATIONSHIP_TYPES}});
	    foreach my $relationship_type (sort {$a->id() cmp $b->id()} @all_relationship_types) {
	    	
			my $relationship_type_id = $relationship_type->id();
			
			#
			# Object property
			#
			print $file_handle "<owl:ObjectProperty rdf:about=\"", $oboContentUrl, $local_idspace, "#", $relationship_type_id, "\">\n";
			
			#
			# name:
			#
			print $file_handle "\t<rdfs:label xml:lang=\"en\">", $relationship_type->name(), "</rdfs:label>\n" if ($relationship_type->name());
			
			#
			# comment:
			#
			print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $relationship_type->comment(), "</rdfs:comment>\n" if ($relationship_type->comment());
			
			#
			# Def:
			#
			if (defined $relationship_type->def()->text()) {
				print $file_handle "\t<oboInOwl:hasDefinition>\n";
				print $file_handle "\t\t<oboInOwl:Definition>\n";
				print $file_handle "\t\t\t<rdfs:label xml:lang=\"en\">", char_hex_http($relationship_type->def()->text()), "</rdfs:label>\n";
				
				print_hasDbXref_for_owl($file_handle, $relationship_type->def()->dbxref_set(), $oboContentUrl, 3);
				
				print $file_handle "\t\t</oboInOwl:Definition>\n";
				print $file_handle "\t</oboInOwl:hasDefinition>\n";
			}
			
			#
			# Synonym:
			#
			foreach my $synonym ($relationship_type->synonym_set()) {
				my $st = $synonym->type();
				my $synonym_type;
				if ($st eq "EXACT") {
					$synonym_type = "hasExactSynonym";
				} elsif ($st eq "BROAD") {
					$synonym_type = "hasBroadSynonym";
				} elsif ($st eq "NARROW") {
					$synonym_type = "hasNarrowSynonym";
				} elsif ($st eq "RELATED") {
					$synonym_type = "hasRelatedSynonym";
				} else {
					# todo consider the synonym types defined in the header: 'synonymtypedef' tag
					confess "A non-valid synonym type has been found ($synonym). Valid types: EXACT, BROAD, NARROW, RELATED";
				}
				print $file_handle "\t<oboInOwl:", $synonym_type, ">\n";
				print $file_handle "\t\t<oboInOwl:Synonym>\n";
				print $file_handle "\t\t\t<rdfs:label xml:lang=\"en\">", $synonym->def()->text(), "</rdfs:label>\n";
				
				print_hasDbXref_for_owl($file_handle, $synonym->def()->dbxref_set(), $oboContentUrl, 3);
				
				print $file_handle "\t\t</oboInOwl:Synonym>\n";
				print $file_handle "\t</oboInOwl:", $synonym_type, ">\n";
			}
			#
			# namespace: TODO implement namespace in relationship
			#
			foreach my $ns ($relationship_type->namespace()) {
				print $file_handle "\t<oboInOwl:hasNamespace>", $ns, "</oboInOwl:hasNamespace>\n";
			}
			
			#
			# alt_id: TODO implement alt_id in relationship
			#
			foreach my $alt_id ($relationship_type->alt_id()->get_set()) {
				print $file_handle "\t<oboInOwl:hasAlternativeId>", $alt_id, "</oboInOwl:hasAlternativeId>\n";
			}
			
			#
			# is_a:
			#
			my $rt = $self->get_relationship_type_by_name("is_a");
			if (defined $rt)  {
		    		my @heads = @{$self->get_head_by_relationship_type($relationship_type, $rt)};
		    		foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
						print $file_handle "\t<rdfs:subPropertyOf rdf:resource=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($head->id()), "\"/>\n"; # head->name() not used
		    		}
		    }
			
			#
			# Properties:
			#
			print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#TransitiveProperty\"/>\n" if ($relationship_type->is_transitive());
			print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#SymmetricProperty\"/>\n" if ($relationship_type->is_symmetric()); # No cases so far
			print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n"if ($relationship_type->is_metadata_tag());
			#print $file_handle "\t<is_reflexive rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">true</is_reflexive>\n" if ($relationship_type->is_reflexive());
			#print $file_handle "\t<is_anti_symmetric rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">true</is_anti_symmetric>\n" if ($relationship_type->is_anti_symmetric()); # anti-symmetric <> not symmetric
			
			#
			# xref's
			#
			print_hasDbXref_for_owl($file_handle, $relationship_type->xref_set(), $oboContentUrl, 1);
			
			## There is no way to code these rel's in OBO
			##print $file_handle "\t<rdf:type rdf:resource=\"&owl;FunctionalProperty\"/>\n" if (${$relationship{$_}}{"TODO"});
			##print $file_handle "\t<rdf:type rdf:resource=\"&owl;InverseFunctionalProperty\"/>\n" if (${$relationship{$_}}{"TODO"});
			##print $file_handle "\t<owl:inverseOf rdf:resource=\"#has_authors\"/>\n" if (${$relationship{$_}}{"TODO"});
			print $file_handle "</owl:ObjectProperty>\n\n";
			
			#
			# replaced_by
			#
			foreach my $replaced_by ($relationship_type->replaced_by()->get_set()) {
				print $file_handle "\t<oboInOwl:replacedBy rdf:resource=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($replaced_by), "\"/>\n";
			}
			
			#
			# consider
			#
			foreach my $consider ($relationship_type->consider()->get_set()) {
				print $file_handle "\t<oboInOwl:consider rdf:resource=\"", $oboContentUrl, $local_idspace, "#", obo_id2owl_id($consider), "\"/>\n";
			}
	    }
#				
#		#
#		# Datatype annotation properties: todo: AnnotationProperty or not?
#		#
#
#		# autoGeneratedBy
#		#print $file_handle "<owl:DatatypeProperty rdf:ID=\"autoGeneratedBy\">\n";
#		#print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
#		#print $file_handle "\t<rdfs:range rdf:resource=\"http://www.w3.org/2001/XMLSchema#string\"/>\n";
#		#print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", "The program that generated this ontology.", "</rdfs:comment>\n";
#		#print $file_handle "</owl:DatatypeProperty>\n\n";
#		
#		# is_anti_symmetric
#		print $file_handle "<owl:DatatypeProperty rdf:ID=\"is_anti_symmetric\">\n";
#		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
#		print $file_handle "</owl:DatatypeProperty>\n\n";
#		
#		# is_reflexive
#		print $file_handle "<owl:DatatypeProperty rdf:ID=\"is_reflexive\">\n";
#		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
#		print $file_handle "</owl:DatatypeProperty>\n\n";
		
		#
		# EOF:
		#
		print $file_handle "</rdf:RDF>\n\n";
		print $file_handle "<!--\nGenerated with onto-perl: ".$0.", ".`date`."\n-->";
		
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
	    	
	    	my $term_id = $term->id();
	    	
	    	#
	    	# is_a: term1 -> term2
	    	#
	    	my $rt = $self->get_relationship_type_by_name("is_a");
	    	if (defined $rt)  {
		    	my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
		    	foreach my $head (sort {$a->id() cmp $b->id()} @heads) {
		    		if (!defined $term->name()) {
			    		confess "The term with id: ", $term_id, " has no name!" ;
			    	} elsif (!defined $head->name()) {
			    		confess "The term with id: ", $head->id(), " has no name!" ;
			    	} else {
			    		# TODO write down the name() instead of the id()
		    			print $file_handle "\n\t", obo_id2owl_id($term_id), " -> ", obo_id2owl_id($head->id()), ";";
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
				    		confess "The term with id: ", $term_id, " has no name!" ;
				    	} elsif (!defined $head->name()) {
				    		confess "The term with id: ", $head->id(), " has no name!" ;
				    	} else {	
							print $file_handle "\n\t", obo_id2owl_id($term_id), " -> ", obo_id2owl_id($head->id()), ";";
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
	    	
	    	my $term_id = $term->id();
	    	#
			# Class name
			#
			print $file_handle "\tnode [\n";
			my $term_sns = $term->subnamespace();
			my $id = $id{$term_sns};
			$gml_id{$term_id} = 100000000 * (defined($id)?$id:1) + $term->code();
			#$id{$term->id()} = $gml_id;
			print $file_handle "\t\troot_index	-", $gml_id{$term_id}, "\n";
			print $file_handle "\t\tid			-", $gml_id{$term_id}, "\n";
			print $file_handle "\t\tgraphics	[\n";
			#print $file_handle "\t\t\tx	1656.0\n";
			#print $file_handle "\t\t\ty	255.0\n";
			print $file_handle "\t\t\tw	40.0\n";
			print $file_handle "\t\t\th	40.0\n";
			print $file_handle "\t\t\tfill	\"#".$color_id{$term_sns}."\"\n";
			print $file_handle "\t\t\toutline	\"#000000\"\n";
			print $file_handle "\t\t\toutline_width	1.0\n";
			print $file_handle "\t\t]\n";
			print $file_handle "\t\tlabel		\"", $term_id, "\"\n";
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
				   		confess "The term with id: ", $term_id, " has no name!" ;
				   	} elsif (!defined $head->name()) {
				   		confess "The term with id: ", $head->id(), " has no name!" ;
				   	} else {
			    		print $file_handle "\tedge [\n";
			    		print $file_handle "\t\troot_index	-", $gml_id{$term_id}, "\n";
		    			print $file_handle "\t\tsource		-", $gml_id{$term_id}, "\n";
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
	my ($self, $term_set) = @_;
    
	# TODO improve this algorithm
	my $result = CCO::Core::Ontology->new();
	foreach my $term ($term_set->get_set()) {
		$result->has_term($term) || $result->add_term($term);
		foreach my $rel (@{$self->get_relationships_by_target_term($term)}){
			$result->add_relationship($rel);
			my $rel_type = $self->get_relationship_type_by_id($rel->type());
			$result->has_relationship_type($rel_type) || $result->add_relationship_type($rel_type);
		}
		foreach my $descendent (@{$self->get_descendent_terms($term)}) {
			$result->has_term($descendent) || $result->add_term($descendent);
		}
	}
	return $result;
}

=head2 get_subontology_from

  Usage    - $ontology->get_subontology_from($new_root_term)
  Returns  - a subontology from the given term of this ontology 
  Args     - the term (CCO::Core::Term) that is the root of the subontology
  Function - creates a subontology having as root the given term
  
=cut

sub get_subontology_from {
	my ($self, $root_term) = @_;
	my $result = CCO::Core::Ontology->new();
	if ($root_term) {
		$self->has_term($root_term) || confess "The term '", $root_term,"' does not belong to this ontology";
		my @queue = ($root_term);
		while (scalar(@queue) > 0) {
			my $unqueued = shift @queue;
			$result->add_term($unqueued);
			foreach my $rel (@{$self->get_relationships_by_target_term($unqueued)}){
				$result->add_relationship($rel);
				my $rel_type = $self->get_relationship_type_by_id($rel->type());
				$result->has_relationship_type($rel_type) || $result->add_relationship_type($rel_type);
			}
			my @children = @{$self->get_child_terms($unqueued)};
			@queue = (@queue, @children);
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

=head2 owl_id2obo_id

  Usage    - $ontology->owl_id2obo_id($term)
  Returns  - the ID for OBO representation.
  Args     - the OWL-type ID.
  Function - Transform an OWL-type ID into an OBO-type one. E.g. CCO_I1234567 -> CCO:I1234567
  
=cut

sub owl_id2obo_id {
	$_[0] =~ s/_/:/;
	return $_[0];
}

=head2 char_hex_http

  Usage    - $ontology->char_hex_http($seq)
  Returns  - the sequence with the hexadecimal representation for the http special characters
  Args     - the sequence of characters
  Function - Transforms a http character to its equivalent one in hexadecimal. E.g. : -> %3A
  
=cut

sub char_hex_http { 
	$_[0] =~ s/:/%3A/g;
	$_[0] =~ s/;/%3B/g;
	$_[0] =~ s/</%3C/g;
	$_[0] =~ s/=/%3D/g;
	$_[0] =~ s/>/%3E/g;
	$_[0] =~ s/\?/%3F/g;
	
#number sign                    #     23   &#035; --> #   &num;      --> &num;
#dollar sign                    $     24   &#036; --> $   &dollar;   --> &dollar;
#percent sign                   %     25   &#037; --> %   &percnt;   --> &percnt;

	$_[0] =~ s/\//%2F/g;
	$_[0] =~ s/&/%26/g;

	return $_[0];
}

sub print_hasDbXref_for_owl {
	my ($file_handle, $set, $oboContentUrl, $tab_times) = @_;
	my $tab0 = "\t"x$tab_times;
	my $tab1 = "\t"x($tab_times + 1);
	my $tab2 = "\t"x($tab_times + 2);
	for my $ref ($set->get_set()) {
		print $file_handle $tab0."<oboInOwl:hasDbXref>\n";
		print $file_handle $tab1."<oboInOwl:DbXref>\n";
		my $db = $ref->db();
		my $acc = $ref->acc();

		# Special case when db=http and acc=www.domain.com
		# <rdfs:label>URL:http%3A%2F%2Fwww2.merriam-webster.com%2Fcgi-bin%2Fmwmednlm%3Fbook%3DMedical%26va%3Dforebrain</rdfs:label>
		# <oboInOwl:hasURI rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI">http%3A%2F%2Fwww2.merriam-webster.com%2Fcgi-bin%2Fmwmednlm%3Fbook%3DMedical%26va%3Dforebrain</oboInOwl:hasURI>
		if ($db eq 'http') {
			my $http_location = char_hex_http($acc);
			print $file_handle $tab2."<rdfs:label>URL:http%3A%2F%2F", $http_location, "</rdfs:label>\n";
			print $file_handle $tab2."<oboInOwl:hasURI rdf:datatype=\"http://www.w3.org/2001/XMLSchema#anyURI\">",$http_location,"</oboInOwl:hasURI>\n";	
		} else {
			print $file_handle $tab2."<rdfs:label>", $db, ":", $acc, "</rdfs:label>\n";
			print $file_handle $tab2."<oboInOwl:hasURI rdf:datatype=\"http://www.w3.org/2001/XMLSchema#anyURI\">",$oboContentUrl,$db,"#",$db,"_",$acc,"</oboInOwl:hasURI>\n";
		}
		print $file_handle $tab1."</oboInOwl:DbXref>\n";
		print $file_handle $tab0."</oboInOwl:hasDbXref>\n";
	}
}

=head2 get_descendent_terms

  Usage    - $ontology->get_descendent_terms($term)
  Returns  - a set with the descendent terms (CCO::Core::Term) of the given term
  Args     - the term (CCO::Core::Term) for which all the descendent will be found
  Function - returns recursively all the child terms of the given term
  
=cut
sub get_descendent_terms {
	# TODO implement another method: get_descendent_terms(string)
	my ($self, $term) = @_;
	my $result = CCO::Util::TermSet->new();
	if ($term) {    	
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
	
	my ($self, $term) = @_;
	my $result = CCO::Util::TermSet->new();
    if ($term) {
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

  Usage    - $ontology->create_rel->($tail, $type, $head)
  Returns  - CCO::Core::Ontology object
  Args     - CCO::Core::(Term|Relationship) object, relationship type string, and the CCO::Core::(Term|Relationship) object, 
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

=head2 get_term_by_xref

  Usage    - $ontology->get_term_by_xref($db, $acc)
  Returns  - the term (CCO::Core::Term) associated with the given external database ID. 'undef' is returned if there is no term for the given arguments.	
  Args     - the name of the external database and the ID (strings)
  Function - returns the term associated with the given external database ID
  
=cut
sub get_term_by_xref {
	my ($self, $db, $acc) = @_;
    my $result;
    if ($db && $acc) {		
		foreach my $term (@{$self->get_terms()}) { # return the exact occurrence
			$result = $term; 
			foreach my $xref ($term->xref_set_as_string()) {
				return $result if (($xref->db() eq $db) && ($xref->acc() eq $acc));
			}
		}
    }
	return undef;
}

1;

=head1 NAME

    CCO::Core::Ontology  - an ontology holding terms and their relationships
    
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

$onto-idspace("CCO");

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

Copyright (C) 2006, 2007 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    
