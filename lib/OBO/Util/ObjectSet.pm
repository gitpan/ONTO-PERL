# $Id: ObjectSet.pm 2010-09-29 Erick Antezana $
#
# Module  : ObjectSet.pm
# Purpose : A generic set of ontology objects (terms, relationships, dbxrefs, etc.).
# License : Copyright (c) 2007, 2008, 2009, 2010 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#

package OBO::Util::ObjectSet;

=head1 NAME

OBO::Util::ObjectSet - An implementation of a set of OBO ontology objects.

=head1 SYNOPSIS

use OBO::Util::ObjectSet;

$set = OBO::Util::ObjectSet->new();

$id = OBO::XO::OBO_ID->new();

$size = $set->size();

if ($ok) {
	
	$set->add($term);
	
} else {
	
	$set->add($term);
	
	$set->add($relationship);
	
}

=head1 DESCRIPTION

The OBO::Util::ObjectSet class implements a set of ontology objects such as Terms, Relationships, etc.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008, 2009, 2010 by Erick Antezana

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

sub add {
	my ($self, $new_id) = @_;
	my $result = undef; # nothing added
	my $element_id = $new_id->id();
	if ($element_id && !$self->contains($new_id)) {
		$self->{MAP}->{$element_id} = $new_id;
		$result = $new_id; # successfully added
	} else {
		# don't add repeated elements
	}
	return $result;
}

=head2 add_all

  Usage    - $set->add_all($ele1, $ele2, $ele3, ...)
  Returns  - the last added id (e.g. an object of type OBO::XO::OBO_ID)
  Args     - the elements to be added
  Function - adds the given elements to this set
  
=cut

sub add_all {
	my $self = shift;
	my $result;
	foreach my $ele (@_) {
		$result = $self->add($ele);
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
	return $result;
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
	my $result = 0; # I initially guess they're NOT identical
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