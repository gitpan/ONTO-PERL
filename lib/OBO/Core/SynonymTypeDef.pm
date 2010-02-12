# $Id: SynonymTypeDef.pm 1845 2008-01-08 12:33:09Z erant $
#
# Module  : SynonymTypeDef.pm
# Purpose : A synonym type definition.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana@gmail.com>
#
package OBO::Core::SynonymTypeDef;

=head1 NAME

OBO::Core::SynonymTypeDef  - A synonym type definition. It should contain a synonym 
type name, a space, a quote enclosed description, and an optional scope specifier.
    
=head1 SYNOPSIS

use OBO::Core::SynonymTypeDef;

use strict;


my $std1 = OBO::Core::SynonymTypeDef->new();

my $std2 = OBO::Core::SynonymTypeDef->new();


# synonym_type_name

$std1->synonym_type_name("goslim_plant");

$std2->synonym_type_name("goslim_yeast");


# description

$std1->description("Plant GO slim");

$std2->description("Yeast GO slim");


# scope

$std1->scope("EXACT");

$std2->scope("BROAD");


# synonym type def as string

my $std3 = OBO::Core::SynonymTypeDef->new();

$std3->synonym_type_def_as_string("goslim_plant", "Plant GO slim", "EXACT");

if ($std1->equals($std3)) {
	
	print "std1 is the same as std3\n";
	
}


=head1 DESCRIPTION

A synonym type defintion provides a description of a user-defined synonym 
type. This object holds: a synonym type name, a description, and an 
optional scope specifier (c.f. OBO flat file specification). The scope 
specifier indicates the default scope for any synonym that has this type.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

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
        
        $self->{SYNONYM_TYPE_NAME}  = undef; # required
        $self->{DESCRIPTION}        = undef; # required
        $self->{SCOPE}              = undef; # optional: The scope specifier indicates the default scope for any synonym that has this type.
        
        bless ($self, $class);
        return $self;
}
=head2 synonym_type_name

  Usage    - print $synonym_type_def->synonym_type_name() or $synonym_type_def->synonym_type_name($synonym_type_name)
  Returns  - the synonym type name (string)
  Args     - the synonym type name (string)
  Function - gets/sets the synonym type name
  
=cut

sub synonym_type_name {
	my ($self, $synonym_type_name) = @_;
	$self->{SYNONYM_TYPE_NAME} = $synonym_type_name if ($synonym_type_name);
    return $self->{SYNONYM_TYPE_NAME};
}

=head2 description

  Usage    - print $synonym_type_def->description() or $synonym_type_def->description($desc)
  Returns  - the synonym description (string)
  Args     - the synonym description (string)
  Function - gets/sets the synonym description
  
=cut

sub description {
	my ($self, $desc) = @_;
    $self->{DESCRIPTION} = $desc if ($desc);
    return $self->{DESCRIPTION};
}

=head2 scope

  Usage    - print $synonym_type_def->scope() or $synonym_type_def->scope($scope)
  Returns  - the scope of this synonym type definition (string)
  Args     - the scope of this synonym type definition (string)
  Function - gets/sets the scope of this synonym type definition
  
=cut

sub scope {
	my ($self, $scope) = @_;
	$self->{SCOPE} = $scope if ($scope);
    return $self->{SCOPE};
}

=head2 synonym_type_def_as_string

  Usage    - $synonym_type_def->synonym_type_def_as_string() or $synonym_type_def->synonym_type_def_as_string("UK_SPELLING", "British spelling", "EXACT")
  Returns  - the synonym type definition (string)
  Args     - the synonym type definition (string)
  Function - gets/sets the definition of this synonym
  
=cut

sub synonym_type_def_as_string {
	my ($self, $synonym_type_name, $desc, $scope) = @_;
	if ($synonym_type_name && $desc){
		$self->{SYNONYM_TYPE_NAME} = $synonym_type_name;
		$self->{DESCRIPTION} = $desc;
		$self->{SCOPE} = $scope if ($scope);
		return; # set mode
	}
	$scope = $self->{SCOPE};
	if (defined $scope) {
		return $self->{SYNONYM_TYPE_NAME}." "."\"".$self->{DESCRIPTION}."\""." ".$scope;
	} else {
		return $self->{SYNONYM_TYPE_NAME}." "."\"".$self->{DESCRIPTION}."\"";
	}
}

=head2 equals

  Usage    - print $synonym_type_def->equals($another_synonym_type_def)
  Returns  - either 1 (true) or 0 (false)
  Args     - the synonym type definition to compare with
  Function - tells whether this synonym type definition is equal to the given argument (another synonym type definition)
  
=cut

sub equals {
	my ($self, $target) = @_;
	my $result = 0;
	if ($target) {
		
		confess "The synonym type name of this synonym type definition is undefined" if (!defined($self->{SYNONYM_TYPE_NAME}));
		confess "The synonym type name of the target synonym type definition is undefined" if (!defined($self->{SYNONYM_TYPE_NAME}));
		
		confess "The description of the this synonym type definition is undefined" if (!defined($target->{DESCRIPTION}));
		confess "The description of the target synonym type definition is undefined" if (!defined($target->{DESCRIPTION}));
		
		$result = ($self->{SYNONYM_TYPE_NAME} eq $target->{SYNONYM_TYPE_NAME}) && ($self->{DESCRIPTION} eq$target->{DESCRIPTION});
		$result = $result && ($self->{SCOPE} eq $target->{SCOPE}) if (defined $self->{SCOPE} && defined $target->{SCOPE}); # Future improvement, consider case: scope1 undefined and scope 2 defined!
	}
	return $result;
}

1;    