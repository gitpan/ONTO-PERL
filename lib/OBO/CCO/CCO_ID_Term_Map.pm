# $Id: CCO_ID_Term_Map.pm 2010-09-23 12:30:37Z easr $
#
# Module  : CCO_ID_Term_Map.pm
# Purpose : A (birectional) map CCO_ID vs Term name.
# License : Copyright (c) 2006, 2007, 2008, 2009, 2010 Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
package OBO::CCO::CCO_ID_Term_Map;

=head1 NAME

OBO::CCO::CCO_ID_Term_Map - A map between CCO IDs and term names.
    
=head1 SYNOPSIS

use OBO::CCO::CCO_ID_Term_Map;

$cco_id_set  = CCO_ID_Term_Map -> new;

$cco_id_set->file("ontology.ids");

$file = $cco_id_set -> file;

$size = $cco_id_set -> size;

$cco_id_set->file("CCO");

if ($cco_id_set->add("CCO:C1234567")) { ... }

$new_id = $cco_id_set->get_new_id("CCO", "C");

=head1 DESCRIPTION

The OBO::CCO::CCO_ID_Term_Map class implements a map for storing CCO IDs and their corresponding names.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, 2007, 2008, 2009, 2010 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut

our @ISA = qw(OBO::XO::OBO_ID_Term_Map);
use OBO::XO::OBO_ID_Term_Map;
use Carp;
use strict;

use OBO::CCO::CCO_ID_Set;

sub new {
    my $class = shift;
    my $self  = {};
    $self->{FILE} = shift;

    %{ $self->{MAP_BY_ID} }   = ();    # key=cco_id; value=term name
    %{ $self->{MAP_BY_TERM} } = ();    # key=term name; value=cco_id
    $self->{KEYS} = OBO::CCO::CCO_ID_Set->new();

    bless( $self, $class );

    confess if ( !defined $self->{FILE} );

    # if the file exists:
    if ( -e $self->{FILE} && -r $self->{FILE} ) {
        open( CCO_ID_MAP_IN_FH, "<$self->{FILE}" );
        while (<CCO_ID_MAP_IN_FH>) {
            chomp;
            if ( $_ =~ /(CCO:[A-Z][0-9]{7})\s+(.*)/ ) {
				my ( $key, $value ) = ( $1, $2 ) ;        # e.g.: CCO:I1234567		test
            	
				$self->{MAP_BY_ID}->{$key}     = $value;  # put
				$self->{MAP_BY_TERM}->{$value} = $key;    # put
            } else {
            	warn "\nThe following entry: '", $_, "' found in '", $self->{FILE}, "' is not recognized as a valid CCO key-value pair!";
            }
        }
        close CCO_ID_MAP_IN_FH;
    }
    else {
        open( CCO_ID_MAP_IN_FH, "$self->{FILE}" );

        # TODO include date?
        close CCO_ID_MAP_IN_FH;
    }

    $self->{KEYS}->add_all_as_string( keys( %{ $self->{MAP_BY_ID} } ) );
    return $self;
}

sub _is_valid_id () {
	my $new_name = $_[0];
	return ($new_name =~ /CCO:[A-Z]\d{7}/)?1:0;
}

=head2 get_new_id

  Usage    - $map->get_new_id("CCO", "P", "cell cycle")
  Returns  - a new CCO ID (string)
  Args     - idspace (string), subnamespace (string), term (string)
  Function - get a new CCO ID and insert it (put) into this map
  
=cut

sub get_new_id () {
    my ( $self, $idspace, $subnamespace, $term ) = @_;
    my $result;
    if ( $idspace && $subnamespace && $term ) {
        if ( $self->is_empty() ) {
            $result = $idspace.":".$subnamespace."0000001";
        }
        else {
            $result = $self->{KEYS}->get_new_id($idspace, $subnamespace);
        }
        $self->put( $result, $term );    # put
    }
    return $result;
}

1;