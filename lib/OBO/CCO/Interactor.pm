# $Id: Interactor.pm 1844 2008-01-08 12:30:37Z easr $
#
# Module  : Interactor.pm
# Purpose : An interactor.
# License : Copyright (c) 2007, 2008 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package OBO::CCO::Interactor;

=head1 NAME

OBO::CCO::Interactor - An interactor from IntAct
    
=head1 SYNOPSIS

	my $interactor = OBO::CCO::Interactor->new;

=head1 DESCRIPTION

	An object that stores the needed information for an interactor from Intact

=head1 AUTHOR

Mikel Egana Aranguren, mikel.eganaaranguren@cs.man.ac.uk

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, 2008 by Mikel Egana Aranguren

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

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

=head2 ebi_id

  Usage    - print $interactor->ebi_id() or $interactor->ebi_id($ebi_id)
  Returns  - the IntAct id of the interactor (e.g. EBI-464846)
  Args     - the IntAct id of the interactor (e.g. EBI-464846)
  Function - gets/sets the IntAct id of the interactor (e.g. EBI-464846)
  
=cut

sub ebi_id {
	my $self = shift;
	if (@_) { $self->{ebi_id} = shift }
	return $self->{ebi_id};
}

=head2 id

  Usage    - print $interactor->id() or $interactor->id($id)
  Returns  - the id of the interactor within the IntAct XML file (e.g. 498)
  Args     - the id of the interactor within the IntAct XML file (e.g. 498)
  Function - gets/sets the id of the interactor within the IntAct XML file (e.g. 498)
  
=cut

sub id {
	my $self = shift;
	if (@_) { $self->{id} = shift }
	return $self->{id};
}

=head2 ncbiTaxId

  Usage    - print $interactor->ncbiTaxId() or $interactor->ncbiTaxId($ncbiTaxId)
  Returns  - the id of the taxon that the interactor belongs to (e.g. 3702)
  Args     - the id of the taxon that the interactor belongs to (e.g. 3702)
  Function - gets/sets the id of the taxon that the interactor belongs to (e.g. 3702)
  
=cut

sub ncbiTaxId {
	my $self = shift;
	if (@_) { $self->{ncbiTaxId} = shift }
	return $self->{ncbiTaxId};
}

=head2 shortLabel

  Usage    - print $interactor->shortLabel() or $interactor->shortLabel($shortLabel)
  Returns  - the short label of the interactor (e.g. "o59757_schpo")
  Args     - the short label of the interactor (e.g. "o59757_schpo")
  Function - gets/sets the short label of the interactor (e.g. "o59757_schpo")
  
=cut

sub shortLabel {
	my $self = shift;
	if (@_) { $self->{shortLabel} = shift }
	return $self->{shortLabel};
}

=head2 fullName

  Usage    - print $interactor->fullName() or $interactor->fullName($fullName)
  Returns  - the full name of the interactor (e.g. "Spc7 protein")
  Args     - the full nameof the interactor (e.g. "Spc7 protein")
  Function - gets/sets the full name of the interactor (e.g. "Spc7 protein")
  
=cut

sub fullName {
	my $self = shift;
	if (@_) { $self->{fullName} = shift }
	return $self->{fullName};
}

=head2 uniprot

  Usage    - print $interactor->uniprot() or $interactor->uniprot($uniprot)
  Returns  - the uniprot id of the interactor (e.g. "O59757")
  Args     - the uniprot id of the interactor (e.g. "O59757")
  Function - gets/sets the uniprot id of the interactor (e.g. "O59757")
  
=cut

sub uniprot {
	my $self = shift;
	if (@_) { $self->{uniprot} = shift }
	return $self->{uniprot};
}

=head2 uniprot_secondary

  Usage    - print $interactor->uniprot_secondary() or $interactor->uniprot_secondary($uniprot_secondary)
  Returns  - the uniprot secondary id of the interactor (e.g. "o59757_schpo")
  Args     - the uniprot secondary  id of the interactor (e.g. "o59757_schpo")
  Function - gets/sets the uniprot secondary  id of the interactor (e.g. "o59757_schpo")
  
=cut

sub uniprot_secondary {
	my $self = shift;
	if (@_) { $self->{uniprot_secondary} = shift }
	return $self->{uniprot_secondary};
}

=head2 alias

  Usage    - print $interactor->alias() or $interactor->alias($alias)
  Returns  - the alias of the interactor (e.g. "SPCC1020.02")
  Args     - the alias of the interactor (e.g. "SPCC1020.02")
  Function - gets/sets the alias of the interactor (e.g. "SPCC1020.02")
  
=cut

sub alias {
	my $self = shift;
	if (@_) { $self->{alias} = shift }
	my @alias = @{$self->{alias}};
	return \@alias;
}

1;