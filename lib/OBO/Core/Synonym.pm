# $Id: Synonym.pm 2010-10-29 erick.antezana $
#
# Module  : Synonym.pm
# Purpose : A synonym for this term.
# License : Copyright (c) 2006-2011 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::Core::Synonym;

use OBO::Core::Dbxref;
use OBO::Core::Def;
use OBO::Util::Set;
use strict;
use warnings;

sub new {
	my $class                   = shift;
	my $self                    = {};

	$self->{SCOPE}              = undef;                 # required: {exact_synonym, broad_synonym, narrow_synonym, related_synonym}
	$self->{DEF}                = OBO::Core::Def->new(); # required
	$self->{SYNONYM_TYPE_NAME}  = undef;                 # optional

	bless ($self, $class);
	return $self;
}

=head2 scope

  Usage    - print $synonym->scope() or $synonym->scope("EXACT")
  Returns  - the synonym scope
  Args     - the synonym scope: 'EXACT', 'BROAD', 'NARROW', 'RELATED'
  Function - gets/sets the synonym scope
  
=cut

sub scope {
	my ($self, $synonym_scope) = @_;
	if ($synonym_scope) {
		my $possible_scopes = OBO::Util::Set->new();
		my @synonym_scopes  = ('EXACT', 'BROAD', 'NARROW', 'RELATED');
		$possible_scopes->add_all(@synonym_scopes);
		if ($possible_scopes->contains($synonym_scope)) {
			$self->{SCOPE} = $synonym_scope;
		} else {
			die 'The synonym scope you provided must be one of the following: ', join (', ', @synonym_scopes);
		}
	}
    return $self->{SCOPE};
}

=head2 def

  Usage    - print $synonym->def() or $synonym->def($def)
  Returns  - the synonym definition (OBO::Core::Def)
  Args     - the synonym definition (OBO::Core::Def)
  Function - gets/sets the synonym definition
  
=cut

sub def {
	my ($self, $def) = @_;
	$self->{DEF} = $def if ($def);
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
	$self->{SYNONYM_TYPE_NAME}     = $synonym_type_name if ($synonym_type_name);
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
		
		my @dbxrefs = split (',', $dbxref_as_string);
		
		my $r_db_acc      = qr/([ \*\.\w-]*):([ \#~\w:\\\+\?\{\}\$\/\(\)\[\]\.=&!%_-]*)/o;
		my $r_desc        = qr/\s+\"([^\"]*)\"/o;
		my $r_mod         = qr/\s+(\{[\w ]+=[\w ]+\})/o;
		
		foreach my $entry (@dbxrefs) {
			my ($match, $db, $acc, $desc, $mod) = undef;
			my $dbxref = OBO::Core::Dbxref->new();
			if ($entry =~ m/$r_db_acc$r_desc$r_mod?/) {
				$db    = _unescape($1);
				$acc   = _unescape($2);
				$desc  = _unescape($3);
				$mod   = _unescape($4) if ($4);
			} elsif ($entry =~ m/$r_db_acc$r_desc?$r_mod?/) {
				$db    = _unescape($1);
				$acc   = _unescape($2);
				$desc  = _unescape($3) if ($3);
				$mod   = _unescape($4) if ($4);
			} else {
				die "The references of this synonym: '", $text, "' were not properly defined. Check the 'dbxref' field (", $entry, ").";
			}
			
			# set the dbxref:
			$dbxref->name($db.':'.$acc);
			$dbxref->description($desc) if (defined $desc);
			$dbxref->modifier($mod) if (defined $mod);
			$def->dbxref_set->add($dbxref);
		}
		$self->{DEF} = $def;
	}
	
	my @result  = (); # a Set?
	my @dbxrefs = $self->{DEF}->dbxref_set()->get_set();
	my @sorted_dbxrefs = map { $_->[0] }                 # restore original values
						sort { $a->[1] cmp $b->[1] }     # sort
						map  { [$_, lc($_->as_string)] } # transform: value, sortkey
						$self->{DEF}->dbxref_set()->get_set();							
	#foreach my $dbxref (sort {($a && $b)?(lc($a->as_string()) cmp lc($b->as_string())):0} @dbxrefs) {
	foreach my $dbxref (@sorted_dbxrefs) {	
		push @result, $dbxref->as_string();
	}
	# min  output: "synonym text" [dbxref's] 
	# full output: "synonym text" synonym_scope SYNONYM_TYPE_NAME [dbxref's] <-- to get this use 'OBO::Core::Term::synonym_as_string()'
	return '"'.$self->{DEF}->text().'"'.' ['.join(', ', @result).']';
}

=head2 equals

  Usage    - print $synonym->equals($another_synonym)
  Returns  - either 1 (true) or 0 (false)
  Args     - the synonym (OBO::Core::Synonym) to compare with
  Function - tells whether this synonym is equal to the parameter
  
=cut

sub equals {
	my ($self, $target) = @_;
	my $result = 0;
	if ($target && eval { $target->isa('OBO::Core::Synonym') }) {

		die 'The scope of this synonym is undefined.' if (!defined($self->{SCOPE}));
		die 'The scope of the target synonym is undefined.' if (!defined($target->{SCOPE}));
		
		$result = (($self->{SCOPE} eq $target->{SCOPE}) && ($self->{DEF}->equals($target->{DEF})));
		$result = $result && ($self->{SYNONYM_TYPE_NAME} eq $target->{SYNONYM_TYPE_NAME}) if (defined $self->{SYNONYM_TYPE_NAME} && defined $target->{SYNONYM_TYPE_NAME});
	} else {
		die "An unrecognized object type (not a OBO::Core::Synonym) was found: '", $target, "'";
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

OBO::Core::Synonym  - A term synonym.
    
=head1 SYNOPSIS

use OBO::Core::Synonym;

use OBO::Core::Dbxref;

use strict;


my $syn1 = OBO::Core::Synonym->new();

my $syn2 = OBO::Core::Synonym->new();

my $syn3 = OBO::Core::Synonym->new();

my $syn4 = OBO::Core::Synonym->new();


# scope

$syn1->scope('EXACT');

$syn2->scope('BROAD');

$syn3->scope('NARROW');

$syn4->scope('NARROW');


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

$syn3->def_as_string("This is a dummy synonym", '[CCO:vm, CCO:ls, CCO:ea "Erick Antezana"]');

my @refs_syn3 = $syn3->def()->dbxref_set()->get_set();

my %r_syn3;

foreach my $ref_syn3 (@refs_syn3) {
	
	$r_syn3{$ref_syn3->name()} = $ref_syn3->name();
	
}


=head1 DESCRIPTION

A synonym for a term held by the ontology. This synonym must have a type 
and a definition (OBO::Core::Def) describing the origins of the synonym, and may 
indicate a synonym category or scope information.

The synonym scope may be one of four values: EXACT, BROAD, NARROW, RELATED. 

A term may have any number of synonyms. 

c.f. OBO flat file specification.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2011 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut