# $Id: Def.pm 2010-10-29 erick.antezana $
#
# Module  : Def.pm
# Purpose : Definition structure.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::Core::Def;

use OBO::Util::DbxrefSet;
use strict;
use warnings;

sub new {
	my $class           = shift;
	my $self            = {};

	$self->{TEXT}       = undef; # required, scalar (1)
	$self->{DBXREF_SET} = OBO::Util::DbxrefSet->new(); # required, Dbxref (0..n)

	bless ($self, $class);
	return $self;
}

=head2 text

  Usage    - print $def->text() or $def->text($text)
  Returns  - the definition text (string)
  Args     - the definition text (string)
  Function - gets/sets the definition text
  
=cut

sub text {
	my ($self, $text) = @_;
	if ($text) { $self->{TEXT} = $text }
	return $self->{TEXT};
}

=head2 dbxref_set

  Usage    - $def->dbxref_set() or $def->dbxref_set($dbxref_set)
  Returns  - the definition dbxref set (OBO::Util::DbxrefSet)
  Args     - the definition dbxref set (OBO::Util::DbxrefSet)
  Function - gets/sets the definition dbxref set
  
=cut

sub dbxref_set {
	my ($self, $dbxref_set) = @_;
	$self->{DBXREF_SET} = $dbxref_set if ($dbxref_set);
	return $self->{DBXREF_SET};
}

=head2 dbxref_set_as_string

  Usage    - $definition->dbxref_set_as_string() or $definition->dbxref_set_as_string("[GOC:elh, PMID:9334324]")
  Returns  - the dbxref set (string) of this definition; [] if the set is empty
  Args     - the dbxref set (string) describing the source(s) of this definition
  Function - gets/sets the dbxref set of this definition. The set operation actually *adds* the new dbxrefs to the existing set
  
=cut

sub dbxref_set_as_string {
	my ($self, $dbxref_as_string) = @_;

	if ($dbxref_as_string) {
		$dbxref_as_string =~ s/^\[//;
		$dbxref_as_string =~ s/\]$//;		
		$dbxref_as_string =~ s/\\,/;;;;/g;  # trick to keep the comma's
		$dbxref_as_string =~ s/\\"/;;;;;/g; # trick to keep the double quote's

		my @lineas = $dbxref_as_string =~ /\"([^\"]*)\"/g; # get the double-quoted pieces
		foreach my $l (@lineas) {
			my $cp = $l;
			$l =~ s/,/;;;;/g; # trick to keep the comma's
			$dbxref_as_string =~ s/\Q$cp\E/$l/;
		}
		
		my @dbxrefs = split (/,/, $dbxref_as_string);
		
		foreach my $entry (@dbxrefs) {
			my ($match, $db, $acc, $desc, $mod) = ('', '', '', '', '');
			my $dbxref = OBO::Core::Dbxref->new();
			if ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)\s+\"([^\"]*)\"\s+(\{[\w ]+=[\w ]+\}))/) {
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
				$desc  = _unescape($4);
				$mod   = _unescape($5);
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)\s+(\{[\w ]+=[\w ]+\}))/) {
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
				$mod   = _unescape($4);
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)\s+\"([^\"]*)\")/) {
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
				$desc  = _unescape($4);
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*))/) { # skip: , and "
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
			} else {
				die "The references of this definition: '", $self->text(), "' were not properly defined. Check the 'dbxref' field (", $entry, ").";
			}
			
			# set the dbxref:
			$dbxref->name($db.':'.$acc);
			$dbxref->description($desc) if (defined $desc);
			$dbxref->modifier($mod) if (defined $mod);
			$self->{DBXREF_SET}->add($dbxref);
		}
	}
	my @result = (); # a Set?
	foreach my $dbxref (sort {lc($b->as_string()) cmp lc($a->as_string())} $self->dbxref_set()->get_set()) {
		unshift @result, $dbxref->as_string();
	}
	return "[".join(', ', @result)."]";
}

=head2 equals

  Usage    - $def->equals($another_def)
  Returns  - either 1 (true) or 0 (false)
  Args     - the definition to compare with
  Function - tells whether this definition is equal to the parameter
  
=cut

sub equals {
	my ($self, $target) = @_;
	my $result = 0;
	if ($target) {
		die "The text of this definition is undefined." if (!defined($self->{TEXT}));
		die "The text of the target definition is undefined." if (!defined($target->{TEXT}));

		$result = (($self->{TEXT} eq $target->{TEXT}) && ($self->{DBXREF_SET}->equals($target->{DBXREF_SET})));
	}
	return $result;
}

sub _unescape {
	my $match = $_[0];
	$match =~ s/;;;;;/\\"/g;
	$match =~ s/;;;;/\\,/g;
	return $match;
}

1;

__END__


=head1 NAME

OBO::Core::Def  - A definition structure of the current term. A term should 
have zero or one instance of this type per term description.
    
=head1 SYNOPSIS

use OBO::Core::Def;

use OBO::Core::Dbxref;

use strict;

# three new def's

my $def1 = OBO::Core::Def->new();

my $def2 = OBO::Core::Def->new();

my $def3 = OBO::Core::Def->new();


$def1->text("CCO:vm text");

$def2->text("CCO:ls text");

$def3->text("CCO:ea text");


my $ref1 = OBO::Core::Dbxref->new();

my $ref2 = OBO::Core::Dbxref->new();

my $ref3 = OBO::Core::Dbxref->new();


$ref1->name("CCO:vm");

$ref2->name("CCO:ls");

$ref3->name("CCO:ea");


my $dbxref_set1 = OBO::Util::DbxrefSet->new();

$dbxref_set1->add($ref1);


my $dbxref_set2 = OBO::Util::DbxrefSet->new();

$dbxref_set2->add($ref2);


my $dbxref_set3 = OBO::Util::DbxrefSet->new();

$dbxref_set3->add($ref3);

$def1->dbxref_set($dbxref_set1);

$def2->dbxref_set($dbxref_set2);

$def3->dbxref_set($dbxref_set3);


# dbxref_set_as_string

$def2->dbxref_set_as_string("[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"] {opt=first}");

my @refs_def2 = $def2->dbxref_set()->get_set();

my %r_def2;

foreach my $ref_def2 (@refs_def2) {
	
	$r_def2{$ref_def2->name()} = $ref_def2->name();
	
}


=head1 DESCRIPTION

A OBO::Core::Def object encapsules a definition for a universal. There must be 
zero or one instance of this type per term description. An object of this type
should have a quote enclosed definition text, and a OBO::Core::Dbxref set 
containing data base cross references which describe the origin of this 
definition (see OBO::Core::Dbxref for information on how Dbxref lists are used).

c.f. OBO flat file specification.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
