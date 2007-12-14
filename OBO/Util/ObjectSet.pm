# $Id: ObjectSet.pm 1387 2007-08-06 16:51:02Z erant $
#
# Module  : ObjectSet.pm
# Purpose : A generic set of ontology objects (terms, relationships, dbwrefs, etc).
# License : Copyright (c) 2007 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#

package OBO::Util::ObjectSet;

=head1 NAME

OBO::Util::ObjectSet - An implementation of a set of ontology objects

=head1 SYNOPSIS

use OBO::Util::ObjectSet;

$cco_id_set = OBO::Util::ObjectSet->new();

$id = OBO::CCO::CCO_ID->new();

$size = $cco_id_set->size();

if ($cco_id_set->add($id)) { ... }

=head1 DESCRIPTION

The OBO::Util::ObjectSet class implements a set of ontology objects such as Terms, Relationships, etc.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

our @ISA = qw(OBO::Util::ObjectIdSet);
use OBO::Util::ObjectIdSet;

use strict;
use warnings;
use Carp;
    
=head2 add

  Usage    - $set->add($element)
  Returns  - the added element
  Args     - the element to be added. It must have an ID
  Function - adds an element to this set
  
=cut

sub add () {
	my ($self, $new_id) = @_;
	my $result; # nothing added
	my $element_id = $new_id->id();
	if ($element_id && !$self->contains($new_id)) {
		$self->{MAP}->{$element_id} = $new_id;
		$result = $new_id; # successfully added
	}
	return $result;
}

=head2 add_all

  Usage    - $set->add_all($ele1, $ele2, $ele3, ...)
  Returns  - the last added id (OBO::CCO::CCO_ID)
  Args     - the elements to be added
  Function - adds the given elements to this set
  
=cut

sub add_all {
        my $self = shift;
        my $result;
        foreach (@_) {
                $result = $self->add($_);
        }
        return $result;
}

=head2 remove

  Usage    - $set->remove($element_to_be_removed)
  Returns  - 1 (true) if this set contained the given element
  Args     - element (it must have an ID) to be removed from this set, if present
  Function - removes an element from this set if it is present
  
=cut

sub remove {
	my ($self, $element_to_be_removed) = @_;
	my $result = $self->contains($element_to_be_removed);
	delete $self->{MAP}->{$element_to_be_removed->id()} if ($result);
	return $self->contains($element_to_be_removed);
}

=head2 contains

  Usage    - $set->contains($id)
  Returns  - 1 (true) or 0 (false)
  Args     - the element (it must have an ID) to look up
  Function - tells if the given ID is in this set
  
=cut

sub contains {
	my ($self, $target) = @_;
	my $id = $target->id();
	return (defined $id && defined $self->{MAP}->{$id})?1:0;
}

=head2 equals

  Usage    - $set->equals($other_set)
  Returns  - 1 (true) or 0 (false)
  Args     - the other set to check with
  Function - tells if this set is equal to the given one
  
=cut

sub equals {
	my $self = shift;
	my $result = 0; # I guess they'are NOT identical
	my $other_set = shift;
	my %count = ();

	my @this = map ({$_->id();} values (%{$self->{MAP}}));
	my @that = map ({$_->id();} $other_set->get_set());
	
	if ($#this == $#that) {
		foreach (@this, @that) {
			$count{$_}++;
		}
		foreach my $count (values %count) {
			if ($count != 2) {
				$result = 0;
				last;
			} else {
				$result = 1;
			}
		}
	}
	return $result;
}

1;