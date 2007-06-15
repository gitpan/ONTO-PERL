# $Id: Set.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : Set.pm
# Purpose : A Set of scalars implementation.
# License : Copyright (c) 2006, 2007 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
# TODO implement function 'eliminate duplicates', see GoaAssociationSet.t
package CCO::Util::Set;

use strict;
use warnings;
use Carp;

sub new {
	my $class        = shift;
	my $self         = {};
	@{$self->{SET}}  = ();
	
	bless ($self, $class);
	return $self;
}

=head2 add

  Usage    - $set->add($element)
  Returns  - true if the element was successfully added
  Args     - the element to be added
  Function - adds an element to this set
  
=cut
sub add {
	my ($self, $ele) = @_;
	my $result = 0; # nothing added
	if ($ele) {
		if ( !$self -> contains($ele) ) {
			push @{$self->{SET}}, $ele;
			$result = 1; # successfully added
		}
	}
	return $result;
}

=head2 add_all

  Usage    - $set->add_all($ele1, $ele2, $ele3, ...)
  Returns  - true if the elements were successfully added
  Args     - the elements to be added
  Function - adds the given elements to this set
  
=cut
sub add_all {
	my $self = shift;
	my $result = 1; # something added
	foreach (@_) {
		$result *= $self->add ($_);
	}
	return $result;
}

=head2 get_set

  Usage    - $set->get_set()
  Returns  - this set
  Args     - none
  Function - returns this set
  
=cut
sub get_set {
	my $self = shift;
	return (!$self->is_empty())?@{$self->{SET}}:();
}

=head2 contains

  Usage    - $set->contains($ele)
  Returns  - 1 (true) if this set contains the given element
  Args     - the element to be checked
  Function - checks if this set constains the given element
  
=cut
sub contains {
	my ($self, $target) = @_;
	my $result = 0;
	foreach my $ele ( @{$self->{SET}}) {
		if ( $target eq $ele) {
			$result = 1;
			last;
		}
	}
	return $result;
}

=head2 size

  Usage    - $set->size()
  Returns  - the size of this set
  Args     - none
  Function - tells the number of elements held by this set
  
=cut
sub size {
	my $self = shift;
	return $#{$self->{SET}} + 1;
}

=head2 clear

  Usage    - $set->clear()
  Returns  - none
  Args     - none
  Function - clears this list
  
=cut
sub clear {
	my $self = shift;
	@{$self->{SET}} = ();
}

=head2 remove

  Usage    - $set->remove($element_to_be_removed)
  Returns  - 1 (true) if this set contained the given element
  Args     - element to be removed from this set, if present
  Function - removes an element from this set if it is present
  
=cut
sub remove {
	my $self = shift;
	my $element_to_be_removed = shift;
	my $result = $self->contains($element_to_be_removed);
	if ($result) {
		for (my $i = 0; $i <= $#{$self->{SET}}; $i++) {
			if ($element_to_be_removed eq ${$self->{SET}}[$i]) {
				splice(@{$self->{SET}}, $i, 1); # erase the slot
				last;
			}
		}
	}
	return $result;
}

=head2 is_empty

  Usage    - $set->is_empty()
  Returns  - true if this set is empty
  Args     - none
  Function - checks if this set is empty
  
=cut
sub is_empty{
	my $self = shift;
	return ($#{$self->{SET}} == -1);
}

=head2 equals

  Usage    - $set->equals($another_set)
  Returns  - either 1 (true) or 0 (false)
  Args     - the set (Core::Util::Set) to compare with
  Function - tells whether this set is equal to the given one
  
=cut
sub equals {
	my $self = shift;
	my $result = 0; # I guess they'are NOT identical
	if (@_) {
		my $other_set = shift;
		my %count = ();
	
		my @this = map ({scalar $_;} @{$self->{SET}});
		my @that = map ({scalar $_;} $other_set->get_set());
		
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
	}
	return $result;
}

1;

=head1 NAME

    CCO::Util::Set  - a Set implementation
    
=head1 SYNOPSIS

use CCO::Util::Set;

use strict;

my $my_set = CCO::Util::Set->new();

$my_set->add("CCO:P0000001");

print "contains" if ($my_set->contains("CCO:P0000001"));

$my_set->add_all("CCO:P0000002", "CCO:P0000003", "CCO:P0000004");

print "contains" if ($my_set->contains("CCO:P0000002") && $my_set->contains("CCO:P0000003") && $my_set->contains("CCO:P0000004"));

foreach ($my_set->get_set()) {

	print $_, "\n";

}

print "\nContained!\n" if ($my_set->contains("CCO:P0000001"));

my $my_set2 = CCO::Util::Set->new();

$my_set2->add_all("CCO:P0000001", "CCO:P0000002", "CCO:P0000003", "CCO:P0000004");

print "contains" if ($my_set2->contains("CCO:P0000002") && $my_set->contains("CCO:P0000003") && $my_set->contains("CCO:P0000004"));

$my_set->equals($my_set2);

$my_set2->size() == 4;

$my_set2->remove("CCO:P0000003");

print "contains" if ($my_set2->contains("CCO:P0000001") && $my_set->contains("CCO:P0000002") && $my_set->contains("CCO:P0000004"));

$my_set2->size() == 3;

$my_set2->remove("CCO:P0000005");

print "contains" if ($my_set2->contains("CCO:P0000001") && $my_set->contains("CCO:P0000002") && $my_set->contains("CCO:P0000004"));

$my_set2->size() == 3;

$my_set2->clear();

print "not contains" if (!$my_set2->contains("CCO:P0000001") || !$my_set->contains("CCO:P0000002") || !$my_set->contains("CCO:P0000004"));

$my_set2->size() == 0;

$my_set2->is_empty();

=head1 DESCRIPTION

A collection that contains no duplicate elements. More formally, sets contain no 
pair of elements $e1 and $e2 such that $e1->equals($e2). As implied by its name, 
this interface models the mathematical set abstraction.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
