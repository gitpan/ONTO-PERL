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
    
	bless ($self, $class);
    
    confess if (!defined $self->{FILE});
    
    # if the file exists:
	if (-e $self->{FILE} && -r $self->{FILE}) {
		open (CCO_ID_MAP_IN_FH, "<$self->{FILE}") || die "The file '", $self->{FILE}, "' was not found: ", $!;
		while (<CCO_ID_MAP_IN_FH>) {
			chomp;
			my ($key, $value) = ($1, $2) if ($_ =~ /(CCO:[A-Z][0-9]{7})\s+(.*)/); # e.g.: CCO:I1234567		test
			$self->{MAP_BY_ID}->{$key} = $value;   #put
			$self->{MAP_BY_TERM}->{$value} = $key; #put			
		}
		close CCO_ID_MAP_IN_FH;		
	}	
	return $self;	
}

=head2 put

  Usage    - $map->put("CCO:P0000056", "cell cycle")
  Returns  - the old value of the key if this one was defined
  Args     - CCO id (string), term name (string)
  Function - puts an entry in the map
  Remark   - for adding entries into the map, use method get_new_cco_id()
  
=cut
sub put () {
	my $self   = shift;
	my $result;
	
	if (@_) {
		my $key   = shift; # a CCO_ID as string
		croak "The ID is not valid: '$key'\n" if ($key !~ /CCO:[A-Z]\d{7}/);
		
		my $value = shift; # a Term as string
		$result = $self->{MAP_BY_ID}->{$key}; # old value
		
		if ($self->contains_key($key) || $self->contains_value($value)){ 
			warn "Entry $key - $value already exists!", $!;
		}
		$self->{MAP_BY_ID}->{$key} = $value; #put
		$self->{MAP_BY_TERM}->{$value} = $key; #put
	}
	return $result;
}

=head2 get_new_cco_id

  Usage    - $map->get_new_cco_id("CCO", "P", "cell cycle")
  Returns  - a new CCO ID (string)
  Args     - namespace (string), subnamespace (string), term (string)
  Function - get a new CCO ID and insert it (put) into this map
  
=cut
sub get_new_cco_id () {
	my $self = shift;
	my $result;
	if (@_) {
		my $namespace    = shift; # is this parameter redundant?
		my $subnamespace = shift;
		my $term         = shift;
		
		if ($self->is_empty()){
			$result = $namespace.":".$subnamespace."0000001";
		} else {
			my $keys_set = CCO::Util::CCO_ID_Set->new();
			$keys_set->add_all_as_string($self->keys_set());
			$result = $keys_set->get_new_id($namespace, $subnamespace);
		}
		$self -> put ($result, $term); #put
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
	my $self = shift;
	my $result;
	if (@_) {
		my $term_name = shift;
		$result = $self->{MAP_BY_TERM}->{$term_name};
	}
	return $result;
}

=head2 get_term_by_cco_id

  Usage    - $map->get_term_by_cco_id($cco_id)
  Returns  - the term name (string) associated to the given CCO id
  Args     - a CCO id (string)
  Function - the term name associated to the given CCO id
  
=cut
sub get_term_by_cco_id () {
	my $self = shift;
	my $result;
	if (@_) {
		my $cco_id = shift;
		$result = $self->{MAP_BY_ID}->{$cco_id};
	}
	return $result;
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
	my $self = shift;
	my $result = 0;
	if (@_) {
		my $searched_key = shift;
		foreach my $ele ($self->keys_set()){
			if ( $ele eq $searched_key )  {
				$result = 1;
				last;
			}
		}
	}
	return $result;
}

=head2 contains_value

  Usage    - $map->contains_value($v)
  Returns  - 1 (true) or 0 (false)
  Args     - a value or term
  Function - 1 (true) or 0 (false)
  
=cut
sub contains_value () {
	my $self = shift;
	my $result = 0;
	if (@_) {
		my $searched_value = shift;
		foreach my $ele ($self->values_set ()){
			if ( $ele eq $searched_value )  {
				$result = 1;
				last;
			}
		}
	}
	return $result;
}

sub equals () {
	my $self = shift;
	my $result = 0;
	my $other_map =shift;
	# TODO compare keys and values
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

  Usage    - $map->write_map($file_name) or $map->write_map()
  Returns  - 1 (true) or 0 (false)
  Args     - output file name (optional)
  Function - prints the contents of the map to a file or to STDOUT
  
=cut
sub write_map () {
	
	my $self = shift;
	my $map_file_name = shift;
	if ($map_file_name) {
		my $result;
		open (FH, ">".$map_file_name) || die "Cannot write map to file: $map_file_name, $!"; 
		foreach (sort keys %{$self->{MAP_BY_ID}}){
			$result = print FH "$_\t$self->{MAP_BY_ID}->{$_}\n";			
		}
		close FH;	
		return $result;
	}
	else {
		foreach (sort keys %{$self->{MAP_BY_ID}}){
			print "$_\t$self->{MAP_BY_ID}->{$_}\n";			
		}
	}	
}

1;

=head1 NAME

    CCO::Util::CCO_ID_Term_Map - a map between CCO IDs and term names.
    
=head1 SYNOPSIS

use CCO::Util::CCO_ID_Term_Map;

$cco_id_set  = CCO_ID_Term_Map -> new;
$cco_id_set->file("ontology.ids");

$file = $cco_id_set -> file
$size = $cco_id_set -> size;

$cco_id_set->file("CCO");

if ($cco_id_set->add("CCO:C1234567")) { ... }
$new_id = $cco_id_set->get_new_id("CCO", "C");

=head1 DESCRIPTION

The CCO::Util::CCO_ID_Term_Map class implements a map for storing CCO IDs and
their corresponding names.

=head1 AUTHOR

Erick Antezana, E<lt>erant@psb.ugent.beE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by erant

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
    