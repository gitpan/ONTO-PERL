# $Id: Interaction.pm 2094 2010-09-29 erick.antezana $
#
# Module  : Interaction.pm
# Purpose : An interaction.
# License : Copyright (c) 2007, 2008 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package OBO::CCO::Interaction;

=head1 NAME

OBO::CCO::Interaction - An interaction from IntAct
    
=head1 SYNOPSIS

	my $interaction = OBO::CCO::Interaction->new;

=head1 DESCRIPTION

	An object that stores the needed information for an interaction from Intact

=head1 AUTHOR

Mikel Egana Aranguren, mikel.eganaaranguren@cs.man.ac.uk

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Mikel Egana Aranguren

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
	$self->{primaryRef} = undef;
	$self->{interactionType} = undef; 
	$self->{shortLabel} = undef; 
	$self->{fullName} = undef; 
# 	$self->{goodInteractorID} = undef;
	$self->{interactorRef} = []; # interactor ids
	$self->{interactorRefRoles} = (); # interactorRef-Role, interactorRef-Role,
# 	$self->{interactors} = []; # interactor objects	
	bless ($self, $class);
	return $self;
}

=head2 primaryRef

  Usage    - print $interaction->primaryRef() or $interaction->primaryRef($primaryRef)
  Returns  - the IntAct id of the interaction (e.g. EBI-464846)
  Args     - the IntAct id of the interaction (e.g. EBI-464846)
  Function - gets/sets the IntAct id of the interaction (e.g. EBI-464846)
  
=cut

sub primaryRef {
	my $self = shift;
	if (@_) { $self->{primaryRef} = shift }
	return $self->{primaryRef};
}

=head2 interactionType

  Usage    - print $interaction->interactionType() or $interaction->interactionType($interactionType)
  Returns  - the type of the interaction (e.g. "physical association")
  Args     - the type of the interaction (e.g. "physical association")
  Function - gets/sets the type of the interaction (e.g. "physical association")
  
=cut

sub interactionType {
	my $self = shift;
	if (@_) { $self->{interactionType} = shift }
	return $self->{interactionType};
}

=head2 shortLabel

  Usage    - print $interaction->shortLabel() or $interaction->shortLabel($shortLabel)
  Returns  - the short label of the interaction (e.g. "q9p7r6-rse1")
  Args     - the short label of the interaction (e.g. "q9p7r6-rse1")
  Function - gets/sets the short label of the interaction (e.g. "q9p7r6-rse1")
  
=cut

sub shortLabel {
	my $self = shift;
	if (@_) { $self->{shortLabel} = shift }
	return $self->{shortLabel};
}

=head2 fullName

  Usage    - print $interaction->fullName() or $interaction->fullName($fullName)
  Returns  - the full name of the interaction (e.g. "Proteomic analysis identifies a new complex required for nuclear pre-mRNA retention and splicing")
  Args     - the full name of the interaction (e.g. "Proteomic analysis identifies a new complex required for nuclear pre-mRNA retention and splicing")
  Function - gets/sets the full name of the interaction (e.g. "Proteomic analysis identifies a new complex required for nuclear pre-mRNA retention and splicing")
  
=cut

sub fullName {
	my $self = shift;
	if (@_) { $self->{fullName} = shift }
	return $self->{fullName};
}

# sub goodInteractorID {
# 	my $self = shift;
# 	if (@_) { $self->{goodInteractorID} = shift }
# 	return $self->{goodInteractorID};
# }

=head2 interactorRef

  Usage    - $interaction->interactorRef() or $interaction->interactorRef(@interactorRef)
  Returns  - the array of interactor ids that participate in this interaction
  Args     - the array of interactor ids that participate in this interaction
  Function - gets/sets the array of interactor ids that participate in this interaction
  
=cut

sub interactorRef {
	my $self = shift;
	if (@_) { $self->{interactorRef} = shift }
	my @interactorRef = @{$self->{interactorRef}};
	return \@interactorRef;
}

=head2 interactorRefRoles

  Usage    - $interaction->interactorRefRoles() or $interaction->interactorRefRoles(%interactorRefRoles)
  Returns  - the hash of interactor ids and their roles
  Args     - the hash of interactor ids and their roles
  Function - gets/sets the hash of interactor ids and their roles
  
=cut

sub interactorRefRoles {
	my $self = shift;
	if (@_) { $self->{interactorRefRoles} = shift }
	my %interactorRefRoles = %{$self->{interactorRefRoles}};
	return \%interactorRefRoles;
}

# sub interactors {
# 	my $self = shift;
# 	if (@_) { $self->{interactors} = shift }
# 	my @interactors = @{$self->{interactors}};
# 	return \@interactors;
# }

1;