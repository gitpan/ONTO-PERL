# $Id: Relationship.pm 1845 2010-09-29 Erick Antezana $
#
# Module  : Relationship.pm
# Purpose : Relationship in the Ontology.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::Core::Relationship;

=head1 NAME

OBO::Core::Relationship  - A relationship between two terms or two relationships within an ontology.

=head1 SYNOPSIS

use OBO::Core::Relationship;
use OBO::Core::Term;
use strict;

# three new relationships
my $r1 = OBO::Core::Relationship->new();
my $r2 = OBO::Core::Relationship->new();
my $r3 = OBO::Core::Relationship->new();

$r1->id("CCO:P0000001_is_a_CCO:P0000002");
$r2->id("CCO:P0000002_part_of_CCO:P0000003");
$r3->id("CCO:P0000001_has_child_CCO:P0000003");

$r1->type("is_a");
$r2->type("part_of");
$r3->type("has_child");

!$r1->equals($r2);
!$r2->equals($r3);
!$r3->equals($r1);

# three new terms
my $n1 = OBO::Core::Term->new();
my $n2 = OBO::Core::Term->new();
my $n3 = OBO::Core::Term->new();

$n1->id("CCO:P0000001");
$n2->id("CCO:P0000002");
$n3->id("CCO:P0000003");

$n1->name("One");
$n2->name("Two");
$n3->name("Three");

# r1(n1, n2)
$r1->head($n2);
$r1->tail($n1);

# r2(n2, n3)
$r2->head($n3);
$r2->tail($n2);

# r3(n1, n3)
$r3->head($n3);
$r3->tail($n1);

# three new relationships
my $r4 = OBO::Core::Relationship->new();
my $r5 = OBO::Core::Relationship->new();
my $r6 = OBO::Core::Relationship->new();

$r4->id("CCO:R0000004");
$r5->id("CCO:R0000005");
$r6->id("CCO:R0000006");

$r4->type("r4");
$r5->type("r5");
$r6->type("r6");

$r4->link($n1, $n2);
$r5->link($n2, $n3);
$r6->link($n1, $n3);

=head1 DESCRIPTION

A Relationship between two terms (OBO::Core::Term) in the ontology (OBO::Core::Ontology).

A relationships must have a unique ID (e.g. "CCO:P0000028_is_a_CCO:P0000005"), 
a type (e.g. "is_a") and it must known the linking terms (tail and head).

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use strict;
use warnings;
use Carp;

sub new {
        my $class                   = shift;
        my $self                    = {};
        
        $self->{ID}                 = undef; # required, string (1)
        $self->{TYPE}               = undef; # required, string (1)
        
        $self->{HEAD}               = undef; # required, string (1)
        $self->{TAIL}               = undef; # required, string (1)
        
        bless ($self, $class);
        return $self;
}

=head2 id

  Usage    - print $relationship->id() or $relationship->id($id)
  Returns  - the relationship ID (string)
  Args     - the relationship ID (string)
  Function - gets/sets an ID
  
=cut

sub id {
	my $self = shift;
	if (@_) { $self->{ID} = shift }
	return $self->{ID};
}

=head2 type

  Usage    - $relationship->type("is_a") or print $relationship->type()
  Returns  - the type of the relationship (string)
  Args     - the type of the relationship (string)
  Function - gets/sets the type of the relationship
  
=cut

sub type {
	my $self = shift;
	if (@_) {
		$self->{TYPE} = shift;
    }
    return $self->{TYPE};
}

=head2 equals

  Usage    - print $relationship->equals($another_relationship)
  Returns  - either 1 (true) or 0 (false)
  Args     - the relationship (OBO::Core::Relationship) to compare with
  Function - tells whether this relationship is equal to the parameter
  
=cut

sub equals  {
	my $self = shift;
	my $result = 0;
	if (@_) {
     	my $target = shift;
		my $self_id = $self->{'ID'};
		my $target_id = $target->{'ID'};
		confess "The ID of this relationship is not defined" if (!defined($self_id));
		confess "The ID of the target relationship is not defined" if (!defined($target_id));
		$result = ($self_id eq $target_id);
	}
	return $result;
}

=head2 head

  Usage    - $relationship->head($object) or $relationship->head()
  Returns  - the OBO::Core::Term (object or target) or OBO::Core::RelationshipType (object or target) targeted by this relationship
  Args     - the target term (OBO::Core::Term) or the target relationship type (OBO::Core::RelationshipType)
  Function - gets/sets the term/relationship type attached to the head of the relationship
  
=cut

sub head {
	my $self = shift;
	if (@_) {
		my $object = shift;
		$self->{HEAD} = $object;
	}
    return $self->{HEAD};
}

=head2 tail

  Usage    - $relationship->tail($subject) or $relationship->tail()
  Returns  - the OBO::Core::Term (subject or source) or OBO::Core::RelationshipType (object or target) sourced by this relationship
  Args     - the source term (OBO::Core::Term) or the source relationship type (OBO::Core::RelationshipType)
  Function - gets/sets the term/relationship type attached to the tail of the relationship
  
=cut

sub tail {
	my $self = shift;
	if (@_) {
		my $subject = shift;
		$self->{TAIL} = $subject;
	}
    return $self->{TAIL};
}

=head2 link

  Usage    - $relationship->link($tail, $head) or $relationship->link()
  Returns  - the two Terms or two RelationshipTypes (subject and source) connected by this relationship
  Args     - the source(tail, OBO::Core::Term/OBO::Core::RelationshipType) and target(head, OBO::Core::Term/OBO::Core::RelationshipType) term/relationship type
  Function - gets/sets the terms/relationship type attached to this relationship
  
=cut

sub link {
	my $self = shift;
	if (@_) {
		my $tail = shift;
		my $head = shift;
		$self->{TAIL} = $tail;
		$self->{HEAD} = $head;
    }
    return ($self->{TAIL}, $self->{HEAD});
}

1;