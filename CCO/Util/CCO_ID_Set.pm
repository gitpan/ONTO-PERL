# $Id: CCO_ID_Set.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : CCO_ID_Set.pm
# Purpose : A set of CCO id's.
# License : Copyright (c) 2006, 2007 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#

package CCO::Util::CCO_ID_Set;
our @ISA = qw(CCO::Util::ObjectSet);
use CCO::Util::ObjectSet;
use CCO::Util::CCO_ID;

use strict;
use warnings;
use Carp;
    
=head2 add_as_string

  Usage    - $set->add_as_string($id)
  Returns  - the added id (CCO::Util::CCO_ID)
  Args     - the CCO id (string) to be added
  Function - adds an CCO_ID to this set
  
=cut
sub add_as_string () {
	my ($self, $id_as_string) = @_;
	my $result;
	if ($id_as_string) {
		my $new_cco_id_obj = CCO::Util::CCO_ID->new();
		$new_cco_id_obj->id_as_string($id_as_string);
		$result = $self->add($new_cco_id_obj);
	}
	return $result;
}

=head2 add_all_as_string

  Usage    - $set->add_all_as_string($id1, $id2, ...)
  Returns  - the last added id (CCO::Util::CCO_ID)
  Args     - the id(s) (strings) to be added
  Function - adds a series of CCO_IDs to this set
  
=cut
sub add_all_as_string () {
	my $self = shift;
	my $result;
	foreach (@_) {
		$result = $self->add_as_string ($_);
	}
	return $result;
}

=head2 get_new_id

  Usage    - $set->get_new_id($idspace, $subnamespace)
  Returns  - a new CCO id (string)
  Args     - none
  Function - returns a new CCO ID as string and adds this id to the set
  
=cut
sub get_new_id {
	my ($self, $idspace, $subnamespace) = @_;
	
	my $new_cco_id = CCO::Util::CCO_ID->new();
	confess "The idspace is invalid: ", $idspace if ($idspace !~ /[A-Z][A-Z][A-Z]/);
	$new_cco_id->idspace($idspace);
	confess "The subnamespace is invalid: ", $subnamespace if ($subnamespace !~ /[CFPXIRTBNYZ]/);
	$new_cco_id->subnamespace($subnamespace);
	
	# get the last 'number'
	if ($self->is_empty()){
		$new_cco_id -> number("0000001");
	} else {
		my @arr = sort {$a cmp $b} keys %{$self->{MAP}};
		$new_cco_id->number( $self->{MAP}->{$arr[$#arr]}->number() );
	}
	while (!defined ($self -> add( $new_cco_id = $new_cco_id->next_id() ))) {}
	return $new_cco_id->id_as_string ();
}

1;

=head1 NAME

    CCO::Util::CCO_ID_Set - class implementing a set of CCO::Util::CCO_ID objects.

=head1 SYNOPSIS

use CCO::Util::CCO_ID_Set;

use CCO::Util::CCO_ID;


$cco_id_set = CCO::Util::CCO_ID_Set->new();

$id = CCO::Util::CCO_ID->new();

$size = $cco_id_set->size();

if ($cco_id_set->add($id)) { ... }

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
    
