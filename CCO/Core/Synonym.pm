# $Id: Synonym.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : Synonym.pm
# Purpose : A synonym of a Term.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
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
        
        bless ($self, $class);
        return $self;
}

=head2 type

  Usage    - print $synonym->type() or $synonym->type("exact")
  Returns  - the synonym type
  Args     - the synonym type: 'exact', 'broad', 'narrow', 'related'
  Function - gets/sets the synonym name
  
=cut
sub type {
	my $self = shift;
	if (@_) {
		my $synonym_type = shift;
		my $possible_types = CCO::Util::Set->new();
		# todo 'alt_id' is also a valid value?
		$possible_types->add_all('exact', 'broad', 'narrow', 'related');
		if ($possible_types->contains($synonym_type)) {
			$self->{TYPE} = $synonym_type;
		} else {
			croak "The synonym type must be one of the following: 'exact', 'broad', 'narrow', 'related'";
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
	my $self = shift;
    if (@_) {
    		my $def = shift;
    		croak "The definition must be a CCO::Core::Def object" if (!UNIVERSAL::isa($def, 'CCO::Core::Def'));
		$self->{DEF} = $def; 
	}
    return $self->{DEF};
}

=head2 def_as_string

  Usage    - $synonym->def_as_string() or $synonym->def_as_string("Here goes the synonym.", "[GOC:elh, PMID:9334324]")
  Returns  - the synonym text (string)
  Args     - the synonym text plus the dbxref list describing the source of this definition
  Function - gets/sets the definition of this synonym
  
=cut
sub def_as_string {
	my $self = shift;
	if (@_) {
		my $text = shift;
		my $dbxref_as_string = shift;
		
		$text || croak "The text for defining the synonym was not defined";
		$dbxref_as_string || croak "The dbxrefs for this synonym (",$text ,") were not defined";
				
		$dbxref_as_string =~ s/^\[//;
		$dbxref_as_string =~ s/\]$//;
		$dbxref_as_string =~ s/,\s+/,/g;
		my @refs = split(/,/, $dbxref_as_string);
    		
		my $def = CCO::Core::Def->new();
		$def->text($text);
		
		my $dbxref_set = CCO::Core::DbxrefSet->new();
		foreach my $ref (@refs) {
			if ($ref =~ /([\w-]+:[\w-]+)(\s+\"([\w ]+)\")?(\s+(\{[\w ]+=[\w ]+\}))?/) {
				my $dbxref = CCO::Core::Dbxref->new();
				$dbxref->name($1);
				$dbxref->description($3) if (defined $3);
				$dbxref->modifier($5) if (defined $5);
				$dbxref_set->add($dbxref);
			} else {
				croak "There were not defined the references for this synonym: '", $text, "'. Check the 'dbxref' field.";
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
	my $self = shift;
	my $result = 0;
	if (@_) {
		my $target = shift;
		
		croak "The element to be tested must be a CCO::Core::Synonym object" if (!UNIVERSAL::isa($target, 'CCO::Core::Synonym'));
		croak "The type of this synonym is undefined" if (!defined($self->{TYPE}));
		croak "The type of the target synonym is undefined" if (!defined($target->{TYPE}));
		
		$result = (($self->{TYPE} eq $target->{TYPE}) && ($self->{DEF}->equals($target->{DEF})));
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
$syn1->type('exact');
$syn2->type('broad');
$syn3->type('narrow');
$syn4->type('narrow');

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

my $refs_set1 = CCO::Core::DbxrefSet->new();
$refs_set1->add_all($ref1,$ref2,$ref3,$ref4);
$def1->dbxref_set($refs_set1);
$syn1->def($def1);

my $refs_set2 = CCO::Core::DbxrefSet->new();
$refs_set2->add($ref2);
$def2->dbxref_set($refs_set2);
$syn2->def($def2);

my $refs_set3 = CCO::Core::DbxrefSet->new();
$refs_set3->add($ref3);
$def3->dbxref_set($refs_set3);
$syn3->def($def3);

my $refs_set4 = CCO::Core::DbxrefSet->new();
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
A synonym for a term held by the ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    