# $Id: CCO_ID.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : CCO_ID.pm
# Purpose : A CCO_ID.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#

package CCO::Util::CCO_ID;

use strict;
use Carp;
    
sub new {
        my $class = shift;
        my $self  = {};
        $self->{NAMESPACE}    = undef; # namespace
        $self->{SUBNAMESPACE} = undef; # subnamespace
        $self->{NUMBER}       = undef; # 7 digits
        bless ($self, $class);
        return $self;
}

=head2 namespace

  Usage    - print $id->namespace() or $id->namespace($name)
  Returns  - the namespace (string)
  Args     - the namespace (string)
  Function - gets/sets the namespace
  
=cut
sub namespace {
	my $self = shift;
	if (@_) { $self->{NAMESPACE} = shift }
	return $self->{NAMESPACE};
}

=head2 subnamespace

  Usage    - print $id->subnamespace() or $id->subnamespace($name)
  Returns  - the subnamespace (string)
  Args     - the subnamespace (string)
  Function - gets/sets the subnamespace
  
=cut
sub subnamespace {
	my $self = shift;
    if (@_) { $self->{SUBNAMESPACE} = shift }
    return $self->{SUBNAMESPACE};
}

=head2 number

  Usage    - print $id->number() or $id->number($name)
  Returns  - the number (scalar)
  Args     - the number (scalar)
  Function - gets/sets the number
  
=cut
sub number {
	my $self = shift;
    if (@_) { $self->{NUMBER} = shift }
    return $self->{NUMBER};
}

=head2 id_as_string

  Usage    - print $id->id_as_string() or $id->id_as_string("CCO:X0000001")
  Returns  - the id as string (scalar)
  Args     - the id as string
  Function - gets/sets the id as string
  
=cut
sub id_as_string () {
	my $self = shift;
	if (@_) {
		my $id_as_string = shift;
		
		# The SUBNAMESPACE or subnamespace may be one of the following:
		#
		#	C	Cellular component
		#	F	Molecular Function
		#	P	Biological Process
		#	X	Cross reference
		#	I	Instance
		#	R	Reference
		#	T	Taxon
		#	I	Interaction
		#	N	Instance
		#	B	Biopolymer (gene, protein)
		#	U	Upper Level Ontology
		#	L	Relationship type (e.g. is_a)
		
		if ( $id_as_string =~ /([A-Z][A-Z][A-Z]):([CFPXIRTBN])([0-9][0-9][0-9][0-9][0-9][0-9][0-9])/ ) {
			$self->{'NAMESPACE'} = $1;
			$self->{'SUBNAMESPACE'} = $2;
			$self->{'NUMBER'} = substr($3 + 10000000, 1, 7); # trick: forehead zeros
		}
	} else {
		warn "There is no namespace defined for the CCO ID in use!" if (!defined $self->{'NAMESPACE'});
		warn "There is no subnamespace defined for the CCO ID in use!" if (!defined $self->{'SUBNAMESPACE'});
		warn "There is no number defined for the CCO ID in use!" if (!defined $self->{'NUMBER'});
		
		my $id = $self->{'NAMESPACE'}.":".$self->{'SUBNAMESPACE'}.$self->{'NUMBER'};
		return $id;
	}
}

=head2 equals

  Usage    - print $id->equals($id)
  Returns  - 1 (true) or 0 (false)
  Args     - the other ID (CCO_ID)
  Function - tells if the IDs are equal
  
=cut
sub equals () {
	my $self = shift;
	my $target = shift;
	return (($self->{'NAMESPACE'} eq $target->{'NAMESPACE'}) && 
			($self->{'SUBNAMESPACE'} eq $target->{'SUBNAMESPACE'}) &&
			($self->{'NUMBER'} == $target->{'NUMBER'}));
}

=head2 next_id

  Usage    - print $id->next_id($id)
  Returns  - the next ID (CCO_ID)
  Args     - none
  Function - returns the next ID
  
=cut
sub next_id () {
	my $self = shift;
	my $next_id = CCO::Util::CCO_ID->new();
	$next_id->{'NAMESPACE'} = $self->{'NAMESPACE'};
	$next_id->{'SUBNAMESPACE'} = $self->{'SUBNAMESPACE'};
	$next_id->{'NUMBER'} = substr(10000001 + $self->{'NUMBER'}, 1, 7); # trick: forehead zeros
	return $next_id;
}

=head2 previous_id

  Usage    - print $id->previous_id($id)
  Returns  - the previous ID (CCO_ID)
  Args     - none
  Function - returns the previous ID
  
=cut
sub previous_id () {
	my $self = shift;
	my $previous_id = CCO::Util::CCO_ID->new ();
	$previous_id->{'NAMESPACE'} = $self->{'NAMESPACE'};
	$previous_id->{'SUBNAMESPACE'} = $self->{'SUBNAMESPACE'};
	$previous_id->{'NUMBER'} = substr((10000000 + $self->{'NUMBER'}) - 1, 1, 7); # trick: forehead zeros
	return $previous_id;
}

1;

=head1 NAME

    CCO::Util::CCO_ID - module for describing Cell Cycle Ontology (CCO) 
    identifiers. Its namespace, subnamespace and number are stored.

=head1 SYNOPSIS

use CCO::Util::CCO_ID;

$id = CCO_ID->new();

$id->namespace("CCO");
$id->subnamespace("X");
$id->number("0000001");

$namespace = $id->namespace();
$subnamespace = $id->subnamespace();
$number = $id->number();

print $id->id_as_string();
$id->id_as_string("CCO:P1234567");

=head1 DESCRIPTION

The CCO::Util::CCO_ID class implements a Cell-Cycle Ontology identifier.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    