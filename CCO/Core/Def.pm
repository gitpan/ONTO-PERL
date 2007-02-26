# $Id: Def.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : Def.pm
# Purpose : Definition structure.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
package CCO::Core::Def;
use CCO::Util::DbxrefSet;
use strict;
use warnings;
use Carp;

sub new {
        my $class                   = shift;
        my $self                    = {};
        
        $self->{TEXT}               = undef; # required, scalar (1)
        $self->{DBXREF_SET}         = CCO::Util::DbxrefSet->new(); # required, Dbxref (0..n)
        
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
  Returns  - the definition dbxref set (CCO::Util::DbxrefSet)
  Args     - the definition dbxref set (CCO::Util::DbxrefSet)
  Function - gets/sets the definition dbxref set
  
=cut
sub dbxref_set {
	my ($self, $dbxref_set) = @_;
	if ($dbxref_set) {
    	$self->{DBXREF_SET} = $dbxref_set;
    }
    return $self->{DBXREF_SET};
}

=head2 dbxref_set_as_string

  Usage    - $definition->dbxref_set_as_string() or $definition->dbxref_set_as_string("[GOC:elh, PMID:9334324]")
  Returns  - the dbxref set (string) of this definition; [] if the set is empty
  Args     - the dbxref set (string) describing the source(s) of this definition
  Function - gets/sets the dbxref set of this definition
  
=cut
sub dbxref_set_as_string {
	my ($self, $dbxref_as_string) = @_;
	if ($dbxref_as_string) {
		$dbxref_as_string =~ s/\[//;
		$dbxref_as_string =~ s/\]//;
		my @refs = split(/, /, $dbxref_as_string);
		
		my $dbxref_set = CCO::Util::DbxrefSet->new();
		foreach my $ref (@refs) {
			if ($ref =~ /([\w-]+:[\w:,\(\)\.-]+)(\s+\"([\w ]+)\")?(\s+(\{[\w ]+=[\w ]+\}))?/) {
				my $dbxref = CCO::Core::Dbxref->new();
				$dbxref->name($1);
				$dbxref->description($3) if (defined $3);
				$dbxref->modifier($5) if (defined $5);
				$dbxref_set->add($dbxref);
			} else {
				confess "There were not defined the references for this definition: ", $self->id(), ". Check the 'dbxref' field.";
			}
		}
		$self->{DBXREF_SET} = $dbxref_set;
	}
	my @result = (); # a Set?
	foreach my $dbxref ($self->dbxref_set()->get_set()) {
		push @result, $dbxref->as_string();
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

		confess "The text of this definition is undefined" if (!defined($self->{TEXT}));
		confess "The text of the target definition is undefined" if (!defined($target->{TEXT}));
		
		$result = (($self->{TEXT} eq $target->{TEXT}) && ($self->{DBXREF_SET}->equals($target->{DBXREF_SET})));
	}
	return $result;
}

1;

=head1 NAME

    CCO::Core::Def  - Definition structure.
    
=head1 SYNOPSIS

use CCO::Core::Def;

use CCO::Core::Dbxref;

use strict;

# three new def's

my $def1 = CCO::Core::Def->new();

my $def2 = CCO::Core::Def->new();

my $def3 = CCO::Core::Def->new();


$def1->text("CCO:vm text");

$def2->text("CCO:ls text");

$def3->text("CCO:ea text");


my $ref1 = CCO::Core::Dbxref->new();

my $ref2 = CCO::Core::Dbxref->new();

my $ref3 = CCO::Core::Dbxref->new();


$ref1->name("CCO:vm");

$ref2->name("CCO:ls");

$ref3->name("CCO:ea");


my $dbxref_set1 = CCO::Util::DbxrefSet->new();

$dbxref_set1->add($ref1);


my $dbxref_set2 = CCO::Util::DbxrefSet->new();

$dbxref_set2->add($ref2);


my $dbxref_set3 = CCO::Util::DbxrefSet->new();

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

A Def object encapsules a definition for a universal. There must be zero or one 
instances of this tag per term description. More than one definition for a term 
must generate a parse error. The value of this tag should be the quote enclosed 
definition text, followed by a dbxref set containing dbxrefs that describe the 
origin of this definition (see CCO::Core::Dbxref for information on how dbxref 
lists are used).

c.f. OBO flat file specification.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    