# $Id: RelationshipType.pm 2010-12-22 erick.antezana $
#
# Module  : RelationshipType.pm
# Purpose : Type of Relationship in the Ontology: is_a, part_of, etc.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::Core::RelationshipType;

use strict;
use warnings;

use OBO::Core::Dbxref;
use OBO::Core::Def;
use OBO::Util::Map;
use OBO::Util::Set;
use OBO::Util::SynonymSet;

sub new {
	my $class                   = shift;
	my $self                    = {};

	$self->{ID}                 = undef;                        # required, string (1)
	$self->{IS_ANONYMOUS}       = undef;                        # [1|0], 0 by default
	$self->{NAME}               = undef;                        # string (1)

	$self->{NAMESPACE_SET}      = OBO::Util::Set->new();        # set (0..N)
	$self->{ALT_ID}             = OBO::Util::Set->new();        # set (0..N)
	$self->{BUILTIN}            = undef;                        # [1|0], 0 by default
	$self->{DEF}                = OBO::Core::Def->new;          # (0..1)
	$self->{COMMENT}            = undef;                        # string (0..1)
	$self->{SUBSET_SET}         = OBO::Util::Set->new();        # set of scalars (0..N)
	$self->{SYNONYM_SET}        = OBO::Util::SynonymSet->new(); # set of synonyms (0..N)
	$self->{XREF_SET}           = OBO::Util::DbxrefSet->new();  # set of dbxref's (0..N)
	$self->{DOMAIN}             = OBO::Util::Set->new();        # set of scalars (0..N)
	$self->{RANGE}              = OBO::Util::Set->new();        # set of scalars (0..N)
	$self->{IS_ANTI_SYMMETRIC}  = undef;                        # [1|0], 0 by default
	$self->{IS_CYCLIC}          = undef;                        # [1|0], 0 by default
	$self->{IS_REFLEXIVE}       = undef;                        # [1|0], 0 by default
	$self->{IS_SYMMETRIC}       = undef;                        # [1|0], 0 by default
	$self->{IS_TRANSITIVE}      = undef;                        # [1|0], 0 by default
	$self->{INVERSE_OF}         = undef;                        # string (0..1) # TODO This should be a Set of Relationships...
	$self->{TRANSITIVE_OVER}    = OBO::Util::Set->new();        # set of scalars (0..N)

	$self->{HOLDS_OVER_CHAIN}   = OBO::Util::Map->new();        # map of scalars-->ref's to arrays (0..N)
	$self->{FUNCTIONAL}         = undef;                        # [1|0], 0 by default
	$self->{INVERSE_FUNCTIONAL} = undef;                        # [1|0], 0 by default
	
	$self->{INTERSECTION_OF}    = OBO::Util::Set->new();        # (0..N)
	$self->{UNION_OF}           = OBO::Util::Set->new();        # (0..N)
	$self->{DISJOINT_FROM}      = OBO::Util::Set->new();        # (0..N)

	$self->{CREATED_BY}         = undef;                        # scalar (0..1)
	$self->{CREATION_DATE}      = undef;                        # scalar (0..1)
	$self->{MODIFIED_BY}        = undef;                        # scalar (0..1)
	$self->{MODIFICATION_DATE}  = undef;                        # scalar (0..1)
	$self->{IS_OBSOLETE}        = undef;                        # [1|0], 0 by default
	$self->{REPLACED_BY}        = OBO::Util::Set->new();        # set of scalars (0..N)
	$self->{CONSIDER}           = OBO::Util::Set->new();        # set of scalars (0..N)
	$self->{IS_METADATA_TAG}    = undef;                        # [1|0], 0 by default

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

=head2 is_anonymous

  Usage    - print $relationship_type->is_anonymous() or $relationship_type->is_anonymous("1")
  Returns  - either 1 (true) or 0 (false)
  Args     - either 1 (true) or 0 (false)
  Function - tells whether this relationship type is anonymous or not.
  
=cut
sub is_anonymous {
	my $self = shift;
    $self->{IS_ANONYMOUS} = shift if (@_);
    return (defined($self->{IS_ANONYMOUS}) && $self->{IS_ANONYMOUS} == 1)?1:0;
}

=head2 name

  Usage    - print $relationship_type->name()
  Returns  - the name of the relationship type
  Args     - the name of the relationship type
  Function - gets/sets the name of the relationship type
  
=cut

sub name {
	my ($self, $name) = @_;
	$self->{NAME} = $name if ($name);
	return $self->{NAME};
}

=head2 alt_id

  Usage    - $relationship_type->alt_id() or $relationship_type->alt_id($id1, $id2, $id3, ...)
  Returns  - a set (OBO::Util::Set) with the alternate id(s) of this relationship type
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
  Returns  - the definition (OBO::Core::Def) of the relationship type
  Args     - the definition (OBO::Core::Def) of the relationship type
  Function - gets/sets the definition of the relationship type
  
=cut

sub def {
	my ($self, $def) = @_;
	$self->{DEF} = $def if ($def); 
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
    	my $def = $self->{DEF};
		$def->text($text);
		my $dbxref_set = OBO::Util::DbxrefSet->new();
		
		$dbxref_as_string =~ s/^\[//;
		$dbxref_as_string =~ s/\]$//;		
		$dbxref_as_string =~ s/\\,/;;;;/g; # trick to keep the comma's
		$dbxref_as_string =~ s/\\"/;;;;;/g; # trick to keep the double quote's
		
		my @lineas = $dbxref_as_string =~ /\"([^\"]*)\"/g; # get the double-quoted pieces
		foreach my $l (@lineas) {
			my $cp = $l;
			$l =~ s/,/;;;;/g; # trick to keep the comma's
			$dbxref_as_string =~ s/\Q$cp\E/$l/;
		}
		
		my @dbxrefs = split (",", $dbxref_as_string);
		
		foreach my $entry (@dbxrefs) {
			my ($match, $db, $acc, $desc, $mod) = ('', '', '', '', '');
			my $dbxref = OBO::Core::Dbxref->new();
			if ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)\s+\"([^\"]*)\"\s+(\{[\w ]+=[\w ]+\}))/) {
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
				$desc  = _unescape($4);
				$mod   = _unescape($5);
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)\s+(\{[\w ]+=[\w ]+\}))/) {
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
				$mod   = _unescape($4);
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)\s+\"([^\"]*)\")/) {
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
				$desc  = _unescape($4);
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*))/) { # skip: , y "
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
			} else {
				die "The references of the relationship type with ID: '", $self->id(), "' were not properly defined. Check the 'dbxref' field (", $entry, ").";
			}
			
			# set the dbxref:
			$dbxref->name($db.':'.$acc);
			$dbxref->description($desc) if (defined $desc);
			$dbxref->modifier($mod) if (defined $mod);
			$dbxref_set->add($dbxref);
		}
		$def->dbxref_set($dbxref_set);
		$self->{DEF} = $def;
	}
	my @result = (); # a Set?
	foreach my $dbxref (sort {lc($a->id()) cmp lc($b->id())} $self->{DEF}->dbxref_set()->get_set()) {
		push @result, $dbxref->as_string();
	}
	my $d = $self->{DEF}->text();
	if (defined $d) {
		return "\"".$self->{DEF}->text()."\""." [".join(', ', @result)."]";
	} else {
		return "\"\" [".join(', ', @result)."]";
	}
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

=head2 subset

  Usage    - $relationship_type->subset() or $relationship_type->subset($ss1, $ss2, $ss3, ...)
  Returns  - an array with the subset to which this relationship type belongs
  Args     - the subset(s) to which this relationship type belongs
  Function - gets/sets the subset(s) to which this relationship type belongs
  
=cut
sub subset {
	my $self = shift;
	if (scalar(@_) > 1) {
   		$self->{SUBSET_SET}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{SUBSET_SET}->add(shift);
	}
	return $self->{SUBSET_SET}->get_set();
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
		die "The name of this relationship type (", $self->id(), ") is undefined" if (!defined($self->name()));
		# do not add 'EXACT' synonyms with the same 'name':
		$self->{SYNONYM_SET}->add($synonym) if (!($synonym->scope() eq "EXACT" && $synonym->def()->text() eq $self->name()));
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

		my $synonym = OBO::Core::Synonym->new();
		$synonym->def_as_string($synonym_text, $dbxrefs);
		$synonym->scope($scope);
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
  Args     - analogous xref(s) (OBO::Util::DbxrefSet) of this relationship type in another vocabulary
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
		$xref_as_string =~ s/^\[//;
		$xref_as_string =~ s/\]$//;		
		$xref_as_string =~ s/\\,/;;;;/g; # trick to keep the comma's
		$xref_as_string =~ s/\\"/;;;;;/g; # trick to keep the double quote's
		
		my @lineas = $xref_as_string =~ /\"([^\"]*)\"/g; # get the double-quoted pieces
		foreach my $l (@lineas) {			
			my $cp = $l;
			$l =~ s/,/;;;;/g; # trick to keep the comma's
			$xref_as_string =~ s/\Q$cp\E/$l/;
		}
		
		my $xref_set = $self->{XREF_SET};
		
		my @dbxrefs = split (/,/, $xref_as_string);
		
		foreach my $entry (@dbxrefs) {
			my ($match, $db, $acc, $desc, $mod) = ('', '', '', '', '');
			my $xref = OBO::Core::Dbxref->new();
			if ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)\s+\"([^\"]*)\"\s+(\{[\w ]+=[\w ]+\}))/) {
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
				$desc  = _unescape($4);
				$mod   = _unescape($5);
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)\s+(\{[\w ]+=[\w ]+\}))/) {
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
				$mod   = _unescape($4);
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)\s+\"([^\"]*)\")/) {
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
				$desc  = _unescape($4);
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*))/) { # skip: , y "
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
			} else {
				die "The references of the relationship type with ID: '", $self->id(), "' were not properly defined. Check the 'xref' field (", $entry, ").";
			}
			
			# set the dbxref:
			$xref->name($db.':'.$acc);
			$xref->description($desc) if (defined $desc);
			$xref->modifier($mod) if (defined $mod);
			$xref_set->add($xref);
		}
		$self->{XREF_SET} = $xref_set; # We are overwriting the existing set; otherwise, add the new elements to the existing set!
	}
	my @result = $self->xref_set()->get_set();
}

=head2 domain

  Usage    - print $relationship_type->domain() or $relationship_type->domain($id1, $id2, $id3, ...)
  Returns  - a set (OBO::Util::Set) with the domain(s) to which this relationship type belongs
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
  Returns  - a set (OBO::Util::Set) with the range(s) of this relationship type
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

  Usage    - $relationship_type->inverse_of() or $relationship_type->inverse_of($inv_rel)
  Returns  - inverse relationship type (OBO::Core::RelationshipType) of this relationship type
  Args     - inverse relationship type (OBO::Core::RelationshipType) of this relationship type
  Function - gets/sets the inverse relationship type of this relationship type
  
=cut

sub inverse_of {
	my ($self, $rel) = @_;
    if ($rel) {
		$self->{INVERSE_OF} = $rel;
		$rel->{INVERSE_OF}  = $self;
		# TODO: test what would happend when we delete any of those two relationships.
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
    $self->{IS_CYCLIC} = $rel if ($rel);
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
    $self->{IS_REFLEXIVE} = $rel if ($rel);
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
    $self->{IS_SYMMETRIC} = $rel if ($rel);
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
    $self->{IS_ANTI_SYMMETRIC} = $rel if ($rel);
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
    $self->{IS_TRANSITIVE} = $rel if ($rel);
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
    $self->{IS_METADATA_TAG} = $rel if ($rel);
    return (defined($self->{IS_METADATA_TAG}) && $self->{IS_METADATA_TAG} == 1)?1:0;
}

=head2 transitive_over

  Usage    - $relationship_type->transitive_over() or $relationship_type->transitive_over($id1, $id2, $id3, ...)
  Returns  - a set (OBO::Util::Set) with the relationship type(s) for which this relationship type is(are) transitive over
  Args     - the relationship type(s) (string) with which this one is transitive over
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

=head2 holds_over_chain

  Usage    - $relationship_type->holds_over_chain() or $relationship_type->holds_over_chain($rt1, $rt2)
  Returns  - an array of pairs (string) with the relationship type identifiers for which this relationship type holds over a chain
  Args     - the relationship type identifiers (string) with which this one holds over a chain
  Function - gets/sets the set of the relationship types for which this relationship type holds over a chain
  
=cut

sub holds_over_chain {
	my $self = shift;
	my $composition_symbol = "&&";
	if (scalar(@_) == 2) {
		my $key = $_[0].$composition_symbol.$_[1]; # R<-R1&&R2
		$self->{HOLDS_OVER_CHAIN}->put($key, \@_);
	}
	return $self->{HOLDS_OVER_CHAIN}->values();
}

=head2 functional

  Usage    - $relationship_type->functional() or $relationship_type->functional(1) or $relationship_type->functional(0)
  Returns  - tells if this relationship type is functional; false by default
  Args     - 1 (true) or 0 (false)
  Function - gets/sets the value indicating whether this relationship type is functional
  
=cut

sub functional {
	my ($self, $rel) = @_;
	$self->{FUNCTIONAL} = $rel if ($rel);
	return (defined($self->{FUNCTIONAL}) && $self->{FUNCTIONAL} == 1)?1:0;
}

=head2 inverse_functional

  Usage    - $relationship_type->inverse_functional() or $relationship_type->inverse_functional(1) or $relationship_type->inverse_functional(0)
  Returns  - tells if this relationship type is inverse functional; false by default
  Args     - 1 (true) or 0 (false)
  Function - gets/sets the value indicating whether this relationship type is inverse functional
  
=cut

sub inverse_functional {
	my ($self, $rel) = @_;
	$self->{INVERSE_FUNCTIONAL} = $rel if ($rel);
	return (defined($self->{INVERSE_FUNCTIONAL}) && $self->{INVERSE_FUNCTIONAL} == 1)?1:0;
}

=head2 intersection_of
        
  Usage    - $relationship_type->intersection_of() or $relationship_type->intersection_of($t1, $t2, $r1, ...)
  Returns  - an array with the terms/relations which define this relationship type
  Args     - a set (strings) of terms/relations which define this relationship type
  Function - gets/sets the set of terms/relatonships defining this relationship type
        
=cut
sub intersection_of {
	my $self = shift;
	if (scalar(@_) > 1) {
		$self->{INTERSECTION_OF}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{INTERSECTION_OF}->add(shift);
	}
	return $self->{INTERSECTION_OF}->get_set();
}

=head2 union_of
        
  Usage    - $relationship_type->union_of() or $relationship_type->union_of($t1, $t2, $r1, ...)
  Returns  - an array with the terms/relations which define this relationship type
  Args     - a set (strings) of terms/relations which define this relationship type
  Function - gets/sets the set of terms/relatonships defining this relationship type
        
=cut    
sub union_of {
	my $self = shift;
	if (scalar(@_) > 1) {
		$self->{UNION_OF}->add_all(@_);
	} elsif (scalar(@_) == 1) { 
		$self->{UNION_OF}->add(shift);
	}
	return $self->{UNION_OF}->get_set();
} 

=head2 disjoint_from

  Usage    - $relationship_type->disjoint_from() or $relationship_type->disjoint_from($disjoint_term_id1, $disjoint_term_id2, $disjoint_term_id3, ...)
  Returns  - the disjoint relationship type id(s) (string(s)) from this one
  Args     - the relationship type id(s) (string) that is (are) disjoint from this one
  Function - gets/sets the disjoint relationship type(s) from this one
  
=cut
sub disjoint_from {
	my $self = shift;
	if (scalar(@_) > 1) {
   		$self->{DISJOINT_FROM}->add_all(@_);
	} elsif (scalar(@_) == 1) {
		$self->{DISJOINT_FROM}->add(shift);
	}
	return $self->{DISJOINT_FROM}->get_set();
}

=head2 created_by

  Usage    - print $relationship_type->created_by() or $relationship_type->created_by("erick_antezana")
  Returns  - name (string) of the creator of the relationship type, may be a short username, initials or ID
  Args     - name (string) of the creator of the relationship type, may be a short username, initials or ID
  Function - gets/sets the name of the creator of the relationship type
  
=cut
sub created_by {
	my ($self, $created_by) = @_;
	$self->{CREATED_BY} = $created_by if ($created_by);
	return $self->{CREATED_BY};
}

=head2 creation_date

  Usage    - print $relationship_type->creation_date() or $relationship_type->creation_date("2010-04-13T01:32:36Z")
  Returns  - date (string) of creation of the relationship type specified in ISO 8601 format
  Args     - date (string) of creation of the relationship type specified in ISO 8601 format
  Function - gets/sets the date of creation of the relationship type
  
=cut
sub creation_date {
	my ($self, $creation_date) = @_;
	$self->{CREATION_DATE} = $creation_date if ($creation_date);
	return $self->{CREATION_DATE};
}

=head2 modified_by

  Usage    - print $relationship_type->modified_by() or $relationship_type->modified_by("erick_antezana")
  Returns  - name (string) of the modificator of the relationship type, may be a short username, initials or ID
  Args     - name (string) of the modificator of the relationship type, may be a short username, initials or ID
  Function - gets/sets the name of the modificator of the relationship type
  
=cut
sub modified_by {
	my ($self, $modified_by) = @_;
	$self->{MODIFIED_BY} = $modified_by if ($modified_by);
	return $self->{MODIFIED_BY};
}

=head2 modification_date

  Usage    - print $relationship_type->modification_date() or $relationship_type->modification_date("2010-04-13T01:32:36Z")
  Returns  - date (string) of modification of the relationship type specified in ISO 8601 format
  Args     - date (string) of modification of the relationship type specified in ISO 8601 format
  Function - gets/sets the date of modification of the relationship type
  
=cut
sub modification_date {
	my ($self, $modification_date) = @_;
	$self->{MODIFICATION_DATE} = $modification_date if ($modification_date);
	return $self->{MODIFICATION_DATE};
}

=head2 is_obsolete

  Usage    - print $relationship_type->is_obsolete()
  Returns  - either 1 (true) or 0 (false)
  Args     - either 1 (true) or 0 (false)
  Function - tells whether the relationship type is obsolete or not. 'false' by default.
  
=cut

sub is_obsolete {
	my ($self, $obs) = @_;
    $self->{IS_OBSOLETE} = $obs if ($obs);
    return (defined($self->{IS_OBSOLETE}) && $self->{IS_OBSOLETE} == 1)?1:0;
}

=head2 replaced_by

  Usage    - $relationship_type->replaced_by() or $relationship_type->replaced_by($id1, $id2, $id3, ...)
  Returns  - a set (OBO::Util::Set) with the id(s) of the replacing relationship type(s)
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
  Returns  - a set (OBO::Util::Set) with the appropiate substitute(s) for an obsolete relationship type
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
	$self->{BUILTIN} = $rel if ($rel);
	return (defined($self->{BUILTIN}) && $self->{BUILTIN} == 1)?1:0;
}

=head2 equals

  Usage    - print $relationship_type->equals($another_relationship_type)
  Returns  - either 1 (true) or 0 (false)
  Args     - the relationship type (OBO::Core::RelationshipType) to compare with
  Function - tells whether this relationship type is equal to the parameter
  
=cut

sub equals  {
	my ($self, $target) = @_;
	my $result = 0;
	if ($target) {
		my $self_id = $self->{'ID'};
		my $target_id = $target->{'ID'};
		die "The ID of this relationship type is not defined." if (!defined($self_id));
		die "The ID of the target relationship type is not defined." if (!defined($target_id));
		$result = ($self_id eq $target_id);
	}
	return $result;
}

sub _unescape {
	my $match = $_[0];
	$match =~ s/;;;;;/\\"/g;
	$match =~ s/;;;;/\\,/g;
	return $match;
}

1;

__END__


=head1 NAME

OBO::Core::RelationshipType - A type of relationship type in an ontology.
    
=head1 SYNOPSIS

use OBO::Core::RelationshipType;

use strict;


# three new relationships types

my $r1 = OBO::Core::RelationshipType->new();

my $r2 = OBO::Core::RelationshipType->new();

my $r3 = OBO::Core::RelationshipType->new();


$r1->id("CCO:R0000001");

$r2->id("CCO:R0000002");

$r3->id("CCO:R0000003");


$r1->name("is a");

$r2->name("part of");

$r3->name("participates in");


# rel. type creator + date

$r1->created_by("erick_antezana");

$r1->creation_date("2008-04-13T01:32:36Z ");


# inverse

my $r3_inv = OBO::Core::RelationshipType->new();

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

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut