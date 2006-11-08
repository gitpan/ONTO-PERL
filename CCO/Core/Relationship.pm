# $Id: Relationship.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : Relationship.pm
# Purpose : Relationship in the Ontology.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Core::Relationship;
use strict;
use warnings;
use Carp;

sub new {
        my $class                   = shift;
        my $self                    = {};
        
        $self->{ID}                 = undef; # required, string (1)
        $self->{TYPE}               = undef; # required, string (1) # todo usar RelationshipType?
        
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

  Usage    - print $relationship->type()
  Returns  - the type of the relationship
  Args     - the type of the relationship
  Function - gets/sets the type of the relationship
  
=cut
sub type {
	my $self = shift;
    if (@_) { $self->{TYPE} = shift }
    return $self->{TYPE};
}

=head2 equals

  Usage    - print $relationship->equals($another_relationship)
  Returns  - either 1 (true) or 0 (false)
  Args     - the relationship (CCO::Core::Relationship) to compare with
  Function - tells whether this relationship is equal to the parameter
  
=cut
sub equals  {
	my $self = shift;
	my $result = 0;
	if (@_) {
     	my $target = shift;
		croak "The term to be compared with must be a CCO::Core::Relationship object" if (!UNIVERSAL::isa($target, "CCO::Core::Relationship"));
		my $self_id = $self->{'ID'};
		my $target_id = $target->{'ID'};
		croak "The ID of this relationship is not defined" if (!defined($self_id));
		croak "The ID of the target relationship is not defined" if (!defined($target_id));
		$result = ($self_id eq $target_id);
	}
	return $result;
}

=head2 head

  Usage    - $relationship->head($object)
  Returns  - the CCO::Core::Term (object or target) targeted by this relationship
  Args     - the target term (CCO::Core::Term)
  Function - gets/sets the term attached to the head of the relationship
  
=cut
sub head {
	my $self = shift;
	if (@_) {
		my $term = shift;
		croak "The term to be bound as head to this relationship must be a CCO::Core::Term object" if (!UNIVERSAL::isa($term, "CCO::Core::Term"));
     	$self->{HEAD} = $term;
	}
    return $self->{HEAD};
}

=head2 tail

  Usage    - $relationship->tail($subject)
  Returns  - the CCO::Core::Term (subject or source) sourced by this relationship
  Args     - the source term (CCO::Core::Term)
  Function - gets/sets the term attached to the tail of the relationship
  
=cut
sub tail {
	my $self = shift;
	if (@_) {
		my $term = shift;
		croak "The term to be bound as tail to this relationship must be a CCO::Core::Term object" if (!UNIVERSAL::isa($term, "CCO::Core::Term"));
		$self->{TAIL} = $term;
	}
    return $self->{TAIL};
}

=head2 link

  Usage    - $relationship->link()
  Returns  - the Terms (subject and source) connected by this relationship
  Args     - the source(tail) and target(head) term
  Function - gets/sets the terms attached to this relationship
  
=cut
sub link {
	my $self = shift;
	if (@_) {
		my $tail = shift;
		croak "The term to be bound as tail to this relationship must be a CCO::Core::Term object" if (!UNIVERSAL::isa($tail, "CCO::Core::Term"));
		my $head = shift;
		croak "The term to be bound as head to this relationship must be a CCO::Core::Term object" if (!UNIVERSAL::isa($head, "CCO::Core::Term"));
		$self->{TAIL} = $tail;
		$self->{HEAD} = $head;
    }
    return ($self->{TAIL}, $self->{HEAD});
}

1;

=head1 NAME
    Core::Relationship  - a relationship in an ontology
=head1 SYNOPSIS

use CCO::Core::Relationship;
use CCO::Core::Term;
use strict;

# three new relationships
my $r1 = CCO::Core::Relationship->new;
my $r2 = CCO::Core::Relationship->new;
my $r3 = CCO::Core::Relationship->new;

$r1->id("CCO:P0000001_is_a_CCO:P0000002");
$r2->id("CCO:P0000002_part_of_CCO:P0000003");
$r3->id("CCO:P0000001_has_child_CCO:P0000003");

$r1->type("is_a");
$r2->type("part_of");
$r3->type("has_child");

# three new terms
my $n1 = CCO::Core::Term->new;
my $n2 = CCO::Core::Term->new;
my $n3 = CCO::Core::Term->new;

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
my $r4 = CCO::Core::Relationship->new;
my $r5 = CCO::Core::Relationship->new;
my $r6 = CCO::Core::Relationship->new;

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
A Relationship in the ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut