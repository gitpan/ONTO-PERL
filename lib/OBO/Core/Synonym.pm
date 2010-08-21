# $Id: Synonym.pm 1845 2010-01-08 12:33:09Z easr $
#
# Module  : Synonym.pm
# Purpose : A synonym for this term.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::Core::Synonym;

=head1 NAME

OBO::Core::Synonym  - A term synonym.
    
=head1 SYNOPSIS

use OBO::Core::Synonym;

use OBO::Core::Dbxref;

use strict;


my $syn1 = OBO::Core::Synonym->new();

my $syn2 = OBO::Core::Synonym->new();

my $syn3 = OBO::Core::Synonym->new();

my $syn4 = OBO::Core::Synonym->new();


# type

$syn1->type('EXACT');

$syn2->type('BROAD');

$syn3->type('NARROW');

$syn4->type('NARROW');


# def

my $def1 = OBO::Core::Def->new();

my $def2 = OBO::Core::Def->new();

my $def3 = OBO::Core::Def->new();

my $def4 = OBO::Core::Def->new();


$def1->text("Hola mundo1");

$def2->text("Hola mundo2");

$def3->text("Hola mundo3");

$def4->text("Hola mundo3");


my $ref1 = OBO::Core::Dbxref->new();

my $ref2 = OBO::Core::Dbxref->new();

my $ref3 = OBO::Core::Dbxref->new();

my $ref4 = OBO::Core::Dbxref->new();


$ref1->name("CCO:vm");

$ref2->name("CCO:ls");

$ref3->name("CCO:ea");

$ref4->name("CCO:ea");


my $refs_set1 = OBO::Util::DbxrefSet->new();

$refs_set1->add_all($ref1,$ref2,$ref3,$ref4);

$def1->dbxref_set($refs_set1);

$syn1->def($def1);


my $refs_set2 = OBO::Util::DbxrefSet->new();

$refs_set2->add($ref2);

$def2->dbxref_set($refs_set2);

$syn2->def($def2);


my $refs_set3 = OBO::Util::DbxrefSet->new();

$refs_set3->add($ref3);

$def3->dbxref_set($refs_set3);

$syn3->def($def3);


my $refs_set4 = OBO::Util::DbxrefSet->new();

$refs_set4->add($ref4);

$def4->dbxref_set($refs_set4);

$syn4->def($def4);


# def as string

$syn3->def_as_string("This is a dummy synonym", "[CCO:vm, CCO:ls, CCO:ea \"Erick Antezana\"]");

my @refs_syn3 = $syn3->def()->dbxref_set()->get_set();

my %r_syn3;

foreach my $ref_syn3 (@refs_syn3) {
	
	$r_syn3{$ref_syn3->name()} = $ref_syn3->name();
	
}


=head1 DESCRIPTION

A synonym for a term held by the ontology. This synonym must have a type 
and definition (OBO::Core::Def) describing the origins of the synonym, and may 
indicate a synonym category or scope information.

The synonym scope may be one of four values: EXACT, BROAD, NARROW, RELATED. 

A term may have any number of synonyms. 

c.f. OBO flat file specification.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use OBO::Core::Dbxref;
use OBO::Core::Def;
use OBO::Util::Set;
use strict;
use warnings;
use Carp;

sub new {
	my $class                   = shift;
	my $self                    = {};

	$self->{TYPE}               = undef; # required: exact_synonym, broad_synonym, narrow_synonym, related_synonym
	$self->{DEF}                = OBO::Core::Def->new(); # required
	$self->{SYNONYM_TYPE_NAME}  = undef;

	bless ($self, $class);
	return $self;
}

=head2 type

  Usage    - print $synonym->type() or $synonym->type("EXACT")
  Returns  - the synonym scope
  Args     - the synonym scope: 'EXACT', 'BROAD', 'NARROW', 'RELATED'
  Function - gets/sets the synonym scope
  
=cut

sub type {
	my ($self, $synonym_type) = @_;
	if ($synonym_type) {
		my $possible_types = OBO::Util::Set->new();
		$possible_types->add_all('EXACT', 'BROAD', 'NARROW', 'RELATED');
		if ($possible_types->contains($synonym_type)) {
			$self->{TYPE} = $synonym_type;
		} else {
			confess "The synonym type must be one of the following: 'EXACT', 'BROAD', 'NARROW', 'RELATED'";
		}
	}
    return $self->{TYPE};
}

=head2 def

  Usage    - print $synonym->def() or $synonym->def($def)
  Returns  - the synonym definition (OBO::Core::Def)
  Args     - the synonym definition (OBO::Core::Def)
  Function - gets/sets the synonym definition
  
=cut

sub def {
	my ($self, $def) = @_;
	if ($def) {
		$self->{DEF} = $def; 
	}
	return $self->{DEF};
}

=head2 synonym_type_name

  Usage    - print $synonym->synonym_type_name() or $synonym->synonym_type_name("UK_SPELLING")
  Returns  - the name of the synonym type associated to this synonym
  Args     - the synonym type name (string)
  Function - gets/sets the synonym name
  
=cut

sub synonym_type_name {
	my ($self, $synonym_type_name) = @_;
	$self->{SYNONYM_TYPE_NAME} = $synonym_type_name if ($synonym_type_name);
	return $self->{SYNONYM_TYPE_NAME};
}

=head2 def_as_string

  Usage    - $synonym->def_as_string() or $synonym->def_as_string("Here goes the synonym.", "[GOC:elh, PMID:9334324]")
  Returns  - the synonym text (string)
  Args     - the synonym text plus the dbxref list describing the source of this definition
  Function - gets/sets the definition of this synonym
  
=cut

sub def_as_string {
	my ($self, $text, $dbxref_as_string) = @_;
	if ($text && $dbxref_as_string){
		my $def = OBO::Core::Def->new();
		$def->text($text);

		$dbxref_as_string =~ s/^\[//;
		$dbxref_as_string =~ s/\]$//;		
		$dbxref_as_string =~ s/\\,/;;;;/g; # trick to keep the comma's
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
			} elsif ($entry =~ m/(([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*))/) { # skip: , y "
				$match = _unescape($1);
				$db    = _unescape($2);
				$acc   = _unescape($3);
			} else {
				confess "The references of this synonym: '", $text, "' were not properly defined. Check the 'dbxref' field (", $entry, ").";
			}
			
			# set the dbxref:
			$dbxref->name($db.':'.$acc);
			$dbxref->description($desc) if (defined $desc);
			$dbxref->modifier($mod) if (defined $mod);
			$def->{DBXREF_SET}->add($dbxref);
		}
		$self->{DEF} = $def;
	}
	
	my @result  = (); # a Set?
	my @dbxrefs = $self->{DEF}->dbxref_set()->get_set();
	foreach my $dbxref (sort {($a && $b)?(lc($a->as_string()) cmp lc($b->as_string())):0} @dbxrefs) {
		push @result, $dbxref->as_string();
	}
	# output: "synonym text" [dbxref's]
	# modify here to have: "synonym text" synonym_type [dbxref's]
	return "\"".$self->{DEF}->text()."\""." [".join(', ', @result)."]";
}

=head2 equals

  Usage    - print $synonym->equals($another_synonym)
  Returns  - either 1 (true) or 0 (false)
  Args     - the synonym to compare with
  Function - tells whether this synonym is equal to the parameter
  
=cut

sub equals {
	my ($self, $target) = @_;
	my $result = 0;
	if ($target) {
		
		confess "The type of this synonym is undefined" if (!defined($self->{TYPE}));
		confess "The type of the target synonym is undefined" if (!defined($target->{TYPE}));
		
		$result = (($self->{TYPE} eq $target->{TYPE}) && ($self->{DEF}->equals($target->{DEF})));
		$result = $result && ($self->{SYNONYM_TYPE_NAME} eq $target->{SYNONYM_TYPE_NAME}) if (defined $self->{SYNONYM_TYPE_NAME} && defined $target->{SYNONYM_TYPE_NAME});
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
