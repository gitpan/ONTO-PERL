# $Id: Interaction.pm 1 2006-06-01 16:21:45Z erant $
#
# Module  : Interaction.pm
# Purpose : An interaction.
# License : Copyright (c) 2007 Cell Cycle Ontology. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : CCO <ccofriends@psb.ugent.be>
#
package CCO::Core::Interaction;

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

sub primaryRef {
	my $self = shift;
	if (@_) { $self->{primaryRef} = shift }
	return $self->{primaryRef};
}

sub interactionType {
	my $self = shift;
	if (@_) { $self->{interactionType} = shift }
	return $self->{interactionType};
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

# sub goodInteractorID {
# 	my $self = shift;
# 	if (@_) { $self->{goodInteractorID} = shift }
# 	return $self->{goodInteractorID};
# }

sub interactorRef {
	my $self = shift;
	if (@_) { $self->{interactorRef} = shift }
	my @interactorRef = @{$self->{interactorRef}};
	return \@interactorRef;
}


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