# $Id: CCO_ID_Term_Map.pm 291 2006-06-01 16:21:45Z erant $
#
# Module  : CCO_ID_Term_Map.pm
# Purpose : A (birectional) map CCO_ID vs Term name.
# License : Copyright (c) 2006 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erant@psb.ugent.be>
#
# URGENT implement a test file (CCO_ID_Term_Map.t) for this module
package CCO::Util::CCO_ID_Term_Map;

use Carp;
use strict;

use CCO::Util::CCO_ID_Set;

sub new {
	my $class     = shift;
	my $self      = {};
	$self->{FILE} = shift;
	
	%{$self->{MAP_BY_ID}}    = (); # key=cco_id; value=term
	%{$self->{MAP_BY_TERM}}  = (); # key=term; value=cco_id
	$self->{KEYS}            = CCO::Util::CCO_ID_Set->new();
    
	bless ($self, $class);
    
	confess if (!defined $self->{FILE});
    
	# if the file exists:
	if (-e $self->{FILE} && -r $self->{FILE}) {
		open (CCO_ID_MAP_IN_FH, "<$self->{FILE}");
		while (<CCO_ID_MAP_IN_FH>) {
			chomp;
			my ($key, $value) = ($1, $2) if ($_ =~ /(CCO:[A-Z][0-9]{7})\s+(\w+.*)/); # e.g.: CCO:I1234567		test
			$self->{MAP_BY_ID}->{$key} = $value;   #put
			$self->{MAP_BY_TERM}->{$value} = $key; #put			
		}
		close CCO_ID_MAP_IN_FH;		
	}
	else {
		open (CCO_ID_MAP_IN_FH, "$self->{FILE}");
		# TODO include date?
		close CCO_ID_MAP_IN_FH;
	}

	$self->{KEYS}->add_all_as_string(keys (%{$self->{MAP_BY_ID}}));
	return $self;	
}

=head2 put

  Usage    - $map->put("CCO:P0000056", "cell cycle")
  Returns  - none
  Args     - CCO id (string), term name (string)
  Function - puts an entry in the map
  Remark   - for adding entries into the map, use method get_new_cco_id()
  
=cut
sub put () {
	my ($self, $key, $value) = @_;
	
	if ($key && $value) {
		confess "The ID is not valid: '$key'\n" if ($key !~ /CCO:[A-Z]\d{7}/);
		
		if (!defined $self->{MAP_BY_ID}->{$key} && !defined $self->{MAP_BY_TERM}->{$value}) {
			$self->{MAP_BY_ID}->{$key} = $value;   # put
			$self->{MAP_BY_TERM}->{$value} = $key; # put
			$self->{KEYS}->add_as_string($key);
		} else {
			# either the key or value are already in the map !
		}
	}
}

=head2 get_new_cco_id

  Usage    - $map->get_new_cco_id("CCO", "P", "cell cycle")
  Returns  - a new CCO ID (string)
  Args     - namespace (string), subnamespace (string), term (string)
  Function - get a new CCO ID and insert it (put) into this map
  
=cut
sub get_new_cco_id () {
	my ($self, $namespace, $subnamespace, $term) = @_;
	my $result;
	if ($namespace && $subnamespace && $term) {
		# is the namespace parameter redundant?
		
		if ($self->is_empty()){
			$result = $namespace.":".$subnamespace."0000001";
		} else {
			$result = $self->{KEYS}->get_new_id($namespace, $subnamespace);
		}
		$self->put($result, $term); # put
	}	
	return $result;
}

=head2 get_cco_id_by_term

  Usage    - $map->get_cco_id_by_term($term_name)
  Returns  - the CCO id associated to the given term name
  Args     - a term name (string)
  Function - the term associated to the given term
  
=cut
sub get_cco_id_by_term () {
	my ($self, $term_name) = @_;
	return $self->{MAP_BY_TERM}->{$term_name};
}

=head2 get_term_by_cco_id

  Usage    - $map->get_term_by_cco_id($cco_id)
  Returns  - the term name (string) associated to the given CCO id
  Args     - a CCO id (string)
  Function - the term name associated to the given CCO id
  
=cut
sub get_term_by_cco_id () {
	my ($self, $cco_id) = @_;
	return $self->{MAP_BY_ID}->{$cco_id};
}

=head2 keys_set

  Usage    - $map->keys_set()
  Returns  - the keys (or CCO ids)
  Args     - none
  Function - the keys (or CCO ids)
  
=cut
sub keys_set () {
	my $self = shift;
	return keys (%{$self->{MAP_BY_ID}});
}

=head2 values_set

  Usage    - $map->values_set()
  Returns  - the values (or terms names)
  Args     - none
  Function - the keys (or terms names)
  
=cut
sub values_set () {
	my $self = shift;
	return values (%{$self->{MAP_BY_ID}});
}

=head2 contains_key

  Usage    - $map->contains_key($k)
  Returns  - 1 (true) or 0 (false)
  Args     - a key or CCO id
  Function - 1 (true) or 0 (false)
  
=cut
sub contains_key () {
	my ($self, $searched_key) = @_;
	return (defined $self->{MAP_BY_ID}->{$searched_key})?1:0;
}

=head2 contains_value

  Usage    - $map->contains_value($v)
  Returns  - 1 (true) or 0 (false)
  Args     - a value or term
  Function - 1 (true) or 0 (false)
  
=cut
sub contains_value () {
        my ($self, $searched_value) = @_;
        return (defined $self->{MAP_BY_TERM}->{$searched_value})?1:0;
}

sub equals () {
	my $self = shift;
	my $result = 0;
	my $other_map =shift;
	# TODO compare keys and values
	confess "not implemented method!";
	return $result;
}

=head2 size

  Usage    - $map->size()
  Returns  - the size of this map
  Args     - none
  Function - the size of this map
  
=cut
sub size () {
	my $self = shift;
	my @keys = keys (%{$self->{MAP_BY_ID}});
	return $#keys+1;
}

=head2 file

  Usage    - $map->file()
  Returns  - the size of this map
  Args     - none
  Function - the size of this map
  
=cut
sub file () {
	my $self = shift;
    if (@_) { $self->{FILE} = shift }
    return $self->{FILE};
}

=head2 clear

  Usage    - $map->clear()
  Returns  - clears this map
  Args     - none
  Function - clears this map
  
=cut
sub clear () {
	my $self = shift;
	%{$self->{MAP_BY_ID}}  = ();
	%{$self->{MAP_BY_TERM}}  = ();
	# todo clean the file
}

=head2 is_empty

  Usage    - $map->is_empty()
  Returns  - 1 (true) or 0 (false)
  Args     - none
  Function - tells if this map is empty
  
=cut
sub is_empty (){
	my $self = shift;
	return ($self->size() == 0);
}

=head2 write_map

  Usage    - $map->write_map()
  Returns  - none
  Args     - none
  Function - prints the contents of the map to the file associated to this object 
  
=cut
sub write_map () {
	my $self = shift;
	open (FH, ">".$self->{FILE}) || die "Cannot write map to file: '$self->{FILE}', $!"; 
	foreach (sort keys %{$self->{MAP_BY_ID}}){
		print FH "$_\t$self->{MAP_BY_ID}->{$_}\n";			
	}
	close FH;	
}

1;

=head1 NAME

    CCO::Util::CCO_ID_Term_Map - a map between CCO IDs and term names.
    
=head1 SYNOPSIS

use CCO::Util::CCO_ID_Term_Map;

$cco_id_set  = CCO_ID_Term_Map -> new;

$cco_id_set->file("ontology.ids");

$file = $cco_id_set -> file;

$size = $cco_id_set -> size;

$cco_id_set->file("CCO");

if ($cco_id_set->add("CCO:C1234567")) { ... }

$new_id = $cco_id_set->get_new_id("CCO", "C");

=head1 DESCRIPTION

The CCO::Util::CCO_ID_Term_Map class implements a map for storing CCO IDs and their corresponding names.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    
