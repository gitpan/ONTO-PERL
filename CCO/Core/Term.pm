# $Id: Term.pm 1585 2007-10-12 15:23:38Z erant $
#
# Module  : Term.pm
# Purpose : Term in the Ontology.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Core::Term;

=head1 NAME

CCO::Core::Term  - A universal/term/class/concept in an ontology
    
=head1 SYNOPSIS

use CCO::Core::Term;

use CCO::Core::Def;

use CCO::Util::DbxrefSet;

use CCO::Core::Dbxref;

use CCO::Core::Synonym;

use strict;


# three new terms

my $n1 = CCO::Core::Term->new();

my $n2 = CCO::Core::Term->new();

my $n3 = CCO::Core::Term->new();


# id's

$n1->id("CCO:P0000001");

$n2->id("CCO:P0000002");

$n3->id("CCO:P0000003");


# alt_id

$n1->alt_id("CCO:P0000001_alt_id");

$n2->alt_id("CCO:P0000002_alt_id1", "CCO:P0000002_alt_id2", "CCO:P0000002_alt_id3", "CCO:P0000002_alt_id4");


# name

$n1->name("One");

$n2->name("Two");

$n3->name("Three");


$n1->is_obsolete(1);

$n1->is_obsolete(0);

$n1->is_anonymous(1);

$n1->is_anonymous(0);


# synonyms

my $syn1 = CCO::Core::Synonym->new();

$syn1->type('EXACT');

my $def1 = CCO::Core::Def->new();

$def1->text("Hola mundo1");

my $sref1 = CCO::Core::Dbxref->new();

$sref1->name("CCO:vm");

my $srefs_set1 = CCO::Util::DbxrefSet->new();

$srefs_set1->add($sref1);

$def1->dbxref_set($srefs_set1);

$syn1->def($def1);

$n1->synonym($syn1);


my $syn2 = CCO::Core::Synonym->new();

$syn2->type('BROAD');

my $def2 = CCO::Core::Def->new();

$def2->text("Hola mundo2");

my $sref2 = CCO::Core::Dbxref->new();

$sref2->name("CCO:ls");

$srefs_set1->add_all($sref1);

my $srefs_set2 = CCO::Util::DbxrefSet->new();

$srefs_set2->add_all($sref1, $sref2);

$def2->dbxref_set($srefs_set2);

$syn2->def($def2);

$n2->synonym($syn2);


my $syn3 = CCO::Core::Synonym->new();

$syn3->type('BROAD');

my $def3 = CCO::Core::Def->new();

$def3->text("Hola mundo2");

my $sref3 = CCO::Core::Dbxref->new();

$sref3->name("CCO:ls");

my $srefs_set3 = CCO::Util::DbxrefSet->new();

$srefs_set3->add_all($sref1, $sref2);

$def3->dbxref_set($srefs_set3);

$syn3->def($def3);

$n3->synonym($syn3);


# synonym as string

$n2->synonym_as_string("Hello world2", "[CCO:vm2, CCO:ls2]", "EXACT");


# xref

$n1->xref("Uno");

$n1->xref("Eins");

$n1->xref("Een");

$n1->xref("Un");

$n1->xref("Uj");

my $xref_length = $n1->xref()->size();


my $def = CCO::Core::Def->new();

$def->text("Hola mundo");

my $ref1 = CCO::Core::Dbxref->new();

my $ref2 = CCO::Core::Dbxref->new();

my $ref3 = CCO::Core::Dbxref->new();


$ref1->name("CCO:vm");

$ref2->name("CCO:ls");

$ref3->name("CCO:ea");


my $refs_set = CCO::Util::DbxrefSet->new();

$refs_set->add_all($ref1,$ref2,$ref3);

$def->dbxref_set($refs_set);

$n1->def($def);

$n2->def($def);


# def as string

$n2->def_as_string("This is a dummy definition", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"] {opt=first}");

my @refs_n2 = $n2->def()->dbxref_set()->get_set();

my %r_n2;

foreach my $ref_n2 (@refs_n2) {
	
	$r_n2{$ref_n2->name()} = $ref_n2->name();
	
}


=head1 DESCRIPTION

A Term in the ontology. c.f. OBO flat file specification.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use CCO::Core::Def;
use CCO::Core::Synonym;
use CCO::Util::SynonymSet;
use CCO::Util::Set;
use strict;
use warnings;
use Carp;

sub new {
	my $class                   = shift;
	my $self                    = {};
        
	$self->{ID}                 = undef; # required, scalar (1)
	$self->{NAME}               = undef; # required, scalar (1)
	$self->{IS_ANONYMOUS}       = undef; # [1|0], 0 by default
	$self->{ALT_ID}             = CCO::Util::Set->new(); # set (0..N)
	$self->{DEF}                = CCO::Core::Def->new(); # (0..1)
	$self->{NAMESPACE_SET}      = CCO::Util::Set->new(); # set (0..N)
	$self->{COMMENT}            = undef; # scalar (0..1)
	$self->{SUBSET_SET}         = CCO::Util::Set->new(); # set of scalars (0..N)
	$self->{SYNONYM_SET}        = CCO::Util::SynonymSet->new(); # set of synonyms (0..N)
	$self->{XREF_SET}           = CCO::Util::DbxrefSet->new(); # set of dbxref's (0..N)
	#@{$self->{IS_A}}            = (); # (0..N) #delete: the Ontology provides it
	$self->{INTERSECTION_OF}    = CCO::Util::Set->new(); # (0..N)
	$self->{UNION_OF}           = CCO::Util::Set->new(); # (0..N)
	$self->{DISJOINT_FROM}      = CCO::Util::Set->new(); # (0..N)
	#@{$self->{RELATIONSHIP}}    = (); # (0..N) # delete: the Ontology provides it
	$self->{IS_OBSOLETE}        = undef; # [1|0], 0 by default
	$self->{REPLACED_BY}        = CCO::Util::Set->new(); # set of scalars (0..N)
	$self->{CONSIDER}           = CCO::Util::Set->new(); # set of scalars (0..N)
	$self->{BUILTIN}            = undef; # [1|0], 0 by default
        
	bless ($self, $class);
	return $self;
}

=head2 id

  Usage    - print $term->id() or $term->id($id) 
  Returns  - the term ID (string)
  Args     - the term ID (string)
  Function - gets/sets the ID of this term
  
=cut
sub id {
	my ($self, $id) = @_;
	if ($id) { $self->{ID} = $id }
	return $self->{ID};
}

=head2 idspace

  Usage    - print $term->idspace() 
  Returns  - the idspace of this term; otherwise, 'NN'
  Args     - none
  Function - gets the idspace of this term
  
=cut
sub idspace {
	my $self = shift;
	$self->{ID} =~ /([A-Z]+):/ if ($self->{ID});
	return $1 || 'NN';
}

=head2 subnamespace

  Usage    - print $term->subnamespace() 
  Returns  - the subnamespace of this term (character); otherwise, 'X'
  Args     - none
  Function - gets the subnamespace of this term
  
=cut
sub subnamespace {
	my $self = shift;
	$self->{ID} =~ /:([A-Z])/ if ($self->{ID});
	return $1 || 'X';
}

=head2 code

  Usage    - print $term->code() 
  Returns  - the code of this term (character); otherwise, '0000000'
  Args     - none
  Function - gets the code of this term
  
=cut
sub code {
	my $self = shift;
	$self->{ID} =~ /:[A-Z]?(.*)/ if ($self->{ID});	
	return $1 || '0000000';
}


=head2 name

  Usage    - print $term->name() or $term->name($name)
  Returns  - the name (string) of this term
  Args     - the name (string) of this term
  Function - gets/sets the name of this term
  
=cut
sub name {
	my ($self, $name) = @_;
    if ($name) { $self->{NAME} = $name }
    return $self->{NAME};
}

=head2 is_anonymous

  Usage    - print $term->is_anonymous() or $term->is_anonymous("1")
  Returns  - either 1 (true) or 0 (false)
  Args     - either 1 (true) or 0 (false)
  Function - tells whether this term is anonymous or not.
  
=cut
sub is_anonymous {
	my $self = shift;
    if (@_) { $self->{IS_ANONYMOUS} = shift }
    return (defined($self->{IS_ANONYMOUS}) && $self->{IS_ANONYMOUS} == 1)?1:0;
}

=head2 alt_id

  Usage    - $term->alt_id() or $term->alt_id($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the alternate id(s) of this term
  Args     - the alternate id(s) (string) of this term
  Function - gets/sets the alternate id(s) of this term
  
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

  Usage    - $term->def() or $term->def($def)
  Returns  - the definition (CCO::Core::Def) of this term
  Args     - the definition (CCO::Core::Def) of this term
  Function - gets/sets the definition of the term
  
=cut
sub def {
	my ($self, $def) = @_;
    if ($def) {
		$self->{DEF} = $def; 
	}
    return $self->{DEF};
}

=head2 def_as_string

  Usage    - $term->def_as_string() or $term->def_as_string("During meiosis, the synthesis of DNA proceeding from the broken 3' single-strand DNA end that uses the homologous intact duplex as the template.", "[GOC:elh, PMID:9334324]")
  Returns  - the definition (string) of this term
  Args     - the definition (string) of this term plus the dbxref list (string) describing the source of this definition
  Function - gets/sets the definition of this term
  
=cut
sub def_as_string {
	my ($self, $text, $dbxref_as_string) = @_;
	if (defined $text && defined $dbxref_as_string) {
		$dbxref_as_string =~ s/\[//;
		$dbxref_as_string =~ s/\]//;
		my @refs = split(/, /, $dbxref_as_string);
    		
		my $def = $self->{DEF};
		$def->text($text);
		
		my $dbxref_set = CCO::Util::DbxrefSet->new();
		foreach my $ref (@refs) {
			if ($ref =~ /([\w-]+:[\w:\\,\"\+\?\{\}\$\/\(\)\[\]\.-]+)(\s+\"([\w ]+)\")?(\s+(\{[\w ]+=[\w ]+\}))?/) {
				my $dbxref = CCO::Core::Dbxref->new();
				$dbxref->name($1);
				$dbxref->description($3) if (defined $3);
				$dbxref->modifier($5) if (defined $5);
				$dbxref_set->add($dbxref);
			} else {
				confess "There were not defined the references for this term: ", $self->id(), ". Check the 'dbxref' field.";
			}
		}
		$def->dbxref_set($dbxref_set);
		
		$self->{DEF} = $def; 
	}
	my @result = (); # a Set?
	foreach my $dbxref (sort {$a->as_string() cmp $b->as_string()} $self->{DEF}->dbxref_set()->get_set()) {
		push @result, $dbxref->as_string();
	}
	return "\"".$self->{DEF}->text()."\""." [".join(', ', @result)."]";
}

=head2 namespace

  Usage    - $term->namespace() or $term->namespace($ns1, $ns2, $ns3, ...)
  Returns  - an array with the namespace to which this term belongs
  Args     - the namespacet(s) to which this term belongs
  Function - gets/sets the namespace(s) to which this term belongs
  
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

  Usage    - print $term->comment() or $term->comment("This is a comment")
  Returns  - the comment (string) of this term
  Args     - the comment (string) of this term
  Function - gets/sets the comment of this term
  
=cut
sub comment {
	my ($self, $comment) = @_;
    if ($comment) { $self->{COMMENT} = $comment }
    return $self->{COMMENT};
}

=head2 subset

  Usage    - $term->subset() or $term->subset($ss1, $ss2, $ss3, ...)
  Returns  - an array with the subset to which this term belongs
  Args     - the subset(s) to which this term belongs
  Function - gets/sets the subset(s) to which this term belongs
  
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

  Usage    - $term->synonym_set() or $term->synonym_set($synonym1, $synonym2, $synonym3, ...)
  Returns  - an array with the synonym(s) of this term
  Args     - the synonym(s) (CCO::Core::Synonym) of this term
  Function - gets/sets the synonym(s) of this term
  
=cut
sub synonym_set {
	my $self = shift;
	foreach my $synonym (@_) {
		confess "The name of this term (", $self->id(), ") is undefined" if (!defined($self->name()));
		# do not add 'EXACT' synonyms with the same 'name':
		$self->{SYNONYM_SET}->add($synonym) if (!($synonym->type() eq "EXACT" && $synonym->def()->text() eq $self->name()));
   	}
	return $self->{SYNONYM_SET}->get_set();
}

=head2 synonym_as_string

  Usage    - print $term->synonym_as_string() or $term->synonym_as_string("this is a synonym text", "[CCO:ea]", "EXACT")
  Returns  - an array with the synonym(s) of this term
  Args     - the synonym text (string), the dbxrefs (string), synonym scope (string) of this term, and optionally the synonym type name (string)
  Function - gets/sets the synonym(s) of this term
  
=cut
sub synonym_as_string {
	my ($self, $synonym_text, $dbxrefs, $scope, $synonym_type_name) = @_;
	if ($synonym_text && $dbxrefs && $scope) {

		my $synonym = CCO::Core::Synonym->new();
		$synonym->def_as_string($synonym_text, $dbxrefs);
		$synonym->type($scope);
		$synonym->synonym_type_name($synonym_type_name); # optional argument
		$self->synonym_set($synonym);
		return; # set operation
	}
	my @result;
	foreach my $synonym ($self->{SYNONYM_SET}->get_set()) {
		push @result, $synonym->def_as_string();
   	}
	return @result;
}

=head2 xref_set

  Usage    - $term->xref_set() or $term->xref_set($dbxref_set)
  Returns  - a Dbxref set (CCO::Util::DbxrefSet) with the analogous xref(s) of this term in another vocabulary
  Args     - a set of analogous xref(s) (CCO::Util::DbxrefSet) of this term in another vocabulary
  Function - gets/sets the analogous xref(s) set of this term in another vocabulary
  
=cut
sub xref_set {
	my ($self, $xref_set) = @_;
	if ($xref_set) {
    	$self->{XREF_SET} = $xref_set;
    }
    return $self->{XREF_SET};
}

=head2 xref_set_as_string

  Usage    - $term->xref_set_as_string() or $term->xref_set_as_string("[Reactome:20610, EC:2.3.2.12]")
  Returns  - the dbxref set with the analogous xref(s) of this term; [] if the set is empty
  Args     - the dbxref set with the analogous xref(s) of this term
  Function - gets/sets the dbxref set with the analogous xref(s) of this term
  
=cut
sub xref_set_as_string {
	my ($self, $xref_as_string) = @_;
	if ($xref_as_string) {
		$xref_as_string =~ s/^\[//;
		$xref_as_string =~ s/\]$//;
		my @refs = split(/, /, $xref_as_string);
		
		my $xref_set = $self->{XREF_SET};
		foreach my $ref (@refs) {
			if ($ref =~ /([\w-]+:[~\w:\\,\"\+\?\{\}\$\/\(\)\[\]\.-]+)(\s+\"([\w ]+)\")?(\s+(\{[\w ]+=[\w ]+\}))?/) {
				my $xref = CCO::Core::Dbxref->new();
				$xref->name($1);
				$xref->description($3) if (defined $3);
				$xref->modifier($5) if (defined $5);
				$xref_set->add($xref);
			} else {
				confess "There were not defined the references for this term: '", $self->id(), "'. Check the 'dbxref' field.";
			}
		}
		$self->{XREF_SET} = $xref_set; # Is this line necessary?
	}
	my @result = $self->xref_set()->get_set();
}

=head2 intersection_of
        
  Usage    - $term->intersection_of() or $term->intersection_of($t1, $t2, $r1, ...)
  Returns  - an array with the terms/relations which define this term
  Args     - a set (strings) of terms/relations which define this term
  Function - gets/sets the set of terms/relatonships defining this term
        
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
        
  Usage    - $term->union_of() or $term->union_of($t1, $t2, $r1, ...)
  Returns  - an array with the terms/relations which define this term
  Args     - a set (strings) of terms/relations which define this term
  Function - gets/sets the set of terms/relatonships defining this term
        
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

  Usage    - $term->disjoint_from() or $term->disjoint_from($disjoint_term_id1, $disjoint_term_id2, $disjoint_term_id3, ...)
  Returns  - the disjoint term id(s) (string(s)) from this one
  Args     - the term id(s) (string) that is (are) disjoint from this one
  Function - gets/sets the disjoint term(s) from this one
  
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

=head2 is_obsolete

  Usage    - print $term->is_obsolete()
  Returns  - either 1 (true) or 0 (false)
  Args     - either 1 (true) or 0 (false)
  Function - tells whether the term is obsolete or not. 'false' by default.
  
=cut
sub is_obsolete {
	my $self = shift;
    if (@_) { $self->{IS_OBSOLETE} = shift }
    return (defined($self->{IS_OBSOLETE}) && $self->{IS_OBSOLETE} == 1)?1:0;
}

=head2 replaced_by

  Usage    - $term->replaced_by() or $term->replaced_by($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the id(s) of the replacing term(s)
  Args     - the the id(s) of the replacing term(s) (string)
  Function - gets/sets the the id(s) of the replacing term(s)
  
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

  Usage    - $term->consider() or $term->consider($id1, $id2, $id3, ...)
  Returns  - a set (CCO::Util::Set) with the appropiate substitute(s) for an obsolete term
  Args     - the appropiate substitute(s) for an obsolete term (string)
  Function - gets/sets the appropiate substitute(s) for this obsolete term
  
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

  Usage    - print $term->equals($another_term)
  Returns  - either 1 (true) or 0 (false)
  Args     - the term (CCO::Core::Term) to compare with
  Function - tells whether this term is equal to the parameter
  
=cut
sub equals {
	my ($self, $target) = @_;
	return (defined $target && $self->{'ID'} eq $target->{'ID'})?1:0;
}

1;