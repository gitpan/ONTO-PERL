# $Id: CCO_ID_Set.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : CCO_ID_Set.pm
# Purpose : A set of CCO id's.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#

package CCO::Util::CCO_ID_Set;

use strict;
use Carp;

use CCO::Util::CCO_ID;
    
sub new {
	my $class       = shift;
	my $self        = {};
    @{$self->{SET}}	= ();
	
	bless ($self, $class);
	return $self;
}

=head2 get_set

  Usage    - $set->get_set()
  Returns  - this set (CCO::Util::CCO_ID_Set) of CCO IDs
  Args     - none
  Function - returns this set
  
=cut
sub get_set () {
	my $self = shift;
	return @{$self->{SET}};
}

=head2 add

  Usage    - $set->add($cco_id)
  Returns  - the added id (CCO::Util::CCO_ID)
  Args     - the CCO id (CCO::Util::CCO_ID) to be added
  Function - adds a CCO ID to this set
  
=cut
sub add () {
	my $self = shift;
	my $result; # nothing added
	if (@_) {
		my $new_id = shift;
		croak "The element to be added must be a CCO::Util::CCO_ID object" if (!UNIVERSAL::isa($new_id, "CCO::Util::CCO_ID"));
		if ( !$self -> contains($new_id) ) {
			push @{$self->{SET}}, $new_id;
			$result = $new_id; # successfully added
		}
	}
	return $result;
}
=head2 add_all

  Usage    - $set->add_all($id1, $id2, ...)
  Returns  - the last added id (CCO::Util::CCO_ID)
  Args     - the id(s) (CCO::Util::CCO_ID) to be added
  Function - adds a series of CCO_IDs to this set
  
=cut
sub add_all () {
	my $self = shift;
	my $result; # nothing added
	foreach (@_) {
		$result = $self->add ($_);
	}
	return $result;
}

=head2 add_as_string

  Usage    - $set->add_as_string($id)
  Returns  - the added id (CCO::Util::CCO_ID)
  Args     - the CCO id (string) to be added
  Function - adds an CCO_ID to this set
  
=cut
sub add_as_string () {
	my $self = shift;
	my $result; # nothing added
	if (@_) {
		my $new_cco_id_obj = CCO::Util::CCO_ID -> new ();
		$new_cco_id_obj -> id_as_string (shift);
		return $self -> add ($new_cco_id_obj);
	} else {
		return $result;
	}
}

=head2 add_all_as_string

  Usage    - $set->add_all_as_string($id1, $id2, ...)
  Returns  - the last added id (CCO::Util::CCO_ID)
  Args     - the id(s) (strings) to be added
  Function - adds a series of CCO_IDs to this set
  
=cut
sub add_all_as_string () {
	my $self = shift;
	my $result; # nothing added
	foreach (@_) {
		$result = $self->add_as_string ($_);
	}
	return $result;
}

=head2 get_new_id

  Usage    - $set->get_new_id($id)
  Returns  - a new CCO id (string)
  Args     - none
  Function - returns a new CCO ID as string
  
=cut
sub get_new_id {
	my $self = shift;
	
	my $new_cco_id = CCO::Util::CCO_ID->new();
	my $namespace = shift;
	croak "The namespace is invalid: ", $namespace if ($namespace !~ /[A-Z][A-Z][A-Z]/);
	$new_cco_id->namespace($namespace);
	my $subnamespace = shift;
	croak "The subnamespace is invalid: ", $subnamespace if ($subnamespace !~ /[CFPXIRTBN]/);
	$new_cco_id->subnamespace($subnamespace);
	
	# get the last 'number'
	if ($self->is_empty()){
		$new_cco_id -> number("0000001");
	} else {
		$new_cco_id -> number( ${$self->{SET}}[ $#{$self->{SET}} ] -> number);
	}
	
	while (!defined ($self -> add($new_cco_id = $new_cco_id -> next_id ()))) {}
	return $new_cco_id -> id_as_string ();
}

=head2 contains

  Usage    - $set->contains($id)
  Returns  - 1 (true) or 0 (false)
  Args     - the ID (CCO::Util::CCO_ID) to look up
  Function - tells if the given ID is in this set
  
=cut
sub contains {
	my $self = shift;
	my $result = 0;
	if (@_) {
		my $target = shift;
		foreach my $ele (@{$self->{SET}}){
			if ( $target-> equals($ele) ) {
				$result = 1;
				last;
			}
		} 
	}
	return $result;
}

=head2 size

  Usage    - $set->size()
  Returns  - the size of this set
  Args     - none
  Function - the size of this set
  
=cut
sub size {
	my $self = shift;
    return $#{$self->{SET}} + 1;
}

=head2 clear

  Usage    - $set->clear()
  Returns  - clears this set
  Args     - none
  Function - clears this set
  
=cut
sub clear {
	my $self = shift;
	@{$self->{SET}} = ();
}

=head2 is_empty

  Usage    - $set->is_empty()
  Returns  - 1 (true) or 0 (false)
  Args     - none
  Function - tells if this set is empty
  
=cut
sub is_empty{
	my $self = shift;
	return ($#{$self->{SET}} == -1);
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

	my @this = map ({$_->id_as_string();} @{$self->{SET}});
	my @that = map ({$_->id_as_string();} $other_set->get_set());
	
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

=head1 NAME

    CCO::Util::CCO_ID_Set - class implementing a set of CCO::Util::CCO_ID objects.

=head1 SYNOPSIS

use CCO::Util::CCO_ID_Set;

$cco_id_set  = CCO::Util::CCO_ID_Set -> new ();

$size = $cco_id_set -> size;

if ($cco_id_set->add("CCO:C1234567")) { ... }
$new_id = $cco_id_set->get_new_id("CCO", "C");

=head1 DESCRIPTION

The CCO::Util::CCO_ID_Set class implements a Cell-Cycle Ontology identifiers set.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    