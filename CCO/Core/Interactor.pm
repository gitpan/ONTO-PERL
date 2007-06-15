# $Id: Interactor.pm 1 2006-06-01 16:21:45Z erant $
#
# Module  : Interactor.pm
# Purpose : An interactor.
# License : Copyright (c) 2007 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package CCO::Core::Interactor;

use strict;
use warnings;
use Carp;

sub new {
	my $class = shift;
	my $self = {};
	$self->{ebi_id} = undef; 
	$self->{id} = undef; 
	$self->{ncbiTaxId} = undef;
	$self->{shortLabel} = undef; 
	$self->{fullName} = undef; 
	$self->{uniprot} = undef;
	$self->{uniprot_secondary} = undef;
	$self->{alias} = [];	
	bless ($self, $class);
	return $self;
}

sub ebi_id {
	my $self = shift;
	if (@_) { $self->{ebi_id} = shift }
	return $self->{ebi_id};
}

sub id {
	my $self = shift;
	if (@_) { $self->{id} = shift }
	return $self->{id};
}

sub ncbiTaxId {
	my $self = shift;
	if (@_) { $self->{ncbiTaxId} = shift }
	return $self->{ncbiTaxId};
}

sub shortLabel {
	my $self = shift;
	if (@_) { $self->{shortLabel} = shift }
	return $self->{shortLabel};
}

sub fullName {
	my $self = shift;
	if (@_) { $self->{fullName} = shift }
	return $self->{fullName};
}

sub uniprot {
	my $self = shift;
	if (@_) { $self->{uniprot} = shift }
	return $self->{uniprot};
}

sub uniprot_secondary {
	my $self = shift;
	if (@_) { $self->{uniprot_secondary} = shift }
	return $self->{uniprot_secondary};
}

sub alias {
	my $self = shift;
	if (@_) { $self->{alias} = shift }
	my @alias = @{$self->{alias}};
	return \@alias;
}

1;