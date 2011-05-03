# $Id: Dbxref.pm 2011-03-29 erick.antezana $
#
# Module  : Dbxref.pm
# Purpose : Reference structure.
# License : Copyright (c) 2006-2011 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::Core::Dbxref;

use strict;
use warnings;

sub new {
	my $class            = shift;
	my $self             = {};

	$self->{DB}          = ''; # required, scalar (1)
	$self->{ACC}         = ''; # required, scalar (1)
	$self->{DESCRIPTION} = ''; # scalar (0..1)
	$self->{MODIFIER}    = ''; # scalar (0..1)
    
	bless ($self, $class);
	return $self;
}

=head2 name

  Usage    - print $dbxref->name() or $dbxref->name($name)
  Returns  - the dbxref name (string)
  Args     - the dbxref name (string) that follows this convention DB:ACC (ACC may be an empty string like some dbxrefs from the ChEBI ontology)
  Function - gets/sets the dbxref name
  
=cut

sub name {
	my ($self, $name) = @_;
	if ($name) {
		if ($name =~ /([\*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)/ || 
			$name =~ /(http):\/\/(.*)/) {
			$self->{DB}  = $1;
			$self->{ACC} = $2;
		}
	} elsif (!defined($self->{DB}) || !defined($self->{ACC})) {
		die 'The name of this dbxref is not defined.';
	} else {  # get-mode
		return $self->{DB}.':'.$self->{ACC};
	}
}

# Alias
*id = \&name;

=head2 db

  Usage    - print $dbxref->db() or $dbxref->db($db)
  Returns  - the dbxref db (string)
  Args     - the dbxref db (string)
  Function - gets/sets the dbxref db
  
=cut

sub db {
	my ($self, $db) = @_;
	if ($db) {
		$self->{DB} = $db;
	} elsif (!defined($self->{DB})) {
		die "The database (db) of this 'dbxref' is not defined.";
	} else { # get-mode
		return $self->{DB};
	}
}

=head2 acc

  Usage    - print $dbxref->acc() or $dbxref->acc($acc)
  Returns  - the dbxref acc (string)
  Args     - the dbxref acc (string)
  Function - gets/sets the dbxref acc
  
=cut

sub acc {
	my ($self, $acc) = @_;
	if ($acc) {
		$self->{ACC} = $acc;
	} elsif (!defined($self->{ACC})) {
		die 'The accession number (acc) of this dbxref is not defined.';
	} else { # get-mode
		return $self->{ACC};
	}
}

=head2 description

  Usage    - print $dbxref->description() or $dbxref->description($description)
  Returns  - the dbxref description (string)
  Args     - the dbxref description (string)
  Function - gets/sets the dbxref description
  
=cut

sub description {
	my ($self, $description) = @_;
	if ($description) { 
		$self->{DESCRIPTION} = $description;
	} elsif (!defined($self->{DB}) || !defined($self->{ACC})) {
		die 'The name of this dbxref is not defined.';
	} else { # get-mode
		return $self->{DESCRIPTION};
	}
}

=head2 modifier

  Usage    - print $dbxref->modifier() or $dbxref->modifier($modifier)
  Returns  - the optional trailing modifier (string)
  Args     - the optional trailing modifier (string)
  Function - gets/sets the optional trailing modifier
  
=cut

sub modifier {
	my ($self, $modifier) = @_;
	if ($modifier) { 
		$self->{MODIFIER} = $modifier;
	} elsif (!defined($self->{DB}) || !defined($self->{ACC})) {
		die 'The name of this dbxref is not defined.';
	} else { # get-mode
		return $self->{MODIFIER};
	}
}

=head2 as_string

  Usage    - print $dbxref->as_string()
  Returns  - returns this dbxref ([name "description" {modifier}]) as string
  Args     - none
  Function - returns this dbxref as string
  
=cut

sub as_string {
	my ($self) = @_;
	die 'The name of this dbxref is not defined.' if (!defined($self->{DB}) || !defined($self->{ACC}));
	my $result = $self->{DB}.':'.$self->{ACC};
	$result   .= ' "'.$self->{DESCRIPTION}.'"' if (defined $self->{DESCRIPTION} && $self->{DESCRIPTION} ne '');
	$result   .= ' '.$self->{MODIFIER} if (defined $self->{MODIFIER} && $self->{MODIFIER} ne '');
	return $result;
}

=head2 equals

  Usage    - print $dbxref->equals($another_dbxref)
  Returns  - either 1(true) or 0 (false)
  Args     - the dbxref(OBO::Core::Dbxref) to compare with
  Function - tells whether this dbxref is equal to the parameter
  
=cut

sub equals {
	my ($self, $target) = @_;
	
	if ($target && eval { $target->isa('OBO::Core::Dbxref') }) {
		
		if (!defined($self->{DB}) || !defined($self->{ACC})) {
			die 'The name of this dbxref is undefined.';
		} 
		if (!defined($target->{DB}) || !defined($target->{ACC})) {
			die 'The name of the target dbxref is undefined.';
		}
		return (($self->{DB}          eq $target->{DB})          &&
				($self->{ACC}         eq $target->{ACC})         &&
				($self->{DESCRIPTION} eq $target->{DESCRIPTION}) &&
				($self->{MODIFIER}    eq $target->{MODIFIER}));
	} else {
		die "An unrecognized object type (not a OBO::Core::Dbxref) was found: '", $target, "'";
	}
	return 0;
}

1;

__END__

=head1 NAME

OBO::Core::Dbxref -  A database reference structure.
    
=head1 SYNOPSIS

use OBO::Core::Dbxref;

use strict;

# three new dbxref's

my $ref1 = OBO::Core::Dbxref->new;

my $ref2 = OBO::Core::Dbxref->new;

my $ref3 = OBO::Core::Dbxref->new;


$ref1->name("CCO:vm");

$ref1->description("this is a description");

$ref1->modifier("{opt=123}");

$ref2->name("CCO:ls");

$ref3->name("CCO:ea");


my $ref4 = $ref3;

my $ref5 = OBO::Core::Dbxref->new;

$ref5->name("CCO:vm");

$ref5->description("this is a description");

$ref5->modifier("{opt=123}");


=head1 DESCRIPTION

A dbxref object encapsules a reference for a universal.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2011 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut