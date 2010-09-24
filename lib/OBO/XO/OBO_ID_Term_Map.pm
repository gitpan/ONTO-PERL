# $Id: OBO_ID_Term_Map.pm 2010-24-09 12:30:37Z easr $
#
# Module  : OBO_ID_Term_Map.pm
# Purpose : A (birectional) map OBO_ID vs Term name.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::XO::OBO_ID_Term_Map;

=head1 NAME

OBO::XO::OBO_ID_Term_Map - A map between OBO IDs and term names.
    
=head1 SYNOPSIS

use OBO::XO::OBO_ID_Term_Map;

$obo_id_set  = OBO_ID_Term_Map->new();

$obo_id_set->file("gene_ontology.ids");

$file = $obo_id_set->file();

$size = $obo_id_set->size();

$obo_id_set->file("OBO");

if ($obo_id_set->add("OBO:0007049")) { ... }

$new_id = $obo_id_set->get_new_id("GO");

=head1 DESCRIPTION

The OBO::XO::OBO_ID_Term_Map class implements a map for storing OBO IDs and their corresponding names.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

use Carp;
use strict;

use OBO::XO::OBO_ID_Set;

sub new {
    my $class = shift;
    my $self  = {};
    $self->{FILE} = shift;

    %{ $self->{MAP_BY_ID} }   = ();    # key=obo_id; value=term name
    %{ $self->{MAP_BY_TERM} } = ();    # key=term name; value=obo_id
    $self->{KEYS} = OBO::XO::OBO_ID_Set->new();

    bless( $self, $class );

    confess if ( !defined $self->{FILE} );

    # if the file exists:
    if ( -e $self->{FILE} && -r $self->{FILE} ) {
        open( OBO_ID_MAP_IN_FH, "<$self->{FILE}" );
        while (<OBO_ID_MAP_IN_FH>) {
            chomp;
            if ( $_ =~ /(\w+:\d+)\s+(.*)/ ) {
				my ( $key, $value ) = ( $1, $2 ) ;        # e.g.: GO:0007049	cell cycle
            	
				$self->{MAP_BY_ID}->{$key}     = $value;  # put
				$self->{MAP_BY_TERM}->{$value} = $key;    # put
            } else {
            	warn "\nThe following entry: '", $_, "' found in '", $self->{FILE}, "' is not recognized as a valid OBO key-value pair!";
            }
        }
        close OBO_ID_MAP_IN_FH;
    }
    else {
        open( OBO_ID_MAP_IN_FH, "$self->{FILE}" );

        # TODO include date?
        close OBO_ID_MAP_IN_FH;
    }

    $self->{KEYS}->add_all_as_string( keys( %{ $self->{MAP_BY_ID} } ) );
    return $self;
}

sub _is_valid_id () {
	my $new_name = $_[0];
	return ($new_name =~ /\w+:\d+/)?1:0;
}

=head2 put

  Usage    - $map->put("GO:0007049", "cell cycle")
  Returns  - none
  Args     - OBO id (string), term name (string)
  Function - either puts a new entry in the map or modifies an existing entry by changing the term name
  Remark   - prior to adding new entries to the map, use method get_new_id()
  
=cut

sub put () {
    my ( $self, $new_id, $new_name ) = @_;

    if ( $new_id && $new_name ) {
        confess "The ID is not valid: '$new_id'\n" if ($self->_is_valid_id($new_id));
        
        my $has_key   = $self->contains_key($new_id);
        my $has_value = $self->contains_value($new_name);
		
        if (!$has_key && !$has_value) {                       # new pair : new key and new value
        	$self->{MAP_BY_ID}->{$new_id}     = $new_name;    # put
            $self->{MAP_BY_TERM}->{$new_name} = $new_id;      # put
            $self->{KEYS}->add_as_string($new_id);
        } elsif ($has_key && !$has_value) {                   # updating the value (=term name)
        	my $old_value = $self->{MAP_BY_ID}->{$new_id};
        	$self->{MAP_BY_ID}->{$new_id}     = $new_name;    # updating the value
 			delete $self->{MAP_BY_TERM}->{$old_value};	      # erase the old entry
            $self->{MAP_BY_TERM}->{$new_name} = $new_id;      # put
        } else {
        	warn "This case should have never happened: -> ($new_id, $new_name)";
        }
    }
}

=head2 get_new_id

  Usage    - $map->get_new_id("GO", "cell cycle")
  Returns  - a new OBO ID (string)
  Args     - idspace (string), term (string)
  Function - get a new OBO ID and insert it (put) into this map
  
=cut

sub get_new_id () {
    my ( $self, $idspace, $term ) = @_;
    my $result;
    if ( $idspace && $term ) {
        if ( $self->is_empty() ) {
            $result = $idspace.":"."0000001";
        }
        else {
            $result = $self->{KEYS}->get_new_id($idspace);
        }
        $self->put( $result, $term );    # put
    }
    return $result;
}

=head2 get_id_by_term

  Usage    - $map->get_id_by_term($term_name)
  Returns  - the OBO id associated to the given term name
  Args     - a term name (string)
  Function - the term associated to the given term
  
=cut

sub get_id_by_term () {
    my ( $self, $term_name ) = @_;
    return $self->{MAP_BY_TERM}->{$term_name};
}

=head2 get_term_by_id

  Usage    - $map->get_term_by_id($obo_id)
  Returns  - the term name (string) associated to the given OBO id
  Args     - an OBO id (string)
  Function - the term name associated to the given OBO id
  
=cut

sub get_term_by_id () {
    my ( $self, $obo_id ) = @_;
    return $self->{MAP_BY_ID}->{$obo_id};
}

=head2 keys_set

  Usage    - $map->keys_set()
  Returns  - the keys (or OBO ids)
  Args     - none
  Function - the keys (or OBO ids)
  
=cut

sub keys_set () {
    my $self = shift;
    return keys( %{ $self->{MAP_BY_ID} } );
}

=head2 values_set

  Usage    - $map->values_set()
  Returns  - the values (or terms names)
  Args     - none
  Function - the keys (or terms names)
  
=cut

sub values_set () {
    my $self = shift;
    return values( %{ $self->{MAP_BY_ID} } );
}

=head2 contains_key

  Usage    - $map->contains_key($k)
  Returns  - 1 (true) or 0 (false)
  Args     - a key or OBO id
  Function - 1 (true) or 0 (false)
  
=cut

sub contains_key () {
    my ( $self, $searched_key ) = @_;
    return ( defined $self->{MAP_BY_ID}->{$searched_key} ) ? 1 : 0;
}

=head2 contains_value

  Usage    - $map->contains_value($v)
  Returns  - 1 (true) or 0 (false)
  Args     - a value or term
  Function - 1 (true) or 0 (false)
  
=cut

sub contains_value () {
    my ( $self, $searched_value ) = @_;
    return ( defined $self->{MAP_BY_TERM}->{$searched_value} ) ? 1 : 0;
}

sub equals () {
    my $self      = shift;
    my $result    = 0;
    my $other_map = shift;

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
    my @keys = keys( %{ $self->{MAP_BY_ID} } );
    return $#keys + 1;
}

=head2 file

  Usage    - $map->file()
  Returns  - the file of this map
  Args     - none
  Function - the file of this map
  
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
    %{ $self->{MAP_BY_ID} }   = ();
    %{ $self->{MAP_BY_TERM} } = ();
}

=head2 is_empty

  Usage    - $map->is_empty()
  Returns  - 1 (true) or 0 (false)
  Args     - none
  Function - tells if this map is empty
  
=cut

sub is_empty () {
    my $self = shift;
    return ( $self->size() == 0 );
}

=head2 write_map

  Usage    - $map->write_map()
  Returns  - none
  Args     - none
  Function - prints the contents of the map to the file associated to this object 
  
=cut

sub write_map () {
    my $self = shift;
    open( FH, ">" . $self->{FILE} )
      || die "Cannot write map to file: '$self->{FILE}', $!";
    foreach ( sort keys %{ $self->{MAP_BY_ID} } ) {
    	if ($self->{MAP_BY_ID}->{$_}) {
        	print FH "$_\t$self->{MAP_BY_ID}->{$_}\n";
    	} else {
    		warn "There is no value in the IDs map for this key: ", $_;
    	}
    }
    close FH;
}

=head2 remove_by_key

  Usage    - $map->remove_by_key('OBO:B0000001')
  Returns  - the value corresponding to the given key that will be eventually removed
  Args     - the key (OBO ID as string) of the entry to be removed (string)
  Function - removes one entry  from the map
  
=cut

sub remove_by_key () {
    my ($self, $key) = @_;
    my $value = $self->{MAP_BY_ID}{$key};
    delete $self->{MAP_BY_ID}{$key};
    delete $self->{MAP_BY_TERM}{$value};
    delete $self->{KEYS}{MAP}{$key};
    return $value;
}
1;