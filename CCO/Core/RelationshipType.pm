# $Id: RelationshipType.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : RelationshipType.pm
# Purpose : Type of Relationship in the Ontology: is_a, part_of, etc.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Core::RelationshipType;
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
        
        $self->{DEF}                = CCO::Core::Def->new; # (0..1)
        $self->{COMMENT}            = undef; # string (0..1)
        $self->{SYNONYM_SET}        = CCO::Util::SynonymSet->new(); # set of synonyms (0..N)
        $self->{XREF_SET}           = CCO::Util::DbxrefSet->new(); # set of dbxref's (0..N)
        $self->{DOMAIN}             = undef; # string (0..1)
        $self->{RANGE}              = undef; # string (0..1)
        $self->{INVERSE_OF}         = undef; # string (0..1)
        $self->{TRANSITIVE_OVER}    = undef; # string (0..1)
        $self->{IS_CYCLIC}          = undef; # [1|0], 0 by default
        $self->{IS_REFLEXIVE}       = undef; # [1|0], 0 by default
        $self->{IS_SYMMETRIC}       = undef; # [1|0], 0 by default
        $self->{IS_ANTI_SYMMETRIC}  = undef; # [1|0], 0 by default
        $self->{IS_TRANSITIVE}      = undef; # [1|0], 0 by default
        $self->{IS_METADATA_TAG}    = undef; # [1|0], 0 by default
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
	my $self = shift;
	if (@_) { $self->{ID} = shift }
	return $self->{ID};
}

=head2 name

  Usage    - print $relationship_type->name()
  Returns  - the name of the relationship type
  Args     - the name of the relationship type
  Function - gets/sets the name of the relationship type
  
=cut
sub name {
	my $self = shift;
    if (@_) { $self->{NAME} = shift }
    return $self->{NAME};
}

=head2 def

  Usage    - $relationship_type->def() or $relationship_type->def($def)
  Returns  - the definition (CCO::Core::Def) of the relationship type
  Args     - the definition (CCO::Core::Def) of the relationship type
  Function - gets/sets the definition of the relationship type
  
=cut
sub def {
	my $self = shift;
	if (@_) {
		my $def = shift;
		croak "The definition must be a CCO::Core::Def object" if (!UNIVERSAL::isa($def, 'CCO::Core::Def'));
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
	my $self = shift;
    if (@_) {
		my $text = shift;
		my $dbxref_as_string = shift;
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
				croak "There were not defined the references for this relationship type: ", $self->id(), ". Check the 'dbxref' field.";
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

=head2 comment

  Usage    - print $relationship_type->comment()
  Returns  - the comment of this relationship type
  Args     - the comment of this relationship type
  Function - gets/sets the comment of this relationship type
  
=cut
sub comment {
	my $self = shift;
    if (@_) { $self->{COMMENT} = shift }
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
		croak "The synonym must be a CCO::Core::Synonym object" if (!UNIVERSAL::isa($synonym, 'CCO::Core::Synonym'));
		croak "The name of this relationship type (", $self->id(), ") is undefined" if (!defined($self->name()));
		# do not add 'EXACT' synonyms with the same 'name':
		$self->{SYNONYM_SET}->add($synonym) if (!($synonym->type() eq "EXACT" && $synonym->def()->text() eq $self->name()));
   	}
	return $self->{SYNONYM_SET}->get_set();
}

=head2 synonym_as_string

  Usage    - print $relationship_type->synonym_as_string() or $relationship_type->synonym_as_string("this is a synonym text", "[CCO:ea]", "EXACT")
  Returns  - an array with the synonym(s) of this relationship type
  Args     - the synonym text (string), the dbxrefs (string) and synonym type (string) of this relationship type
  Function - gets/sets the synonym(s) of this relationship type
  
=cut
sub synonym_as_string {
	# todo all, check parameters, similar to def_as_string()?
	my $self = shift;
	if (@_) {
		my $synonym_text = shift;
		my $dbxrefs      = shift;
		my $type         = shift;
		$synonym_text || croak "The synonym text for this relationship type (",$self->id() ,") was not defined";
		$dbxrefs || croak "The dbxrefs for the synonym of this relationship type (",$self->id() ,") was not defined";
		$type || croak "The synonym type for the synonym of this relationship type (",$self->id() ,") was not defined";
		
		my $synonym = CCO::Core::Synonym->new();
		$synonym->def_as_string($synonym_text, $dbxrefs);
		$synonym->type($type);
		
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
  Args     - analogous xref(s) of this relationship type in another vocabulary
  Function - gets/sets the analogous xref(s) of this relationship type in another vocabulary
  
=cut
sub xref_set {
	my $self = shift;
	if (@_) {
		my $xref_set = shift;
    		croak "The xref must be a CCO::Util::DbxrefSet object" if (!UNIVERSAL::isa($xref_set, 'CCO::Util::DbxrefSet'));
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
	my $self = shift;
	if (@_) {
		my $xref_as_string = shift;
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
		# todo do not overwrite the existing set; add the new elements to the existing set!
		$self->{XREF_SET} = $xref_set;
	}
	my @result = $self->xref_set()->get_set();
}

=head2 domain

  Usage    - print $relationship_type-->domain()
  Returns  - the domain to which this relationship type belongs
  Args     - the domain to which this relationship type belongs
  Function - gets/sets the domain to which this relationship type belongs
  
=cut
sub domain {
	my $self = shift;
    if (@_) { $self->{DOMAIN} = shift }
    return $self->{DOMAIN};
}

=head2 range

  Usage    - print $relationship_type->range()
  Returns  - the range of this relationship type
  Args     - the range of this relationship type
  Function - gets/sets the range of this relationship type
  
=cut
sub range {
	my $self = shift;
    if (@_) { $self->{RANGE} = shift }
    return $self->{RANGE};
}

=head2 inverse_of

  Usage    - print $relationship_type->inverse_of()
  Returns  - inverse relationship type of this relationship type
  Args     - inverse relationship type of this relationship type
  Function - gets/sets the inverse relationship type of this relationship type
  
=cut
sub inverse_of {
	my $self = shift;
    if (@_) {
    		my $rel = shift;
    		$self->{INVERSE_OF} = $rel;
    		$rel->{INVERSE_OF}  = $self;
    		# todo que pasa cuando hago delete de una de las relaciones?
    	}
    return $self->{INVERSE_OF};
}

=head2 transitive_over

  Usage    - print $relationship_type->transitive_over()
  Returns  - the relationship type with which this one is transitive over
  Args     - the relationship type with which this one is transitive over
  Function - gets/sets the relationship type with which this one is transitive over
  
=cut
sub transitive_over {
	my $self = shift;
    if (@_) { $self->{TRANSITIVE_OVER} = shift }
    return $self->{TRANSITIVE_OVER};
}


=head2 is_cyclic

  Usage    - $relationship_type->is_cyclic()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is cyclic or not.
  
=cut
sub is_cyclic {
	my $self = shift;
    if (@_) { $self->{IS_CYCLIC} = shift }
    return (defined($self->{IS_CYCLIC}) && $self->{IS_CYCLIC} == 1)?1:0;
}

=head2 is_reflexive

  Usage    - $relationship_type->is_reflexive()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is reflexive or not.
  
=cut
sub is_reflexive {
	my $self = shift;
    if (@_) { $self->{IS_REFLEXIVE} = shift }
    return (defined($self->{IS_REFLEXIVE}) && $self->{IS_REFLEXIVE} == 1)?1:0;
}

=head2 is_symmetric

  Usage    - $relationship_type->is_symmetric()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is symmetric or not.
  
=cut
sub is_symmetric {
	my $self = shift;
    if (@_) { $self->{IS_SYMMETRIC} = shift }
    return (defined($self->{IS_SYMMETRIC}) && $self->{IS_SYMMETRIC} == 1)?1:0;
}

=head2 is_anti_symmetric

  Usage    - $relationship_type->is_anti_symmetric()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is anti symmetric or not.
  
=cut
sub is_anti_symmetric {
	my $self = shift;
    if (@_) { $self->{IS_ANTI_SYMMETRIC} = shift }
    return (defined($self->{IS_ANTI_SYMMETRIC}) && $self->{IS_ANTI_SYMMETRIC} == 1)?1:0;
}

=head2 is_transitive

  Usage    - $relationship_type->is_transitive()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is transitive or not.
  
=cut
sub is_transitive {
	my $self = shift;
    if (@_) { $self->{IS_TRANSITIVE} = shift }
    return (defined($self->{IS_TRANSITIVE}) && $self->{IS_TRANSITIVE} == 1)?1:0;
}

=head2 is_metadata_tag

  Usage    - $relationship_type->is_metadata_tag()
  Returns  - 1 (true) or 0 (false)
  Args     - 1 (true) or 0 (false)
  Function - tells whether the relationship type is a metadata tag or not.
  
=cut
sub is_metadata_tag {
	my $self = shift;
    if (@_) { $self->{IS_METADATA_TAG} = shift }
    return (defined($self->{IS_METADATA_TAG}) && $self->{IS_METADATA_TAG} == 1)?1:0;
}

=head2 builtin

  Usage    - $term->builtin() or $term->builtin(1) or $term->builtin(0)
  Returns  - tells if this term is builtin to the OBO format; false by default
  Args     - 1 (true) or 0 (false)
  Function - gets/sets the value indicating whether this term is builtin to the OBO format
  
=cut
sub builtin {
	my $self = shift;
	if (@_) { $self->{BUILTIN} = shift }
	return (defined($self->{BUILTIN}) && $self->{BUILTIN} == 1)?1:0;
}

=head2 equals

  Usage    - print $relationship_type->equals($another_relationship_type)
  Returns  - either 1 (true) or 0 (false)
  Args     - the relationship type to compare with
  Function - tells whether this relationship type is equal to the parameter
  
=cut
sub equals  {
	my $self = shift;
	my $result = 0;
	if (@_) {
     	my $target = shift;
		croak "The term to be compared with must be a CCO::Core::RelationshipType object" if (!UNIVERSAL::isa($target, "CCO::Core::RelationshipType"));
		my $self_id = $self->{'ID'};
		my $target_id = $target->{'ID'};
		croak "The ID of this relationship type is not defined" if (!defined($self_id));
		croak "The ID of the target relationship type is not defined" if (!defined($target_id));
		$result = ($self_id eq $target_id);
	}
	return $result;
}

1;

=head1 NAME
    Core::RelationshipType  - a type of relationship type in an ontology
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

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut