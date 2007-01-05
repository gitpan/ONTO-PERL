# $Id: Set.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : Set.pm
# Purpose : A Set of scalars implementation.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
# TODO implement function 'eliminate duplicates', see GoaAssociationSet.t
# TODO implement function 'remove'
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

sub DESTROY {
	
}

=head2 add

  Usage    - $set->add()
  Returns  - true if the element was successfully added
  Args     - the element to be added
  Function - adds an element to this set
  
=cut
sub add {
	my $self = shift;
	my $result = 0; # nothing added
	if (@_) {
		my $ele = shift;
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
  Args     - 
  Function - returns this set
  
=cut
sub get_set {
	my $self = shift;
	return (!$self->is_empty())?@{$self->{SET}}:();
}

=head2 contains

  Usage    - $set->contains()
  Returns  - 1 (true) if this set contains the given element
  Args     - the element to be checked
  Function - checks if this set constains the given element
  
=cut
sub contains {
	my $self = shift;
	my $result = 0;
	my $target = shift;
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
  Args     - 
  Function - tells the number of elements held by this set
  
=cut
sub size {
	my $self = shift;
    return $#{$self->{SET}} + 1;
}

=head2 clear

  Usage    - $set->clear()
  Returns  - 
  Args     - 
  Function - clears this list
  
=cut
sub clear {
	my $self = shift;
	@{$self->{SET}} = ();
}

=head2 is_empty

  Usage    - $set->is_empty()
  Returns  - true if this set is empty
  Args     - 
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
		croak "The element to be tested must be a CCO::Util::Set object" if (!UNIVERSAL::isa($other_set, 'CCO::Util::Set'));
		
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
    Util::Set  - a Set implementation
=head1 SYNOPSIS

use Set;

#################
# class methods #
#################
$my_set = Set->new;

#######################
# object data methods #
#######################

### set versions ###
$my_set->add("CCO:P0000001");
$my_set->add_all("CCO:P0000002", "CCO:P0000003", "CCO:P0000004");

### get versions ###
foreach ($my_set->get_set()) {
	print $_, "\n";
}

########################
# other object methods #
########################

print "\nContained!\n" if ($my_set->contains("CCO:P0000001"));

$my_set2 = Set->new;
$my_set2->add_all("CCO:P0000001", "CCO:P0000002", "CCO:P0000003", "CCO:P0000004");
print $my_set->equals($my_set2);

=head1 DESCRIPTION
A set.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut