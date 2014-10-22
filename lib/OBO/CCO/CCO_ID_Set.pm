# $Id: CCO_ID_Set.pm 2010-09-29 Erick Antezana $
#
# Module  : CCO_ID_Set.pm
# Purpose : A set of CCO id's.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#

package OBO::CCO::CCO_ID_Set;


=head1 NAME

OBO::CCO::CCO_ID_Set - An implementation of a set of OBO::CCO::CCO_ID objects.

=head1 SYNOPSIS

use OBO::CCO::CCO_ID_Set;

use OBO::CCO::CCO_ID;


$cco_id_set = OBO::CCO::CCO_ID_Set->new();

$id = OBO::CCO::CCO_ID->new();

$size = $cco_id_set->size();

if ($cco_id_set->add($id)) { ... }

$new_id = $cco_id_set->get_new_id("CCO", "C");

=head1 DESCRIPTION

The OBO::CCO::CCO_ID_Set class implements a Cell-Cycle Ontology identifiers set.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

our @ISA = qw(OBO::XO::OBO_ID_Set);
use OBO::XO::OBO_ID_Set;
use OBO::CCO::CCO_ID;

use strict;
use warnings;
use Carp;

=head2 add_as_string

  Usage    - $set->add_as_string($id)
  Returns  - the added id (OBO::CCO::CCO_ID)
  Args     - the CCO id (string) to be added
  Function - adds an CCO_ID to this set
  
=cut

sub add_as_string () {
	my ($self, $id_as_string) = @_;
	my $result;
	if ($id_as_string) {
		my $new_obo_id_obj = OBO::CCO::CCO_ID->new();
		$new_obo_id_obj->id_as_string($id_as_string);
		$result = $self->add($new_obo_id_obj);
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
	my $new_cco_id = OBO::CCO::CCO_ID->new();
	confess "The idspace is invalid: ", $idspace if ($idspace !~ /[A-Z][A-Z][A-Z]/);
	$new_cco_id->idspace($idspace);
	confess "The subnamespace is invalid: ", $subnamespace if ($subnamespace !~ /[CFPXIORTBGNYZU]/);
	$new_cco_id->subnamespace($subnamespace);
	# get the last 'localID'
	if ($self->is_empty()){
		$new_cco_id->localID("0000001");
	} else {
		my @arr = sort {$a cmp $b} keys %{$self->{MAP}};
		$new_cco_id->localID( $self->{MAP}->{$arr[$#arr]}->localID() );
	}
	while (!defined ($self -> add( $new_cco_id = $new_cco_id->next_id() ))) {}
	return $new_cco_id->id_as_string ();
}

1;