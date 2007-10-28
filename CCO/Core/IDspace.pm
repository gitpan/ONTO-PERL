# $Id: IDspace.pm 1375 2007-08-06 15:56:17Z erant $
#
# Module  : IDspace.pm
# Purpose : A mapping between a "local" ID space and a "global" ID space.
# License : Copyright (c) 2007 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Core::IDspace;

=head1 NAME

CCO::Core::IDspace - A mapping between a "local" ID space and a "global" ID space
    
=head1 SYNOPSIS

use CCO::Core::IDspace;

use strict;

my $idspace = CCO::Core::IDspace->new();


$idspace->local_idspace("CCO");

$idspace->uri("http://www.cellcycleontology.org/ontology/CCO");

$idspace->description("cell cycle ontology terms);

=head1 DESCRIPTION

A mapping between a "local" ID space and a "global" ID space.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use strict;
use warnings;
use Carp;

sub new {
	my $class                   = shift;
	my $self                    = {};

	$self->{LOCAL_IDSPACE}      = ""; # required, scalar (1)
	$self->{URI}                = ""; # required, scalar (1)
	$self->{DESCRIPTION}        = undef; # scalar (0..1)
        
	bless ($self, $class);
	return $self;
}

=head2 local_idspace

  Usage    - print $idspace->local_idspace() or $idspace->local_idspace($local_idspace)
  Returns  - the lcoal ID space(string)
  Args     - the local ID space (string)
  Function - gets/sets the local ID space
  
=cut

sub local_idspace {
	my ($self, $local_idspace) = @_;
	if ($local_idspace) {
		$self->{LOCAL_IDSPACE} = $local_idspace;
	} else { # get-mode
                confess "The local ID space of this ID space is not defined." if (!defined($self->{LOCAL_IDSPACE}));
        }
	return $self->{LOCAL_IDSPACE};
}

=head2 uri

  Usage    - print $idspace->uri() or $idspace->uri($uri)
  Returns  - the URI (string) of this ID space
  Args     - the URI (string) of this ID space
  Function - gets/sets the URI of this ID space
  
=cut

sub uri {
	my ($self, $uri) = @_;
	if ($uri) {
		$self->{URI} = $uri;
	} else { # get-mode
		confess "The URI of this ID space is not defined." if (!defined($self->{URI}));
	}
	return $self->{URI};
}

=head2 description

  Usage    - print $idspace->description() or $idspace->description($description)
  Returns  - the idspace description (string)
  Args     - the idspace description (string)
  Function - gets/sets the idspace description
  
=cut

sub description {
	my ($self, $description) = @_;
	if ($description) { 
		$self->{DESCRIPTION} = $description;
	} else { # get-mode
		confess "Neither the local idspace nor the URI of this idspace is defined." if (!defined($self->{LOCAL_IDSPACE}) || !defined($self->{URI}));
	}
	return $self->{DESCRIPTION};
}

=head2 as_string

  Usage    - print $idspace->as_string()
  Returns  - returns this idspace (local_idspace uri "description") as string if it is defined; otherwise, undef
  Args     - none
  Function - returns this idspace as string
  
=cut

sub as_string {
	my ($self) = @_;
	confess "Neither the local idspace nor the URI of this idspace is defined." if (!defined($self->{LOCAL_IDSPACE}) || !defined($self->{URI}));
	my $result = $self->{LOCAL_IDSPACE}." ".$self->{URI};
	$result .= " \"".$self->{DESCRIPTION}."\"" if (defined $self->{DESCRIPTION} && $self->{DESCRIPTION} ne "");
	$result = "" if ($result =~ /^\s*$/);
	return $result;
}

=head2 equals

  Usage    - print $idspace->equals($another_idspace)
  Returns  - either 1(true) or 0 (false)
  Args     - the idspace(CCO::Core::IDspace) to compare with
  Function - tells whether this idspace is equal to the parameter
  
=cut

sub equals {
	my ($self, $target) = @_;
	if ($target) {
		confess "Neither the local idspace nor the URI of this idspace is defined." if (!defined($self->{LOCAL_IDSPACE}) || !defined($self->{URI}));
		confess "Neither the local idspace nor the URI of this idspace is defined." if (!defined($target->{LOCAL_IDSPACE}) || !defined($target->{URI}));
		my $result = ((defined $self->{DESCRIPTION} && defined $target->{DESCRIPTION}) && ($self->{DESCRIPTION} eq $target->{DESCRIPTION}));
		return $result && (($self->{LOCAL_IDSPACE} eq $target->{LOCAL_IDSPACE}) &&
				($self->{URI} eq $target->{URI}));
	}
	return 0;
}

1;