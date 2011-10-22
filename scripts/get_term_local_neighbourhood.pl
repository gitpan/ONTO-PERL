#!/usr/local/bin/perl
# $Id: get_term_local_neighbourhood.pl 2011-10-16 erick.antezana $
#
# Script  : get_term_local_neighbourhood.pl
#
# Purpose : Gets the local neighbourhood (set of relationships types and connected terms) of a given term (and over an optional relationship type) in a given OBO ontology.
#
# Usage   : get_term_local_neighbourhood.pl my_ontology.obo term_id [relationship_type] > term_local_neighbourhood.txt
#
# License : Copyright (c) 2006-2011 by Erick Antezana. All rights reserved.
#           This program is free software; you can redistribute it and/or
#           modify it under the same relationships as Perl itself.
#
# Contact : Erick Antezana <erick.antezana -@- gmail.com>
#
################################################################################

use Carp;
use strict;
use warnings;

use OBO::Parser::OBOParser;

my $my_parser = OBO::Parser::OBOParser->new();
my $ontology  = $my_parser->work(shift(@ARGV));

my $term_id           = shift(@ARGV);
my $relationship_type = shift(@ARGV) || undef;

my @nei = @{$ontology->get_term_local_neighbourhood($ontology->get_term_by_id($term_id), $relationship_type)};
foreach my $rel (sort {$a->id() cmp $b->id()} @nei) {
	print $rel->type(), "\t", $rel->head()->id(), "\n";
}

exit 0;

__END__

=head1 NAME

get_term_local_neighbourhood.pl - Gets the local neighbourhood of a given term (and over an optional relationship type) in a given OBO ontology.

=head1 DESCRIPTION

Generates a flat file with two columns (TAB separated) with the 
the local neighbourhood (set of relationships types and connected terms)
of a  given term in a given OBO ontology.

=head1 AUTHOR

Erick Antezana, E<lt>erick.antezana -@- gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2011 by Erick Antezana

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut