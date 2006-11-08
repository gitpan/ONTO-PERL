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
use CCO::Core::TermSet;
use strict;
use warnings;
use Carp;

sub new {
        my $class                     = shift;
        my $self                      = {};
        
        $self->{ID}                   = undef; # required, (1)
        $self->{NAME}                 = undef; # required, (1)
        $self->{NAMESPACE}            = undef; # required, (1)
        $self->{COMMENT}              = undef; # string (0..1)
        
        $self->{TERMS}                = {}; # map: term_id vs. term  (0..n)
        $self->{TERMS_SET}            = CCO::Core::TermSet->new(); # Terms (0..n)
        $self->{RELATIONSHIP_TYPES}   = {}; # map: relationship_type_id vs. relationship_type  (0..n)
        $self->{RELATIONSHIPS}        = {}; # (0..N)
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

=head2 namespace

  Usage    - print $ontology->namespace()
  Returns  - the namespace (string) of this ontology
  Args     - the namespace (string) of this ontology
  Function - gets/sets the namespace of this ontolog
  
=cut
sub namespace {
	my $self = shift;
    if (@_) { $self->{NAMESPACE} = shift }
    return $self->{NAMESPACE};
}

=head2 comment

  Usage    - print $ontology->comment()
  Returns  - the comment (string) of the ontology
  Args     - the comment (string) of the ontology
  Function - gets/sets the comment of the ontology
  
=cut
sub comment {
	my $self = shift;
    if (@_) { $self->{COMMENT} = shift }
    return $self->{COMMENT};
}

=head2 add_term

  Usage    - $ontology->add_term($term)
  Returns  - the just added term (CCO::Core::Term)
  Args     - the term (CCO::Core::Term) to be added
  Function - adds a term to this ontology
  
=cut
sub add_term {
    my $self = shift;
    if (@_) {
		my $term = shift;
    
		croak "A term to be added must be a CCO::Core::Term object" if (!UNIVERSAL::isa($term, 'CCO::Core::Term'));
		$term->id || croak "The term to be added to this ontology does not have an ID";
    
		my $id = $term->id;
		$self->{TERMS}->{$id} = $term;
		$self->{TERMS_SET}->add($term);
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
		my $term_name = shift;
    
		$term_id || croak "A term to be added to this ontology must have an ID";
		$term_name || croak "A term to be added to this ontology must have a name";

		my $new_term = CCO::Core::Term->new();
		$new_term->id($term_id);
		$new_term->name($term_name);
		$self->add_term($new_term);
		return $new_term;
    }
}

=head2 add_relationship_type

  Usage    - $ontology->add_relationship_type($relationship_type)
  Returns  - the just added relationship type (CCO::Core::RelationshipType)
  Args     - the relationship type to be added (CCO::Core::RelationshipType)
  Function - adds a relationship type to this ontology
  
=cut
sub add_relationship_type {
    my $self = shift;
    if (@_) {
		my $relationship_type = shift;
    
		croak "The relationship type to be added must be a CCO::Core::RelationshipType object" if (!UNIVERSAL::isa($relationship_type, 'CCO::Core::RelationshipType'));
		$relationship_type->id || croak "The relationship type to be added to this ontology does not have an ID";
    
		my $id = $relationship_type->id;
		$self->{RELATIONSHIP_TYPES}->{$id} = $relationship_type;
		
		# todo es necesario implementar un set de types? para get_relationship_types()?
		#$self->{RELATIONSHIP_TYPES_SET}->add($relationship_type);
		return $relationship_type;
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
		my $relationship_type_name = shift;
    
		$relationship_type_id || croak "A relationship type to be added to this ontology must have an ID";
		$relationship_type_name || croak "A relationship type to be added to this ontology must have a name";

		my $new_relationship_type = CCO::Core::RelationshipType->new();
		$new_relationship_type->id($relationship_type_id);
		$new_relationship_type->name($relationship_type_name);
		$self->add_relationship_type($new_relationship_type);
		return $new_relationship_type;
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
    
		croak "The term to be deleted must be a CCO::Core::Term object" if (!UNIVERSAL::isa($term, 'CCO::Core::Term'));
		$term->id || croak "The term to be deleted from this ontology does not have an ID";
    
		my $id = $term->id;
		if (defined($id) && defined($self->{TERMS}->{$id})) {
			delete $self->{TERMS}->{$id};
			$self->{TERMS_SET}->remove($term);
		}
		
		# todo delete the relationships: to its parents and children!
    }
}

=head2 has_term

  Usage    - print $ontology->has_term($term)
  Returns  - true or false
  Args     - the term (CCO::Core::Term) to be tested
  Function - checks if the given term belongs to this ontology
  
=cut
sub has_term {
    my $self = shift;
    my $result = 0;
    if (@_) {
		my $term = shift;
    
		croak "The term to be checked must be a CCO::Core::Term object" if (!UNIVERSAL::isa($term, "CCO::Core::Term"));
    
		my $id = $term->id;
		$result = 1 if (defined($id) && defined($self->{TERMS}->{$id}));
    }
    return $result;
}

=head2 has_relationship_type

  Usage    - print $ontology->has_relationship_type($relationship_type)
  Returns  - true or false
  Args     - the relationship (CCO::Core::Relationship) type to be tested
  Function - checks if the given relationship type belongs to this ontology
  
=cut
sub has_relationship_type {
    my $self = shift;
    my $result = 0;
    if (@_) {
		my $relationship_type = shift;
    
		croak "The relationship type to be checked must be a CCO::Core::RelationshipType object" if (!UNIVERSAL::isa($relationship_type, "CCO::Core::RelationshipType"));
    
		my $id = $relationship_type->id();
		$result = 1 if (defined($id) && defined($self->{RELATIONSHIP_TYPES}->{$id}));
    }
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
			croak "The namespace is not defined for this ontology";
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

=head2 get_relationship_types_by_term

  Usage    - $ontology->get_relationship_types_by_term($term)
  Returns  - a reference to an array with the relationship types (CCO::Core::RelationshipType) held by this ontology
  Args     - the term (CCO::Core::Term) for which its relationship types will be found
  Function - returns the relationship types associated to the given term
  
=cut
sub get_relationship_types_by_term {
	my $self = shift;
	my $result = CCO::Util::Set->new(); # todo crear RelationshipTypeSet?
	if (@_) {
		my $term = shift;
		my @rels = values(%{$self->{SOURCE_RELATIONSHIPS}->{$term}});
		foreach my $rel (@rels) {
			$result->add($rel->type()); # todo devolver un RelationshipType
		}
	}
	my @arr = $result->get_set();
    return \@arr;
}

=head2 get_term_by_id

  Usage    - $ontology->get_term_by_id($id)
  Returns  - the term (CCO::Core::Term) associated to the given id
  Args     - the term's id (string)
  Function - returns the term associated to the given id
  
=cut
sub get_term_by_id {
    my $self = shift;
    my $result;
    if (@_) {
		my $id = shift;
		$result = $self->{TERMS}->{$id};
    }
    return $result;
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
    my $self = shift;
    my $result;
    if (@_) {
		my $name = lc(shift);
		my @terms = @{$self->get_terms()};
		my @found_terms = grep { lc($_->name()) eq $name } @terms;
		$result = $found_terms[0]; # todo return the first occurrence for the moment
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
		my @relationship_types = @{$self->get_relationship_types()};
		#my @found_relationship_types;
		#foreach my $relt (@relationship_types) {
		#	warn "ALL: ", $relt->name();
		#	if ( lc($relt->name()) eq $name ) {
		#		push @found_relationship_types, $relt;
		#	}
		#}
		my @found_relationship_types = grep { defined $_ && lc($_->name()) eq lc($name)  } @relationship_types;
		$result = $found_relationship_types[0]; # todo return the first occurrence for the moment
    }
    return $result;
}

=head2 add_relationship

  Usage    - $ontology->add_relationship()
  Returns  - none
  Args     - the relationship (CCO::Core::Relationship) to be added between two existing terms
  Function - adds a relationship between two terms
  
=cut
sub add_relationship {
    my $self = shift;
    my ($relationship) = @_;
    
    croak "The relationship to be added must be a CCO::Core::Relationship object" if (!UNIVERSAL::isa($relationship, "CCO::Core::Relationship"));
    
    my $id = $relationship->id;
    $id || croak "The relationship to be added to this ontology does not have an ID";
    $self->{RELATIONSHIPS}->{$id} = $relationship;
    
    # Are the terms connected by $relationship already in this ontology? if not, add them.
    my $target_term = $self->{RELATIONSHIPS}->{$id}->head();
    $self->has_term($target_term) || $self->add_term($target_term);
    my $source_term = $self->{RELATIONSHIPS}->{$id}->tail();
    $self->has_term($source_term) || $self->add_term($source_term);
    
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
	my $self = shift;
	my $result;
	if (@_) {
		my $id   = shift;
    		$result = $self->{RELATIONSHIPS}->{$id};
	}
    return $result;
}

=head2 get_child_terms

  Usage    - $ontology->get_child_terms($term)
  Returns  - a reference to an array with the child terms (CCO::Core::Term) of the given term
  Args     - the term (CCO::Core::Term) for which the children will be found
  Function - returns the child terms of the given term
  
=cut
sub get_child_terms {
	my $self = shift;
	my $result = CCO::Core::TermSet->new();
    if (@_) {
		my $term = shift;
		my @rels = values(%{$self->{SOURCE_RELATIONSHIPS}->{$term}});
		foreach my $rel (@rels) {
			$result->add($rel->head());
		}
    }
	my @arr = $result->get_set();
    return \@arr;
}

=head2 get_head_by_relationship_type

  Usage    - $ontology->get_head_by_relationship_type($term, $relationship_type)
  Returns  - a reference to an array of terms (CCO::Core::Term) pointed out by the relationship of the given type; otherwise undef
  Args     - the term (CCO::Core::Term) and the relationship type (CCO::Core::RelationshipType)
  Function - returns the term pointed out by the relationship of the given type
  
=cut
sub get_head_by_relationship_type {
	my $self = shift;
	my $result = CCO::Core::TermSet->new();
    if (@_) {
		my $term = shift;
		croak "The term must be a CCO::Core::Term object" if (!UNIVERSAL::isa($term, 'CCO::Core::Term'));
		my $relationship_type = shift;
		croak "The relationship type of this source term (",$term->id() ,") must be a CCO::Core::RelationshipType object" if (!UNIVERSAL::isa($relationship_type, 'CCO::Core::RelationshipType'));
		my @rels = values(%{$self->{SOURCE_RELATIONSHIPS}->{$term}});
		foreach my $rel (@rels) {
			 $result->add($rel->head()) if ($rel->type() eq $relationship_type->name());
		}
    }
    my @arr = $result->get_set();
    return \@arr;
}

=head2 get_tail_by_relationship_type

  Usage    - $ontology->get_tail_by_relationship_type($term, $relationship_type)
  Returns  - a reference to an array of terms (CCO::Core::Term) pointing out the given term by means of the given relationship type; otherwise undef
  Args     - the term (CCO::Core::Term) and the relationship type (CCO::Core::RelationshipType)
  Function - returns the term pointing out the given term by means of the given relationship type
  
=cut
sub get_tail_by_relationship_type {
	my $self = shift;
	my $result = CCO::Core::TermSet->new();
    if (@_) {
		my $term = shift;
		croak "The term must be a CCO::Core::Term object" if (!UNIVERSAL::isa($term, 'CCO::Core::Term'));
		my $relationship_type = shift;
		croak "The relationship type must be a CCO::Core::RelationshipType object" if (!UNIVERSAL::isa($relationship_type, 'CCO::Core::RelationshipType'));
		my @rels = values(%{$self->{TARGET_RELATIONSHIPS}->{$term}});
		foreach my $rel (@rels) {
			 $result->add($rel->tail()) if ($rel->type() eq $relationship_type->name());
		}
    }
    my @arr = $result->get_set();
    return \@arr;
}

=head2 get_recursive_child_terms

  Usage    - $ontology->get_recursive_child_terms($term)
  Returns  - a set with the child terms (CCO::Core::Term) of the given term
  Args     - the term (CCO::Core::Term) for which all the children will be found
  Function - returns all the child terms of the given term
  
=cut
sub get_recursive_child_terms {
	
	my $self = shift;
	my $result = CCO::Core::TermSet->new();
    if (@_) {
    	my $term = shift;
    	my @queue = ();
    	push @queue, $term;
    	while (scalar(@queue) > 0) {
    		my $unqueued = shift @queue;
    		$result->add($unqueued);
    		my @children = @{$self->get_child_terms($unqueued)};
    		for my $child (@children){
    			push @queue, $child;
    		}
    	}
    }
	my @arr = $result->get_set();
    return \@arr;
}

=head2 get_parent_terms

  Usage    - $ontology->get_parent_terms($term)
  Returns  - an array with the parent terms (CCO::Core::Term) of the given term
  Args     - the term (CCO::Core::Term) for which the parents will be found
  Function - returns the parent terms of the given term
  
=cut
sub get_parent_terms {
	my $self = shift;
	my $result = CCO::Core::TermSet->new();
    if (@_) {
		my $term = shift;
		my @rels = values(%{$self->{TARGET_RELATIONSHIPS}->{$term}});
		foreach my $rel (@rels) {
			$result->add($rel->tail());
		}
    }
    return $result->get_set();
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
  Args     - the file handle (STDOUT, STDERR, ...) and the format: obo (by default), xml, owl, dot. Default file handle: STDOUT.
  Function - exports this ontology
  
=cut
sub export {
    my $self = shift;
    my $file_handle = shift || \*STDOUT;
    my $format = shift || "obo";
    
    my $possible_formats = CCO::Util::Set->new();
	$possible_formats->add_all('obo', 'xml', 'owl', 'dot');
	if (!$possible_formats->contains($format)) {
		croak "The format must be one of the following: 'obo', 'xml', 'owl', 'dot'";
	}
    
    if ($format eq "obo") {
	    
		# preambule: OBO header tags
		print $file_handle "format-version: 1.2\n";
		print $file_handle "date: ", `date '+%d:%m:%Y %H:%M'`;
		print $file_handle "default-namespace: cco\n";
		print $file_handle "autogenerated-by: onto-perl\n";
		print $file_handle "remark: The Cell-Cycle Ontology\n";
	
	    # terms
	    my @all_terms = values(%{$self->{TERMS}});
	    foreach my $term (@all_terms) {
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
	    		croak "The term with id: ", $term->id(), " has no name!" ;
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
			# disjoint_from:
			#
			foreach my $disjoint_term_id ($term->disjoint_from()) {
				print $file_handle "\ndisjoint_from: ", $disjoint_term_id;
			}
			
	    	#
	    	# is_a:
	    	#
	    	my $rt = $self->get_relationship_type_by_name("is_a");
	    	if (defined $rt)  {
		    	my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
		    	foreach my $head (@heads) {
		    		if (defined $head->name()) {
			    		print $file_handle "\nis_a: ", $head->id(), " ! ", $head->name();
			    	} else {
			    		croak "The term with id: ", $head->id(), " has no name!" ;
			    	}
		    	}
	    	}
			
			#
	    	# relationship:
	    	#
	    	foreach $rt (@{$self->get_relationship_types()}) {
	    		if ($rt->name() ne "is_a") { # is_a is printed above
					my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
					foreach my $head (@heads) {
						print $file_handle "\nrelationship: ", $rt->name(), " ", $head->id(), " ! ", $head->name();
					}
	    		}
	    	}
	    	#
	    	# synonym:
	    	#
	    	foreach my $synonym ($term->synonym_set()) {
	    		print $file_handle "\nsynonym: ", $synonym->def_as_string(), " {scope=\"", $synonym->type(), "\"}";
	    	}
	    	
	    	#
	    	# comment:
	    	#
	    	print $file_handle "\ncomment: ", $term->comment() if (defined $term->comment());
	    	
	    	#
	    	# xref:
	    	#
	    	foreach my $xref ($term->xref_set_as_string()) {
	    		print $file_handle "\nxref: ", $xref->as_string();
	    	}
	    	
	    	#
	    	# end
	    	#
	    	print $file_handle "\n";
	    }
	    # relationship types
	    my @all_relationship_types = values(%{$self->{RELATIONSHIP_TYPES}});
	    foreach my $relationship_type (@all_relationship_types) {
			print $file_handle "\n[Typedef]";
	    	print $file_handle "\nid: ", $relationship_type->id();
	    	print $file_handle "\nname: ", $relationship_type->name();
	    	print $file_handle "\nbuiltin: true" if ($relationship_type->builtin() == 1);
	    	print $file_handle "\ndef: ", $relationship_type->def_as_string() if (defined $relationship_type->def()->text());
	    	print $file_handle "\ncomment: ", $relationship_type->comment() if (defined $relationship_type->comment());
	    	foreach my $synonym ($relationship_type->synonym_set()) {
	    		print $file_handle "\nsynonym: ", $synonym->def_as_string(), " {scope=\"", $synonym->type(), "\"}";
	    	}
	    	print $file_handle "\nis_cyclic: true" if ($relationship_type->is_cyclic() == 1);
	    	print $file_handle "\nis_reflexive: true" if ($relationship_type->is_reflexive() == 1);
	    	print $file_handle "\nis_symmetric: true" if ($relationship_type->is_symmetric() == 1);
	    	print $file_handle "\nis_anti_symmetric: true" if ($relationship_type->is_anti_symmetric() == 1);
	    	print $file_handle "\nis_transitive: true" if ($relationship_type->is_transitive() == 1);
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
		chomp(my $date = `date '+%d:%m:%Y %H:%M'`);
		print $file_handle "\t\t<date>", $date, "</date>\n";
		print $file_handle "\t\t<default-namespace>cco</default-namespace>\n";
		print $file_handle "\t\t<autogenerated-by>$0</autogenerated-by>\n";
		print $file_handle "\t\t<remark>The Cell-Cycle Ontology</remark>\n";
		print $file_handle "\t</header>\n\n";
		
		foreach my $term (@all_terms) {
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
	    		croak "The term with id: ", $term->id(), " has no name!" ;
	    	}
	    	
	    	#
	    	# def:
	    	#
	    	print $file_handle "\t\t<def>", $term->def_as_string(), "</def>\n" if (defined $term->def()->text());

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
		    	foreach my $head (@heads) {
		    		if (defined $head->name()) {
			    		print $file_handle "\t\t<is_a id=\"", $head->id(), "\">", $head->name(), "</is_a>\n";
			    	} else {
			    		croak "The term with id: ", $head->id(), " has no name!" ;
			    	}
		    	}
	    	}
			
			#
			# relationship:
			#
	    	foreach $rt (@{$self->get_relationship_types()}) {
	    		if ($rt->name() ne "is_a") { # is_a is printed above
					my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
					foreach my $head (@heads) {
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
	    	foreach my $xref ($term->xref_set_as_string()) {
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
	    foreach my $relationship_type (@all_relationship_types) {
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
	    	
	    	print $file_handle "\t</typedef>\n\n";
	    }
	    
	    print $file_handle "</cco>\n";
    } elsif ($format eq "owl") {
		#
		# preambule
		#
		print $file_handle "<?xml version=\"1.0\"?>\n";
		print $file_handle "<rdf:RDF\n";
		print $file_handle "\txmlns=\"http://www.sbcellcycle.org/cco/ontology/cco.owl#\"\n";
		print $file_handle "\txml:base=\"http://www.sbcellcycle.org/cco/ontology/cco.owl\"\n";
		print $file_handle "\txmlns:p1=\"http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl#\"\n";
		print $file_handle "\txmlns:dcterms=\"http://purl.org/dc/terms/\"\n";
		print $file_handle "\txmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"\n";         
		print $file_handle "\txmlns:xsp=\"http://www.owl-ontologies.com/2005/08/07/xsp.owl#\"\n";
		print $file_handle "\txmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n";
		print $file_handle "\txmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"\n";
		print $file_handle "\txmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n";
		print $file_handle "\txmlns:owl=\"http://www.w3.org/2002/07/owl#\"\n";
		print $file_handle ">\n";
		
		print $file_handle "<owl:Ontology rdf:about=\"\">\n";
		print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">Cell-Cycle Ontology</rdfs:comment>\n";
		print $file_handle "\t<owl:versionInfo rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">0.3</owl:versionInfo>\n";
		print $file_handle "\t<owl:imports rdf:resource=\"http://purl.org/dc/elements/1.1/\"/>\n";
		print $file_handle "</owl:Ontology>\n\n";
		
		#
		# term
		#
		my @all_terms = values(%{$self->{TERMS}});
		# visit the terms
		foreach my $term (@all_terms){
			#
			# Class name
			#
			print $file_handle "<owl:Class rdf:ID=\"", obo_id2owl_id($term->id()), "\">\n";;
			
			#
			# label name = class name
			#
			print $file_handle "\t<rdfs:label xml:lang=\"en\">", $term->name(), "</rdfs:label>\n";
				
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
				print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $term->def()->text(), "</rdfs:comment>\n";
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
				print $file_handle "\t<synonym rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", $synonym->def()->text(), "</synonym>\n";
				# todo consider the scope as element attribute as in the following line:
				#print $file_handle "\t<synonym rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\" scope=\"", $synonym->type(), "\">", $synonym->def_as_string(), "</synonym>\n";
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
		    	foreach my $head (@heads) {
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
					foreach my $head (@heads) {
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
	    foreach my $relationship_type (@all_relationship_types) {
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
		
		# xref
		print $file_handle "<owl:DatatypeProperty rdf:ID=\"xref\">\n";
		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
		print $file_handle "\t<rdfs:range rdf:resource=\"http://www.w3.org/2001/XMLSchema#string\"/>\n";
		print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", "Describes an analogous term in another vocabulary. A term may have any number of xref's.", "</rdfs:comment>\n";
		print $file_handle "</owl:DatatypeProperty>\n\n";
		
		# synonym
		print $file_handle "<owl:DatatypeProperty rdf:ID=\"synonym\">\n";
		print $file_handle "\t<rdf:type rdf:resource=\"http://www.w3.org/2002/07/owl#AnnotationProperty\"/>\n";
		print $file_handle "\t<rdfs:range rdf:resource=\"http://www.w3.org/2001/XMLSchema#string\"/>\n";
		print $file_handle "\t<rdfs:comment rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">", "Synonym of the class or relationship.", "</rdfs:comment>\n";
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
		print $file_handle "<!--\nGenerated with ".$0.", ".`date`."-->";
		
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
	    foreach my $term (@all_terms) {
	    	
	    	#
	    	# is_a: term1 -> term2
	    	#
	    	my $rt = $self->get_relationship_type_by_name("is_a");
	    	if (defined $rt)  {
		    	my @heads = @{$self->get_head_by_relationship_type($term, $rt)};
		    	foreach my $head (@heads) {
		    		if (!defined $term->name()) {
			    		croak "The term with id: ", $term->id(), " has no name!" ;
			    	} elsif (!defined $head->name()) {
			    		croak "The term with id: ", $head->id(), " has no name!" ;
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
					foreach my $head (@heads) {
						if (!defined $term->name()) {
				    		croak "The term with id: ", $term->id(), " has no name!" ;
				    	} elsif (!defined $head->name()) {
				    		croak "The term with id: ", $head->id(), " has no name!" ;
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
    }
    
    return 0;
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

1;

=head1 NAME
    Core::Ontology  - an ontology
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

# three new relationships
my $r12 = CCO::Core::Relationship->new();
my $r23 = CCO::Core::Relationship->new();
my $r13 = CCO::Core::Relationship->new();
my $r14 = CCO::Core::Relationship->new();

$r12->id("CCO:P0000001_is_a_CCO:P0000002");
$r23->id("CCO:P0000002_part_of_CCO:P0000003");
$r13->id("CCO:P0000001_participates_in_CCO:P0000003");
$r14->id("CCO:P0000001_participates_in_CCO:P0000004");

$r12->type("is_a");
$r23->type("part_of");
$r13->type("participates_in");
$r14->type("participates_in");

$r12->link($n1, $n2);
$r23->link($n2, $n3);
$r13->link($n1, $n3);
$r14->link($n1, $n4);

# get all terms
my $c = 0;
my %h;
foreach my $t (@{$onto->get_terms()}) {
	$h{$t->id()} = $t;
	$c++;
}

# add relationships
$onto->add_relationship($r12);
$onto->add_relationship($r23);
$onto->add_relationship($r13);
$onto->add_relationship($r14);

# add relationships and terms linked by this relationship
my $n11 = CCO::Core::Term->new();
my $n21 = CCO::Core::Term->new();
$n11->id("CCO:P0000011"); $n11->name("One one"); $n11->def_as_string("Definition One one", "");
$n21->id("CCO:P0000021"); $n21->name("Two one"); $n21->def_as_string("Definition Two one", "");
my $r11_21 = CCO::Core::Relationship->new();
$r11_21->id("CCO:R0001121"); $r11_21->type("r11-21");
$r11_21->link($n11, $n21);
$onto->add_relationship($r11_21); # adds to the ontology the linked terms by this relationship

# get all relationships
my %hr;
foreach my $r (@{$onto->get_relationships()}) {
	$hr{$r->id()} = $r;
}

# get children
my @children = @{$onto->get_child_terms($n1)};
my %ct;
foreach my $child (@children) {
	$ct{$child->id()} = $child;
}

@children = @{$onto->get_child_terms($n3)};
@children = @{$onto->get_child_terms($n2)};

# get parents
my @parents = $onto->get_parent_terms($n3);
@parents = $onto->get_parent_terms($n1);
@parents = $onto->get_parent_terms($n2);

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
This module has several methods to cope with the CCO. Basically, it is a
directed acyclic graph (DAG) holding the terms and nodes which in turn are
linked by relationships. These relationships have an associated relationship 
type.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    