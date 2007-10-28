# $Id: RelationshipType.pm 1585 2007-10-12 15:23:38Z erant $
#
# Module  : RelationshipType.pm
# Purpose : Type of Relationship in the Ontology: is_a, part_of, etc.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Core::RelationshipType;

=head1 NAME

CCO::Core::RelationshipType - A type of relationship type in an ontology
    
=head1 SYNOPSIS

use CCO::Core::RelationshipType;

use strict;


# three new relationships types

my $r1 = CCO::Core::RelationshipType->new();

my $r2 = CCO::Core::RelationshipType->new();

my $r3 = CCO::Core::RelationshipType->new();


$r1->id("CCO:R0000001");

$r2->id("CCO:R0000002");

$r3->id("CCO:R0000003");


$r1->name("is a");

$r2->name("part of");

$r3->name("participates in");


# inverse

my $r3_inv = CCO::Core::RelationshipType->new();

$r3_inv->id("CCO:R0000004");

$r3_inv->name("has participant");

$r3_inv->inverse_of($r3);


# def as string

$r2->def_as_string("This is a dummy definition", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]");

my @refs_r2 = $r2->def()->dbxref_set()->get_set();

my %r_r2;

foreach my $ref_r2 (@refs_r2) {
	
	$r_r2{$ref_r2->name()} = $ref_r2->name();
	
}


=head1 DESCRIPTION

A type of relationship in the ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use CCO::Core::Dbxref;
use CCO::Core::Def;
use CCO::Util::SynonymSet;
use CCO::Util::Set;
use strict;
use warnings;
use Carp;

sub new {
        my $class                   = shift;
        my $self                    = {};
        
        $self->{ID}                 = undef; # required, string (1)
        $self->{NAME}               = undef; # required, string (1)
        
        $self->{ALT_ID}             = CCO::Util::Set->new(); # set (0..N)
        $self->{DEF}                = CCO::Core::Def->new; # (0..1)
        $self->{NAMESPACE_SET}      = CCO::Util::Set->new(); # set (0..N)
        $self->{COMMENT}            = undef; # string (0..1)
        $self->{SYNONYM_SET}        = CCO::Util::SynonymSet->new(); # set of synonyms (0..N)
        $self->{XREF_SET}           = CCO::Util::DbxrefSet->new(); # set of dbxref's (0..N)
        $self->{DOMAIN}             = CCO::Util::Set->new(); # set of scalars (0..N)
        $self->{RANGE}              = CCO::Util::Set->new(); # set of scalars (0..N)
        $self->{IS_CYCLIC}          = undef; # [1|0], 0 by default
        $self->{IS_REFLEXIVE}       = undef; # [1|0], 0 by default
        $self->{IS_SYMMETRIC}       = undef; # [1|0], 0 by default
        $self->{IS_ANTI_SYMMETRIC}  = undef; # [1|0], 0 by default
        $self->{IS_TRANSITIVE}      = undef; # [1|0], 0 by default
        $self->{IS_METADATA_TAG}    = undef; # [1|0], 0 by default
        $self->{INVERSE_OF}         = undef; # string (0..1)
        $self->{TRANSITIVE_OVER}    = CCO::Util::Set->new(); # set of scalars (0..N)
        $self->{IS_OBSOLETE}        = undef; # [1|0], 0 by default
        $self->{REPLACED_BY}        = CCO::Util::Set->new(); # set of scalars (0..N)
		$self->{CONSIDER}           = CCO::Util::Set->new(); # set of scalars (0..N)
        $self->{BUILTIN}            = undef; # [1|0], 0 by default
	
        bless ($self, $class);
        return $self;
}

=head2 id

  Usage    - print $relationship_type->id()
  Returns  - the relationship type ID
  Args     - the relationship type ID
  Function - gets/sets an ID
  
=cut

sub id {
	my ($self, $id) = @_;
	if ($id) { $self->{ID} = $id }
	return $self->{ID};
}

=head2 name

  Usage    - print $relationship_type->name()
  Returns  - the name of the relationship type
  Args     - the name of the relationship type
  Function - gets/sets the name of the relationship type
  
=cut

sub name {
	my ($self, $name) = @_;
	if ($name) { $self->{NAME} = $name }
	return $self->{NAME};
}

=head2 alt_id

  Usage    - $relationship_type->alt_id() or $relationship_type->alt_id($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the alternate id(s) of this relationship type
  Args     - the alternate id(s) (string) of this relationship type
  Function - gets/sets the alternate id(s) of this relationship type
  
=cut

sub alt_id {
	my $self = shift;
	if (scalar(@_) > 1) {
   		$self->{ALT_ID}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{ALT_ID}->add(shift);
	}
	return $self->{ALT_ID};
}

=head2 def

  Usage    - $relationship_type->def() or $relationship_type->def($def)
  Returns  - the definition (CCO::Core::Def) of the relationship type
  Args     - the definition (CCO::Core::Def) of the relationship type
  Function - gets/sets the definition of the relationship type
  
=cut

sub def {
	my ($self, $def) = @_;
	if ($def) {
		$self->{DEF} = $def; 
	}
    return $self->{DEF};
}

=head2 def_as_string

  Usage    - $relationship_type->def_as_string() or $relationship_type->def_as_string("This is a sample", "[CCO:ea, PMID:9334324]")
  Returns  - the definition (string) of the relationship type
  Args     - the definition (string) of the relationship type plus the dbxref list describing the source of this definition
  Function - gets/sets the definition of the relationship type
  
=cut

sub def_as_string {
	my ($self, $text, $dbxref_as_string) = @_;
    if ($text && $dbxref_as_string) {
		$dbxref_as_string =~ s/\[//;
		$dbxref_as_string =~ s/\]//;
		my @refs = split(/, /, $dbxref_as_string);
    		
		my $def = CCO::Core::Def->new();
		$def->text($text);
		
		my $dbxref_set = CCO::Util::DbxrefSet->new();
		foreach my $ref (@refs) {
			if ($ref =~ /([\w-]+:[\w:,\(\)\.-]+)(\"\w+\")?(\{\w+\})?/) {
				my $dbxref = CCO::Core::Dbxref->new();
				$dbxref->name($1);
				$dbxref->description($2) if (defined $2);
				$dbxref->modifier($3) if (defined $3);
				$dbxref_set->add($dbxref);
			} else {
				confess "There were not defined the references for this relationship type: ", $self->id(), ". Check the 'dbxref' field.";
			}
		}
		$def->dbxref_set($dbxref_set);
		
		$self->{DEF} = $def; 
	}
	my @result = (); # a Set?
	foreach my $dbxref ($self->{DEF}->dbxref_set()->get_set()) {
		push @result, $dbxref->as_string();
	}
	return "\"".$self->{DEF}->text()."\""." [".join(', ', @result)."]";
}

=head2 namespace

  Usage    - $relationship_type->namespace() or $relationship_type->namespace($ns1, $ns2, $ns3, ...)
  Returns  - an array with the namespace to which this relationship type belongs
  Args     - the namespacet(s) to which this relationship type belongs
  Function - gets/sets the namespace(s) to which this relationship type belongs
  
=cut

sub namespace {
        my $self = shift;
        if (scalar(@_) > 1) {
                $self->{NAMESPACE_SET}->add_all(@_);
        } elsif (scalar(@_) == 1) {
                $self->{NAMESPACE_SET}->add(shift);
        }
        return $self->{NAMESPACE_SET}->get_set();
}

=head2 comment

  Usage    - print $relationship_type->comment()
  Returns  - the comment of this relationship type
  Args     - the comment of this relationship type
  Function - gets/sets the comment of this relationship type
  
=cut

sub comment {
	my ($self, $comment) = @_;
    if ($comment) { $self->{COMMENT} = $comment }
    return $self->{COMMENT};
}

=head2 synonym_set

  Usage    - $relationship_type->synonym_set() or $relationship_type->synonym_set($synonym1, $synonym2, $synonym3, ...)
  Returns  - an array with the synonym(s) of this relationship type
  Args     - the synonym(s) of this relationship type
  Function - gets/sets the synonym(s) of this relationship type
  
=cut

sub synonym_set {
	my $self = shift;
	foreach my $synonym (@_) {		
		confess "The name of this relationship type (", $self->id(), ") is undefined" if (!defined($self->name()));
		# do not add 'EXACT' synonyms with the same 'name':
		$self->{SYNONYM_SET}->add($synonym) if (!($synonym->type() eq "EXACT" && $synonym->def()->text() eq $self->name()));
   	}
	return $self->{SYNONYM_SET}->get_set();
}

=head2 synonym_as_string

  Usage    - print $relationship_type->synonym_as_string() or $relationship_type->synonym_as_string("this is a synonym text", "[CCO:ea]", "EXACT")
  Returns  - an array with the synonym(s) of this relationship type
  Args     - the synonym text (string), the dbxrefs (string), synonym scope (string) of this relationship type, and optionally the synonym type name (string)
  Function - gets/sets the synonym(s) of this relationship type
  
=cut

sub synonym_as_string {
	my ($self, $synonym_text, $dbxrefs, $scope, $synonym_type_name) = @_;
	if ($synonym_text && $dbxrefs && $scope) {

		my $synonym = CCO::Core::Synonym->new();
		$synonym->def_as_string($synonym_text, $dbxrefs);
		$synonym->type($scope);
		$synonym->synonym_type_name($synonym_type_name); # optional argument
		$self->synonym_set($synonym);
	}
	
	my @result;
	foreach my $synonym ($self->{SYNONYM_SET}->get_set()) {
		push @result, $synonym->def_as_string();
   	}
	return @result;
}

=head2 xref_set

  Usage    - $relationship_type->xref_set() or $relationship_type->xref_set($dbxref_set)
  Returns  - a Dbxref set with the analogous xref(s) of this relationship type in another vocabulary
  Args     - analogous xref(s) (CCO::Util::DbxrefSet) of this relationship type in another vocabulary
  Function - gets/sets the analogous xref(s) of this relationship type in another vocabulary
  
=cut

sub xref_set {
	my ($self, $xref_set) = @_;
	if ($xref_set) {
    	$self->{XREF_SET} = $xref_set;
    }
    return $self->{XREF_SET};
}

=head2 xref_set_as_string

  Usage    - $relationship_type->xref_set_as_string() or $relationship_type->xref_set_as_string("[Reactome:20610, EC:2.3.2.12]")
  Returns  - the dbxref set with the analogous xref(s) of this relationship type; [] if the set is empty
  Args     - the dbxref set with the analogous xref(s) of this relationship type
  Function - gets/sets the dbxref set with the analogous xref(s) of this relationship type
  
=cut

sub xref_set_as_string {
	my ($self, $xref_as_string) = @_;
	if ($xref_as_string) {
		$xref_as_string =~ s/\[//;
		$xref_as_string =~ s/\]//;
		my @refs = split(/, /, $xref_as_string);
		
		my $xref_set = $self->{XREF_SET};
		foreach my $ref (@refs) {
			if ($ref =~ /([\w-]+:[\w:,\(\)\.-]+)(\s+\"([\w ]+)\")?(\s+(\{[\w ]+=[\w ]+\}))?/) {
				my $xref = CCO::Core::Dbxref->new();
				$xref->name($1);
				$xref->description($3) if (defined $3);
				$xref->modifier($5) if (defined $5);
				$xref_set->add($xref);
			} else {
				croak "There were not defined the references for this definition: ", $self->id(), ". Check the 'dbxref' field.";
			}
		}
		# We are overwriting the existing set; otherwise, add the new elements to the existing set!
		$self->{XREF_SET} = $xref_set;
	}
	my @result = $self->xref_set()->get_set();
}

=head2 domain

  Usage    - print $relationship_type->domain() or $relationship_type->domain($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the domain(s) to which this relationship type belongs
  Args     - the domain(s) (string) to which this relationship type belongs
  Function - gets/sets the domain(s) to which this relationship type belongs
  
=cut

sub domain {
	my $self = shift;
	if (scalar(@_) > 1) {
   		$self->{DOMAIN}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{DOMAIN}->add(shift);
	}
	return $self->{DOMAIN};
}

=head2 range

  Usage    - print $relationship_type->range() or $relationship_type->range($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the range(s) of this relationship type
  Args     - the range(s) (string) of this relationship type
  Function - gets/sets the range(s) of this relationship type
  
=cut

sub range {
	my $self = shift;
	if (scalar(@_) > 1) {
   		$self->{RANGE}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{RANGE}->add(shift);
	}
	return $self->{RANGE};
}

=head2 inverse_of

  Usage    - $relationship_type->inverse_of()
  Returns  - inverse relationship type of this relationship type
  Args     - inverse relationship type of this relationship type
  Function - gets/sets the inverse relationship type of this relationship type
  
=cut

sub inverse_of {
	my ($self, $rel) = @_;
    if ($rel) {
		$self->{INVERSE_OF} = $rel;
		$rel->{INVERSE_OF}  = $self;
		# Future improvement: test what would happend when we delete any of those two relationships.
	}
    return $self->{INVERSE_OF};
}

=head2 is_cyclic

  Usage    - $relationship_type->is_cyclic()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is cyclic or not.
  
=cut

sub is_cyclic {
	my ($self, $rel) = @_;
    if ($rel) { $self->{IS_CYCLIC} = $rel }
    return (defined($self->{IS_CYCLIC}) && $self->{IS_CYCLIC} == 1)?1:0;
}

=head2 is_reflexive

  Usage    - $relationship_type->is_reflexive()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is reflexive or not.
  
=cut

sub is_reflexive {
	my ($self, $rel) = @_;
    if ($rel) { $self->{IS_REFLEXIVE} = $rel }
    return (defined($self->{IS_REFLEXIVE}) && $self->{IS_REFLEXIVE} == 1)?1:0;
}

=head2 is_symmetric

  Usage    - $relationship_type->is_symmetric()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is symmetric or not.
  
=cut

sub is_symmetric {
	my ($self, $rel) = @_;
    if ($rel) { $self->{IS_SYMMETRIC} = $rel }
    return (defined($self->{IS_SYMMETRIC}) && $self->{IS_SYMMETRIC} == 1)?1:0;
}

=head2 is_anti_symmetric

  Usage    - $relationship_type->is_anti_symmetric()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is anti symmetric or not.
  
=cut

sub is_anti_symmetric {
	my ($self, $rel) = @_;
    if ($rel) { $self->{IS_ANTI_SYMMETRIC} = $rel }
    return (defined($self->{IS_ANTI_SYMMETRIC}) && $self->{IS_ANTI_SYMMETRIC} == 1)?1:0;
}

=head2 is_transitive

  Usage    - $relationship_type->is_transitive()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is transitive or not.
  
=cut

sub is_transitive {
	my ($self, $rel) = @_;
    if ($rel) { $self->{IS_TRANSITIVE} = $rel }
    return (defined($self->{IS_TRANSITIVE}) && $self->{IS_TRANSITIVE} == 1)?1:0;
}

=head2 is_metadata_tag

  Usage    - $relationship_type->is_metadata_tag()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether this relationship type is a metadata tag or not.
  
=cut

sub is_metadata_tag {
	my ($self, $rel) = @_;
    if ($rel) { $self->{IS_METADATA_TAG} = $rel }
    return (defined($self->{IS_METADATA_TAG}) && $self->{IS_METADATA_TAG} == 1)?1:0;
}

=head2 transitive_over

  Usage    - $relationship_type->transitive_over() or $relationship_type->transitive_over($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the relationship type(s) for which this relationship type is(are) transitive over
  Args     - the relationship type(s) (CCO::Core::RelationshipType) with which this one is transitive over
  Function - gets/sets the set of the relationship type(s) for which this relationship type is(are) transitive over
  
=cut

sub transitive_over {
	my $self = shift;
	if (scalar(@_) > 1) {
   		$self->{TRANSITIVE_OVER}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{TRANSITIVE_OVER}->add(shift);
	}
	return $self->{TRANSITIVE_OVER};
}

=head2 is_obsolete

  Usage    - print $relationship_type->is_obsolete()
  Returns  - either 1 (true) or 0 (false)
  Args     - either 1 (true) or 0 (false)
  Function - tells whether the relationship type is obsolete or not. 'false' by default.
  
=cut

sub is_obsolete {
	my ($self, $obs) = @_;
    if ($obs) { $self->{IS_OBSOLETE} = $obs }
    return (defined($self->{IS_OBSOLETE}) && $self->{IS_OBSOLETE} == 1)?1:0;
}

=head2 replaced_by

  Usage    - $relationship_type->replaced_by() or $relationship_type->replaced_by($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the id(s) of the replacing relationship type(s)
  Args     - the the id(s) of the replacing relationship type(s) (string)
  Function - gets/sets the the id(s) of the replacing relationship type(s)
  
=cut

sub replaced_by {
	my $self = shift;
	if (scalar(@_) > 1) {
   		$self->{REPLACED_BY}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{REPLACED_BY}->add(shift);
	}
	return $self->{REPLACED_BY};
}

=head2 consider

  Usage    - $relationship_type->consider() or $relationship_type->consider($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the appropiate substitute(s) for an obsolete relationship type
  Args     - the appropiate substitute(s) for an obsolete relationship type (string)
  Function - gets/sets the appropiate substitute(s) for this obsolete relationship type
  
=cut

sub consider {
	my $self = shift;
	if (scalar(@_) > 1) {
   		$self->{CONSIDER}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{CONSIDER}->add(shift);
	}
	return $self->{CONSIDER};
}

=head2 builtin

  Usage    - $relationship_type->builtin() or $relationship_type->builtin(1) or $relationship_type->builtin(0)
  Returns  - tells if this relationship type is builtin to the OBO format; false by default
  Args     - 1 (true) or 0 (false)
  Function - gets/sets the value indicating whether this relationship type is builtin to the OBO format
  
=cut

sub builtin {
	my ($self, $rel) = @_;
	if ($rel) { $self->{BUILTIN} = $rel }
	return (defined($self->{BUILTIN}) && $self->{BUILTIN} == 1)?1:0;
}

=head2 equals

  Usage    - print $relationship_type->equals($another_relationship_type)
  Returns  - either 1 (true) or 0 (false)
  Args     - the relationship type (CCO::Core::RelationshipType) to compare with
  Function - tells whether this relationship type is equal to the parameter
  
=cut

sub equals  {
	my ($self, $target) = @_;
	my $result = 0;
	if ($target) {
		my $self_id = $self->{'ID'};
		my $target_id = $target->{'ID'};
		confess "The ID of this relationship type is not defined" if (!defined($self_id));
		confess "The ID of the target relationship type is not defined" if (!defined($target_id));
		$result = ($self_id eq $target_id);
	}
	return $result;
}

1;