# $Id: CCO_ID.pm 1844 2010-09-23 12:30:37Z easr $
#
# Module  : CCO_ID.pm
# Purpose : A CCO_ID.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#

package OBO::CCO::CCO_ID;


=head1 NAME

OBO::CCO::CCO_ID - A module for describing Cell Cycle Ontology (CCO) identifiers. Its idspace, subnamespace and number are stored.

=head1 SYNOPSIS

use OBO::CCO::CCO_ID;

$id = CCO_ID->new();

$id->idspace("CCO");

$id->subnamespace("X");

$id->number("0000001");

$idspace = $id->idspace();

$subnamespace = $id->subnamespace();

$number = $id->number();

print $id->id_as_string();

$id->id_as_string("CCO:P1234567");

=head1 DESCRIPTION

The OBO::CCO::CCO_ID class implements a Cell Cycle Ontology identifier.

A CCO ID holds: IDSPACE, SUBNAMESPACE and a NUMBER in the following form:

	CCO:[A-Z]nnnnnnn

For instance: CCO:P1234567

The SUBNAMESPACE may be one of the following:
 
	C	Cellular component
	F	Molecular Function
	P	Biological Process
	B	Protein
	G	Gene
	I	Interaction
	R	Reference
	T	Taxon
	N	Instance
	U	Upper Level Ontology (CCO)
	L	Relationship type (e.g. is_a)
	Y	Interaction type
	Z	Unknown

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

our @ISA = qw(OBO::XO::OBO_ID);
use OBO::XO::OBO_ID;
use strict;
use Carp;
    
sub new {
	my $class = shift;
	my $self  = {};

	$self->{IDSPACE}      = undef; # string
	$self->{SUBNAMESPACE} = undef; # subnamespace
	$self->{NUMBER}       = undef; # 7 digits

	bless ($self, $class);
	return $self;
}

=head2 subnamespace

  Usage    - print $id->subnamespace() or $id->subnamespace($name)
  Returns  - the subnamespace (string)
  Args     - the subnamespace (string)
  Function - gets/sets the subnamespace
  
=cut

sub subnamespace {
	my ($self, $sns) = @_;
	if ($sns) { $self->{SUBNAMESPACE} = $sns }
	return $self->{SUBNAMESPACE};
}

=head2 id_as_string

  Usage    - print $id->id_as_string() or $id->id_as_string("CCO:X0000001")
  Returns  - the id as string (scalar)
  Args     - the id as string
  Function - gets/sets the id as string
  
=cut

sub id_as_string () {
	my ($self, $id_as_string) = @_;
	if ( defined $id_as_string && $id_as_string =~ /([A-Z][A-Z][A-Z]):([CFPXIRTBGNYZ])([0-9]{7})/ ) {
		$self->{IDSPACE} = $1;
		$self->{SUBNAMESPACE} = $2;
		$self->{NUMBER} = substr($3 + 10000000, 1, 7); # trick: forehead zeros
	} elsif ($self->{IDSPACE} && $self->{SUBNAMESPACE} && $self->{NUMBER}) {
		return $self->{IDSPACE}.":".$self->{SUBNAMESPACE}.$self->{NUMBER};
	}
}
*id = \&id_as_string;

=head2 equals

  Usage    - print $id->equals($id)
  Returns  - 1 (true) or 0 (false)
  Args     - the other ID (OBO::CCO::CCO_ID)
  Function - tells if two IDs are equal
  
=cut

sub equals () {
	my ($self, $target) = @_;
	return (($self->{IDSPACE} eq $target->{IDSPACE}) && 
			($self->{SUBNAMESPACE} eq $target->{SUBNAMESPACE}) &&
			($self->{NUMBER} == $target->{NUMBER}));
}

=head2 next_id

  Usage    - $id->next_id()
  Returns  - the next ID (OBO::CCO::CCO_ID)
  Args     - none
  Function - returns the next ID, which is new
  
=cut

sub next_id () {
	my $self = shift;
	my $next_id = OBO::CCO::CCO_ID->new();
	$next_id->{IDSPACE} = $self->{IDSPACE};
	$next_id->{SUBNAMESPACE} = $self->{SUBNAMESPACE};
	$next_id->{NUMBER} = substr(10000001 + $self->{NUMBER}, 1, 7); # trick: forehead zeros
	return $next_id;
}

=head2 previous_id

  Usage    - $id->previous_id()
  Returns  - the previous ID (OBO::CCO::CCO_ID)
  Args     - none
  Function - returns the previous ID, which is new
  
=cut

sub previous_id () {
	my $self = shift;
	my $previous_id = OBO::CCO::CCO_ID->new ();
	$previous_id->{IDSPACE} = $self->{IDSPACE};
	$previous_id->{SUBNAMESPACE} = $self->{SUBNAMESPACE};
	$previous_id->{NUMBER} = substr((10000000 + $self->{NUMBER}) - 1, 1, 7); # trick: forehead zeros
	return $previous_id;
}

1;