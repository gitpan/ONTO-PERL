# $Id: Synonym.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : Synonym.pm
# Purpose : A synonym for this term.
# License : Copyright (c) 2006, 2007 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Core::Synonym;
use CCO::Core::Dbxref;
use CCO::Core::Def;
use CCO::Util::Set;
use strict;
use warnings;
use Carp;

sub new {
        my $class                   = shift;
        my $self                    = {};
        
        $self->{TYPE}               = undef; # required: exact_synonym, broad_synonym, narrow_synonym, related_synonym
        $self->{DEF}                = CCO::Core::Def->new(); # required
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
	# TODO refactor this method, new name: scope
	my ($self, $synonym_type) = @_;
	if ($synonym_type) {
		my $possible_types = CCO::Util::Set->new();
		# todo 'alt_id' is also a valid value?
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
  Returns  - the synonym definition (CCO::Core::Def)
  Args     - the synonym definition (CCO::Core::Def)
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
		$dbxref_as_string =~ s/^\[//;
		$dbxref_as_string =~ s/\]$//;
		$dbxref_as_string =~ s/,\s+/,/g;
		my @refs = split(/,/, $dbxref_as_string);
    		
		my $def = CCO::Core::Def->new();
		$def->text($text);
		
		my $dbxref_set = CCO::Util::DbxrefSet->new();
		foreach my $ref (@refs) {
			if ($ref =~ /([\w-]+:[\w-]+)(\s+\"([\w ]+)\")?(\s+(\{[\w ]+=[\w ]+\}))?/) {
				my $dbxref = CCO::Core::Dbxref->new();
				$dbxref->name($1);
				$dbxref->description($3) if (defined $3);
				$dbxref->modifier($5) if (defined $5);
				$dbxref_set->add($dbxref);
			} else {
				confess "There were not defined the references for this synonym: '", $text, "'. Check the 'dbxref' field.";
			}
		}
		$def->dbxref_set($dbxref_set);
		
		$self->{DEF} = $def; 
	}
	
	my @result = (); # a Set?
	foreach my $dbxref ($self->{DEF}->dbxref_set()->get_set()) {
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

1;

=head1 NAME

    CCO::Core::Synonym  - A term synonym.
    
=head1 SYNOPSIS

use CCO::Core::Synonym;

use CCO::Core::Dbxref;

use strict;


my $syn1 = CCO::Core::Synonym->new();

my $syn2 = CCO::Core::Synonym->new();

my $syn3 = CCO::Core::Synonym->new();

my $syn4 = CCO::Core::Synonym->new();


# type

$syn1->type('EXACT');

$syn2->type('BROAD');

$syn3->type('NARROW');

$syn4->type('NARROW');


# def

my $def1 = CCO::Core::Def->new();

my $def2 = CCO::Core::Def->new();

my $def3 = CCO::Core::Def->new();

my $def4 = CCO::Core::Def->new();


$def1->text("Hola mundo1");

$def2->text("Hola mundo2");

$def3->text("Hola mundo3");

$def4->text("Hola mundo3");


my $ref1 = CCO::Core::Dbxref->new();

my $ref2 = CCO::Core::Dbxref->new();

my $ref3 = CCO::Core::Dbxref->new();

my $ref4 = CCO::Core::Dbxref->new();


$ref1->name("CCO:vm");

$ref2->name("CCO:ls");

$ref3->name("CCO:ea");

$ref4->name("CCO:ea");


my $refs_set1 = CCO::Util::DbxrefSet->new();

$refs_set1->add_all($ref1,$ref2,$ref3,$ref4);

$def1->dbxref_set($refs_set1);

$syn1->def($def1);


my $refs_set2 = CCO::Util::DbxrefSet->new();

$refs_set2->add($ref2);

$def2->dbxref_set($refs_set2);

$syn2->def($def2);


my $refs_set3 = CCO::Util::DbxrefSet->new();

$refs_set3->add($ref3);

$def3->dbxref_set($refs_set3);

$syn3->def($def3);


my $refs_set4 = CCO::Util::DbxrefSet->new();

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
and definition (CCO::Core::Def) describing the origins of the synonym, and may 
indicate a synonym category or scope information.

The synonym scope may be one of four values: EXACT, BROAD, NARROW, RELATED. 

A term may have any number of synonyms. 

c.f. OBO flat file specification.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    